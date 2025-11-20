import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:open_file/open_file.dart';

class UpdateService {
  // UPDATE WITH YOUR ACTUAL GITHUB INFO
  static const String githubOwner = 'Rehancodecraft'; // Your GitHub username
  static const String githubRepo = 'EC-Saver';
  static const String githubApiUrl = 'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  static Future<Map<String, dynamic>> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      print('DEBUG: Checking for updates...');
      print('DEBUG: Current version: $currentVersion');

      // Fetch latest release from GitHub
      final response = await http.get(
        Uri.parse(githubApiUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      );

      print('DEBUG: GitHub API response: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name'].toString().replaceAll('v', '');
        final apkUrl = _getApkDownloadUrl(data['assets']);

        print('DEBUG: Latest version: $latestVersion');
        print('DEBUG: Download URL: $apkUrl');

        if (apkUrl.isEmpty) {
          print('DEBUG: No APK found in release');
          return {'updateAvailable': false};
        }

        if (_isUpdateAvailable(currentVersion, latestVersion)) {
          return {
            'updateAvailable': true,
            'latestVersion': latestVersion,
            'downloadUrl': apkUrl,
            'releaseNotes': data['body'] ?? 'New update available',
          };
        }
      }

      return {'updateAvailable': false};
    } catch (e) {
      print('DEBUG: Update check error: $e');
      return {'updateAvailable': false, 'error': e.toString()};
    }
  }

  static String _getApkDownloadUrl(List<dynamic> assets) {
    for (var asset in assets) {
      if (asset['name'].toString().endsWith('.apk')) {
        return asset['browser_download_url'];
      }
    }
    return '';
  }

  static bool _isUpdateAvailable(String current, String latest) {
    final currentParts = current.split('.').map(int.parse).toList();
    final latestParts = latest.split('.').map(int.parse).toList();

    for (int i = 0; i < 3; i++) {
      if (latestParts[i] > currentParts[i]) return true;
      if (latestParts[i] < currentParts[i]) return false;
    }
    return false;
  }

  // Simplified: Just open browser to download
  static Future<void> downloadUpdate(String downloadUrl) async {
    final Uri url = Uri.parse(downloadUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw Exception('Could not open download link');
    }
  }

  // Download APK into app external storage and open installer.
  // onProgress receives values 0.0 .. 1.0
  static Future<void> downloadAndInstallUpdate(
    String downloadUrl,
    void Function(double) onProgress,
  ) async {
    if (downloadUrl.isEmpty) {
      throw Exception('Empty download URL');
    }

    // Request storage permission on Android
    if (Platform.isAndroid) {
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        throw Exception('Storage permission denied');
      }
    }

    final uri = Uri.parse(downloadUrl);
    final client = http.Client();

    final request = http.Request('GET', uri);
    final response = await client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Failed to download APK: ${response.statusCode}');
    }

    final contentLength = response.contentLength ?? 0;
    final bytes = <int>[];
    int received = 0;

    // Determine file path (external storage preferred)
    Directory dir;
    if (Platform.isAndroid) {
      dir = (await getExternalStorageDirectory()) ?? await getApplicationDocumentsDirectory();
    } else {
      dir = await getApplicationDocumentsDirectory();
    }

    final filePath = '${dir.path}/ec_saver_update.apk';
    final file = File(filePath);
    if (await file.exists()) {
      await file.delete();
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

    // Ensure file is written
    if (!await file.exists() || await file.length() == 0) {
      throw Exception('Downloaded file is empty');
    }

    // Open the file with system installer (no browser redirect)
    final result = await OpenFile.open(file.path);
    if (result.type != ResultType.done) {
      // still return; system installer should handle
      // throw Exception('Failed to open installer: ${result.message}');
    }
  }
}
