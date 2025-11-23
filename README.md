# EC Saver - Emergency Cases Saver

**Official emergency incident management system for Rescue 1122 Pakistan personnel.**

A comprehensive mobile application designed to help rescuers maintain accurate records of emergency responses, manage professional records, and track off days, leaves, and gazetted holidays - all working completely offline.

## 📱 Features

### Core Functionality
- ✅ **100% Offline Operation** - Works completely offline with local SQLite database
- ✅ **One-Time Registration** - Register once with SMS OTP verification
- ✅ **Emergency Case Recording** - Fast and easy emergency case entry with EC numbers
- ✅ **Multiple Entries per Date** - Add multiple emergency cases on the same date
- ✅ **Off Days Management** - Track Day-offs, Leaves, and Gazetted Holidays
- ✅ **Future Date Planning** - Schedule leaves and holidays in advance (up to 1 year)
- ✅ **Month-wise Organization** - Records grouped by months for easy management
- ✅ **Search & Filter** - Find emergencies by EC number, type, or date
- ✅ **PDF Export** - Generate comprehensive PDF reports with user information and off days
- ✅ **Statistics Dashboard** - View today's entries, monthly totals, and leaves count
- ✅ **Auto-Update System** - Automatic update detection and installation
- ✅ **Professional UI** - Clean, Material Design 3 interface with Rescue 1122 branding

### Data Management
- ✅ **Local Storage** - All data stored locally on device (privacy-first)
- ✅ **Data Export** - Print/export records as PDF with complete information
- ✅ **Month Deletion** - Delete entire month's records (emergencies + off days)
- ✅ **Individual Deletion** - Delete specific emergency entries or off days
- ✅ **Data Protection** - Clear warnings about data loss on uninstall

## 🎯 Key Screens

