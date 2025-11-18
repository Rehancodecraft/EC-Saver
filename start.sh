#!/bin/bash

# Emergency Cases Saver - Rescue 1122 Punjab
# Development Startup Script

clear
echo "================================================"
echo "  Emergency Cases Saver - Rescue 1122 Punjab"
echo "  Starting Development Environment..."
echo "================================================"
echo ""

# Check if Flutter is installed
if ! command -v flutter &> /dev/null; then
    echo "❌ Flutter is not installed or not in PATH"
    echo "Please install Flutter from: https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✓ Flutter detected: $(flutter --version | head -n 1)"
echo ""

# Check for Flutter project
if [ ! -f "pubspec.yaml" ]; then
    echo "❌ pubspec.yaml not found. Are you in the project directory?"
    exit 1
fi

echo "📦 Installing dependencies..."
flutter pub get

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✓ Dependencies installed successfully"
echo ""

# Check for connected devices
echo "📱 Checking for connected devices..."
flutter devices
echo ""

echo "================================================"
echo "  Choose an option:"
echo "================================================"
echo "1. Run on Linux Desktop (RECOMMENDED - Fast & Light)"
echo "2. Run on Web Server (Open in ANY browser)"
echo "3. Run on Chrome (Direct)"
echo "4. Run on connected device/emulator"
echo "5. Build APK (Release mode)"
echo "6. Run Flutter doctor"
echo "7. Clean build files"
echo "8. Exit"
echo ""
read -p "Enter your choice (1-8): " choice

case $choice in
    1)
        echo ""
        echo "🚀 Starting app on Linux Desktop..."
        flutter run -d linux
        ;;
    2)
        echo ""
        echo "🌐 Starting web server on port 8080..."
        echo ""
        echo "📱 Open in your browser:"
        echo "   http://localhost:8080"
        echo ""
        flutter run -d web-server --web-port=8080 --web-hostname=0.0.0.0
        ;;
    3)
        echo ""
        echo "🌐 Starting on Chrome..."
        flutter run -d chrome
        ;;
    4)
        echo ""
        echo "🚀 Starting app on device/emulator..."
        flutter run
        ;;
    5)
        echo ""
        echo "🔨 Building release APK..."
        flutter build apk --release
        
        if [ $? -eq 0 ]; then
            echo ""
            echo "✅ APK built successfully!"
            echo "📁 Location: build/app/outputs/flutter-apk/app-release.apk"
        fi
        ;;
    6)
        echo ""
        echo "🔍 Running Flutter doctor..."
        flutter doctor -v
        ;;
    7)
        echo ""
        echo "🧹 Cleaning build files..."
        flutter clean
        echo "✓ Clean completed"
        ;;
    8)
        echo "Goodbye!"
        exit 0
        ;;
    *)
        echo "Invalid choice. Exiting..."
        exit 1
        ;;
esac

echo ""
echo "================================================"
echo "  Task completed!"
echo "================================================"
