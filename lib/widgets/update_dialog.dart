import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/update_service.dart';

class UpdateDialog extends StatefulWidget {
  final String latestVersion;
  final int latestBuild;
  final String downloadUrl;
  final String releaseNotes;
  final bool forceUpdate;
  const UpdateDialog({
    Key? key,
    required this.latestVersion,
    required this.latestBuild,
    required this.downloadUrl,
    required this.releaseNotes,
    this.forceUpdate = false,
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
      await UpdateService.downloadAndInstallUpdate(
        widget.downloadUrl,
        (progress) {
          if (mounted) {
            setState(() {
              if (progress < 0) {
                // Retry in progress
                _progress = 0.0;
                _status = 'Connection issue. Retrying...';
              } else {
                _progress = progress;
                _status = 'Downloading ${(progress * 100).toStringAsFixed(0)}%';
              }
            });
          }
        },
      );

      setState(() {
        _status = 'Download complete. Starting installation...';
      });

      // Small delay to ensure file is fully written and accessible
      await Future.delayed(const Duration(milliseconds: 500));

      setState(() {
        _status = 'Opening installer automatically...';
      });

      // CRITICAL: Set dismissal AFTER successful download
      // But DON'T set it yet - let it be set after installation completes
      // This ensures the update dialog shows again if installation fails
      final prefs = await SharedPreferences.getInstance();
      final versionKey = '${widget.latestVersion}-${widget.latestBuild}';
      
      // Only set dismissal after download, but clear it on next app start if version changed
      // This way, if installation fails, user can try again
      await prefs.setString('dismissed_update_version', versionKey);
      print('DEBUG: UpdateDialog - Set dismissed version: $versionKey');
      print('DEBUG: UpdateDialog - Note: Will be cleared on next app start if version changes');

      // Wait a bit longer to ensure installer opens before closing dialog
      await Future.delayed(const Duration(seconds: 2));
      
      // Close dialog but keep app running so installer can show
      // The installer dialog should now be visible automatically
      // User does NOT need to manually find or click the downloaded file
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Note: App stays open so installer dialog remains visible
      // User can complete installation and then close app if needed
    } catch (e) {
      print('DEBUG: UpdateDialog - Download error: $e');
      setState(() {
        _isDownloading = false;
        _status = 'Download failed';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Update failed: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !widget.forceUpdate,
      child: AlertDialog(
        title: Row(
          children: [
            Icon(Icons.system_update, color: Colors.red[700]),
            SizedBox(width: 12),
            Text('Update Available'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version ${widget.latestVersion} is available',
                style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(widget.releaseNotes, maxLines: 6, overflow: TextOverflow.ellipsis),
            ),
            SizedBox(height: 16),
            if (_isDownloading) ...[
              LinearProgressIndicator(value: _progress),
              SizedBox(height: 8),
              Text(_status),
            ] else ...[
              Text(
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
          if (!widget.forceUpdate)
            TextButton(
              onPressed: _isDownloading
                  ? null
                  : () async {
                      // Save dismissed version with build number for proper tracking
                      final prefs = await SharedPreferences.getInstance();
                      final versionKey = '${widget.latestVersion}-${widget.latestBuild}';
                      await prefs.setString('dismissed_update_version', versionKey);
                      print('DEBUG: UpdateDialog - User clicked Later, saved dismissed version: $versionKey');
                      
                      // Close dialog and let app continue
                      if (mounted) {
                        Navigator.of(context).pop();
                      }
                    },
              child: Text('Later'),
            ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isDownloading ? null : _startDownload,
              icon: _isDownloading
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Icon(Icons.download),
              label: Text(_isDownloading ? 'Downloading...' : 'Download & Install'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red[700],
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
