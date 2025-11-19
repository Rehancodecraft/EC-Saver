import 'package:flutter/material.dart';
import '../services/update_service.dart';
import '../theme/app_colors.dart';

class DrawerMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ...existing items...
          ListTile(
            leading: const Icon(Icons.system_update, color: AppColors.primaryRed),
            title: const Text('Check for Updates'),
            onTap: () {
              Navigator.pop(context);
              _checkForUpdatesManually(context);
            },
          ),
          // ...existing items...
        ],
      ),
    );
  }

  Future<void> _checkForUpdatesManually(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryRed,
        ),
      ),
    );

    final updateInfo = await UpdateService.checkForUpdates();
    
    if (context.mounted) {
      Navigator.pop(context); // Close loading

      if (updateInfo != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Update available!'),
            backgroundColor: AppColors.secondaryGreen,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You\'re up to date! ✅'),
            backgroundColor: AppColors.secondaryGreen,
          ),
        );
      }
    }
  }
}