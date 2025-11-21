import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class UpdateService {
  // Configure your repo here
  static const String githubOwner = 'Rehancodecraft';
  static const String githubRepo = 'EC-Saver';
  static final String releasesLatestUrl =
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

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

  // NEW: robust check using GitHub Releases API and PackageInfo
  static Future<Map<String, dynamic>> checkForUpdate({String? currentVersion}) async {
    try {
      if (currentVersion == null) {
        final pkg = await PackageInfo.fromPlatform();
        currentVersion = pkg.version;
      }
      print('DEBUG: currentVersion = $currentVersion');

      final resp = await http.get(Uri.parse(releasesLatestUrl), headers: {'Accept': 'application/vnd.github.v3+json'});
      if (resp.statusCode != 200) {
        print('DEBUG: GitHub API failed status=${resp.statusCode}');
        return {'updateAvailable': false};
      }

      final data = json.decode(resp.body) as Map<String, dynamic>;
      final tagName = (data['tag_name'] ?? '').toString();
      final latestVersion = tagName.replaceAll('v', '');
      final assets = (data['assets'] as List<dynamic>? ) ?? [];
      String apkUrl = '';
      int apkSize = 0;
      for (final a in assets) {
        final name = (a['name'] ?? '').toString().toLowerCase();
        if (name.endsWith('.apk')) {
          apkUrl = a['browser_download_url'] ?? '';
          apkSize = (a['size'] ?? 0) as int;
          break;
        }
      }

      print('DEBUG: latestVersion=$latestVersion apkUrl=$apkUrl apkSize=$apkSize');

      final bool updateAvailable = (latestVersion.isNotEmpty && compareVersions(latestVersion, currentVersion) > 0);

      return {
        'updateAvailable': updateAvailable,
        'latestVersion': latestVersion,
        'downloadUrl': apkUrl,
        'releaseNotes': data['body'] ?? '',
        'apkSize': apkSize,
      };
    } catch (e, st) {
      print('DEBUG: checkForUpdate error: $e\n$st');
      return {'updateAvailable': false, 'error': e.toString()};
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
