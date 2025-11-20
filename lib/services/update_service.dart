import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const String githubOwner = 'Rehancodecraft';
  static const String githubRepo = 'EC-Saver';
  static const String githubApiUrl =
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  // Compare semantic versions: returns 1 if a>b, -1 if a<b, 0 if equal
  static int compareVersions(String a, String b) {
    List<int> pa = a.split('+')[0].split('-')[0].split('.').map((s) {
      final n = int.tryParse(s);
      return n ?? 0;
    }).toList();
    List<int> pb = b.split('+')[0].split('-')[0].split('.').map((s) {
      final n = int.tryParse(s);
      return n ?? 0;
    }).toList();
    final len = [pa.length, pb.length].reduce((x, y) => x > y ? x : y);
    for (int i = 0; i < len; i++) {
      final ia = i < pa.length ? pa[i] : 0;
      final ib = i < pb.length ? pb[i] : 0;
      if (ia > ib) return 1;
      if (ia < ib) return -1;
    }
    return 0;
  }

  // If currentVersion is null, get it via PackageInfo
  static Future<Map<String, dynamic>> checkForUpdate({String? currentVersion}) async {
    try {
      if (currentVersion == null) {
        final pkg = await PackageInfo.fromPlatform();
        currentVersion = pkg.version;
      }

      final response = await http.get(Uri.parse(githubApiUrl));
      if (response.statusCode != 200) {
        return {'updateAvailable': false, 'reason': 'GitHub API ${response.statusCode}'};
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final tag = (data['tag_name'] ?? '').toString();
      final latestVersion = tag.replaceAll('v', '');
      String apkUrl = '';

      final assets = (data['assets'] as List<dynamic>?) ?? [];
      for (final a in assets) {
        final name = (a['name'] ?? '').toString();
        if (name.toLowerCase().endsWith('.apk')) {
          apkUrl = (a['browser_download_url'] ?? '').toString();
          break;
        }
      }

      if (latestVersion.isEmpty || apkUrl.isEmpty) {
        return {'updateAvailable': false, 'reason': 'No APK or version in release'};
      }

      final cmp = compareVersions(latestVersion, currentVersion);
      final updateAvailable = cmp == 1;

      return {
        'updateAvailable': updateAvailable,
        'latestVersion': latestVersion,
        'downloadUrl': apkUrl,
        'releaseNotes': data['body'] ?? '',
        'currentVersion': currentVersion,
      };
    } catch (e) {
      return {'updateAvailable': false, 'error': e.toString()};
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
