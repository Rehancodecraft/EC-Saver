import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/update_service.dart';
import '../widgets/update_dialog.dart';
import '../utils/constants.dart';
import 'registration_screen.dart';
import 'home_screen.dart';
import '../services/database_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<double> _scaleAnimation; // NEW: For zoom effect

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500), // Increased for smoother animation
      vsync: this,
    );

    // Existing fade animation
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // NEW: Scale/zoom animation
    _scaleAnimation = Tween<double>(
      begin: 0.5, // Start at 50% size
      end: 1.0,   // End at 100% size
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutBack, // Bounce effect
    ));

    _animationController.forward();
    _checkForUpdatesAndProceed();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdatesAndProceed() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    try {
      final pkg = await PackageInfo.fromPlatform();
      final currentVersion = pkg.version;
      final currentBuild = int.tryParse(pkg.buildNumber) ?? 1;
      final prefs = await SharedPreferences.getInstance();
      final lastAttempt = prefs.getString('dismissed_update_version');

      final updateInfo = await UpdateService.checkForUpdate();
      if (updateInfo['updateAvailable'] == true && mounted) {
        // Only skip if user dismissed this exact version/build
        if (lastAttempt == '${updateInfo['latestVersion']}-${updateInfo['latestBuild']}') {
          _checkRegistrationStatus();
          return;
        }
        showDialog(
          context: context,
          barrierDismissible: updateInfo['forceUpdate'] != true,
          builder: (context) => UpdateDialog(
            latestVersion: updateInfo['latestVersion'],
            latestBuild: updateInfo['latestBuild'],
            downloadUrl: updateInfo['downloadUrl'],
            releaseNotes: updateInfo['releaseNotes'],
            forceUpdate: updateInfo['forceUpdate'] ?? false,
          ),
        );
        return;
      }
    } catch (e) {
      print('DEBUG: Update check failed: $e');
    }
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    await Future.delayed(const Duration(milliseconds: 1000)); // Reduced from 1500

    if (!mounted) return;

    // On web, just go to registration
    if (kIsWeb) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const RegistrationScreen(),
        ),
      );
      return;
    }

    // On mobile, check registration status
    bool isRegistered = false;
    try {
      await DatabaseService().database;
      isRegistered = await DatabaseService().isUserRegistered();
    } catch (e) {
      debugPrint('Database initialization error: $e');
      isRegistered = false;
    }

    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => isRegistered
            ? const HomeScreen()
            : const RegistrationScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryRed,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo with fade and zoom animation
            FadeTransition(
              opacity: _animation,
              child: ScaleTransition( // NEW: Added zoom/scale animation
                scale: _scaleAnimation,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    'assets/image/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_hospital,
                        size: 80,
                        color: AppColors.primaryRed,
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // App Name
            FadeTransition(
              opacity: _animation,
              child: const Text(
                'EC Saver',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
              ),
            ),

            const SizedBox(height: 8),
            
            // Subtitle
            Text(
              'Emergency Cases Saver',
              style: TextStyle(
                fontSize: 16,
                color: Colors.white.withOpacity(0.9),
                letterSpacing: 1,
              ),
            ),
            
            const SizedBox(height: 4),
            
            // Rescue 1122 Pakistan
            Text(
              'Rescue 1122 Pakistan',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withOpacity(0.8),
              ),
            ),

            const SizedBox(height: 60),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ],
        ),
      ),
    );
  }
}
