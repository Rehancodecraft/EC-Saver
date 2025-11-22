# 🔨 Build APK Locally - Step by Step

## Quick Build Command

```bash
flutter build apk --release --no-tree-shake-icons
```

The APK will be created at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Complete Build Process

### Step 1: Fix app_links Plugin (Required First Time)

```bash
# Navigate to project directory
cd /home/rehan/EC-Saver

# Get dependencies first
flutter pub get

# Run the fix script to fix app_links plugin
bash android/fix_plugins.sh
```

### Step 2: Clean Previous Builds (Optional but Recommended)

```bash
flutter clean
flutter pub get
```

### Step 3: Build the APK

```bash
flutter build apk --release --no-tree-shake-icons
```

### Step 4: Verify APK Location

```bash
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

## Alternative: One-Line Build (After First Fix)

```bash
flutter clean && flutter pub get && bash android/fix_plugins.sh && flutter build apk --release --no-tree-shake-icons
```

---

## If Build Fails

### Check Flutter Setup
```bash
flutter doctor -v
```

### Accept Android Licenses
```bash
flutter doctor --android-licenses
```

### Check Android SDK
```bash
echo $ANDROID_HOME
```

---

## Build Options

### Standard Release Build
```bash
flutter build apk --release --no-tree-shake-icons
```

### Split APKs (Smaller Size)
```bash
flutter build apk --split-per-abi --release --no-tree-shake-icons
```

### Debug Build (For Testing)
```bash
flutter build apk --debug
```

---

## APK Location

After successful build:
- **File:** `build/app/outputs/flutter-apk/app-release.apk`
- **Size:** ~15-25 MB
- **Version:** 1.0.8+8 (from pubspec.yaml)

---

## Install on Device

```bash
# Connect Android device via USB
adb devices

# Install APK
adb install build/app/outputs/flutter-apk/app-release.apk
```

---

## Troubleshooting

### Error: "app_links plugin compatibility"
**Solution:** Run `bash android/fix_plugins.sh` before building

### Error: "Android licenses not accepted"
**Solution:** Run `flutter doctor --android-licenses` and accept all

### Error: "Gradle build failed"
**Solution:** 
1. Run `flutter clean`
2. Run `bash android/fix_plugins.sh`
3. Try building again

---

## Quick Reference

```bash
# Complete build process
cd /home/rehan/EC-Saver
flutter clean
flutter pub get
bash android/fix_plugins.sh
flutter build apk --release --no-tree-shake-icons
```

