#!/bin/bash

# EC Saver - Build & Release Script
# Automatically builds APK with correct version name

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "    EC Saver - Release Build Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Get version from pubspec.yaml
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | sed 's/+.*//')
BUILD=$(grep '^version:' pubspec.yaml | sed 's/.*+//')

echo "📦 Building version: $VERSION (build $BUILD)"
echo ""

# Clean previous build
echo "🧹 Cleaning previous build..."
flutter clean
rm -rf build/

# Get dependencies
echo "📥 Getting dependencies..."
flutter pub get

# Build release APK
echo "🔨 Building release APK..."
flutter build apk --release

# Check if build succeeded
if [ $? -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ BUILD SUCCESSFUL!"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "📦 APK Location:"
    echo "   build/app/outputs/flutter-apk/ec-saver-v$VERSION-release.apk"
    echo ""
    echo "📊 File Info:"
    ls -lh build/app/outputs/flutter-apk/*.apk
    echo ""
    echo "🚀 Next Steps:"
    echo "   1. Test APK: adb install build/app/outputs/flutter-apk/ec-saver-v$VERSION-release.apk"
    echo "   2. Upload to GitHub: https://github.com/Rehancodecraft/EC-Saver/releases/new"
    echo "   3. Tag as: v$VERSION"
    echo ""
else
    echo ""
    echo "❌ BUILD FAILED!"
    echo "Check errors above"
    exit 1
fi
