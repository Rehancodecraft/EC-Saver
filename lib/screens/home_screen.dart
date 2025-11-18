import 'package:flutter/material.dart';
import '../models/emergency.dart';
import '../services/database_service.dart';
import '../widgets/drawer_menu.dart';
import '../utils/constants.dart';
import 'emergency_form_screen.dart';
import 'records_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _todayCount = 0;
  int _monthCount = 0;
  Emergency? _lastEmergency;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final monthStart = DateTime(now.year, now.month, 1);

      final todayEmergencies = await DatabaseService().getEmergencies();
      _todayCount = todayEmergencies.where((e) {
        final emergencyDate = DateTime(
          e.emergencyDate.year,
          e.emergencyDate.month,
          e.emergencyDate.day,
        );
        return emergencyDate == today;
      }).length;

      _monthCount = todayEmergencies.where((e) {
        return e.emergencyDate.isAfter(monthStart.subtract(const Duration(days: 1)));
      }).length;

      if (todayEmergencies.isNotEmpty) {
        _lastEmergency = todayEmergencies.first;
      }
    } catch (e) {
      debugPrint('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _navigateToEmergencyForm(String emergencyType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EmergencyFormScreen(
          preSelectedType: emergencyType,
        ),
      ),
    ).then((_) => _loadData());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo.png',
              width: 32,
              height: 32,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(Icons.medical_services, size: 32);
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'EC Saver 1122',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.primaryRed,
        foregroundColor: Colors.white,
      ),
      drawer: const DrawerMenu(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats Card
                    Card(
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStatItem(
                                    icon: Icons.today,
                                    label: 'Today',
                                    count: _todayCount,
                                    color: AppColors.primaryRed,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: _buildStatItem(
                                    icon: Icons.calendar_month,
                                    label: 'This Month',
                                    count: _monthCount,
                                    color: AppColors.secondaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Emergency Type Cards
                    const Text(
                      'Quick Entry',
                      style: AppTextStyles.subheading,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    const Text(
                      'Tap to record emergency',
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: AppSpacing.md),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.md,
                      crossAxisSpacing: AppSpacing.md,
                      children: [
                        _buildEmergencyTypeCard(
                          icon: Icons.two_wheeler,
                          label: 'Bike\nAccident',
                          color: AppColors.accidentOrange,
                          onTap: () => _navigateToEmergencyForm(EmergencyType.bikeAccident),
                        ),
                        _buildEmergencyTypeCard(
                          icon: Icons.directions_car,
                          label: 'Car\nAccident',
                          color: AppColors.medicalBlue,
                          onTap: () => _navigateToEmergencyForm(EmergencyType.carAccident),
                        ),
                        _buildEmergencyTypeCard(
                          icon: Icons.local_fire_department,
                          label: 'Fire',
                          color: AppColors.fireRed,
                          onTap: () => _navigateToEmergencyForm(EmergencyType.fireEmergency),
                        ),
                        _buildEmergencyTypeCard(
                          icon: Icons.emergency,
                          label: 'Other',
                          color: AppColors.otherGrey,
                          onTap: () => _navigateToEmergencyForm(EmergencyType.otherEmergency),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // Last Emergency
                    if (_lastEmergency != null) ...[
                      const Text(
                        'Last Emergency',
                        style: AppTextStyles.subheading,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Card(
                        child: ListTile(
                          leading: const Icon(
                            Icons.access_time,
                            color: AppColors.primaryRed,
                          ),
                          title: Text('EC ${_lastEmergency!.ecNumber}'),
                          subtitle: Text(
                            _lastEmergency!.getFormattedDateTime(),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RecordsScreen(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const EmergencyFormScreen(),
            ),
          ).then((_) => _loadData());
        },
        backgroundColor: AppColors.primaryRed,
        icon: const Icon(Icons.add),
        label: const Text('Enter New Emergency'),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, size: 40, color: color),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '$count',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTextStyles.caption,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildEmergencyTypeCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 48, color: color),
              const SizedBox(height: AppSpacing.sm),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
