#!/bin/bash
# Script to generate a release keystore for EC Saver
# This keystore will be used to sign release APKs and reduce security warnings

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  EC Saver - Keystore Generation Script"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "This script will generate a release keystore for signing APKs."
echo "The keystore will be stored in android/app/upload-keystore.jks"
echo ""
echo "⚠️  IMPORTANT: Keep this keystore file and passwords secure!"
echo "   - Never commit the keystore to Git (already in .gitignore)"
echo "   - Store passwords in a secure password manager"
echo "   - For GitHub Actions, add keystore as a secret"
echo ""

# Check if keystore already exists
if [ -f "android/app/upload-keystore.jks" ]; then
    echo "⚠️  Keystore already exists at android/app/upload-keystore.jks"
    read -p "Do you want to overwrite it? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Keystore generation cancelled."
        exit 1
    fi
    rm -f android/app/upload-keystore.jks
fi

# Get keystore details
echo "Enter keystore details (you can use default values for testing):"
echo ""

read -p "Keystore password (min 6 chars): " STORE_PASSWORD
if [ ${#STORE_PASSWORD} -lt 6 ]; then
    echo "❌ Password must be at least 6 characters"
    exit 1
fi

read -p "Key alias (default: upload): " KEY_ALIAS
KEY_ALIAS=${KEY_ALIAS:-upload}

read -p "Key password (default: same as keystore password): " KEY_PASSWORD
KEY_PASSWORD=${KEY_PASSWORD:-$STORE_PASSWORD}

read -p "Validity in years (default: 25): " VALIDITY
VALIDITY=${VALIDITY:-25}

# Generate keystore
echo ""
echo "🔐 Generating keystore..."
keytool -genkey -v -keystore android/app/upload-keystore.jks \
    -keyalg RSA -keysize 2048 -validity $((VALIDITY * 365)) \
    -alias "$KEY_ALIAS" \
    -storepass "$STORE_PASSWORD" \
    -keypass "$KEY_PASSWORD" \
    -dname "CN=EC Saver, OU=Development, O=NexiVault, L=Lahore, ST=Punjab, C=PK"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ Keystore generated successfully!"
    echo ""
    echo "📁 Location: android/app/upload-keystore.jks"
    echo ""
    echo "📝 Next steps:"
    echo "   1. Create android/key.properties file with:"
    echo "      storePassword=$STORE_PASSWORD"
    echo "      keyPassword=$KEY_PASSWORD"
    echo "      keyAlias=$KEY_ALIAS"
    echo "      storeFile=upload-keystore.jks"
    echo ""
    echo "   2. For GitHub Actions, add these as secrets:"
    echo "      KEYSTORE_FILE (base64 encoded keystore)"
    echo "      KEYSTORE_PASSWORD=$STORE_PASSWORD"
    echo "      KEY_ALIAS=$KEY_ALIAS"
    echo "      KEY_PASSWORD=$KEY_PASSWORD"
    echo ""
    echo "   3. The keystore is already in .gitignore - it won't be committed"
    echo ""
else
    echo ""
    echo "❌ Failed to generate keystore. Make sure Java keytool is installed."
    exit 1
fi

