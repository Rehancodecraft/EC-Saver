# Getting Started - Emergency Cases Saver

## 🚀 Quick Start Guide

Welcome! This guide will get you up and running with the Emergency Cases Saver app in just a few minutes.

---

## ⚡ 60-Second Setup

```bash
# 1. Navigate to project
cd ~/Workspace/rescue_1122_emergency_app

# 2. Add the Rescue 1122 logo
# Place your logo.png file in: assets/images/logo.png

# 3. Install dependencies
flutter pub get

# 4. Run the app
./start.sh
# Or: flutter run
```

---

## 📋 Prerequisites

Make sure you have:

- [x] **Flutter SDK** installed (3.0.0+)
- [x] **Android Studio** or **VS Code** with Flutter extension
- [x] **Android device** or emulator connected
- [x] **Rescue 1122 logo** image ready

**Check Flutter installation:**
```bash
flutter doctor
```

---

## 📁 Project Structure Overview

```
rescue_1122_emergency_app/
├── 📱 lib/                    # Application code
│   ├── main.dart              # App entry point
│   ├── models/                # Data models
│   ├── screens/               # 7 app screens
│   ├── widgets/               # Reusable components
│   ├── services/              # Database logic
│   └── utils/                 # Constants & data
│
├── 🎨 assets/                 # Images & resources
│   └── images/                # Logo goes here!
│
├── 🤖 android/                # Android configuration
│
├── 📚 Documentation/
│   ├── README.md              # Overview
│   ├── SETUP_GUIDE.md         # Detailed setup
│   ├── BUILD_INSTRUCTIONS.md  # How to build APK
│   ├── API_DOCUMENTATION.md   # Database API
│   ├── LOGO_INSTRUCTIONS.md   # Logo setup
│   └── PROJECT_SUMMARY.md     # Complete overview
│
└── ⚙️ Configuration files
    ├── pubspec.yaml           # Dependencies
    ├── start.sh               # Quick start script
    └── analysis_options.yaml  # Code quality rules
```

---

## 🎯 First Things First

### 1. Add the Logo

**CRITICAL:** The app needs the Rescue 1122 logo!

```bash
# Copy your logo to:
cp /path/to/your/logo.png assets/images/logo.png
```

**Logo requirements:**
- Format: PNG
- Size: 512x512px minimum
- Square (1:1 aspect ratio)

**See detailed instructions:** `LOGO_INSTRUCTIONS.md`

---

### 2. Install Dependencies

```bash
flutter pub get
```

This downloads all required packages (~15 dependencies).

---

### 3. Run the App

**Option A: Use the start script** (Recommended)
```bash
./start.sh
```

Choose option 1 to run on your device.

**Option B: Manual command**
```bash
flutter run
```

**Option C: VS Code**
- Open project in VS Code
- Press `F5`

**Option D: Android Studio**
- Open project
- Click Run button (▶️)

---

## 📱 Testing the App

### 1. Registration Flow

When you first launch the app:

1. **Splash Screen** (3 seconds with logo)
2. **Registration Screen** appears
3. Fill in the form:
   - **Name:** Test User
   - **Designation:** Rescue Officer
   - **District:** Lahore
   - **Tehsil:** Lahore City
   - **Mobile:** 03001234567
4. Click "Send OTP"
5. Enter OTP: **123456** (demo OTP)
6. Click "Verify & Register"
7. Success! You're in!

---

### 2. Record an Emergency

1. From **Home Screen**, tap "Enter New Emergency"
2. Fill the form:
   - **EC Number:** 000001
   - **Date/Time:** (auto-filled, or pick)
   - **Type:** Select "Car Accident"
   - **Location:** Main Boulevard, Lahore (optional)
   - **Notes:** Test emergency record (optional)
3. Click "Save Emergency"
4. See success message
5. Navigate to **Records** to view

---

### 3. Explore Features

**Home Screen:**
- View today's & month's stats
- Quick emergency entry
- Emergency type icons

**Records Screen:**
- Search emergencies
- Filter by type
- View month-wise
- Delete month records

**About Screen:**
- App information
- Features list
- Developer details

**Feedback Screen:**
- WhatsApp contact button
- Submit feedback form

---

## 🔧 Development Mode

### Hot Reload

While app is running:
- **Press 'r'** in terminal → Hot reload
- **Press 'R'** in terminal → Hot restart
- **Press 'q'** → Quit

