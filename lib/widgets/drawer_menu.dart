import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../utils/constants.dart';
import '../services/database_service.dart';
import '../models/user_profile.dart';
import '../services/pdf_service.dart';
import '../models/emergency.dart';
import '../models/off_day.dart';

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

  Future<void> _handleQuickPrint(BuildContext context) async {
    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating PDF...'),
                ],
              ),
            ),
          ),
        ),
      );

      final db = DatabaseService();
      
      // Get all emergencies
      final allEmergencies = await db.getAllEmergencies();
      if (allEmergencies.isEmpty) {
        if (context.mounted) {
          Navigator.pop(context); // Close loading
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No emergency records to print')),
          );
        }
        return;
      }

      // Group emergencies by month
      final Map<String, List<Emergency>> groupedEmergencies = {};
      for (var emergency in allEmergencies) {
        final monthKey = '${emergency.emergencyDate.month.toString().padLeft(2, '0')}/${emergency.emergencyDate.year}';
        groupedEmergencies.putIfAbsent(monthKey, () => []).add(emergency);
      }

      // Get all off days
      final allOffDays = await db.getAllOffDays();
      final Map<String, List<OffDay>> groupedOffDays = {};
      for (var offDay in allOffDays) {
        final monthKey = '${offDay.offDate.month.toString().padLeft(2, '0')}/${offDay.offDate.year}';
        groupedOffDays.putIfAbsent(monthKey, () => []).add(offDay);
      }

      // Get user profile
      final userProfile = await db.getUserProfile();

      // Get sorted list of all months
      final allMonths = {...groupedEmergencies.keys, ...groupedOffDays.keys}.toList();
      allMonths.sort((a, b) => b.compareTo(a)); // Sort descending (newest first)

      // Generate and save PDF
      final filePath = await PdfService.quickPrintAndSave(
        groupedEmergencies: groupedEmergencies,
        selectedMonths: allMonths,
        title: 'All EC Records',
        userProfile: userProfile,
        groupedOffDays: groupedOffDays,
      );

      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('PDF saved to Downloads folder'),
            action: SnackBarAction(
              label: 'OK',
              onPressed: () {},
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context); // Close loading
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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

                // Quick Print
                ListTile(
                  leading: const Icon(Icons.print, color: Colors.grey),
                  title: const Text('Quick Print All'),
                  onTap: () {
                    Navigator.pop(context);
                    _handleQuickPrint(context);
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
