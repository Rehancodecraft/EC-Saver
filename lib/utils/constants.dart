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
  static const Color primaryRed = Color(0xFFD32F2F);       // Rescue 1122 Red
  static const Color secondaryGreen = Color(0xFF388E3C);   // Success Green
  static const Color medicalBlue = Color(0xFF2196F3);      // Medical Blue
  static const Color accidentOrange = Color(0xFFFF9800);   // Accident Orange
  static const Color fireRed = Color(0xFFD32F2F);          // Fire Red
  static const Color otherGrey = Color(0xFF9E9E9E);        // Other Grey
  static const Color lateEntryOrange = Color(0xFFFF6F00);  // Late Entry
  
  // Add missing colors
  static const Color textDark = Color(0xFF212121);
  static const Color textLight = Color(0xFF757575);
  static const Color errorRed = Color(0xFFD32F2F);
  static const Color successGreen = Color(0xFF388E3C);
  static const Color cardBackground = Color(0xFFF5F5F5);
  static const Color dividerColor = Color(0xFFE0E0E0);
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
    'LTV',
    'FDR',
    'EMT',
    'JCO',
    'S.I',
    'SC',
    'RSO',
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

class SupabaseConfig {
  static const String supabaseUrl = 'YOUR_SUPABASE_URL_HERE';
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY_HERE';
}

class Districts {
  static const Map<String, List<String>> districtTehsils = {
    "Attock": [
      "Attock",
      "Fateh Jang",
      "Hassan Abdal",
      "Hazro",
      "Jand",
      "Pindi Gheb"
    ],
    "Bahawalnagar": [
      "Bahawalnagar",
      "Chishtian",
      "Fort Abbas",
      "Haroonabad",
      "Minchinabad"
    ],
    "Bahawalpur": [
      "Ahmadpur East",
      "Bahawalpur City",
      "Bahawalpur Saddar",
      "Hasilpur",
      "Khairpur Tamewali",
      "Yazman"
    ],
    "Bhakkar": [
      "Bhakkar",
      "Darya Khan",
      "Kaloorkot",
      "Mankera"
    ],
    "Chakwal": [
      "Chakwal",
      "Choa Saidan Shah",
      "Kallar Kahar"
    ],
    "Chiniot": [
      "Bhawana",
      "Chiniot",
      "Lalian"
    ],
    "Dera Ghazi Khan": [
      "De-Excluded Area D.G. Khan",
      "Dera Ghazi Khan",
      "Kot Chutta"
    ],
    "Faisalabad": [
      "Chak Jhumra",
      "Faisalabad City",
      "Faisalabad Saddar",
      "Jaranwala",
      "Samundri",
      "Tandlianwala"
    ],
    "Gujranwala": [
      "Gujranwala City",
      "Gujranwala Sadar",
      "Kamoke",
      "Naushera Virkan"
    ],
    "Gujrat": [
      "Gujrat",
      "Jalalpur Jattan",
      "Kharian",
      "Khunjah",
      "Sarai Alamgir"
    ],
    "Hafizabad": [
      "Hafizabad",
      "Pindi Bhattian"
    ],
    "Jhang": [
      "Ahmadpur Sial",
      "Athara Hazari",
      "Jhang",
      "Shorkot"
    ],
    "Jhelum": [
      "Dina",
      "Jhelum",
      "Pind Dadan Khan",
      "Sohawa"
    ],
    "Kasur": [
      "Chunian",
      "Kasur",
      "Kot Radha Kishan",
      "Pattoki"
    ],
    "Khanewal": [
      "Jahanian",
      "Kabirwala",
      "Khanewal",
      "Mian Channu"
    ],
    "Khushab": [
      "Khushab",
      "Noorpur Thal",
      "Quaidabad"
    ],
    "Kot Addu": [
      "Chowk Sarwar Shaheed",
      "Kot Addu"
    ],
    "Lahore": [
      "Allama Iqbal",
      "Lahore Cantt",
      "Lahore City",
      "Model Town",
      "Nishtar",
      "Raiwind",
      "Ravi",
      "Saddar",
      "Shalimar",
      "Wahga"
    ],
    "Layyah": [
      "Chaubara",
      "Karor Lal Esan",
      "Layyah"
    ],
    "Lodhran": [
      "Dunyapur",
      "Kahror Pacca",
      "Lodhran"
    ],
    "Mandi Bahauddin": [
      "Malakwal",
      "Mandi Bahauddin",
      "Phalia"
    ],
    "Mianwali": [
      "Isakhel",
      "Mianwali",
      "Piplan"
    ],
    "Multan": [
      "Jalalpur Pirwala",
      "Multan City",
      "Multan Saddar",
      "Shujabad"
    ],
    "Murree": [
      "Kotli Sattian",
      "Murree"
    ],
    "Muzaffargarh": [
      "Alipur",
      "Jatoi",
      "Muzaffargarh"
    ],
    "Nankana Sahib": [
      "Nankana Sahib",
      "Sangla Hill",
      "Shahkot"
    ],
    "Narowal": [
      "Narowal",
      "Shakargarh",
      "Zafarwal"
    ],
    "Okara": [
      "Depalpur",
      "Okara",
      "Renala Khurd"
    ],
    "Rahim Yar Khan": [
      "Khanpur",
      "Liaquatpur",
      "Rahim Yar Khan",
      "Sadiqabad"
    ],
    "Rajanpur": [
      "De-Excluded Area Rajanpur",
      "Jampur",
      "Rajanpur",
      "Rojhan"
    ],
    "Rawalpindi": [
      "Gujar Khan",
      "Kahuta",
      "Kallar Syedan",
      "Rawalpindi Cantt",
      "Rawalpindi City",
      "Rawalpindi Saddar",
      "Taxila"
    ],
    "Sahiwal": [
      "Chichawatni",
      "Sahiwal"
    ],
    "Sargodha": [
      "Bhalwal",
      "Bhera",
      "Kot Momin",
      "Sahiwal (Sargodha Dist)",
      "Sargodha",
      "Shahpur",
      "Sillanwali"
    ],
    "Sheikhupura": [
      "Ferozwala",
      "Muridke",
      "Safdarabad",
      "Sharaqpur",
      "Sheikhupura"
    ],
    "Sialkot": [
      "Daska",
      "Pasrur",
      "Sambrial",
      "Sialkot"
    ],
    "Talagang": [
      "Lawa",
      "Talagang"
    ],
    "Taunsa": [
      "Koh-e-Suleman",
      "Taunsa",
      "Wahova"
    ],
    "Toba Tek Singh": [
      "Gojra",
      "Kamalia",
      "Pirmahal",
      "Toba Tek Singh"
    ],
    "Vehari": [
      "Burewala",
      "Mailsi",
      "Vehari"
    ],
    "Wazirabad": [
      "Alipur Chatha",
      "Wazirabad"
    ]
  };

  static List<String> getAllDistricts() {
    return districtTehsils.keys.toList();
  }

  static List<String> getTehsilsByDistrict(String district) {
    return districtTehsils[district] ?? [];
  }
}
