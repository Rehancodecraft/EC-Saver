#!/bin/bash

# Script to create v1.1.2 release for testing update system

cd /home/rehan/EC-Saver

echo "🚀 Creating v1.1.2 Release..."
echo ""

# Check if version is correct
VERSION=$(grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d '+' -f1 | tr -d ' ')
BUILD=$(grep "^version:" pubspec.yaml | sed 's/version: //' | cut -d '+' -f2 | tr -d ' ')

if [ "$VERSION" != "1.1.2" ]; then
    echo "❌ ERROR: Version in pubspec.yaml is $VERSION, expected 1.1.2"
    exit 1
fi

echo "✅ Version verified: $VERSION+$BUILD"
echo ""

# Commit changes if needed
if [ -n "$(git status --porcelain pubspec.yaml)" ]; then
    echo "📝 Committing version change..."
    git add pubspec.yaml
    git commit -m "chore: Bump version to 1.1.2+12 for testing update system"
    git push origin main
    echo "✅ Committed and pushed"
else
    echo "ℹ️  No changes to commit"
fi

echo ""

# Create and push tag
echo "🏷️  Creating tag v1.1.2..."
if git rev-parse v1.1.2 >/dev/null 2>&1; then
    echo "⚠️  Tag v1.1.2 already exists, deleting..."
    git tag -d v1.1.2
    git push origin :refs/tags/v1.1.2
fi

git tag v1.1.2
git push origin v1.1.2

echo "✅ Tag v1.1.2 created and pushed"
echo ""

# Wait a moment for workflow to start
echo "⏳ Waiting for workflow to start..."
sleep 5

# Show workflow status
echo "📊 Checking workflow status..."
gh run list --workflow="Build and Release APK" --limit 1 -R Rehancodecraft/EC-Saver

echo ""
echo "✅ Release process started!"
echo ""
echo "Monitor build at:"
echo "  https://github.com/Rehancodecraft/EC-Saver/actions"
echo ""
echo "Or watch in terminal:"
echo "  gh run watch -R Rehancodecraft/EC-Saver"

