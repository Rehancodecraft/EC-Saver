package com.nexivault.emergency_cases_saver

import android.content.pm.PackageManager
import android.os.Build
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest
import java.security.cert.X509Certificate

class SignatureInfoPlugin {
    companion object {
        private const val CHANNEL = "com.nexivault.emergency_cases_saver/signature"

        fun registerWith(flutterEngine: FlutterEngine, activity: android.app.Activity) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler { call, result ->
                if (call.method == "getSignatureInfo") {
                    try {
                        val signatureInfo = getSignatureInfo(activity)
                        result.success(signatureInfo)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get signature: ${e.message}", null)
                    }
                } else {
                    result.notImplemented()
                }
            }
        }

        private fun getSignatureInfo(activity: android.app.Activity): Map<String, String> {
            val packageName = activity.packageName
            val packageManager = activity.packageManager
            
            val signatureInfo = mutableMapOf<String, String>()
            
            try {
                val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                    val signingInfo = packageManager.getPackageInfo(
                        packageName,
                        PackageManager.GET_SIGNING_CERTIFICATES
                    ).signingInfo
                    
                    if (signingInfo != null) {
                        if (signingInfo.hasMultipleSigners()) {
                            signingInfo.apkContentsSigners
                        } else {
                            signingInfo.signingCertificateHistory
                        }
                    } else {
                        // Fallback to deprecated method if signingInfo is null
                        @Suppress("DEPRECATION")
                        packageManager.getPackageInfo(
                            packageName,
                            PackageManager.GET_SIGNATURES
                        ).signatures
                    }
                } else {
                    @Suppress("DEPRECATION")
                    packageManager.getPackageInfo(
                        packageName,
                        PackageManager.GET_SIGNATURES
                    ).signatures
                }
                
                if (signatures.isNotEmpty()) {
                    val signature = signatures[0]
                    val cert = signature.toByteArray()
                    
                    // Calculate SHA-1
                    val sha1 = MessageDigest.getInstance("SHA-1").digest(cert)
                    signatureInfo["sha1"] = bytesToHex(sha1)
                    
                    // Calculate SHA-256
                    val sha256 = MessageDigest.getInstance("SHA-256").digest(cert)
                    signatureInfo["sha256"] = bytesToHex(sha256)
                    
                    // Get certificate details
                    try {
                        val certFactory = java.security.cert.CertificateFactory.getInstance("X.509")
                        val x509Cert = certFactory.generateCertificate(
                            java.io.ByteArrayInputStream(cert)
                        ) as X509Certificate
                        
                        signatureInfo["issuer"] = x509Cert.issuerDN.toString()
                        signatureInfo["subject"] = x509Cert.subjectDN.toString()
                    } catch (e: Exception) {
                        signatureInfo["issuer"] = "Error: ${e.message}"
                        signatureInfo["subject"] = "Error: ${e.message}"
                    }
                } else {
                    signatureInfo["error"] = "No signatures found"
                }
            } catch (e: Exception) {
                signatureInfo["error"] = "Exception: ${e.message}"
            }
            
            return signatureInfo
        }
        
        private fun bytesToHex(bytes: ByteArray): String {
            val hexArray = "0123456789ABCDEF".toCharArray()
            val hexChars = CharArray(bytes.size * 3 - 1) // 2 chars per byte + colon separator
            var index = 0
            for (j in bytes.indices) {
                val v = bytes[j].toInt() and 0xFF
                hexChars[index++] = hexArray[v ushr 4]
                hexChars[index++] = hexArray[v and 0x0F]
                if (j < bytes.size - 1) {
                    hexChars[index++] = ':'
                }
            }
            return String(hexChars)
        }
    }
}
