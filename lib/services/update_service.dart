import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

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

  // Extract version and build number from tag (format: v1.0.2+3 or 1.0.2+3)
  static Map<String, dynamic> _parseVersionTag(String tag) {
    // Remove 'v' prefix if present
    String cleanTag = tag.replaceAll('v', '').trim();
    
    // Split by '+' to get version and build number
    List<String> parts = cleanTag.split('+');
    String version = parts[0].trim();
    int buildNumber = 0;
    
    if (parts.length > 1) {
      buildNumber = int.tryParse(parts[1].trim()) ?? 0;
    }
    
    return {
      'version': version,
      'buildNumber': buildNumber,
    };
  }

  // Check if release notes contain [FORCE_UPDATE] tag
  static bool _isForceUpdate(String releaseNotes) {
    return releaseNotes.toUpperCase().contains('[FORCE_UPDATE]') ||
           releaseNotes.toUpperCase().contains('FORCE UPDATE');
  }

  // NEW: robust check using GitHub Releases API and PackageInfo
  static Future<Map<String, dynamic>> checkForUpdate({String? currentVersion}) async {
    try {
      if (currentVersion == null) {
        final pkg = await PackageInfo.fromPlatform();
        currentVersion = pkg.version;
      }
      final pkg = await PackageInfo.fromPlatform();
      final currentBuild = int.tryParse(pkg.buildNumber) ?? 1;

      print('DEBUG: UpdateService - Checking update for version: $currentVersion, build: $currentBuild');

      final response = await http.get(
        Uri.parse(releasesLatestUrl),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) {
        print('DEBUG: GitHub API failed status=${response.statusCode}');
        return {'updateAvailable': false, 'error': 'Failed to check for updates'};
      }

      final data = json.decode(response.body) as Map<String, dynamic>;
      final tagName = (data['tag_name'] ?? '').toString();
      
      // Parse version and build from tag (e.g., v1.0.2+3)
      final parsed = _parseVersionTag(tagName);
      final latestVersion = parsed['version'] as String;
      final latestBuild = parsed['buildNumber'] as int;
      
      // Find APK asset (look for .apk file)
      String apkUrl = '';
      String apkName = '';
      if (data['assets'] != null && (data['assets'] as List).isNotEmpty) {
        for (var asset in data['assets'] as List) {
          final assetName = (asset['name'] ?? '').toString();
          if (assetName.toLowerCase().endsWith('.apk')) {
            apkUrl = asset['browser_download_url'] ?? '';
            apkName = assetName;
            print('DEBUG: UpdateService - Found APK: $apkName');
            print('DEBUG: UpdateService - APK URL: $apkUrl');
            break;
          }
        }
        // Fallback to first asset if no APK found
        if (apkUrl.isEmpty) {
          apkUrl = data['assets']![0]['browser_download_url'] ?? '';
          apkName = (data['assets']![0]['name'] ?? '').toString();
          print('DEBUG: UpdateService - Using fallback APK: $apkName');
        }
      } else {
        print('DEBUG: UpdateService - WARNING: No assets found in release!');
      }
      
      if (apkUrl.isEmpty) {
        print('DEBUG: UpdateService - ERROR: No APK URL found!');
      }
      
      final releaseNotes = (data['body'] ?? '').toString();
      final forceUpdate = _isForceUpdate(releaseNotes);

      print('DEBUG: UpdateService - Latest version: $latestVersion, build: $latestBuild');
      print('DEBUG: UpdateService - Latest tag: $tagName');
      print('DEBUG: UpdateService - APK URL: $apkUrl');
      print('DEBUG: UpdateService - APK Name: $apkName');
      print('DEBUG: UpdateService - Current version: $currentVersion, build: $currentBuild');

      // Compare versions: first by version string, then by build number
      bool updateAvailable = false;
      
      // First compare version strings (e.g., 1.0.6 vs 1.0.2)
      final versionComparison = compareVersions(latestVersion, currentVersion);
      
      if (versionComparison > 0) {
        // Latest version is newer
        updateAvailable = true;
      } else if (versionComparison == 0) {
        // Same version, compare build numbers
        if (latestBuild > 0 && currentBuild > 0) {
          updateAvailable = latestBuild > currentBuild;
        } else if (latestBuild > 0 && currentBuild == 0) {
          // If latest has build number but current doesn't, check if build > 0
          updateAvailable = latestBuild > 0;
        }
      }
      // If versionComparison < 0, latest is older (shouldn't happen), so no update

      print('DEBUG: UpdateService - Version comparison: $versionComparison');
      print('DEBUG: UpdateService - Current: $currentVersion+$currentBuild, Latest: $latestVersion+$latestBuild');
      print('DEBUG: UpdateService - Update available: $updateAvailable');

      return {
        'updateAvailable': updateAvailable,
        'latestVersion': latestVersion,
        'latestBuild': latestBuild,
        'downloadUrl': apkUrl,
        'releaseNotes': releaseNotes,
        'forceUpdate': forceUpdate,
      };
    } catch (e, stackTrace) {
      print('DEBUG: UpdateService - Error: $e');
      print('DEBUG: UpdateService - StackTrace: $stackTrace');
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

    if (!Platform.isAndroid) {
      throw Exception('Auto-update is only supported on Android');
    }

    // Request install permission for Android 8.0+
    final installPermission = await Permission.requestInstallPackages.request();
    if (!installPermission.isGranted) {
      // For Android 11+, we can still try to install via FileProvider
      print('DEBUG: Install permission not granted, will try FileProvider');
    }

    // Request storage permission for older Android versions
    if (await Permission.storage.isDenied) {
      final storageStatus = await Permission.storage.request();
      if (!storageStatus.isGranted && !storageStatus.isPermanentlyDenied) {
        print('DEBUG: Storage permission not granted, will try app-specific directory');
      }
    }

    // Use app-specific external directory (works on all Android versions)
    final appDir = await getApplicationDocumentsDirectory();
    final updateDir = Directory(p.join(appDir.path, 'updates'));
    if (!await updateDir.exists()) {
      await updateDir.create(recursive: true);
    }

    final filePath = p.join(updateDir.path, 'ec-saver-update.apk');
    final file = File(filePath);
    
    // Delete old update file if exists
    if (await file.exists()) {
      try {
        await file.delete();
      } catch (_) {}
    }

    // Download with retry logic
    const maxRetries = 3;
    int retryCount = 0;
    Exception? lastError;

    while (retryCount < maxRetries) {
      try {
        print('DEBUG: Download attempt ${retryCount + 1}/$maxRetries');
        
        // Create a new client for each attempt
        final client = http.Client();
        http.StreamedResponse? response;
        
        try {
          final uri = Uri.parse(downloadUrl);
          final request = http.Request('GET', uri);
          
          // Add headers for better connection handling
          request.headers.addAll({
            'Connection': 'keep-alive',
            'Accept': '*/*',
            'User-Agent': 'EC-Saver-Updater/1.0',
          });

          // Send request with separate connection and read timeouts
          response = await client.send(request).timeout(
            const Duration(minutes: 15), // Total timeout
            onTimeout: () {
              client.close();
              throw TimeoutException('Connection timeout after 15 minutes');
            },
          );

          if (response.statusCode != 200) {
            client.close();
            throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
          }

          final contentLength = response.contentLength ?? 0;
          int received = 0;

          // Download with progress tracking and chunk timeout
          final sink = file.openWrite();
          bool downloadSuccess = false;
          
          try {
            // Use a timeout for reading each chunk to detect connection issues early
            await for (final chunk in response.stream.timeout(
              const Duration(seconds: 30), // Timeout for each chunk read
              onTimeout: (sink) {
                throw TimeoutException('Connection closed: No data received for 30 seconds');
              },
            )) {
              sink.add(chunk);
              received += chunk.length;
              
              if (contentLength > 0) {
                onProgress(received / contentLength);
              } else {
                // If content length is unknown, show progress based on received bytes
                // Assume typical APK size of ~20MB for progress estimation
                const estimatedSize = 20 * 1024 * 1024; // 20MB
                onProgress((received / estimatedSize).clamp(0.0, 0.95));
              }
            }
            downloadSuccess = true;
          } catch (e) {
            await sink.close();
            client.close();
            // Delete partial file
            if (await file.exists()) {
              try {
                await file.delete();
              } catch (_) {}
            }
            throw e;
          } finally {
            if (downloadSuccess) {
              await sink.close();
            }
            client.close();
          }

          // Verify download completed
          if (!await file.exists() || await file.length() == 0) {
            throw Exception('Downloaded file is missing or empty');
          }

          final fileSize = await file.length();
          print('DEBUG: APK downloaded successfully to: $filePath');
          print('DEBUG: File size: $fileSize bytes');
          print('DEBUG: Expected size: $contentLength bytes');
          
          // Verify file size matches (if content length was provided)
          if (contentLength > 0 && fileSize != contentLength) {
            print('WARNING: File size mismatch. Expected: $contentLength, Got: $fileSize');
            // Still proceed if file is reasonably sized
            if (fileSize < contentLength * 0.9) {
              throw Exception('Download incomplete: Expected $contentLength bytes, got $fileSize bytes');
            }
          }

          // Verify minimum file size
          if (fileSize < 1000000) { // Less than 1MB is suspicious
            throw Exception('Downloaded APK file is too small (${fileSize} bytes). File may be corrupted.');
          }

          // Small delay to ensure file is fully written
          await Future.delayed(const Duration(milliseconds: 500));

          // Verify file still exists after delay
          if (!await file.exists()) {
            throw Exception('Downloaded file was deleted or moved');
          }

          // Download successful, break retry loop
          break;
        } catch (e) {
          client.close();
          // Clean up partial file
          if (await file.exists()) {
            try {
              await file.delete();
            } catch (_) {}
          }
          lastError = e is Exception ? e : Exception(e.toString());
          retryCount++;
          
          if (retryCount < maxRetries) {
            // Exponential backoff: wait 2^retryCount seconds
            final waitSeconds = 2 * (1 << (retryCount - 1)); // 2, 4, 8 seconds
            print('DEBUG: Download failed: $e');
            print('DEBUG: Retrying in $waitSeconds seconds... (Attempt ${retryCount + 1}/$maxRetries)');
            onProgress(-1.0); // Signal retry to UI
            await Future.delayed(Duration(seconds: waitSeconds));
          } else {
            throw lastError!;
          }
        }
      } catch (e) {
        if (retryCount >= maxRetries) {
          // All retries exhausted
          final errorMsg = e.toString();
          if (errorMsg.contains('Connection closed') || 
              errorMsg.contains('Connection') ||
              errorMsg.contains('timeout')) {
            throw Exception('Download failed: Network connection issue. Please check your internet connection and try again.\n\nError: $errorMsg');
          }
          throw Exception('Download failed after $maxRetries attempts: $errorMsg');
        }
      }
    }

    // Verify the downloaded file is actually an APK
    if (!filePath.toLowerCase().endsWith('.apk')) {
      print('WARNING: Downloaded file does not have .apk extension!');
    }

    // Use native method channel for installation (more reliable than OpenFile)
    try {
      const platform = MethodChannel('apk_installer');
      final result = await platform.invokeMethod('installApk', {'filePath': filePath});
      print('DEBUG: Native install method result: $result');
      
      if (result != true) {
        throw Exception('Installation failed: Native method returned false');
      }
      
      print('DEBUG: Installer opened successfully via native method');
    } catch (e) {
      print('DEBUG: Native install method failed: $e');
      print('DEBUG: Error details: ${e.toString()}');
      
      // Re-throw with better error message
      throw Exception('Failed to open installer. Please check if installation permission is granted.\nError: $e');
    }
  }
}
