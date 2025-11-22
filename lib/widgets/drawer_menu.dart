import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DrawerMenu extends StatefulWidget {
  final String currentRoute;

  const DrawerMenu({
    Key? key,
    required this.currentRoute,
  }) : super(key: key);

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  UserProfile? _userProfile;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await DatabaseService().getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 260,
      child: Column(
        children: [
          // Header with Logo
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 50, 16, 16),
            decoration: const BoxDecoration(
              color: AppColors.primaryRed,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Logo and App Name Row
                Row(
                  children: [
                    // Logo
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.all(6),
                      child: Image.asset(
                        'assets/image/logo.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return const Icon(
                            Icons.local_hospital,
                            size: 30,
                            color: AppColors.primaryRed,
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    // EC Saver Text
                    const Text(
                      'EC Saver',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // User Info
                if (_userProfile != null) ...[
                  Text(
                    _userProfile!.fullName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _userProfile!.designation,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_userProfile!.district} • ${_userProfile!.tehsil}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ] else ...[
                  Text(
                    'Emergency Cases Saver',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                // Home
                ListTile(
                  leading: const Icon(Icons.home, color: Colors.grey),
                  title: const Text('Home'),
                  selected: widget.currentRoute == '/home',
                  selectedTileColor: AppColors.primaryRed.withOpacity(0.1),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != '/home') {
                      Navigator.pushReplacementNamed(context, '/home');
                    }
                  },
                ),

                // View Records
                ListTile(
                  leading: const Icon(Icons.list_alt, color: Colors.grey),
                  title: const Text('View Records'),
                  selected: widget.currentRoute == '/records',
                  selectedTileColor: AppColors.medicalBlue.withOpacity(0.1),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != '/records') {
                      Navigator.pushNamed(context, '/records');
                    }
                  },
                ),

                // Off Days
                ListTile(
                  leading: const Icon(Icons.event_busy, color: Colors.grey),
                  title: const Text('Off Days'),
                  selected: widget.currentRoute == '/off-days',
                  selectedTileColor: AppColors.accidentOrange.withOpacity(0.1),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != '/off-days') {
                      Navigator.pushNamed(context, '/off-days');
                    }
                  },
                ),

                const Divider(),

                // About
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.grey),
                  title: const Text('About'),
                  selected: widget.currentRoute == '/about',
                  selectedTileColor: AppColors.accidentOrange.withOpacity(0.1),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != '/about') {
                      Navigator.pushNamed(context, '/about');
                    }
                  },
                ),

                // Feedback
                ListTile(
                  leading: const Icon(Icons.feedback, color: Colors.grey),
                  title: const Text('Feedback'),
                  selected: widget.currentRoute == '/feedback',
                  selectedTileColor: AppColors.secondaryGreen.withOpacity(0.1),
                  onTap: () {
                    Navigator.pop(context);
                    if (widget.currentRoute != '/feedback') {
                      Navigator.pushNamed(context, '/feedback');
                    }
                  },
                ),

                const Divider(),

                // Check for Updates
                ListTile(
                  leading: const Icon(Icons.system_update, color: AppColors.primaryRed),
                  title: const Text('Check for Updates'),
                  onTap: () {
                    Navigator.pop(context);
                    _checkForUpdates(context);
                  },
                ),
              ],
            ),
          ),

          // Footer
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              children: [
                Text(
                  'Designed by NexiVault',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 10,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _checkForUpdates(BuildContext context) async {
    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryRed,
        ),
      ),
    );

    try {
      final pkg = await PackageInfo.fromPlatform();
      final currentVersion = pkg.version;
      
      final updateInfo = await UpdateService.checkForUpdate(currentVersion: currentVersion);
      
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog

      if (updateInfo['updateAvailable'] == true && 
          (updateInfo['downloadUrl'] ?? '').toString().isNotEmpty) {
        // Show update dialog
        showDialog(
          context: context,
          barrierDismissible: !(updateInfo['forceUpdate'] ?? false),
          builder: (context) => UpdateDialog(
            latestVersion: updateInfo['latestVersion'],
            latestBuild: updateInfo['latestBuild'] ?? 0,
            downloadUrl: updateInfo['downloadUrl'],
            releaseNotes: updateInfo['releaseNotes'] ?? 'New version available',
            forceUpdate: updateInfo['forceUpdate'] ?? false,
          ),
        );
      } else {
        // Show "up to date" message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You are using the latest version! ✅'),
            backgroundColor: AppColors.secondaryGreen,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Close loading dialog
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error checking for updates: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }
}
