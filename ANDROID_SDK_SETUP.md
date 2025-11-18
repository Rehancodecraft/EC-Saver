# Android SDK Setup Guide

## Issue: Android SDK Not Found

You're seeing this error because Flutter can't find the Android SDK. Here's how to fix it.

---

## 🎯 Quick Fix Options

You have **3 options**:

1. **Install Android Studio** (Recommended - Easiest)
2. **Install Command-line Tools Only** (Lighter weight)
3. **Use Linux/Web Build** (Test now, setup Android later)

---

## ✅ Option 1: Install Android Studio (Recommended)

This is the easiest method and gives you a complete development environment.

### Step 1: Download Android Studio

```bash
# Download Android Studio
cd ~/Downloads
wget https://redirector.gvt1.com/edgedl/android/studio/ide-zips/2024.2.1.12/android-studio-2024.2.1.12-linux.tar.gz

# Or download manually from:
# https://developer.android.com/studio
```

### Step 2: Extract and Install

```bash
# Extract
sudo tar -xzf android-studio-*.tar.gz -C /opt/

# Create desktop entry
cat > ~/.local/share/applications/android-studio.desktop << 'EOF'
[Desktop Entry]
Version=1.0
Type=Application
Name=Android Studio
Icon=/opt/android-studio/bin/studio.png
Exec="/opt/android-studio/bin/studio.sh" %f
Comment=Android Studio IDE
Categories=Development;IDE;
Terminal=false
StartupWMClass=jetbrains-studio
EOF
```

### Step 3: Launch Android Studio

```bash
/opt/android-studio/bin/studio.sh &
```

### Step 4: Complete Setup Wizard

When Android Studio launches:

1. **Welcome Screen** → Click "Next"
2. **Install Type** → Choose "Standard" → Next
3. **Select UI Theme** → Choose your preference → Next
4. **Verify Settings** → Click "Finish"
5. **Wait for SDK download** (This takes 5-10 minutes)
6. **Accept licenses** when prompted

### Step 5: Set Environment Variables

```bash
# Add to ~/.bashrc or ~/.zshrc
cat >> ~/.bashrc << 'EOF'

# Android SDK
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
EOF

# Reload
source ~/.bashrc
```

### Step 6: Verify Installation

```bash
flutter doctor --android-licenses
# Accept all licenses by typing 'y'

flutter doctor
# Should now show Android toolchain with checkmark
```

---

## ⚡ Option 2: Command-Line Tools Only (Lighter)

If you don't want the full Android Studio IDE:

### Step 1: Install Java

```bash
sudo apt update
sudo apt install openjdk-17-jdk -y

# Verify
java -version
```

### Step 2: Download Command-Line Tools

```bash
# Create SDK directory
mkdir -p ~/Android/Sdk
cd ~/Android/Sdk

# Download command-line tools
wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip

# Extract
unzip commandlinetools-linux-*.zip
mkdir -p cmdline-tools/latest
mv cmdline-tools/* cmdline-tools/latest/ 2>/dev/null || true
```

### Step 3: Set Environment Variables

```bash
cat >> ~/.bashrc << 'EOF'

# Android SDK
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/emulator
EOF

source ~/.bashrc
```

### Step 4: Install SDK Components

```bash
# Accept licenses
yes | sdkmanager --licenses

# Install required packages
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
sdkmanager "emulator" "system-images;android-34;google_apis;x86_64"
```

### Step 5: Verify

```bash
flutter doctor --android-licenses
flutter doctor
```

---

## 🖥️ Option 3: Build for Linux/Web (Test Now)

You can test the app immediately on Linux or Web while setting up Android:

### Build for Linux Desktop

```bash
cd ~/Workspace/rescue_1122_emergency_app

# Enable Linux desktop
flutter config --enable-linux-desktop

# Run on Linux
flutter run -d linux
```

### Build for Web (Chrome)

```bash
# Enable web
flutter config --enable-web

# Run on Chrome
flutter run -d chrome
```

**Note:** These are for testing only. For actual deployment to Rescue 1122 personnel, you need Android APK.

