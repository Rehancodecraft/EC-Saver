import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_config.dart';
import 'screens/splash_screen.dart';
import 'screens/home_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/emergency_form_screen.dart';
import 'screens/records_screen.dart';
import 'screens/about_screen.dart';
import 'screens/feedback_screen.dart';
import 'screens/bmi_calculator_screen.dart';
import 'utils/constants.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock app to portrait mode only for better UX
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Supabase for central user registry
  Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  ).catchError((e) {
    if (AppConfig.enableDebugLogs) {
      debugPrint('Supabase initialization error: $e');
    }
    return Supabase.instance;
  });
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EC Saver - Rescue 1122 Pakistan',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: AppColors.primaryRed,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Poppins', // <- Set the default font family
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryRed,
          foregroundColor: Colors.white, 
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
          titleTextStyle: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: Brightness.light,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white, 
            textStyle: const TextStyle(
              fontFamily: 'Poppins', // <- Consistent font family
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
          case '/bmi-calculator':
            page = const BMICalculatorScreen();
            break;
          default:
            page = const SplashScreen();
        }

        if (settings.name == '/') {
          return MaterialPageRoute(
            settings: settings,
            builder: (context) => page,
          );
        }

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
