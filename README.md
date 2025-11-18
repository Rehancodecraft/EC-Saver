# Emergency Cases Saver - Rescue 1122 Punjab

Official emergency incident management system for Rescue 1122 Punjab personnel. This app helps field operators maintain accurate records of emergency responses offline.

## Features

- ✅ **100% Offline Operation** - Works completely offline with local SQLite database
- ✅ **One-Time Registration** - Register once with SMS OTP verification
- ✅ **Quick Emergency Entry** - Fast and easy emergency case recording
- ✅ **Month-wise Organization** - Records grouped by months for easy management
- ✅ **Search & Filter** - Find emergencies by EC number, type, location
- ✅ **Professional UI** - Clean, Material Design 3 interface
- ✅ **Export Reports** - Generate PDF reports (coming soon)
- ✅ **WhatsApp Integration** - Direct support contact

## Screenshots

[Add screenshots here]

## Installation

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (Android 5.0+)

### Setup

1. Clone the repository:
```bash
git clone <repository-url>
cd rescue_1122_emergency_app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build APK

To build a release APK:

```bash
flutter build apk --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user_profile.dart
│   ├── emergency.dart
│   └── monthly_stats.dart
├── screens/                  # UI screens
│   ├── splash_screen.dart
│   ├── registration_screen.dart
│   ├── home_screen.dart
│   ├── emergency_form_screen.dart
│   ├── records_screen.dart
│   ├── about_screen.dart
│   └── feedback_screen.dart
├── widgets/                  # Reusable widgets
│   ├── drawer_menu.dart
│   └── emergency_card.dart
├── services/                 # Business logic
│   └── database_service.dart
└── utils/                    # Utilities & constants
    ├── constants.dart
    └── districts_data.dart
```

## Database Schema

### user_profile
- id (PRIMARY KEY)
- full_name
- designation
- district
- tehsil
- mobile_number
- registration_date
- is_verified

### emergencies
- id (PRIMARY KEY)
- ec_number (UNIQUE)
- date_time
- emergency_type
- location (NULLABLE)
- notes (NULLABLE)
- is_late_entry
- created_at
- created_by (FOREIGN KEY)

### monthly_stats
- month_year (PRIMARY KEY)
- total_count
- bike_accident_count
- car_accident_count
- fire_count
- other_count

### feedback
- id (PRIMARY KEY)
- name
- message
- created_at

## Key Technologies

- **Flutter** - Cross-platform mobile framework
- **SQLite** - Local database storage
- **Provider** - State management
- **Material Design 3** - UI components
- **Intl** - Date/time formatting
- **URL Launcher** - WhatsApp integration

## Color Palette

- Primary Red: `#D32F2F` - Emergency red
- Secondary Green: `#388E3C` - Medical green
- Background White: `#FFFFFF`
- Text Dark: `#212121`
- Text Light: `#757575`
- Error Red: `#F44336`
- Success Green: `#4CAF50`

## Emergency Types

1. 🏍️ Bike Accident
2. 🚗 Car Accident
3. 🔥 Fire Emergency
4. 🚨 Other Emergency

## Supported Districts

All 36 districts of Punjab, Pakistan including:
- Lahore, Faisalabad, Rawalpindi, Multan, Gujranwala, Sialkot
- Bahawalpur, Sargodha, Sheikhupura, Jhang, Rahim Yar Khan
- And 25+ more districts with respective tehsils

## OTP Verification

For demo purposes, the OTP is always `123456`. In production, integrate with:
- Firebase Authentication
- Twilio SMS API
- Local SMS OTP services

## Future Enhancements

- [ ] PDF report generation with charts
- [ ] Data backup to cloud (optional)
- [ ] Statistics dashboard with trends
- [ ] Push notifications
- [ ] Multi-language support (English/Urdu)
- [ ] Dark mode
- [ ] Biometric authentication
- [ ] Export to Excel

## Support

For technical support or feature requests:

**Developer:** NexiVault Tech Solutions  
**Contact:** +92 324 4266595 (WhatsApp)  
**Email:** [Add email if available]

## License

© 2024 NexiVault Tech Solutions. All rights reserved.  
Designed for Rescue 1122 Punjab

## Version History

### v1.0.0 (Current)
- Initial release
- Core emergency recording functionality
- Month-wise record organization
- Search and filter capabilities
- WhatsApp support integration
- Complete offline operation

---

**Note:** This app is designed specifically for Rescue 1122 Punjab personnel and stores all data locally on the device for privacy and offline accessibility.
