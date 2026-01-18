import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SignatureInfoHelper {
  /// Gets the app's signing certificate information (SHA-1, SHA-256, etc.)
  /// This is useful for debugging signature mismatch issues
  static Future<Map<String, String>> getSignatureInfo() async {
    try {
      const platform = MethodChannel('com.nexivault.emergency_cases_saver/signature');
      final Map<dynamic, dynamic> result = await platform.invokeMethod('getSignatureInfo');
      
      return {
        'sha1': result['sha1']?.toString() ?? 'Unknown',
        'sha256': result['sha256']?.toString() ?? 'Unknown',
        'issuer': result['issuer']?.toString() ?? 'Unknown',
        'subject': result['subject']?.toString() ?? 'Unknown',
      };
    } catch (e) {
      debugPrint('Failed to get signature info: $e');
      return {
        'sha1': 'Error: $e',
        'sha256': 'N/A',
        'issuer': 'N/A',
        'subject': 'N/A',
      };
    }
  }

  /// Shows a dialog with signature information
  /// Useful for debugging "app not installed" errors
  static Future<void> showSignatureDialog(BuildContext context) async {
    final info = await getSignatureInfo();
    
    if (!context.mounted) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.blue),
            SizedBox(width: 8),
            Text('App Signature Info'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'This information helps debug "app not installed" errors caused by signature mismatches.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              _buildInfoRow('SHA-1', info['sha1']!),
              const Divider(),
              _buildInfoRow('SHA-256', info['sha256']!),
              const Divider(),
              _buildInfoRow('Issuer', info['issuer']!),
              const Divider(),
              _buildInfoRow('Subject', info['subject']!),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow[50],
                  border: Border.all(color: Colors.orange),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '⚠️ If SHA-1/SHA-256 don\'t match between versions, you\'ll get "app not installed" error when upgrading.',
                  style: TextStyle(fontSize: 11),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Copy SHA-1 to clipboard
              Clipboard.setData(ClipboardData(text: info['sha1']!));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('SHA-1 copied to clipboard')),
              );
            },
            child: const Text('Copy SHA-1'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  static Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
        ),
      ],
    );
  }
}
