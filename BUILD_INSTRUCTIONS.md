# Build Instructions - Emergency Cases Saver

## 🏗️ Building the APK for Distribution

This guide covers building a production-ready APK file for the Emergency Cases Saver app.

---

## Prerequisites

Before building, ensure:

1. ✅ Flutter is installed and configured
2. ✅ All dependencies are installed (`flutter pub get`)
3. ✅ Rescue 1122 logo is added to `assets/images/logo.png`
4. ✅ App has been tested in debug mode
5. ✅ Android SDK is properly configured

---

## Quick Build

### Option 1: Using the Start Script (Easiest)

```bash
./start.sh
# Select option 2 (Build APK)
```

### Option 2: Manual Command

```bash
flutter build apk --release
```

The APK will be created at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Build Types

### 1. Debug Build (Development)

For testing and development:

```bash
flutter build apk --debug
```

**Characteristics:**
- Includes debugging information
- Larger file size (~40-50 MB)
- Not optimized
- Can hot reload

**Use for:**
- Development
- Internal testing
- Debugging issues

---

### 2. Release Build (Production)

For distribution to users:

```bash
flutter build apk --release
```

**Characteristics:**
- Optimized and minified
- Smaller file size (~15-25 MB)
- No debugging info
- Best performance

**Use for:**
- Production deployment
- End-user distribution
- App stores

---

### 3. Profile Build (Performance Testing)

For performance analysis:

```bash
flutter build apk --profile
```

**Use for:**
- Performance profiling
- Identifying bottlenecks
- Optimization work

---

## Advanced Build Options

### Split APKs by ABI

Build separate APKs for different CPU architectures:

```bash
flutter build apk --split-per-abi --release
```

This creates multiple APKs:
- `app-armeabi-v7a-release.apk` (32-bit ARM)
- `app-arm64-v8a-release.apk` (64-bit ARM)
- `app-x86_64-release.apk` (64-bit Intel)

**Benefits:**
- Smaller individual file sizes
- Only downloads compatible version
- Better for Play Store distribution

**File locations:**
```
build/app/outputs/flutter-apk/
├── app-armeabi-v7a-release.apk
├── app-arm64-v8a-release.apk
└── app-x86_64-release.apk
```

---

### Build App Bundle (For Google Play Store)

```bash
flutter build appbundle --release
```

**Output:** `build/app/outputs/bundle/release/app-release.aab`

**Use for:**
- Google Play Store uploads
- Dynamic delivery
- Smaller downloads for users

---

## App Signing

### Debug Signing (Default)

Debug builds are automatically signed with a debug keystore.

**Debug keystore location:**
```
~/.android/debug.keystore
```

**Note:** Debug-signed APKs cannot be uploaded to Play Store.

---

### Release Signing (Production)

For production, you need to sign with your own keystore.

#### Step 1: Create a Keystore

```bash
keytool -genkey -v -keystore ~/rescue1122-keystore.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias rescue1122key
```

**Enter the following information:**
- Password: [Choose a strong password]
- Name: NexiVault Tech Solutions
- Organization: NexiVault
- City: [Your city]
- State: Punjab
- Country: PK

**IMPORTANT:** Keep the keystore and password safe!

---

#### Step 2: Reference Keystore in Project

Create `android/key.properties`:

```properties
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=rescue1122key
storeFile=/home/rehan/rescue1122-keystore.jks
```

**Add to `.gitignore`:**
```
android/key.properties
*.jks
```

---

#### Step 3: Update build.gradle

Edit `android/app/build.gradle`:

```gradle
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

android {
    ...
    
    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null
            storePassword keystoreProperties['storePassword']
        }
    }
    
    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled false
            shrinkResources false
        }
    }
}
```

---

#### Step 4: Build Signed APK

```bash
flutter build apk --release
```

Now the APK is signed with your production key!

---

## Code Obfuscation (Optional)

To make reverse engineering harder:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/debug-info
```

**Benefits:**
- Protects intellectual property
- Makes code harder to reverse engineer
- Reduces APK size

**Note:** Keep the debug info files for crash reports.

---

## Build Optimization

### Enable R8/ProGuard Shrinking

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

Create `android/app/proguard-rules.pro`:

```proguard
# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }

# Keep Rescue 1122 classes
-keep class com.nexivault.emergency_cases_saver.** { *; }

