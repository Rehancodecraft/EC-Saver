import 'package:flutter/material.dart';
import '../services/update_service.dart';
import '../utils/constants.dart';

class UpdateDialog extends StatefulWidget {
  final String latestVersion;
  final String downloadUrl;
  final String releaseNotes;

  const UpdateDialog({
    Key? key,
    required this.latestVersion,
    required this.downloadUrl,
    required this.releaseNotes,
  }) : super(key: key);

  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String _statusText = 'Ready to download';

  Future<void> _downloadUpdate() async {
    setState(() {
      _isDownloading = true;
      _statusText = 'Downloading...';
    });

    try {
      await UpdateService.downloadAndInstallUpdate(
        widget.downloadUrl,
        (progress) {
          setState(() {
            _downloadProgress = progress;
            _statusText = 'Downloading... ${(progress * 100).toInt()}%';
          });
        },
      );

      setState(() {
        _statusText = 'Installing... Please allow installation';
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _statusText = 'Download failed: $e';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Update failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // PREVENT BACK BUTTON
      child: AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.system_update, color: AppColors.primaryRed),
            SizedBox(width: 12),
            Text('Update Required'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Version ${widget.latestVersion} is available',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.releaseNotes,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const SizedBox(height: 20),
            if (_isDownloading) ...[
              LinearProgressIndicator(
                value: _downloadProgress,
                backgroundColor: Colors.grey[300],
                color: AppColors.primaryRed,
              ),
              const SizedBox(height: 8),
              Text(
                _statusText,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                ),
              ),
            ] else ...[
              const Text(
                '⚠️ You must update to continue using the app',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : _downloadUpdate,
              icon: _isDownloading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.download),
              label: Text(_isDownloading ? 'Downloading...' : 'Update Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryRed,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
