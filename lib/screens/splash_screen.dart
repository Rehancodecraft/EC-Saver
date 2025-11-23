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

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotationAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<Offset> _textSlideAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _logoRotationAnimation = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: Curves.easeOut,
      ),
    );

    // Text animations
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _textFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
      ),
    );

    _textSlideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Pulse animation for background
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
      curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _logoController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _textController.forward();
    });

    _checkForUpdatesAndProceed();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkForUpdatesAndProceed() async {
    await Future.delayed(const Duration(milliseconds: 1500));
    try {
      // Force fresh read of PackageInfo to get latest installed version
      // This ensures we read the correct version after app update
      final pkg = await PackageInfo.fromPlatform();
      final currentVersion = pkg.version.trim();
      final currentBuild = int.tryParse(pkg.buildNumber.trim()) ?? 1;
      print('DEBUG: Splash - Current version: $currentVersion, build: $currentBuild');
      print('DEBUG: Splash - PackageInfo details:');
      print('  version: ${pkg.version}');
      print('  buildNumber: ${pkg.buildNumber}');
      print('  packageName: ${pkg.packageName}');

      final prefs = await SharedPreferences.getInstance();
      
      // Check if app version has changed (indicates update was installed)
      final lastKnownVersion = prefs.getString('last_known_app_version');
      final lastKnownBuild = prefs.getInt('last_known_app_build') ?? 0;
      final versionKey = '$currentVersion+$currentBuild';
      final lastVersionKey = lastKnownVersion != null ? '$lastKnownVersion+$lastKnownBuild' : null;
      
      print('DEBUG: Splash - Last known version: $lastVersionKey');
      print('DEBUG: Splash - Current version: $versionKey');
      
      // If version changed, clear dismissed updates and refresh everything
      if (lastVersionKey != null && lastVersionKey != versionKey) {
        print('DEBUG: Splash - App version changed! Clearing update dismissals...');
        await prefs.remove('dismissed_update_version');
        print('DEBUG: Splash - Cleared dismissed_update_version');
      }
      
      // Save current version for next launch
      await prefs.setString('last_known_app_version', currentVersion);
      await prefs.setInt('last_known_app_build', currentBuild);
      print('DEBUG: Splash - Saved current version: $versionKey');
      
      final dismissed = prefs.getString('dismissed_update_version');
      print('DEBUG: Splash - Dismissed version: $dismissed');

      final info = await UpdateService.checkForUpdate(currentVersion: currentVersion);
      print('DEBUG: Splash - Update info: $info');

      if (info['updateAvailable'] == true && (info['downloadUrl'] ?? '').toString().isNotEmpty && mounted) {
        // Check if this exact version was already dismissed
        final versionKey = '${info['latestVersion']}-${info['latestBuild']}';
        if (dismissed == versionKey) {
          print('DEBUG: Splash - Update already dismissed for $versionKey');
          _checkRegistrationStatus();
          return;
        }
        
        print('DEBUG: Splash - Showing update dialog for ${info['latestVersion']}');
        // Show dialog and continue after it's dismissed
        await showDialog(
          context: context,
          barrierDismissible: !(info['forceUpdate'] ?? false),
          builder: (context) => UpdateDialog(
            latestVersion: info['latestVersion'],
            latestBuild: info['latestBuild'] ?? 0,
            downloadUrl: info['downloadUrl'],
            releaseNotes: info['releaseNotes'],
            forceUpdate: info['forceUpdate'] ?? false,
          ),
        );
        
        // After dialog is dismissed (user clicked "Later" or closed it), continue to app
        print('DEBUG: Splash - Update dialog dismissed, continuing to app');
        if (mounted) {
          _checkRegistrationStatus();
        }
        return;
      }
      
      print('DEBUG: Splash - No update available or proceeding to registration');
    } catch (e, st) {
      print('DEBUG: Splash - Error: $e\n$st');
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryRed,
              AppColors.primaryRed.withOpacity(0.8),
              const Color(0xFFB71C1C),
            ],
          ),
        ),
        child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              // Logo with professional animations
              AnimatedBuilder(
                animation: _logoController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _logoFadeAnimation,
                    child: Transform.scale(
                      scale: _logoScaleAnimation.value,
                      child: Transform.rotate(
                        angle: _logoRotationAnimation.value,
                child: Container(
                          width: 160,
                          height: 160,
                  decoration: BoxDecoration(
                    color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                                blurRadius: 30,
                                spreadRadius: 5,
                                offset: const Offset(0, 15),
                              ),
                              BoxShadow(
                                color: Colors.white.withOpacity(0.2),
                        blurRadius: 20,
                                spreadRadius: -5,
                                offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                          padding: const EdgeInsets.all(24),
                  child: Image.asset(
                    'assets/image/logo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.local_hospital,
                                size: 90,
                        color: AppColors.primaryRed,
                      );
                    },
                  ),
                ),
              ),
            ),
                  );
                },
              ),

              const SizedBox(height: 40),

              // App Name with slide and fade
              SlideTransition(
                position: _textSlideAnimation,
                child: FadeTransition(
                  opacity: _textFadeAnimation,
              child: const Text(
                'EC Saver',
                style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                  color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
              
              // Subtitle with fade
              FadeTransition(
                opacity: _textFadeAnimation,
                child: Text(
                  'Emergency Cases Saver',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withOpacity(0.95),
                    letterSpacing: 1.5,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                ),
              ),
            ),

            const SizedBox(height: 8),
            
              // Rescue 1122 Pakistan with fade
              FadeTransition(
                opacity: _textFadeAnimation,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
              'Rescue 1122 Pakistan',
              style: TextStyle(
                fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withOpacity(0.95),
                      letterSpacing: 1,
                    ),
                  ),
              ),
            ),

              const SizedBox(height: 80),
              
              // Loading indicator with pulse
              FadeTransition(
                opacity: _textFadeAnimation,
                child: AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 3.5,
                        ),
                      ),
                    );
                  },
                ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
