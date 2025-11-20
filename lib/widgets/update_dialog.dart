import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';
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
      // mark attempt in prefs
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_attempted_update', widget.latestVersion);

      await UpdateService.downloadAndInstallUpdate(widget.downloadUrl, (p) {
        if (mounted) {
          setState(() {
            _progress = p.clamp(0.0, 1.0);
            _status = p >= 1.0 ? 'Download complete. Opening installer...' : 'Downloading ${(p * 100).toInt()}%';
          });
        }
      });

      // small delay to allow installer intent
      await Future.delayed(const Duration(milliseconds: 800));

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _status = 'Installer opened. The app will close.';
        });

        // close dialog then exit so installer can proceed
        await Future.delayed(const Duration(milliseconds: 600));
        if (mounted) Navigator.of(context).pop();

        // exit app
        try {
          SystemNavigator.pop();
        } catch (_) {}
        try {
          exit(0);
        } catch (_) {}
      }
    } catch (e) {
      // clear attempted flag on error
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('last_attempted_update');

      if (mounted) {
        setState(() {
          _isDownloading = false;
          _status = 'Download failed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
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
            Text(
              'Version ${widget.latestVersion} is available',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.releaseNotes,
                style: const TextStyle(fontSize: 13),
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 16),
            if (_isDownloading) ...[
              LinearProgressIndicator(value: _progress),
              const SizedBox(height: 8),
              Text(_status),
            ] else ...[
              Text(
                '⚠️ You must update to continue using the app',
                style: const TextStyle(
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
              onPressed: _isDownloading ? null : _startDownload,
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
              label: Text(_isDownloading ? 'Downloading...' : 'Download & Install'),
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
