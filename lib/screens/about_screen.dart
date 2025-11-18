import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Logo
            Container(
              width: 120,
              height: 120,
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Image.asset(
                'assets/images/logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

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
                          style: AppTextStyles.subheading,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const Text(
                      'Official emergency incident management system for Rescue 1122 Punjab personnel. '
                      'This app helps field operators maintain accurate records of emergency responses offline.',
                      style: AppTextStyles.body,
                      textAlign: TextAlign.justify,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Key Features
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.star, color: AppColors.secondaryGreen),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Key Features',
                          style: AppTextStyles.subheading,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    const _FeatureItem(
                      icon: Icons.offline_bolt,
                      title: 'Offline First',
                      description: 'Works 100% offline with local database',
                    ),
                    const _FeatureItem(
                      icon: Icons.emergency,
                      title: 'Quick Entry',
                      description: 'Fast emergency case recording',
                    ),
                    const _FeatureItem(
                      icon: Icons.folder,
                      title: 'Organized Records',
                      description: 'Month-wise grouping and easy search',
                    ),
                    const _FeatureItem(
                      icon: Icons.picture_as_pdf,
                      title: 'Export Reports',
                      description: 'Generate PDF reports for monthly data',
                    ),
                    const _FeatureItem(
                      icon: Icons.security,
                      title: 'Secure',
                      description: 'All data stored locally on device',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Developer Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.code, color: AppColors.primaryRed),
                        SizedBox(width: AppSpacing.sm),
                        Text(
                          'Developed By',
                          style: AppTextStyles.subheading,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            AppInfo.developerName,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            AppInfo.copyright,
                            style: AppTextStyles.caption,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            AppInfo.tagline,
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Rescue 1122 Badge
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryRed.withOpacity(0.1),
                    AppColors.secondaryGreen.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.local_hospital,
                    size: 40,
                    color: AppColors.primaryRed,
                  ),
                  SizedBox(height: AppSpacing.sm),
                  Text(
                    'Rescue 1122 Punjab',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                  Text(
                    'Emergency Services',
                    style: AppTextStyles.caption,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              color: AppColors.secondaryGreen.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 20,
              color: AppColors.secondaryGreen,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
