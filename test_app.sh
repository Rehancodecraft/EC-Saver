#!/bin/bash

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║     Emergency Cases Saver - Quick Test Script               ║"
echo "║     Rescue 1122 Punjab Edition                               ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

cd ~/Workspace/rescue_1122_emergency_app

echo "🔍 Checking prerequisites..."
echo ""

# Check Flutter
if command -v flutter &> /dev/null; then
    echo "✓ Flutter found: $(flutter --version | head -n 1)"
else
    echo "✗ Flutter not found"
    exit 1
fi

# Check logo
if [ -f "assets/images/logo.png" ]; then
    SIZE=$(du -h assets/images/logo.png | cut -f1)
    echo "✓ Logo exists: $SIZE"
else
    echo "✗ Logo not found"
    exit 1
fi

echo ""
echo "📦 Getting dependencies..."
flutter pub get > /dev/null 2>&1
echo "✓ Dependencies ready"

echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            Choose Testing Method:                            ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
echo "1. 🖥️  Test on Linux Desktop (Fast, No Setup)"
echo "2. 🌐 Test on Web Browser (Chrome)"
echo "3. 🤖 Build Android APK (Requires Android Studio)"
echo "4. ℹ️  Show Status & Help"
echo "5. 🚪 Exit"
echo ""
read -p "Enter your choice (1-5): " choice

case $choice in
    1)
        echo ""
        echo "🚀 Launching on Linux Desktop..."
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  App Controls:"
        echo "  • Press 'r' to hot reload"
        echo "  • Press 'R' to restart"
        echo "  • Press 'q' to quit"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        flutter config --enable-linux-desktop > /dev/null 2>&1
        flutter run -d linux
        ;;
    2)
        echo ""
        echo "🌐 Launching on Web Browser..."
        echo ""
        flutter config --enable-web > /dev/null 2>&1
        flutter run -d chrome
        ;;
    3)
        echo ""
        echo "🤖 Building Android APK..."
        echo ""
        # Check if Android SDK exists
        if flutter doctor | grep -q "Android toolchain"; then
            echo "✓ Android SDK found"
            echo ""
            echo "Building release APK..."
            flutter build apk --release
            
            if [ $? -eq 0 ]; then
                echo ""
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo "✅ APK Built Successfully!"
                echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
                echo ""
                echo "📁 Location:"
                echo "   build/app/outputs/flutter-apk/app-release.apk"
                echo ""
                ls -lh build/app/outputs/flutter-apk/app-release.apk
                echo ""
                echo "📱 Next Steps:"
                echo "   1. Copy APK to Android device"
                echo "   2. Install on device"
                echo "   3. Test all features"
            else
                echo ""
                echo "❌ Build failed!"
                echo ""
                echo "Possible solutions:"
                echo "1. Read COMPLETE_SOLUTION.md"
                echo "2. Try: flutter clean && flutter pub get"
                echo "3. Check Android SDK setup"
            fi
        else
            echo "❌ Android SDK not found!"
            echo ""
            echo "To build Android APK, you need Android Studio."
            echo ""
            echo "Quick setup:"
            echo "  1. Install: sudo snap install android-studio --classic"
            echo "  2. Launch: android-studio"
            echo "  3. Complete setup wizard"
            echo "  4. Run: flutter doctor --android-licenses"
            echo ""
            echo "For detailed instructions, see:"
            echo "  • ANDROID_SDK_SETUP.md"
            echo "  • COMPLETE_SOLUTION.md"
            echo ""
            echo "OR test the app now without Android SDK:"
            echo "  Run this script again and choose option 1 or 2"
        fi
        ;;
    4)
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║                    Current Status                            ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        flutter doctor
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📚 Available Documentation:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "  COMPLETE_SOLUTION.md   ← All issues & solutions"
        echo "  GETTING_STARTED.md     ← Quick start guide"
        echo "  ANDROID_SDK_SETUP.md   ← Android setup help"
        echo "  BUILD_INSTRUCTIONS.md  ← APK building guide"
        echo "  API_DOCUMENTATION.md   ← Database API"
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📞 Support: WhatsApp +92 324 4266595"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        ;;
    5)
        echo ""
        echo "👋 Goodbye!"
        echo ""
        exit 0
        ;;
    *)
        echo ""
        echo "❌ Invalid choice"
        echo ""
        exit 1
        ;;
esac
