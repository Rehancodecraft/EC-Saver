import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DownloadProgressDialog extends StatelessWidget {
  final double progress;
  final String downloadedSize;
  final String totalSize;

  const DownloadProgressDialog({
    super.key,
    required this.progress,
    required this.downloadedSize,
    required this.totalSize,
  });

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.download, size: 48, color: AppColors.primaryRed),
            const SizedBox(height: 16),
            const Text('Downloading Update...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryRed),
              minHeight: 8,
            ),
            const SizedBox(height: 12),
            Text('${progress.toStringAsFixed(1)}%', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('$downloadedSize / $totalSize', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            const SizedBox(height: 16),
            Text('Please don\'t close the app', style: TextStyle(fontSize: 12, color: Colors.grey[600], fontStyle: FontStyle.italic)),
          ],
        ),
      ),
    );
  }
}
