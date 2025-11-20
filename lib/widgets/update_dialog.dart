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
  double _progress = 0.0;
  String _status = 'Ready';

  Future<void> _startDownload() async {
    setState(() {
      _isDownloading = true;
      _progress = 0.0;
      _status = 'Starting download...';
    });

    try {
      await UpdateService.downloadAndInstallUpdate(widget.downloadUrl, (p) {
        if (mounted) {
          setState(() {
            _progress = p.clamp(0.0, 1.0);
            if (p >= 1.0) {
              _status = 'Download complete. Opening installer...';
            } else {
              _status = 'Downloading ${(p * 100).toInt()}%';
            }
          });
        }
      });

      // Download and install successful
      if (mounted) {
        setState(() {
          _status = 'Please install the update';
          _isDownloading = false;
        });

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✓ Download complete! Please install the update.'),
            backgroundColor: AppColors.secondaryGreen,
            duration: Duration(seconds: 3),
          ),
        );

        // Auto-close dialog after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          if (mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    } catch (e) {
      print('DEBUG: Download error: $e');
      if (mounted) {
        setState(() {
          _isDownloading = false;
          _status = 'Download failed';
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Update failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
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
            Text('Version ${widget.latestVersion} is available', style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Text(widget.releaseNotes, maxLines: 6, overflow: TextOverflow.ellipsis),
            ),
            const SizedBox(height: 16),
            if (_isDownloading) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(_status),
            ] else ...[
              const Text('You must update to continue using the app.'),
            ]
          ],
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : _startDownload,
              icon: _isDownloading ? const SizedBox(width:16, height:16, child:CircularProgressIndicator(color:Colors.white, strokeWidth:2)) : const Icon(Icons.download),
              label: Text(_isDownloading ? 'Downloading...' : 'Download & Install'),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryRed),
            ),
          ),
        ],
      ),
    );
  }
}
