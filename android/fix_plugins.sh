#!/bin/bash
# Fix plugin compatibility issues for app_links and other plugins

echo "🔧 Fixing plugin compatibility issues..."

# Find and fix app_links plugin
find ~/.pub-cache/hosted/pub.dev -name "app_links-*" -type d | while read plugin_dir; do
    build_gradle="$plugin_dir/android/build.gradle"
    if [ -f "$build_gradle" ]; then
        echo "Fixing: $build_gradle"
        
        # Backup
        cp "$build_gradle" "$build_gradle.bak"
        
        # Fix compileSdk references
        sed -i 's/flutter\.compileSdk/34/g' "$build_gradle"
        sed -i 's/flutter\.minSdkVersion/21/g' "$build_gradle"
        sed -i 's/flutter\.targetSdkVersion/34/g' "$build_gradle"
        
        # Add compileSdk if android block exists but compileSdk is missing
        if grep -q "android {" "$build_gradle" && ! grep -q "compileSdk" "$build_gradle"; then
            sed -i '/android {/a\    compileSdk 34' "$build_gradle"
        fi
        
        # Remove any references to flutter.compileSdk that might cause issues
        sed -i '/flutter\.compileSdk/d' "$build_gradle"
        
        echo "✅ Fixed: $build_gradle"
    fi
done

echo "✅ Plugin compatibility fixes applied"

