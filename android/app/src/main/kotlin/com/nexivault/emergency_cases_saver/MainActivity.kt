package com.nexivault.emergency_cases_saver

import android.content.Intent
import android.content.pm.PackageInstaller
import android.net.Uri
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream
import java.util.zip.ZipEntry
import java.util.zip.ZipInputStream
import android.os.Bundle

class MainActivity: FlutterActivity() {
    private val CHANNEL = "apk_installer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "installApk") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    try {
                        installApk(filePath)
                        result.success(true)
                    } catch (e: Exception) {
                        result.error("INSTALL_FAILED", "Failed to install APK: ${e.message}", null)
                    }
                } else {
                    result.error("INVALID_PATH", "File path is null", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun installApk(filePath: String) {
        val file = File(filePath)
        
        // Verify file exists
        if (!file.exists()) {
            throw Exception("APK file does not exist: $filePath")
        }

        // Verify file is readable
        if (!file.canRead()) {
            throw Exception("Cannot read APK file: $filePath")
        }

        // Verify file size (should be at least 1MB)
        val fileSize = file.length()
        if (fileSize < 1024 * 1024) {
            throw Exception("APK file is too small (${fileSize} bytes). File may be corrupted.")
        }

        // Verify it's a valid APK by checking ZIP structure
        try {
            val zipInputStream = ZipInputStream(FileInputStream(file))
            var foundAndroidManifest = false
            var entry: ZipEntry? = zipInputStream.nextEntry
            while (entry != null) {
                if (entry.name == "AndroidManifest.xml") {
                    foundAndroidManifest = true
                    break
                }
                entry = zipInputStream.nextEntry
            }
            zipInputStream.close()
            
            if (!foundAndroidManifest) {
                throw Exception("Invalid APK: AndroidManifest.xml not found. File may be corrupted.")
            }
        } catch (e: Exception) {
            if (e.message?.contains("Invalid APK") == true) {
                throw e
            }
            // If it's a ZIP error, the file is corrupted
            throw Exception("Invalid APK: File is not a valid ZIP archive. File may be corrupted.")
        }

        // Get URI for the APK file
        val apkUri = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            // Use FileProvider for Android 7.0+ (API 24+)
            try {
                FileProvider.getUriForFile(
                    this@MainActivity,
                    "${applicationContext.packageName}.fileprovider",
                    file
                )
            } catch (e: IllegalArgumentException) {
                throw Exception("FileProvider error: ${e.message}. File path: $filePath")
            }
        } else {
            // For older Android versions, use file:// URI
            Uri.fromFile(file)
        }

        // Create installation intent with proper flags to ensure it opens automatically
        val intent = Intent(Intent.ACTION_VIEW).apply {
            // These flags ensure the installer opens in foreground and is visible
            flags = Intent.FLAG_ACTIVITY_NEW_TASK
            flags = flags or Intent.FLAG_ACTIVITY_CLEAR_TOP
            flags = flags or Intent.FLAG_ACTIVITY_SINGLE_TOP
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_GRANT_WRITE_URI_PERMISSION)
            
            setDataAndType(apkUri, "application/vnd.android.package-archive")
            
            // For Android 8.0+ (API 26+), explicitly set the package installer
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                // Try common package installer package names
                val packageInstallers = listOf(
                    "com.android.packageinstaller",
                    "com.google.android.packageinstaller",
                    "com.samsung.android.packageinstaller",
                    "com.miui.packageinstaller",
                    "com.huawei.packageinstaller"
                )
                
                for (packageName in packageInstallers) {
                    try {
                        packageManager.getPackageInfo(packageName, 0)
                        setPackage(packageName)
                        break
                    } catch (e: Exception) {
                        // Package not found, try next one
                    }
                }
            }
        }

        // Verify intent can be handled
        val resolveInfo = packageManager.queryIntentActivities(intent, 0)
        if (resolveInfo.isEmpty()) {
            throw Exception("No app found to handle APK installation. Please enable 'Install unknown apps' permission.")
        }

        // Start installation - this will automatically open the installer dialog
        // User does NOT need to manually find or click the file
        try {
            startActivity(intent)
            // Installation dialog should now appear automatically
        } catch (e: Exception) {
            throw Exception("Failed to start installation: ${e.message}")
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // Keep the splash screen visible while Flutter initializes
    }
}