# SQLite
-keep class org.sqlite.** { *; }
```

---

## Version Management

### Update Version Before Building

Edit `pubspec.yaml`:

```yaml
version: 1.0.0+1
#         ↑    ↑
#    Version   Build
#     Name    Number
```

**Version format:**
- `major.minor.patch+build`
- Example: `1.2.3+15`

**Increment rules:**
- Build number: Every build
- Patch: Bug fixes
- Minor: New features
- Major: Breaking changes

---

## Pre-Build Checklist

Before building for production:

- [ ] Test all features thoroughly
- [ ] Add actual Rescue 1122 logo
- [ ] Update version in pubspec.yaml
- [ ] Update app name if needed
- [ ] Verify all strings are correct
- [ ] Test on multiple devices
- [ ] Check for console errors
- [ ] Verify database operations
- [ ] Test offline functionality
- [ ] Update README and docs
- [ ] Create release notes

---

## Build Process

### 1. Clean Previous Builds

```bash
flutter clean
```

### 2. Get Dependencies

```bash
flutter pub get
```

### 3. Verify Everything Works

```bash
flutter analyze
```

### 4. Run Tests (if any)

```bash
flutter test
```

### 5. Build APK

```bash
flutter build apk --release
```

### 6. Verify APK

```bash
# Check file size
ls -lh build/app/outputs/flutter-apk/app-release.apk

# Install on device
adb install build/app/outputs/flutter-apk/app-release.apk

# Test on device
adb shell am start -n com.nexivault.emergency_cases_saver/.MainActivity
```

---

## Distribution

### Method 1: Direct APK Distribution

```bash
# Copy APK to shared location
cp build/app/outputs/flutter-apk/app-release.apk ~/Desktop/EmergencyCasesSaver-v1.0.0.apk

# Or create a release folder
mkdir -p release/v1.0.0
cp build/app/outputs/flutter-apk/app-release.apk release/v1.0.0/
```

**Share via:**
- WhatsApp
- Email
- USB transfer
- Internal server
- File sharing services

---

### Method 2: Google Play Store

1. **Create signed App Bundle:**
   ```bash
   flutter build appbundle --release
   ```

2. **Prepare Play Store listing:**
   - App name
   - Description
   - Screenshots
   - Feature graphic
   - Icon

3. **Upload to Play Console:**
   - Go to: https://play.google.com/console
   - Create new app
   - Upload AAB file
   - Complete all required fields
   - Submit for review

---

## APK Information

### File Size Expectations

- **Debug APK:** ~40-50 MB
- **Release APK:** ~15-25 MB
- **Split APKs:** ~10-15 MB each

### Supported Architectures

- armeabi-v7a (32-bit ARM)
- arm64-v8a (64-bit ARM)
- x86_64 (64-bit Intel)

### Minimum Requirements

- **Android Version:** 5.0 (Lollipop)
- **API Level:** 21
- **Storage:** ~50 MB
- **RAM:** 1 GB minimum (2 GB recommended)

---

## Troubleshooting Build Issues

### Error: "Flutter SDK not found"

```bash
export PATH="$PATH:/path/to/flutter/bin"
flutter doctor
```

---

### Error: "Gradle build failed"

```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
flutter build apk --release
```

---

### Error: "Unable to load asset"

Check `pubspec.yaml`:
```yaml
flutter:
  assets:
    - assets/images/
```

Verify file exists:
```bash
ls assets/images/logo.png
```

---

### Error: "Keystore not found"

Verify keystore path in `android/key.properties`:
```properties
storeFile=/absolute/path/to/keystore.jks
```

---

### Build is too slow

Speed up builds:

```bash
# Use local cache
flutter pub cache repair

# Parallel builds
flutter build apk --release --dart-define=flutter.tools.parallelism=8

# Skip unnecessary steps
flutter build apk --release --no-pub
```

---

## Final Build Script

Create `build_release.sh`:

```bash
#!/bin/bash
set -e

echo "🏗️  Building Emergency Cases Saver..."
echo "======================================"

# Clean
echo "📦 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Analyze code
echo "🔍 Analyzing code..."
flutter analyze

# Build
echo "🔨 Building release APK..."
flutter build apk --release --split-per-abi

# Success
echo "✅ Build complete!"
echo ""
echo "📱 APKs created:"
ls -lh build/app/outputs/flutter-apk/*.apk
```

Make executable:
```bash
chmod +x build_release.sh
./build_release.sh
```

---

## Next Steps After Building

1. **Test APK thoroughly** on multiple devices
2. **Create release notes** documenting changes
3. **Share with beta testers** for feedback
4. **Distribute to users** via chosen method
5. **Monitor feedback** and fix issues
6. **Plan next version** based on feedback

---

**For detailed setup, see:** SETUP_GUIDE.md  
**For API reference, see:** API_DOCUMENTATION.md  
**For project overview, see:** PROJECT_SUMMARY.md

---

**Ready to build? Run:**
```bash
./start.sh
# Select option 2
```

Or:
```bash
flutter build apk --release
```

**Good luck with your build! 🚀**
