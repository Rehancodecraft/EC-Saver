import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:package_info_plus/package_info_plus.dart';

class UpdateService {
  static const String versionJsonUrl = 'https://raw.githubusercontent.com/USERNAME/repo/main/version.json';

  // Compare semantic versions: returns 1 if a>b, -1 if a<b, 0 if equal
  static int compareVersions(String a, String b) {
    final pa = a.split('+')[0].split('-')[0].split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final pb = b.split('+')[0].split('-')[0].split('.').map((s) => int.tryParse(s) ?? 0).toList();
    final len = pa.length > pb.length ? pa.length : pb.length;
    for (int i = 0; i < len; i++) {
      final ia = i < pa.length ? pa[i] : 0;
      final ib = i < pb.length ? pb[i] : 0;
      if (ia > ib) return 1;
      if (ia < ib) return -1;
    }
    return 0;
  }

  static Future<Map<String, dynamic>> checkForUpdate() async {
    try {
      final pkg = await PackageInfo.fromPlatform();
      final currentVersion = pkg.version;
      final currentBuild = int.tryParse(pkg.buildNumber) ?? 1;

      final response = await http.get(Uri.parse(versionJsonUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['version'] ?? '';
        final latestBuild = data['versionCode'] ?? 0;
        final apkUrl = data['apkUrl'] ?? '';
        final releaseNotes = data['releaseNotes'] ?? '';
        final forceUpdate = data['forceUpdate'] ?? false;

        // Prefer versionCode comparison if available
        bool updateAvailable = false;
        if (latestBuild > currentBuild) {
          updateAvailable = true;
        } else if (latestBuild == currentBuild) {
          // fallback to version string compare
          updateAvailable = compareVersions(latestVersion, currentVersion) > 0;
        }

        return {
          'updateAvailable': updateAvailable,
          'latestVersion': latestVersion,
          'latestBuild': latestBuild,
          'downloadUrl': apkUrl,
          'releaseNotes': releaseNotes,
          'forceUpdate': forceUpdate,
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
    if (downloadUrl.isEmpty) throw Exception('Empty download URL');
    if (Platform.isAndroid) {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted) throw Exception('Storage permission denied');
    }

    final uri = Uri.parse(downloadUrl);
    final client = http.Client();
    final response = await client.send(http.Request('GET', uri));
    if (response.statusCode != 200) {
      client.close();
      throw Exception('Failed to download APK: HTTP ${response.statusCode}');
    }

    final contentLength = response.contentLength ?? 0;
    int received = 0;
    Directory dir;
    if (Platform.isAndroid) {
      final dirs = await getExternalStorageDirectories(type: StorageDirectory.downloads);
      dir = (dirs != null && dirs.isNotEmpty) ? dirs.first : Directory('/storage/emulated/0/Download');
    } else {
      dir = await getApplicationDocumentsDirectory();
    }
    if (!await dir.exists()) await dir.create(recursive: true);

    final filePath = p.join(dir.path, 'ec-saver-update.apk');
    final file = File(filePath);
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
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
    await OpenFile.open(filePath);
  }
}
