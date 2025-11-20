import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path/path.dart' as p;

class UpdateService {
  static const String githubOwner = 'Rehancodecraft';
  static const String githubRepo = 'EC-Saver';
  static const String githubApiUrl =
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  static Future<Map<String, dynamic>> checkForUpdate(String currentVersion) async {
    try {
      final response = await http.get(Uri.parse(githubApiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = (data['tag_name'] ?? '').replaceAll('v', '');
        final assets = data['assets'] as List<dynamic>? ?? [];
        final apkAsset = assets.firstWhere(
          (a) => (a['name'] as String).endsWith('.apk'),
          orElse: () => null,
        );
        final apkUrl = apkAsset != null ? apkAsset['browser_download_url'] as String : '';

        bool isUpdateAvailable = false;
        if (latestVersion.isNotEmpty && apkUrl.isNotEmpty) {
          final currentParts = currentVersion.split('.').map(int.parse).toList();
          final latestParts = latestVersion.split('.').map(int.parse).toList();
          for (int i = 0; i < 3; i++) {
            if (latestParts[i] > currentParts[i]) {
              isUpdateAvailable = true;
              break;
            } else if (latestParts[i] < currentParts[i]) {
              break;
            }
          }
        }

        return {
          'updateAvailable': isUpdateAvailable,
          'latestVersion': latestVersion,
          'downloadUrl': apkUrl,
          'releaseNotes': data['body'] ?? '',
        };
      }
      return {'updateAvailable': false};
    } catch (e) {
      print('Update check error: $e');
      return {'updateAvailable': false};
    }
  }

  static Future<void> downloadAndInstallUpdate(
    String downloadUrl,
    void Function(double) onProgress,
  ) async {
    if (downloadUrl.isEmpty) {
      throw Exception('Empty download URL');
    }

    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) {
        throw Exception('Storage permission denied');
      }
    }

    final uri = Uri.parse(downloadUrl);
    final client = http.Client();
    final request = http.Request('GET', uri);
    final response = await client.send(request);

    if (response.statusCode != 200) {
      client.close();
      throw Exception('Failed to download APK: HTTP ${response.statusCode}');
    }

    final contentLength = response.contentLength ?? 0;
    var received = 0;

    Directory dir;
    try {
      if (Platform.isAndroid) {
        final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
        if (dirs != null && dirs.isNotEmpty) {
          dir = dirs.first;
        } else {
          dir = Directory('/storage/emulated/0/Download');
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } catch (e) {
      client.close();
      throw Exception('Failed to access download directory: $e');
    }

    final filePath = p.join(dir.path, 'ec-saver-update.apk');
    final file = File(filePath);

    try {
      if (await file.exists()) {
        try {
          await file.delete();
        } catch (e) {
          print('WARN: Could not delete existing APK: $e');
        }
      }

      final sink = file.openWrite();
      try {
        await for (final chunk in response.stream) {
          sink.add(chunk);
          received += chunk.length;
          if (contentLength > 0) {
            onProgress(received / contentLength);
          } else {
            onProgress(0);
          }
        }
      } finally {
        await sink.close();
        client.close();
      }

      if (!await file.exists() || await file.length() == 0) {
        throw Exception('Downloaded file is missing or empty after write.');
      }

      await Future.delayed(const Duration(milliseconds: 300));
      print('DEBUG: Download complete. File saved to: $filePath');

      final result = await OpenFile.open(filePath);
      print('DEBUG: OpenFile result: ${result.type} - ${result.message}');
    } catch (e) {
      throw Exception('Download/install failed for path=$filePath : $e');
    }
  }
}
