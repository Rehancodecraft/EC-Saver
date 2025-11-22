import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/emergency_form_screen.dart';
import 'screens/records_screen.dart';
import 'screens/about_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/off_days_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Supabase asynchronously (don't block startup)
  Supabase.initialize(
    url: 'https://ssddnidpcjcbajxyhjgg.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNzZGRuaWRwY2pjYmFqeHloamdnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjM0NTQ3MjksImV4cCI6MjA3OTAzMDcyOX0.UcAIUQB5cXnkX5Yc75qmcm_R8_-JdGB-qY6XrfiYbTU',
  ).catchError((e) {
    debugPrint('DEBUG: Supabase init error: $e');
    return Supabase.instance; // Return existing instance or handle error
  });
  
  runApp(const MyApp()); // Don't wait for Supabase
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EC Saver - Rescue 1122 Pakistan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryRed,
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(),
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white, // Add this - fixes all AppBar text/icons
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
          titleTextStyle: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          systemOverlayStyle: const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, // Global fix for all ElevatedButtons
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primaryRed,
          primary: AppColors.primaryRed,
          secondary: AppColors.secondaryGreen,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Custom page transitions
        Widget page;
        switch (settings.name) {
          case '/':
            page = const SplashScreen();
            break;
          case '/registration':
            page = const RegistrationScreen();
            break;
          case '/home':
            page = const HomeScreen();
            break;
          case '/add-emergency':
            page = const EmergencyFormScreen();
            break;
          case '/records':
            page = const RecordsScreen();
            break;
          case '/about':
            page = const AboutScreen();
            break;
          case '/feedback':
            page = const FeedbackScreen();
            break;
          case '/off-days':
            page = const OffDaysScreen();
            break;
          default:
            page = const SplashScreen();
        }

        // No transition for splash screen
        if (settings.name == '/') {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => page,
          );
        }

        // Custom transitions for all other pages
        return PageRouteBuilder(
          settings: settings,
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            const begin = Offset(1.0, 0.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return SlideTransition(
              position: animation.drive(tween),
              child: FadeTransition(
                opacity: animation,
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 300),
        );
      },
    );
  }
}
