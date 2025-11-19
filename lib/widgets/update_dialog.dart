import 'package:flutter/material.dart';
import '../utils/constants.dart';

class UpdateDialog extends StatelessWidget {
  final String version;
  final String releaseNotes;
  final String apkUrl;
  final bool forceUpdate;
  final String fileSize;
  final VoidCallback onUpdatePressed;

  const UpdateDialog({
    Key? key,
    required this.version,
    required this.releaseNotes,
    required this.apkUrl,
    required this.forceUpdate,
    required this.fileSize,
    required this.onUpdatePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.system_update, color: AppColors.primaryRed, size: 28),
          const SizedBox(width: 12),
          const Text('Update Available', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Version $version is now available', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 16),
            const Text('What\'s New:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryRed)),
            const SizedBox(height: 8),
            Text(releaseNotes, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
              child: Column(
                children: [
                  _buildInfoRow('Size', fileSize),
                  const SizedBox(height: 8),
                  _buildInfoRow('Version', version),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (!forceUpdate)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Later', style: TextStyle(color: Colors.grey)),
          ),
        ElevatedButton(
          onPressed: onUpdatePressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondaryGreen,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text('UPDATE NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: Colors.grey)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
