# Logo Setup Instructions

## Required Logo Image

You need to add the **Rescue 1122 Punjab logo** to the project before running the app.

### Logo File Location

Save the logo image as:
```
assets/images/logo.png
```

### Logo Specifications

**Required:**
- **Format:** PNG (with transparency preferred)
- **Size:** 512x512 pixels minimum
- **Aspect Ratio:** 1:1 (square)
- **Color Mode:** RGB or RGBA
- **File Name:** `logo.png` (lowercase, no spaces)

**Recommended:**
- High resolution (1024x1024 pixels ideal)
- Transparent background
- Centered design
- Clear visibility at small sizes

### The Logo You Provided

Based on the logo image you provided (the Rescue 1122 badge with moon and star), here's how to use it:

1. **Save the image** you provided to:
   ```
   assets/images/logo.png
   ```

2. **The logo will be used in:**
   - Splash screen (180x180px)
   - App header (40x40px)
   - About screen (120x120px)
   - Drawer menu (80x80px)
   - App icon/launcher icon

### How to Add the Logo

#### Option 1: Manual Copy (Easiest)

```bash
# Navigate to the assets/images directory
cd ~/Workspace/rescue_1122_emergency_app/assets/images

# Copy your logo file here
cp /path/to/your/rescue1122_logo.png ./logo.png

# Verify it's there
ls -lh logo.png
```

#### Option 2: Using File Manager

1. Open your file manager
2. Navigate to: `~/Workspace/rescue_1122_emergency_app/assets/images/`
3. Paste your logo file
4. Rename it to: `logo.png`

### Temporary Placeholder (Development Only)

If you don't have the logo right now, you can create a simple placeholder:

```bash
cd ~/Workspace/rescue_1122_emergency_app/assets/images

# This creates a simple colored placeholder (requires ImageMagick)
# Install ImageMagick: sudo apt install imagemagick
convert -size 512x512 xc:#D32F2F -gravity center \
  -pointsize 48 -fill white -annotate +0+0 "RESCUE\n1122" \
  logo.png
```

**⚠️ Important:** Replace the placeholder with the actual Rescue 1122 logo before production release!

### App Icon Generation

After adding the logo, generate app icons:

```bash
# Install flutter_launcher_icons
flutter pub get

# Generate icons
flutter pub run flutter_launcher_icons:main

# This will create icons for:
# - Android (all densities)
# - iOS (all sizes)
```

The icons will be generated in:
- Android: `android/app/src/main/res/mipmap-*/`
- iOS: `ios/Runner/Assets.xcassets/AppIcon.appiconset/`

### Verify Logo Integration

After adding the logo:

1. **Run the app:**
   ```bash
   flutter run
   ```

2. **Check these screens:**
   - Splash screen (should show logo for 3 seconds)
   - Home screen (logo in app bar, top-left)
   - About screen (large centered logo)
   - Drawer menu (logo in header)

3. **If logo doesn't appear:**
   ```bash
   # Restart Flutter
   flutter clean
   flutter pub get
   flutter run
   ```

### Logo Usage in Code

The logo is referenced in multiple places:

**Splash Screen** (`lib/screens/splash_screen.dart`):
```dart
Image.asset('assets/images/logo.png', fit: BoxFit.contain)
```

**Home Screen** (`lib/screens/home_screen.dart`):
```dart
Image.asset('assets/images/logo.png', height: 40, width: 40)
```

**About Screen** (`lib/screens/about_screen.dart`):
```dart
Image.asset('assets/images/logo.png', fit: BoxFit.contain)
```

### Troubleshooting

#### "Unable to load asset: assets/images/logo.png"

**Solution:**
1. Verify file exists: `ls assets/images/logo.png`
2. Check file name is exactly: `logo.png` (lowercase)
3. Verify pubspec.yaml has:
   ```yaml
   flutter:
     assets:
       - assets/images/
   ```
4. Run: `flutter clean && flutter pub get`
5. Restart app

#### Logo appears blurry or pixelated

**Solution:**
- Use higher resolution image (1024x1024px)
- Ensure PNG format, not JPEG
- Use vector format if possible (SVG), then convert to PNG

#### Logo has wrong colors

**Solution:**
- Ensure RGB color mode
- Check transparency (alpha channel)
- Use image editing software to adjust colors

### Image Editing Tools

If you need to edit/resize the logo:

**Free Tools:**
- **GIMP:** https://www.gimp.org/ (Linux, Windows, Mac)
- **Inkscape:** https://inkscape.org/ (Vector graphics)
- **Photopea:** https://www.photopea.com/ (Online, free)

**Online Tools:**
- **TinyPNG:** https://tinypng.com/ (Compress PNG)
- **Squoosh:** https://squoosh.app/ (Resize/optimize)

### Converting Your Logo

If you have the logo in different format:

**From JPEG to PNG:**
```bash
convert logo.jpg logo.png
```

**From SVG to PNG:**
```bash
inkscape -w 1024 -h 1024 logo.svg -o logo.png
```

**Resize to proper dimensions:**
```bash
convert logo.png -resize 1024x1024 logo.png
```

### Final Checklist

Before running the app:

- [ ] Logo file exists at: `assets/images/logo.png`
- [ ] File size is reasonable (< 1MB)
- [ ] Image is square (1:1 aspect ratio)
- [ ] Image is high resolution (≥ 512x512px)
- [ ] Image is PNG format
- [ ] Ran `flutter pub get` after adding logo
- [ ] Tested app launch to verify logo appears

---

**Need Help?**

If you need assistance with the logo setup, contact:
- Developer: NexiVault Tech Solutions
- WhatsApp: +92 324 4266595
