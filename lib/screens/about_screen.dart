import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';
import '../widgets/drawer_menu.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      drawer: DrawerMenu(currentRoute: '/about'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Logo Section - Use actual Rescue 1122 logo
            Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(20),
              child: Image.asset(
                'assets/image/logo.png',
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback to icon if image not found
                  return const Icon(
                    Icons.local_hospital,
                    size: 100,
                    color: AppColors.primaryRed,
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // App Name
            const Text(
              AppInfo.appName,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Version
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: AppColors.primaryRed.withOpacity(0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                'Version ${AppInfo.version}',
                style: const TextStyle(
                  color: AppColors.primaryRed,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Description
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.info_outline, color: AppColors.primaryRed),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'About This App',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'This is free and private application specially designed for rescuers, allowing you to save your emergency numbers and access them instantly whenever needed. In addition, the app enables you to maintain and update your complete professional record in an organized way.',
                      style: TextStyle(
                        fontSize: 15,
                        height: 1.6,
                        color: Colors.black87,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Key Features
            const Text(
              'Key Features',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            // Feature 1
            _buildFeatureItem(
              Icons.save_outlined,
              'Save Emergency Cases',
              'Quick and easy emergency case recording',
              Colors.grey, // Changed from AppColors.secondaryGreen
            ),

            // Feature 2
            _buildFeatureItem(
              Icons.analytics_outlined,
              'Professional Records',
              'Maintain organized professional records',
              Colors.grey, // Changed from AppColors.medicalBlue
            ),

            // Feature 3
            _buildFeatureItem(
              Icons.security_outlined,
              'Private & Secure',
              'Your data stays on your device',
              Colors.grey, // Changed from AppColors.primaryRed
            ),

            // Feature 4
            _buildFeatureItem(
              Icons.location_city_outlined,
              'Multi-District Support',
              'Covers all 46 districts of Punjab',
              Colors.grey, // Changed from AppColors.accidentOrange
            ),

            const SizedBox(height: AppSpacing.md),

            // Developed By Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Developed By',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NexiVault',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '© ${DateTime.now().year} NexiVault. All rights reserved.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Website Link Button
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        final Uri url = Uri.parse('https://nexivault.dev');
                        if (!await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        )) {
                          throw Exception('Could not launch $url');
                        }
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open website: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.language, size: 18),
                    label: const Text('Visit Website'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[700],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
