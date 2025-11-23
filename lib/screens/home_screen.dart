import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/user_profile.dart';
import '../services/database_service.dart';
import '../utils/constants.dart';
import '../widgets/drawer_menu.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  int _todayCount = 0;
  int _monthlyCount = 0;
  int _monthlyLeaves = 0;
  bool _isLoading = true;
  UserProfile? _userProfile;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Animation setup - optimized for performance
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400), // Reduced from 1000ms
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // Simple curve
      ),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1), // Reduced from 0.3
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // Simpler curve
      ),
    );
    
    _animationController.forward();
    
    _loadUserProfile();
    _loadMonthlyStats();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    final profile = await DatabaseService().getUserProfile();
    setState(() {
      _userProfile = profile;
    });
  }

  Future<void> _loadMonthlyStats() async {
    try {
      final dbService = DatabaseService();
      
      // Get today's date range
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
      
      // Get this month's date range
      final monthStart = DateTime(now.year, now.month, 1);
      final monthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
      
      // Get all emergencies
      final allEmergencies = await dbService.getAllEmergencies();
      
      // Count today's emergencies
      final todayEmergencies = allEmergencies.where((e) =>
        e.emergencyDate.isAfter(todayStart) && e.emergencyDate.isBefore(todayEnd)
      ).length;
      
      // Count this month's emergencies
      final monthlyEmergencies = allEmergencies.where((e) =>
        e.emergencyDate.isAfter(monthStart) && e.emergencyDate.isBefore(monthEnd)
      ).length;
      
      // Get all off days and count ALL off days for current month (leaves, gazetted holidays, day-offs)
      final allOffDays = await dbService.getOffDays();
      final monthlyOffDays = allOffDays.where((offDay) {
        // Check if it's in current month
        final isInMonth = offDay.offDate.isAfter(monthStart.subtract(const Duration(days: 1))) &&
                          offDay.offDate.isBefore(monthEnd.add(const Duration(days: 1)));
        return isInMonth;
      }).length;
      
      setState(() {
        _todayCount = todayEmergencies;
        _monthlyCount = monthlyEmergencies;
        _monthlyLeaves = monthlyOffDays;
        _isLoading = false;
      });
    } catch (e) {
      print('DEBUG: Error loading stats: $e');
      setState(() {
        _todayCount = 0;
        _monthlyCount = 0;
        _monthlyLeaves = 0;
        _isLoading = false;
      });
    }
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.grey[700], size: 20),
                    const SizedBox(width: 12),
                    const Text(
                      'Statistics Overview',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              // Current Date Header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  border: Border(
                    bottom: BorderSide(color: Colors.grey[200]!, width: 1),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      DateFormat('dd MMMM yyyy').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('EEEE').format(DateTime.now()),
                      style: TextStyle(
                        color: Colors.blue[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Main Content
              Expanded(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Stats Cards - Today's Entries
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.08),
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
                                  padding: const EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                    color: AppColors.primaryRed.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: const Icon(
                                    Icons.today,
                                    color: AppColors.primaryRed,
                                    size: 16,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                const Expanded(
                                  child: Text(
                                    'Today\'s Entries',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '$_todayCount',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryRed,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Emergency Cases',
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Stats Cards Row (This Month Entries & Leaves)
                      Row(
                        children: [
                          // This Month's Entries Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.08),
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
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: AppColors.secondaryGreen.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: const Icon(
                                          Icons.calendar_month,
                                          color: AppColors.secondaryGreen,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Expanded(
                                        child: Text(
                                          'This Month',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$_monthlyCount',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.secondaryGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Total Entries',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(width: 12),

                          // This Month's Off Days Card
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey[300]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.08),
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
                                        padding: const EdgeInsets.all(5),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(5),
                                        ),
                                        child: const Icon(
                                          Icons.event_busy,
                                          color: Colors.orange,
                                          size: 16,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      const Expanded(
                                        child: Text(
                                          'This Month',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '$_monthlyLeaves',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Off Days',
                                    style: TextStyle(
                                      fontSize: 10,
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
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
