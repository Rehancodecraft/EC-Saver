#!/bin/bash
# Quick script to build APK locally

echo "🔨 Building APK for EC-Saver..."
echo ""

# Step 1: Clean
echo "🧹 Cleaning previous builds..."
flutter clean

# Step 2: Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Step 3: Fix app_links plugin
echo "🔧 Fixing app_links plugin compatibility..."
bash android/fix_plugins.sh

# Step 4: Build APK
echo "🏗️  Building release APK..."
flutter build apk --release --no-tree-shake-icons

# Step 5: Check result
if [ -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo ""
    echo "✅ APK built successfully!"
    echo "📁 Location: build/app/outputs/flutter-apk/app-release.apk"
    echo "📊 File size:"
    ls -lh build/app/outputs/flutter-apk/app-release.apk
else
    echo ""
    echo "❌ Build failed! Check the error messages above."
    exit 1
fi

