#!/bin/bash

# Script to prepare landing page files for Netlify deployment

echo "🚀 Preparing files for Netlify deployment..."
echo ""

# Create deployment folder
DEPLOY_DIR="netlify-deploy"

# Remove old deployment folder if exists
if [ -d "$DEPLOY_DIR" ]; then
    echo "🗑️  Removing old deployment folder..."
    rm -rf "$DEPLOY_DIR"
fi

# Create new deployment folder
mkdir -p "$DEPLOY_DIR/assets/image"

# Copy required files
echo "📋 Copying files..."
cp index.html "$DEPLOY_DIR/"
cp assets/image/logo.png "$DEPLOY_DIR/assets/image/"
cp assets/image/landpagebackground.jpg "$DEPLOY_DIR/assets/image/"

# Verify files
echo ""
echo "✅ Files prepared:"
echo "📁 Structure:"
tree -L 3 "$DEPLOY_DIR" 2>/dev/null || find "$DEPLOY_DIR" -type f

echo ""
echo "📊 File sizes:"
du -sh "$DEPLOY_DIR"/*
du -sh "$DEPLOY_DIR/assets/image"/*

echo ""
echo "✅ Ready for Netlify deployment!"
echo ""
echo "Next steps:"
echo "1. Go to https://app.netlify.com"
echo "2. Click 'Add new site' → 'Deploy manually'"
echo "3. Drag and drop the '$DEPLOY_DIR' folder"
echo "4. Wait for deployment (~30 seconds)"
echo "5. Your site is live! 🎉"
echo ""
echo "Or deploy via CLI:"
echo "  cd $DEPLOY_DIR"
echo "  netlify deploy --prod"

