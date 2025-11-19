import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';

class UpdateService {
  static const String versionUrl =
      'https://raw.githubusercontent.com/Rehancodecraft/EC-Saver/main/version.json';

  static const MethodChannel _channel = MethodChannel('apk_installer');

  static Future<Map<String, dynamic>?> checkForUpdates() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      String currentVersion = packageInfo.version;

      final response = await http.get(Uri.parse(versionUrl)).timeout(
            const Duration(seconds: 10),
          );

      if (response.statusCode == 200) {
        Map<String, dynamic> versionData = json.decode(response.body);
        String latestVersion = versionData['version'];

        if (_isUpdateAvailable(currentVersion, latestVersion)) {
          return versionData;
        }
      }
      return null;
    } catch (e) {
      print('Error checking updates: $e');
      return null;
    }
  }

  static bool _isUpdateAvailable(String current, String latest) {
    try {
      List<int> currentParts = current.split('.').map(int.parse).toList();
      List<int> latestParts = latest.split('.').map(int.parse).toList();

      for (int i = 0; i < 3; i++) {
        if (i >= currentParts.length || i >= latestParts.length) break;
        if (latestParts[i] > currentParts[i]) return true;
        if (latestParts[i] < currentParts[i]) return false;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> downloadAndInstallAPK(
    String apkUrl,
    Function(int received, int total)? onProgress,
  ) async {
    try {
      if (Platform.isAndroid) {
        var status = await Permission.storage.request();
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            return false;
          }
        }

        if (await Permission.requestInstallPackages.isDenied) {
          await Permission.requestInstallPackages.request();
        }
      }

      Directory? directory = await getExternalStorageDirectory();
      String savePath = '${directory!.path}/emergency_cases_saver_update.apk';

      File file = File(savePath);
      if (await file.exists()) {
        await file.delete();
      }

      Dio dio = Dio();
      await dio.download(
        apkUrl,
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1 && onProgress != null) {
            onProgress(received, total);
          }
        },
      );

      // Use platform channel to install APK
      if (Platform.isAndroid) {
        try {
          await _channel.invokeMethod('installApk', {'filePath': savePath});
        } catch (e) {
          print('Platform channel error: $e');
        }
      }

      return true;
    } catch (e) {
      print('Error downloading/installing: $e');
      return false;
    }
  }
}
