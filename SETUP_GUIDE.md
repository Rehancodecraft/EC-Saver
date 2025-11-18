# Setup Guide - Emergency Cases Saver

## Complete Installation & Setup Instructions

### Prerequisites

Before you begin, ensure you have the following installed:

1. **Flutter SDK** (3.0.0 or higher)
   - Download from: https://flutter.dev/docs/get-started/install
   - Add Flutter to your PATH

2. **Android Studio** or **VS Code**
   - Android Studio: https://developer.android.com/studio
   - VS Code with Flutter extension: https://code.visualstudio.com/

3. **Android SDK**
   - Minimum SDK: API 21 (Android 5.0)
   - Target SDK: API 34 (Android 14)

4. **Git** (for version control)
   - Download from: https://git-scm.com/

### Step-by-Step Setup

#### 1. Clone the Project

```bash
cd ~/Workspace
git clone <repository-url>
cd rescue_1122_emergency_app
```

Or if starting fresh in the existing directory:
```bash
cd ~/Workspace/rescue_1122_emergency_app
```

#### 2. Install Flutter Dependencies

```bash
flutter pub get
```

This will download all required packages listed in `pubspec.yaml`.

#### 3. Add the Rescue 1122 Logo

**IMPORTANT:** You need to add the Rescue 1122 logo image:

1. Save the logo image as: `assets/images/logo.png`
2. Recommended size: 512x512 pixels
3. Format: PNG with transparent background (preferred)

**Logo Requirements:**
- Square aspect ratio (1:1)
- High resolution (at least 512x512px)
- PNG format
- Transparent or white background

If you don't have the logo yet, you can use a placeholder:
```bash
# Create a placeholder (for development only)
# In production, replace with actual Rescue 1122 logo
```

#### 4. Verify Flutter Installation

```bash
flutter doctor -v
```

Fix any issues reported by Flutter Doctor before proceeding.

#### 5. Connect Device or Start Emulator

**Option A: Physical Device**
- Enable Developer Mode on your Android device
- Enable USB Debugging
- Connect via USB cable
- Verify with: `flutter devices`

**Option B: Android Emulator**
- Open Android Studio
- Go to: Tools > Device Manager
- Create a new Virtual Device (recommended: Pixel 5, API 34)
- Start the emulator
- Verify with: `flutter devices`

#### 6. Run the App

**Using the start script (Recommended):**
```bash
./start.sh
```

**Or manually:**
```bash
# Debug mode
flutter run

# Release mode
flutter run --release
```

#### 7. Build APK for Distribution

```bash
# Build release APK
flutter build apk --release

# Build App Bundle (for Play Store)
flutter build appbundle --release
```

The APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Development Setup

#### VS Code Setup

1. Install extensions:
   - Flutter
   - Dart
   - Flutter Widget Snippets (optional)

2. Open the project:
   ```bash
   code ~/Workspace/rescue_1122_emergency_app
   ```

3. Press `F5` to run in debug mode

#### Android Studio Setup

1. Open Android Studio
2. File > Open > Select project directory
3. Wait for Gradle sync to complete
4. Click Run (▶️) button

### Configuration Files

#### Important Files to Configure

1. **pubspec.yaml**
   - Contains all dependencies
   - Configure app name, version
   - Add assets paths

2. **AndroidManifest.xml**
   - Location: `android/app/src/main/AndroidManifest.xml`
   - App permissions
   - Package name

3. **build.gradle**
   - Location: `android/app/build.gradle`
   - App ID: `com.nexivault.emergency_cases_saver`
   - Version code and name

### Database Location

The SQLite database is stored locally on the device:

**Android:**
```
/data/data/com.nexivault.emergency_cases_saver/databases/rescue_1122.db
```

**Access via ADB:**
```bash
# Pull database from device
adb shell
cd /data/data/com.nexivault.emergency_cases_saver/databases/
cp rescue_1122.db /sdcard/
exit
adb pull /sdcard/rescue_1122.db
```

