import 'package:flutter/material.dart';

// App Information
class AppInfo {
  static const String appName = 'Emergency Cases Saver';
  static const String version = '1.0.0';
  static const String developerName = 'NexiVault Tech Solutions';
  static const String developerPhone = '+92 324 4266595';
  static const String copyright = '© 2024 NexiVault Tech Solutions. All rights reserved.';
  static const String tagline = 'Designed for Rescue 1122 Punjab';
}

// Color Palette
class AppColors {
  static const Color primaryRed = Color(0xFFD32F2F);
  static const Color secondaryGreen = Color(0xFF388E3C);
  static const Color backgroundWhite = Color(0xFFFFFFFF);
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color errorRed = Color(0xFFF44336);
  static const Color successGreen = Color(0xFF4CAF50);
  static const Color cardBackground = Color(0xFFFAFAFA);
  static const Color dividerColor = Color(0xFFE0E0E0);
  
  // Emergency Type Colors
  static const Color medicalBlue = Color(0xFF2196F3);
  static const Color accidentOrange = Color(0xFFFF9800);
  static const Color fireRed = Color(0xFFD32F2F);
  static const Color otherGrey = Color(0xFF9E9E9E);
}

// Text Styles
class AppTextStyles {
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );
  
  static const TextStyle bodyLight = TextStyle(
    fontSize: 16,
    color: AppColors.textLight,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textLight,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
}

// Spacing
class AppSpacing {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

// Border Radius
class AppRadius {
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

// Emergency Types
class EmergencyType {
  static const String bikeAccident = 'Bike Accident';
  static const String carAccident = 'Car Accident';
  static const String fireEmergency = 'Fire Emergency';
  static const String otherEmergency = 'Other Emergency';
  
  static List<String> getAll() {
    return [bikeAccident, carAccident, fireEmergency, otherEmergency];
  }
  
  static IconData getIcon(String type) {
    switch (type) {
      case bikeAccident:
        return Icons.two_wheeler;
      case carAccident:
        return Icons.directions_car;
      case fireEmergency:
        return Icons.local_fire_department;
      case otherEmergency:
        return Icons.emergency;
      default:
        return Icons.help_outline;
    }
  }
  
  static Color getColor(String type) {
    switch (type) {
      case bikeAccident:
      case carAccident:
        return AppColors.accidentOrange;
      case fireEmergency:
        return AppColors.fireRed;
      case otherEmergency:
        return AppColors.otherGrey;
      default:
        return AppColors.otherGrey;
    }
  }
}

// Designations - KEEP ONLY NEW 7 OPTIONS WITH EMT
class Designations {
  static const List<String> all = [
    'LTV (Light Transport Vehicle Driver)',
    'FDR (First Data Responder)',
    'EMT (Emergency Medical Technician)',
    'JCO (Junior Commissioned Officer)',
    'S.I (Sub Inspector)',
    'SC (Station Commander)',
    'RSO (Rescue Service Officer)',
  ];
}

// Animation Durations
class AppDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
}

// Database Constants
class DatabaseConstants {
  static const String databaseName = 'rescue_1122.db';
  static const int databaseVersion = 1;
  
  // Table Names
  static const String userProfileTable = 'user_profile';
  static const String emergenciesTable = 'emergencies';
  static const String monthlyStatsTable = 'monthly_stats';
  static const String feedbackTable = 'feedback';
}

// Validation Constants
class ValidationConstants {
  static const int ecNumberLength = 6;
  static const int minNameLength = 3;
  static const int maxNameLength = 50;
  static const int mobileNumberLength = 11;
  static const int otpLength = 6;
  static const int maxLocationLength = 200;
  static const int maxNotesLength = 500;
  static const int otpTimeoutSeconds = 60;
}
