import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';

class DrawerMenu extends StatefulWidget {
  final String currentRoute;

  const DrawerMenu({
    super.key,
    required this.currentRoute,
  });

  @override
  State<DrawerMenu> createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> {
  UserProfile? _userProfile;
  String _appVersion = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadAppVersion();
  }

  Future<void> _loadUserProfile() async {
    final profile = await DatabaseService().getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  Future<void> _loadAppVersion() async {
    try {
      // Force fresh read - create new instance to avoid caching
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version.trim();
      final build = packageInfo.buildNumber.trim();
      setState(() {
        _appVersion = 'v$version${build.isNotEmpty && build != '0' ? '+$build' : ''}';
      });
      print('DEBUG: DrawerMenu - Loaded version: $_appVersion');
    } catch (e) {
      print('DEBUG: DrawerMenu - Error loading version: $e');
      setState(() {
        _appVersion = 'v1.0.0';
      });
    }
  }
  
  // Method to refresh version (can be called after update)
  void refreshVersion() {
    _loadAppVersion();
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
                  _appVersion,
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
}