---

## 🎯 Recommended Path

For your use case (deploying to Rescue 1122 personnel), I recommend:

**NOW:** Build for Linux/Web to test the app immediately  
**THEN:** Install Android Studio (Option 1) to build APK

### Quick Test (5 minutes)

```bash
cd ~/Workspace/rescue_1122_emergency_app

# First, add the logo
# Place logo.png in assets/images/

# Test on Linux
flutter config --enable-linux-desktop
flutter run -d linux
```

This lets you see and test the app while Android SDK downloads in the background.

---

## 🔍 Troubleshooting

### "Command not found: sdkmanager"

```bash
# Check Android SDK path
echo $ANDROID_HOME
ls $ANDROID_HOME

# If empty, SDK not installed properly
# Repeat installation steps
```

### "Unable to locate Android SDK"

```bash
# Tell Flutter where Android SDK is
flutter config --android-sdk ~/Android/Sdk

# Verify
flutter doctor -v
```

### "License not accepted"

```bash
flutter doctor --android-licenses
# Type 'y' for each license
```

### "Platform tools not found"

```bash
# Install platform tools
sdkmanager "platform-tools"

# Or via Android Studio:
# Tools → SDK Manager → SDK Tools → Android SDK Platform-Tools
```

---

## ✅ Verification Checklist

After setup, verify everything works:

```bash
# 1. Check Flutter can find Android SDK
flutter doctor

# Should show:
# ✓ Flutter
# ✓ Android toolchain
# ✓ Chrome
# ✓ Linux toolchain
# ✓ Connected device

# 2. Try building APK
cd ~/Workspace/rescue_1122_emergency_app
flutter build apk --release

# 3. Check output
ls -lh build/app/outputs/flutter-apk/app-release.apk
```

---

## 🚀 Once Android SDK is Ready

After Android SDK is installed and working:

### Connect Android Device (Physical)

```bash
# Enable USB debugging on your phone:
# Settings → About Phone → Tap "Build Number" 7 times
# Settings → Developer Options → Enable "USB Debugging"

# Connect phone via USB

# Verify connection
adb devices
# Should show your device

# Run app
flutter run
```

### Or Create Android Emulator

```bash
# List available system images
sdkmanager --list | grep system-images

# Create emulator
avdmanager create avd -n Pixel5 -k "system-images;android-34;google_apis;x86_64" -d "pixel_5"

# Start emulator
emulator -avd Pixel5 &

# Wait for emulator to boot, then:
flutter run
```

---

## 📱 Quick Start After Setup

Once Android SDK is configured:

```bash
cd ~/Workspace/rescue_1122_emergency_app

# Add logo (if not done)
cp /path/to/logo.png assets/images/logo.png

# Get dependencies
flutter pub get

# Build APK
./start.sh
# Choose option 2

# Or directly:
flutter build apk --release
```

---

## 💡 Which Option Should I Choose?

**If you:**
- Want full IDE experience → **Option 1** (Android Studio)
- Want minimal installation → **Option 2** (Command-line tools)
- Want to test immediately → **Option 3** (Linux/Web)
- Are deploying to users → **Must use Option 1 or 2** (need APK)

**Recommended for production:**
Install Android Studio (Option 1) - it's the most reliable and includes everything you need.

---

## ⏱️ Time Estimates

- **Android Studio Install:** 30-45 minutes (includes downloads)
- **Command-line Tools:** 15-20 minutes
- **Linux/Web Test:** 5 minutes (immediate)

---

## 📞 Need Help?

If you encounter issues:

1. Check Flutter documentation: https://flutter.dev/docs/get-started/install/linux
2. Android Studio guide: https://developer.android.com/studio/install
3. Contact: +92 324 4266595 (WhatsApp)

---

## 🎯 Next Steps

**Right now:**
```bash
# Quick test on Linux (5 minutes)
flutter config --enable-linux-desktop
flutter run -d linux
```

**For production:**
```bash
# Install Android Studio following Option 1 above
# Then build APK for deployment
```

---

**After Android SDK setup, return to normal workflow using `./start.sh`**