### Debug vs Release

**Debug Mode** (for development):
```bash
flutter run
# or
flutter run --debug
```

**Release Mode** (for testing performance):
```bash
flutter run --release
```

---

## 🏗️ Building APK

### Quick Build

```bash
./start.sh
# Select option 2
```

Or manually:
```bash
flutter build apk --release
```

**Output location:**
```
build/app/outputs/flutter-apk/app-release.apk
```

**See detailed instructions:** `BUILD_INSTRUCTIONS.md`

---

## 📚 Documentation Guide

Here's what to read and when:

### Start Here (You are here!)
- **GETTING_STARTED.md** ← Quick overview
- **README.md** ← Project overview

### When Setting Up
- **SETUP_GUIDE.md** ← Detailed installation
- **LOGO_INSTRUCTIONS.md** ← How to add logo

### When Developing
- **API_DOCUMENTATION.md** ← Database methods
- **PROJECT_SUMMARY.md** ← Complete project info

### When Building
- **BUILD_INSTRUCTIONS.md** ← How to create APK

---

## 🎨 Customization Quick Tips

### Change App Name

Edit `android/app/src/main/AndroidManifest.xml`:
```xml
<application android:label="Your App Name">
```

### Change Colors

Edit `lib/utils/constants.dart`:
```dart
class AppColors {
  static const Color primaryRed = Color(0xFFD32F2F);
  // Change colors here
}
```

### Add New District

Edit `lib/utils/districts_data.dart`:
```dart
const Map<String, List<String>> districtsData = {
  "Your District": ["Tehsil 1", "Tehsil 2"],
  // Add more...
}
```

---

## ❓ Troubleshooting

### "Flutter SDK not found"
```bash
# Add to PATH
export PATH="$PATH:/path/to/flutter/bin"
```

### "Unable to load asset: logo.png"
```bash
# Verify logo exists
ls assets/images/logo.png

# Refresh
flutter pub get
flutter run
```

### "Gradle build failed"
```bash
flutter clean
flutter pub get
flutter run
```

### App crashes on launch
```bash
# Uninstall completely
adb uninstall com.nexivault.emergency_cases_saver

# Reinstall
flutter run
```

---

## 📊 App Features Overview

| Feature | Description |
|---------|-------------|
| **Offline Mode** | Works 100% without internet |
| **Registration** | One-time setup with OTP |
| **Quick Entry** | Fast emergency recording |
| **Search** | Find by EC, location, notes |
| **Filter** | By emergency type |
| **Month View** | Organized by months |
| **Delete** | Month-wise deletion |
| **WhatsApp** | Direct support contact |
| **Statistics** | Today & month counts |
| **Professional UI** | Material Design 3 |

---

## 🎯 Next Steps

After getting the app running:

1. ✅ **Test all features** thoroughly
2. ✅ **Add actual logo** (if using placeholder)
3. ✅ **Customize** if needed
4. ✅ **Build APK** for distribution
5. ✅ **Share with users**
6. ✅ **Gather feedback**

---

## 📞 Need Help?

**Developer Contact:**
- WhatsApp: +92 324 4266595
- Company: NexiVault Tech Solutions

**Resources:**
- Flutter Docs: https://flutter.dev/docs
- Project Issues: [If GitHub repo exists]

---

## ✅ Checklist

Before considering setup complete:

- [ ] Flutter installed and working
- [ ] Project dependencies installed
- [ ] Rescue 1122 logo added
- [ ] App runs on device/emulator
- [ ] Registration flow tested
- [ ] Emergency entry tested
- [ ] All screens explored
- [ ] Documentation read
- [ ] Ready to build APK

---

## 🚀 You're Ready!

The app is now set up and ready to use. Here's what you can do:

**For Development:**
```bash
flutter run                    # Run in debug mode
flutter analyze                # Check code quality
flutter test                   # Run tests (if any)
```

**For Deployment:**
```bash
./start.sh                     # Interactive menu
# Or:
flutter build apk --release    # Build APK
```

**For More Info:**
- Read `SETUP_GUIDE.md` for detailed setup
- Read `BUILD_INSTRUCTIONS.md` for APK building
- Read `API_DOCUMENTATION.md` for database API
- Read `PROJECT_SUMMARY.md` for overview

---

**Happy coding! 🎉**

---

*This is a production-ready Flutter app for Rescue 1122 Punjab emergency management.*
