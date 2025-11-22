#!/bin/bash

# Script to fix v1.1.2 release issues
# This will delete and recreate v1.1.2 with correct version

cd /home/rehan/EC-Saver

echo "🔧 Fixing v1.1.2 Release Issues..."
echo ""

# Check current version in pubspec.yaml
CURRENT_VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d '+' -f1 | tr -d ' ')
CURRENT_BUILD=$(grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d '+' -f2 | tr -d ' ')

echo "📋 Current pubspec.yaml version: $CURRENT_VERSION+$CURRENT_BUILD"
echo ""

# Ensure version is 1.1.2+12
if [ "$CURRENT_VERSION" != "1.1.2" ]; then
    echo "⚠️  Warning: pubspec.yaml version is $CURRENT_VERSION, expected 1.1.2"
    echo "📝 Updating to 1.1.2+12..."
    sed -i "s/^version:.*/version: 1.1.2+12/" pubspec.yaml
    git add pubspec.yaml
    git commit -m "fix: Ensure version is 1.1.2+12 for correct APK build"
    git push origin main
    echo "✅ Updated and pushed"
fi

echo ""
echo "🗑️  Deleting existing v1.1.2 tag and release..."
git tag -d v1.1.2 2>/dev/null
git push origin :refs/tags/v1.1.2 2>/dev/null

echo ""
echo "🏷️  Creating new v1.1.2 tag..."
git tag v1.1.2
git push origin v1.1.2

echo ""
echo "✅ Tag v1.1.2 recreated and pushed"
echo ""
echo "⏳ Waiting for workflow to start..."
sleep 5

echo ""
echo "📊 Checking workflow status..."
gh run list --workflow="Build and Release APK" --limit 1 -R Rehancodecraft/EC-Saver

echo ""
echo "✅ Fix applied!"
echo ""
echo "The workflow will now:"
echo "1. Extract version from tag: v1.1.2 → 1.1.2"
echo "2. Get build from pubspec.yaml: 12"
echo "3. Update pubspec.yaml: 1.1.2+12"
echo "4. Build APK with correct version"
echo "5. Verify APK has version 1.1.2"
echo "6. Create release with correct APK"
echo ""
echo "Monitor at: https://github.com/Rehancodecraft/EC-Saver/actions"

