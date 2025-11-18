#!/bin/bash

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  🚀 Emergency Cases Saver - Rescue 1122"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Check if clang++ is installed
if ! command -v clang++ &> /dev/null; then
    echo "❌ Missing build tools!"
    echo ""
    echo "You need to install C++ compiler first."
    echo ""
    echo "Run this command:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "sudo apt-get update && sudo apt-get install -y \\"
    echo "  clang cmake ninja-build pkg-config \\"
    echo "  libgtk-3-dev liblzma-dev libstdc++-12-dev"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "OR run on Web instead (no installation needed):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "flutter run -d chrome"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    read -p "Press Enter to open in Chrome, or Ctrl+C to cancel..."
    cd ~/Workspace/rescue_1122_emergency_app
    flutter run -d chrome
    exit 0
fi

echo "✓ Build tools found!"
echo ""
echo "Starting app on Linux Desktop..."
echo ""
echo "Controls:"
echo "  • Press 'r' to hot reload"
echo "  • Press 'R' to restart"  
echo "  • Press 'q' to quit"
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

cd ~/Workspace/rescue_1122_emergency_app
flutter run -d linux
