import 'package:flutter/material.dart';
import '../services/database_service.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import '../widgets/download_progress_dialog.dart';
import '../widgets/drawer_menu.dart';
import '../utils/constants.dart';
import '../models/user_profile.dart';
import '../models/emergency.dart';
import 'emergency_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  UserProfile? _userProfile;
  int _monthlyCount = 0;
  int _todayCount = 0; // Add this line
  Emergency? _lastEmergency;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _loadMonthlyStats();
    _checkForUpdates();
  }

  Future<void> _loadMonthlyStats() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    final emergencies = await _databaseService.getEmergencies();
    
    // Count today's cases
    final todayCases = emergencies.where((e) {
      final emergencyDay = DateTime(
        e.emergencyDate.year,
        e.emergencyDate.month,
        e.emergencyDate.day,
      );
      return emergencyDay.isAtSameMomentAs(today);
    }).length;
    
    // Count this month's cases
    final monthStart = DateTime(now.year, now.month, 1);
    final monthlyEmergencies = emergencies.where((e) {
      return DateTime(
        e.emergencyDate.year,
        e.emergencyDate.month,
        e.emergencyDate.day,
      ).isAfter(monthStart.subtract(const Duration(days: 1)));
    }).toList();

    setState(() {
      _todayCount = todayCases;
      _monthlyCount = monthlyEmergencies.length;
      if (monthlyEmergencies.isNotEmpty) {
        _lastEmergency = monthlyEmergencies.first;
      }
    });
  }

  Future<void> _loadUserProfile() async {
    setState(() => _isLoading = true);
    try {
      final userProfile = await _databaseService.getUserProfile();
      setState(() {
        _userProfile = userProfile;
      });
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _checkForUpdates() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final updateInfo = await UpdateService.checkForUpdates();
    if (updateInfo != null && mounted) {
      _showUpdateDialog(updateInfo);
    }
  }

  void _showUpdateDialog(Map<String, dynamic> updateInfo) {
    showDialog(
      context: context,
      barrierDismissible: !updateInfo['forceUpdate'],
      builder: (context) => UpdateDialog(
        version: updateInfo['version'],
        releaseNotes: updateInfo['releaseNotes'],
        apkUrl: updateInfo['apkUrl'],
        forceUpdate: updateInfo['forceUpdate'],
        fileSize: updateInfo['fileSize'],
        onUpdatePressed: () {
          Navigator.of(context).pop();
          _startDownload(updateInfo['apkUrl']);
        },
      ),
    );
  }

  void _startDownload(String apkUrl) {
    double progress = 0;
    String downloadedSize = '0 MB';
    String totalSize = '0 MB';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          UpdateService.downloadAndInstallAPK(apkUrl, (received, total) {
            setState(() {
              progress = (received / total) * 100;
              downloadedSize = '${(received / 1048576).toStringAsFixed(1)} MB';
              totalSize = '${(total / 1048576).toStringAsFixed(1)} MB';
            });
          }).then((success) {
            if (mounted) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? 'Update downloaded! Installing...' : 'Update failed. Please try again.'),
                  backgroundColor: success ? AppColors.secondaryGreen : Colors.red,
                ),
              );
            }
          });

          return DownloadProgressDialog(
            progress: progress,
            downloadedSize: downloadedSize,
            totalSize: totalSize,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            // Rescue 1122 Logo
            Container(
              width: 35,
              height: 35,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Image.asset(
                'assets/image/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.local_hospital,
                    size: 20,
                    color: AppColors.primaryRed,
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            const Text('EC Saver'), // Changed from 'Emergency Cases Saver'
          ],
        ),
        backgroundColor: AppColors.primaryRed,
        elevation: 0,
      ),
      drawer: const DrawerMenu(currentRoute: '/home'),
      body: Stack(
        children: [
          // Background Image - Exact Fit
          Positioned.fill(
            child: Opacity(
              opacity: 0.25,
              child: Image.asset(
                'assets/image/background.png',
                fit: BoxFit.cover, // Fills entire screen, maintains aspect ratio
                alignment: Alignment.center, // Centers the image
                errorBuilder: (context, error, stackTrace) {
                  return Container(color: Colors.white);
                },
              ),
            ),
          ),

          // Main Content
          Column(
            children: [
              // Stats Header Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.grey[700], size: 22),
                    const SizedBox(width: 12),
                    const Text(
                      'Monthly Statistics Overview',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards Row (Today & This Month)
                      Row(
                        children: [
                          // Today Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.primaryRed.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.today,
                                          color: AppColors.primaryRed,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'Today',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '$_todayCount',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryRed,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Cases',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 16),

                          // This Month's Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month,
                                          color: AppColors.secondaryGreen,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      const Expanded(
                                        child: Text(
                                          'This Month',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    '$_monthlyCount',
                                    style: const TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'Cases',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // ONLY ONE Add Emergency Button (Green)
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            final result = await Navigator.pushNamed(context, '/add-emergency');
                            if (result == true && mounted) {
                              await _loadMonthlyStats();
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.secondaryGreen,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 3,
                          ),
                          icon: const Icon(Icons.add_circle_outline, size: 28, color: Colors.white),
                          label: const Text(
                            'Add New Emergency',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // View Records Button (Changed from "View All Records")
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pushNamed(context, '/records');
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primaryRed, width: 2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          icon: const Icon(Icons.list_alt, size: 24, color: AppColors.primaryRed),
                          label: const Text(
                            'View Records',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryRed,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
