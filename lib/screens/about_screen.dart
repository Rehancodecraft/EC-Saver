import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../widgets/drawer_menu.dart';
import '../utils/signature_info_helper.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> with SingleTickerProviderStateMixin {
  String _version = 'Loading...';
  String _buildNumber = '';
  String _latestVersion = '';
  bool _isCheckingUpdate = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _loadVersionInfo();
    _fetchLatestVersion();
    
    // Animation setup - optimized
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300), // Reduced from 800ms
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate( // Reduced scale
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut, // Simpler curve
      ),
    );
    
    _animationController.forward();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh version when screen becomes visible (after app update)
    _loadVersionInfo();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadVersionInfo() async {
    try {
      // Force fresh read - create new instance to avoid caching
      // This is critical after app updates
      final packageInfo = await PackageInfo.fromPlatform();
      
      // Debug logging to verify what we're reading
      debugPrint('DEBUG: About Screen - PackageInfo from installed app:');
      debugPrint('  version: ${packageInfo.version}');
      debugPrint('  buildNumber: ${packageInfo.buildNumber}');
      debugPrint('  appName: ${packageInfo.appName}');
      debugPrint('  packageName: ${packageInfo.packageName}');
      
      final newVersion = packageInfo.version.trim();
      final newBuild = packageInfo.buildNumber.trim();
      
      if (mounted) {
        setState(() {
          // PackageInfo reads from the actual installed app's AndroidManifest.xml
          // This should show the version that was used when the APK was built
          _version = newVersion;
          _buildNumber = newBuild;
        });
        
        // Verify what we set
        debugPrint('DEBUG: About Screen - Displaying version: $_version+$_buildNumber');
        
        // If version changed, refresh latest version from GitHub
        if (_latestVersion.isEmpty || _latestVersion != newVersion) {
          _fetchLatestVersion();
        }
      }
    } catch (e, stackTrace) {
      debugPrint('ERROR: About Screen - Failed to load version info: $e');
      debugPrint('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _version = 'Unknown';
          _buildNumber = '';
        });
      }
    }
  }

  Future<void> _fetchLatestVersion() async {
    if (_isCheckingUpdate) return;
    
    setState(() {
      _isCheckingUpdate = true;
    });

    try {
      final response = await http.get(
        Uri.parse('https://api.github.com/repos/Rehancodecraft/EC-Saver/releases/latest'),
        headers: {'Accept': 'application/vnd.github.v3+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final tagName = (data['tag_name'] ?? '').toString();
        // Remove 'v' prefix if present
        final version = tagName.replaceAll('v', '').trim();
        
        if (mounted) {
          setState(() {
            _latestVersion = version;
            _isCheckingUpdate = false;
          });
        }
      }
    } catch (e) {
      debugPrint('DEBUG: About Screen - Failed to fetch latest version: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCheckingUpdate = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      drawer: DrawerMenu(currentRoute: '/about'),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Logo Section - Use actual Rescue 1122 logo
            Container(
              width: 150,
              height: 150,
              padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
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

                // Version - Now dynamic with latest version from GitHub
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryRed.withOpacity(0.1),
                        AppColors.primaryRed.withOpacity(0.15),
                      ],
                    ),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: AppColors.primaryRed.withOpacity(0.3),
                      width: 1,
                    ),
              ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.primaryRed,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Version $_version${_buildNumber.isNotEmpty && _buildNumber != '0' ? '+$_buildNumber' : ''}',
                            style: const TextStyle(
                              color: AppColors.primaryRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          IconButton(
                            icon: _isCheckingUpdate
                                ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primaryRed,
                                    ),
                                  )
                                : const Icon(
                                    Icons.refresh,
                                    size: 16,
                                    color: AppColors.primaryRed,
                                  ),
                            onPressed: _isCheckingUpdate
                                ? null
                                : () {
                                    _loadVersionInfo();
                                    _fetchLatestVersion();
                                  },
                            tooltip: 'Refresh version',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.fingerprint,
                              size: 16,
                              color: AppColors.primaryRed,
                            ),
                            onPressed: () {
                              SignatureInfoHelper.showSignatureDialog(context);
                            },
                            tooltip: 'View signature info (for debugging)',
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                        ],
                      ),
                      if (_latestVersion.isNotEmpty && _latestVersion != _version) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Latest: v$_latestVersion',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 11,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
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

            // Precautions / Warning Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(color: Colors.red[300]!, width: 2),
              ),
              color: Colors.red[50],
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning_amber_rounded, color: Colors.red[700], size: 28),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Important Precautions',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '⚠️ Data Loss Warning',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.red[800],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'If you uninstall this app, all your data will be permanently lost. NexiVault will not be responsible for any data loss.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.5,
                              color: Colors.red[900],
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.orange[50],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.print, color: Colors.orange[800], size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Make sure to print all your entries before uninstalling the app.',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.orange[900],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
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
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () {},
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                color.withOpacity(0.2),
                                color.withOpacity(0.1),
                              ],
                            ),
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
                  ),
                ),
      ),
    );
  }
}