1. **Splash Screen** - App initialization and update checking
2. **Registration Screen** - One-time user registration with OTP verification
3. **Home Screen** - Statistics overview (today's entries, monthly totals, leaves)
4. **Emergency Form Screen** - Add emergency cases, off days, leaves, or gazetted holidays
5. **Records Screen** - View all records organized by month with search and filter
6. **About Screen** - App information, version details, and important precautions
7. **Feedback Screen** - Submit feedback and contact support

## 📦 Installation

### Download APK

**Latest Release:** [Download v1.2.8](https://github.com/Rehancodecraft/EC-Saver/releases/latest)

Or visit the landing page: [EC Saver Landing Page](https://ec-saver.netlify.app) (if deployed)

### For Developers

#### Prerequisites
- Flutter SDK 3.24.5 or higher
- Dart SDK 3.0.0 or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (Android 5.0+ / API 21+)

#### Setup

1. **Clone the repository:**
```bash
git clone https://github.com/Rehancodecraft/EC-Saver.git
cd EC-Saver
```

2. **Install dependencies:**
```bash
flutter pub get
```

3. **Run the app:**
```bash
flutter run
```

#### Build APK

**Using script:**
```bash
./build_apk.sh
```

**Manual build:**
```bash
flutter build apk --release
```

The APK will be available at: `build/app/outputs/flutter-apk/app-release.apk`

## 🏗️ Project Structure

```
lib/
├── main.dart                 # App entry point and routing
├── models/                   # Data models
│   ├── user_profile.dart     # User profile model
│   ├── emergency.dart        # Emergency case model
│   ├── off_day.dart          # Off day/leave/holiday model
│   └── monthly_stats.dart    # Monthly statistics model
├── screens/                  # UI screens
│   ├── splash_screen.dart    # Splash and update check
│   ├── registration_screen.dart  # User registration
│   ├── home_screen.dart      # Statistics dashboard
│   ├── emergency_form_screen.dart  # Add entries
│   ├── records_screen.dart   # View all records
│   ├── about_screen.dart     # App information
│   └── feedback_screen.dart  # Feedback form
├── widgets/                  # Reusable widgets
│   ├── drawer_menu.dart      # Navigation drawer
│   ├── emergency_card.dart   # Emergency entry card
│   └── update_dialog.dart    # Update prompt dialog
├── services/                 # Business logic
│   ├── database_service.dart # SQLite database operations
│   ├── pdf_service.dart      # PDF generation
│   ├── update_service.dart   # App update management
│   └── supabase_service.dart # Supabase integration (optional)
└── utils/                    # Utilities & constants
    ├── constants.dart        # App constants and colors
    └── districts_data.dart   # District and tehsil data
```

## 🗄️ Database Schema

### user_profile
- `id` (PRIMARY KEY)
- `full_name` - Rescuer's full name
- `designation` - Job designation
- `district` - District name
- `tehsil` - Tehsil name
- `mobile_number` - Phone number
- `registration_date` - Registration timestamp
- `is_verified` - Verification status

### emergencies
- `id` (PRIMARY KEY)
- `ec_number` - Emergency case number
- `emergency_date` - Date and time of emergency
- `emergency_type` - Type of emergency (max 2 words, 20 chars)
- `location` (NULLABLE) - Location details
- `notes` (NULLABLE) - Additional notes (max 500 chars)
- `is_late_entry` - Whether entry was made after the date
- `created_at` - Entry creation timestamp
- `created_by` (NULLABLE) - User ID who created entry

### off_days
- `id` (PRIMARY KEY)
- `off_date` - Date of off day/leave/holiday
- `notes` - Type and description (e.g., "Leave - Personal", "Gazetted Holiday - Eid")
- `created_at` - Entry creation timestamp

### monthly_stats
- `month_year` (PRIMARY KEY) - Format: "MMMM yyyy"
- `total_count` - Total emergencies in month
- `bike_accident_count` - Bike accidents count
- `car_accident_count` - Car accidents count
- `fire_count` - Fire emergencies count
- `other_count` - Other emergencies count

### feedback
- `id` (PRIMARY KEY)
- `name` - Feedback submitter name
- `message` - Feedback message
- `created_at` - Submission timestamp

## 🎨 Design System

### Color Palette
- **Primary Red:** `#D32F2F` - Emergency red (Rescue 1122 branding)
- **Secondary Green:** `#388E3C` - Medical green
- **Orange:** `#FF9800` - Leaves/off days indicator
- **Blue:** `#2196F3` - Date display
- **Background:** `#FFFFFF` - White
- **Text Dark:** `#212121`
- **Text Light:** `#757575`
- **Error Red:** `#F44336`
- **Success Green:** `#4CAF50`

### Typography
- **Headings:** Bold, 18-24px
- **Body:** Regular, 14-16px
- **Labels:** Medium weight, 12-15px
- **Small text:** Regular, 10-12px

## 📋 Entry Types

### Emergency Entry
- Requires EC number
- Requires emergency type (max 2 words, 20 characters)
- Optional notes (max 500 characters)
- Cannot be added on off days
- Multiple entries allowed per date
- Future dates disabled

### Day-off
- No EC number required
- Optional notes
- Can be scheduled for future dates
- Cannot be added if date has emergency entries

### Leave
- No EC number required
- Optional notes
- Can be scheduled for future dates
- Cannot be added if date has emergency entries
- Counted in "Leaves" statistics

### Gazetted Holiday
- No EC number required
- Optional notes
- Can be scheduled for future dates
- Cannot be added if date has emergency entries
- Counted in "Leaves" statistics

## 📊 Statistics

The home screen displays:
- **Today's Entries** - Total emergency cases for today
- **This Month's Entries** - Total emergency entries for current month
- **This Month's Leaves** - Total leaves and gazetted holidays (excludes day-offs)

## 📄 PDF Export

PDF reports include:
- **User Information Section:**
  - Name, Phone Number
  - Designation, District, Tehsil
- **Emergency Records Table:**
  - EC Number, Date, Type
  - Organized by month
- **Off Days Section:**
  - All leaves, gazetted holidays, and day-offs
  - Dates and types clearly labeled

## 🔄 Update System

- **Automatic Detection** - Checks for updates on app launch
- **Version Comparison** - Compares installed version with latest GitHub release
- **Download & Install** - Automatic APK download and installation
- **Retry Logic** - 3 attempts with exponential backoff on connection failures
- **FileProvider Integration** - Secure APK installation
- **Version Display** - Shows current and latest versions in About screen

## 🌐 Supported Districts

All **46 districts** of Punjab, Pakistan including:
- Lahore, Faisalabad, Rawalpindi, Multan, Gujranwala, Sialkot
- Bahawalpur, Sargodha, Sheikhupura, Jhang, Rahim Yar Khan
- And 40+ more districts with respective tehsils

## 🔐 Privacy & Security

- **100% Local Storage** - All data stored on device
- **No Cloud Sync** - No data sent to external servers
- **Offline First** - Works without internet connection
- **Data Ownership** - User has complete control over their data

## ⚠️ Important Precautions

**Data Loss Warning:**
- If you uninstall this app, **all your data will be permanently lost**
- NexiVault will not be responsible for any data loss
- **Always print/export your records before uninstalling**

## 🛠️ Technologies Used

- **Flutter 3.24.5** - Cross-platform mobile framework
- **Dart 3.0+** - Programming language
- **SQLite (sqflite)** - Local database storage
- **PDF (printing)** - PDF generation and printing
- **Package Info Plus** - App version information
- **HTTP** - GitHub API integration for updates
- **Path Provider** - File system access
- **Permission Handler** - Android permissions
- **URL Launcher** - External links and WhatsApp
- **Intl** - Date/time formatting and localization

## 📱 Platform Support

- **Android:** 5.0+ (API 21+)
- **Minimum SDK:** 21
- **Target SDK:** 36
- **Compile SDK:** 36

## 🚀 Deployment

### GitHub Releases
- Automatic APK builds via GitHub Actions
- Tag-based releases (e.g., `v1.2.8`)
- APK automatically attached to releases

### Landing Page
- Netlify deployment folder: `netlify-deploy/`
- Automatic version detection from GitHub
- Direct APK download without redirects

## 📝 Version History

### v1.2.8 (Current)
- Enhanced home screen with larger, readable text
- Fixed leaves counter (counts only leaves + gazetted holidays)
- PDF includes user information and off days
- Added precautions section in About screen
- Improved professional design

### v1.2.7
- Allow future dates for off days/leaves/gazetted holidays
- Emergency entries remain restricted to past/today

### v1.2.6
- Fixed off days counter to show all off days
- Further reduced card sizes
- Changed icons for better appearance

### v1.2.5
- Fixed date display format
- Reduced card sizes
- Improved layout hierarchy

### v1.2.4
- Added current month and date display
- Added leaves count for current month
- Enhanced statistics dashboard

### v1.2.3
- Allow multiple emergency entries on same date
- Improved records display

### v1.2.2
- Test release for update system

### v1.2.1
- Fixed "APP not installed" error
- Added package installer queries
- Enhanced APK verification
- Improved error handling

### v1.2.0
- Test release for update system

### v1.1.9
- Fixed FileProvider path mismatch
- Changed to cache directory for APK storage

### v1.1.8
- Test release

### v1.1.7
- Added retry logic for downloads
- Improved connection handling
- Better error messages

### v1.1.6
- Test release

### v1.1.5
- Improved off days display in records
- Specific labels (Leave, Gazetted Holiday, Day-off)
- Delete button for individual off days
- Off days deleted with month records

### v1.1.4
- Changed "Gazetted Day" to "Gazetted Holiday"
- Changed "Off-Day" to "Day-off"

### v1.1.3
- Fixed update detection and installation

### v1.1.2
- Rebuild for testing

### v1.1.1
- Removed "Check for Updates" button
- Improved version management

### v1.1.0
- Integrated off days feature into emergency form
- Removed separate off days screen
- Enhanced records display

### v1.0.9
- Initial stable release
- Core emergency recording functionality
- Month-wise record organization
- Search and filter capabilities

## 🤝 Support

**Developer:** NexiVault  
**Contact:** +92 324 4266595 (WhatsApp)  
**Website:** https://nexivault.dev  
**GitHub:** https://github.com/Rehancodecraft/EC-Saver

## 📄 License

© 2025 NexiVault. All rights reserved.  
Designed specifically for Rescue 1122 Pakistan personnel.

## 🔗 Links

- **GitHub Repository:** https://github.com/Rehancodecraft/EC-Saver
- **Latest Releases:** https://github.com/Rehancodecraft/EC-Saver/releases
- **Landing Page:** https://ec-saver.netlify.app (if deployed)

---

**Note:** This app is designed specifically for Rescue 1122 Pakistan personnel and stores all data locally on the device for privacy and offline accessibility. Always backup your data by printing PDF reports before uninstalling.
