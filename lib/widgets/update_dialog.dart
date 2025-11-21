import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:flutter/services.dart';

import '../services/update_service.dart';
import '../utils/constants.dart';

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
              _progress = progress;
              _status = 'Downloading ${(progress * 100).toStringAsFixed(0)}%';
            });
          }
        },
      );

      setState(() {
        _status = 'Download complete. Opening installer...';
      });

      // CRITICAL: Set dismissal AFTER successful download
      final prefs = await SharedPreferences.getInstance();
      final versionKey = '${widget.latestVersion}-${widget.latestBuild}';
      await prefs.setString('dismissed_update_version', versionKey);
      print('DEBUG: UpdateDialog - Set dismissed version: $versionKey');

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) Navigator.of(context).pop();

      // Exit app to allow clean installation
      try {
        SystemNavigator.pop();
      } catch (_) {}
      try {
        exit(0);
      } catch (_) {}
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
    return WillPopScope(
      onWillPop: () async => widget.forceUpdate ? false : true,
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
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('dismissed_update_version', widget.latestVersion);
                      Navigator.of(context).pop();
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
