#!/bin/bash

# EC Saver - Auto Version Bump Script
# Usage: ./bump_version.sh [major|minor|patch]

VERSION_FILE="pubspec.yaml"
VERSION_TYPE="${1:-patch}"  # default to patch if not specified

# Get current version
CURRENT_VERSION=$(grep '^version:' $VERSION_FILE | sed 's/version: //' | sed 's/+.*//')
CURRENT_BUILD=$(grep '^version:' $VERSION_FILE | sed 's/.*+//')

echo "Current version: $CURRENT_VERSION+$CURRENT_BUILD"

# Split version into parts
IFS='.' read -r -a VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR="${VERSION_PARTS[0]}"
MINOR="${VERSION_PARTS[1]}"
PATCH="${VERSION_PARTS[2]}"

# Increment based on type
case $VERSION_TYPE in
  major)
    MAJOR=$((MAJOR + 1))
    MINOR=0
    PATCH=0
    ;;
  minor)
    MINOR=$((MINOR + 1))
    PATCH=0
    ;;
  patch)
    PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Invalid version type. Use: major, minor, or patch"
    exit 1
    ;;
esac

# Increment build number
NEW_BUILD=$((CURRENT_BUILD + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo "New version: $NEW_VERSION+$NEW_BUILD"

# Update pubspec.yaml
sed -i "s/^version: .*/version: $NEW_VERSION+$NEW_BUILD/" $VERSION_FILE

echo "✅ Version updated in pubspec.yaml"
echo "📝 New version: $NEW_VERSION+$NEW_BUILD"
echo ""
echo "Next steps:"
echo "1. Review changes: git diff pubspec.yaml"
echo "2. Commit: git commit -am 'Bump version to $NEW_VERSION'"
echo "3. Build APK: flutter build apk --release"
echo "4. APK will be named: ec-saver-v$NEW_VERSION.apk"
