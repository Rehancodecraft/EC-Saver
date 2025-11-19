import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';

class UpdateService {
  // REPLACE WITH YOUR GITHUB INFO
  static const String githubOwner = 'YOUR_GITHUB_USERNAME';
  static const String githubRepo = 'EC-Saver';
  static const String githubApiUrl = 'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';

  static Future<Map<String, dynamic>> checkForUpdate() async {
    try {
      // Get current app version
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;

      // Fetch latest release from GitHub
      final response = await http.get(Uri.parse(githubApiUrl));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final latestVersion = data['tag_name'].replaceAll('v', '');
        final apkUrl = _getApkDownloadUrl(data['assets']);

        print('DEBUG: Current version: $currentVersion');
        print('DEBUG: Latest version: $latestVersion');

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

  static Future<void> downloadAndInstallUpdate(
    String downloadUrl,
    Function(double) onProgress,
  ) async {
    try {
      // Request storage permission
      if (!await Permission.storage.request().isGranted) {
        throw Exception('Storage permission denied');
      }

      // Get download directory
      final dir = await getExternalStorageDirectory();
      final filePath = '${dir!.path}/ec_saver_update.apk';

      // Delete old APK if exists
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }

      // Download APK
      final request = await HttpClient().getUrl(Uri.parse(downloadUrl));
      final response = await request.close();
      
      final bytes = <int>[];
      final totalBytes = response.contentLength;
      var receivedBytes = 0;

      await for (var chunk in response) {
        bytes.addAll(chunk);
        receivedBytes += chunk.length;
        onProgress(receivedBytes / totalBytes);
      }

      // Write to file
      await file.writeAsBytes(bytes);

      // Install APK
      await OpenFile.open(filePath);
    } catch (e) {
      print('DEBUG: Download error: $e');
      rethrow;
    }
  }
}
