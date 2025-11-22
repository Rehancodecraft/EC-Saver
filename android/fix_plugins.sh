#!/bin/bash
# Fix plugin compatibility issues for app_links and other plugins

echo "🔧 Fixing plugin compatibility issues..."

# Find and fix app_links plugin
find ~/.pub-cache/hosted/pub.dev -name "app_links-*" -type d | while read plugin_dir; do
    build_gradle="$plugin_dir/android/build.gradle"
    if [ -f "$build_gradle" ]; then
        echo "🔍 Found app_links plugin: $build_gradle"
        
        # Backup
        cp "$build_gradle" "$build_gradle.bak"
        
        echo "📄 Original build.gradle content:"
        cat "$build_gradle"
        
        # Create a completely new compatible build.gradle
        cat > "$build_gradle" << 'EOF'
group 'com.llfbandit.app_links'
version '1.0-SNAPSHOT'

buildscript {
    ext.kotlin_version = '2.1.0'
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath 'com.android.tools.build:gradle:8.9.1'
        classpath "org.jetbrains.kotlin:kotlin-gradle-plugin:$kotlin_version"
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

apply plugin: 'com.android.library'
apply plugin: 'kotlin-android'

android {
    compileSdk 34
    namespace "com.llfbandit.app_links"
    
    compileOptions {
        sourceCompatibility JavaVersion.VERSION_1_8
        targetCompatibility JavaVersion.VERSION_1_8
    }
    
    kotlinOptions {
        jvmTarget = '1.8'
    }
    
    sourceSets {
        main.java.srcDirs += 'src/main/kotlin'
    }
    
    defaultConfig {
        minSdk 21
    }
}

dependencies {
    implementation "org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version"
}
EOF
        
        echo "✅ Replaced app_links build.gradle with compatible version"
        echo "📄 New build.gradle content:"
        cat "$build_gradle"
    fi
done

echo "✅ Plugin compatibility fixes applied"