### Testing

#### Test Registration Flow

1. Launch app
2. Complete registration form:
   - Full Name: Test User
   - Designation: Rescue Officer
   - District: Lahore
   - Tehsil: Lahore City
   - Mobile: 03001234567
3. Enter OTP: `123456` (demo OTP)
4. Verify successful registration

#### Test Emergency Recording

1. From Home screen, tap "Enter New Emergency"
2. Fill in form:
   - EC Number: 000001
   - Date/Time: Current date and time
   - Type: Select any emergency type
   - Location (optional): Test location
   - Notes (optional): Test notes
3. Tap "Save Emergency"
4. Verify success message
5. Check Records screen to see the entry

### Troubleshooting

#### Common Issues

**1. "Flutter SDK not found"**
```bash
# Verify Flutter is in PATH
echo $PATH
# Add to PATH if needed
export PATH="$PATH:/path/to/flutter/bin"
```

**2. "Gradle build failed"**
```bash
# Clean and rebuild
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

**3. "Unable to load asset"**
- Verify logo exists at: `assets/images/logo.png`
- Run: `flutter pub get`
- Restart the app

**4. "Android licenses not accepted"**
```bash
flutter doctor --android-licenses
# Accept all licenses by typing 'y'
```

**5. "SQLite database errors"**
```bash
# Uninstall app completely
adb uninstall com.nexivault.emergency_cases_saver
# Reinstall
flutter run
```

#### Debug Mode Issues

If app crashes in debug mode:
1. Check terminal for error messages
2. Look for red error screens in app
3. Verify all dependencies are installed
4. Try running: `flutter clean && flutter pub get`

### Performance Optimization

#### Release Build Optimization

The app is configured for optimal performance:
- Minification: Disabled (for debugging)
- Obfuscation: Can be enabled for production
- Multi-dex: Enabled for large apps

To enable optimizations:
Edit `android/app/build.gradle`:
```gradle
buildTypes {
    release {
        minifyEnabled true
        shrinkResources true
        proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
    }
}
```

### Customization

#### Change App Name

1. Edit `pubspec.yaml`:
```yaml
name: your_app_name
```

2. Edit `android/app/src/main/AndroidManifest.xml`:
```xml
android:label="Your App Name"
```

#### Change Package Name

1. Edit `android/app/build.gradle`:
```gradle
defaultConfig {
    applicationId "com.yourcompany.yourapp"
}
```

2. Update folder structure:
```
android/app/src/main/kotlin/com/yourcompany/yourapp/
```

3. Update MainActivity.kt package declaration

#### Change Color Scheme

Edit `lib/utils/constants.dart`:
```dart
class AppColors {
  static const Color primaryRed = Color(0xFFD32F2F);
  // Modify colors here
}
```

### Production Checklist

Before releasing to production:

- [ ] Replace demo OTP with real SMS integration
- [ ] Add actual Rescue 1122 logo
- [ ] Test on multiple devices and Android versions
- [ ] Enable ProGuard/R8 for code obfuscation
- [ ] Sign APK with release keystore
- [ ] Test all features offline
- [ ] Verify database operations
- [ ] Test backup/restore functionality
- [ ] Review all permissions
- [ ] Update version number
- [ ] Create app screenshots
- [ ] Write release notes

### Getting Help

If you encounter issues:

1. Check this guide first
2. Review Flutter documentation: https://flutter.dev/docs
3. Check GitHub issues (if repository exists)
4. Contact developer: +92 324 4266595 (WhatsApp)

### Next Steps

After successful setup:

1. Familiarize yourself with the codebase
2. Review `lib/utils/constants.dart` for configuration
3. Test all features thoroughly
4. Customize as needed for your requirements
5. Build and distribute the APK

---

**Note:** This app is designed for offline use. No internet connection is required after installation.
