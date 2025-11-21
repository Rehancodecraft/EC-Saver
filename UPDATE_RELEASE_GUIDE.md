# 📱 Complete Guide: Releasing Updates for EC Saver

This guide explains how to release new versions of EC Saver so users automatically get notified and can update seamlessly.

---

## 🎯 How Auto-Update Works

1. **Automatic Check**: When users open the app, it checks GitHub Releases for new versions
2. **Version Comparison**: Compares current app version with latest GitHub release
3. **User Notification**: Shows update dialog if a newer version is available
4. **Download & Install**: Users can download and install the APK directly
5. **Data Preservation**: All user data (SQLite database) is automatically preserved during updates

---

## 📋 Step-by-Step: Releasing a New Update

### Step 1: Update Version in `pubspec.yaml`

**Current version format:** `version: X.Y.Z+BUILD`

- **X.Y.Z** = Version number (e.g., 1.0.2)
- **BUILD** = Build number (e.g., 3)

**Example:**
```yaml
version: 1.0.3+4  # Version 1.0.3, Build 4
```

**Important Rules:**
- ✅ **Always increment the build number** (the number after `+`)
- ✅ **Increment version number** for major/minor updates
- ✅ **Build number must be higher** than previous release for update detection

---

### Step 2: Make Your Code Changes

Make all your code changes, test thoroughly, then proceed to build.

---

### Step 3: Build Release APK

```bash
cd /home/rehan/EC-Saver
flutter clean
flutter pub get
flutter build apk --release
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

**Note:** The build script automatically names it as `ec-saver-v{VERSION}-release.apk`

---

### Step 4: Create GitHub Release

1. **Go to your GitHub repository**: https://github.com/Rehancodecraft/EC-Saver
2. **Click "Releases"** → **"Create a new release"**
3. **Fill in the release details:**

   **Tag version:** `v1.0.3+4` (must match `pubspec.yaml` format: `v` + version + `+` + build)
   
   **Example tags:**
   - `v1.0.2+3` ✅
   - `v1.0.3+4` ✅
   - `v2.0.0+10` ✅
   
   **Release title:** `EC Saver v1.0.3` (user-friendly title)
   
   **Description (Release Notes):**
   ```
   ## What's New in v1.0.3
   
   - Fixed update notification bug
   - Improved performance
   - Added new features
   
   ## Bug Fixes
   - Fixed crash on startup
   - Fixed data sync issue
   
   ## Notes
   - This update requires Android 6.0 or higher
   ```

   **Optional: Force Update**
   - If you want to force users to update (they can't dismiss), add `[FORCE_UPDATE]` anywhere in the release notes
   - Example: `[FORCE_UPDATE] Critical security update - please update immediately`

4. **Upload APK:**
   - Click **"Attach binaries"** or drag and drop
   - Upload: `build/app/outputs/flutter-apk/app-release.apk`
   - **Important:** The APK file must be named with `.apk` extension

5. **Publish Release:**
   - Check **"Set as the latest release"** (if this is your latest version)
   - Click **"Publish release"**

---

### Step 5: Verify Release

1. **Check Release URL:**
   ```
   https://github.com/Rehancodecraft/EC-Saver/releases/latest
   ```

2. **Verify API Response:**
   ```bash
   curl https://api.github.com/repos/Rehancodecraft/EC-Saver/releases/latest
   ```
   
   Should return JSON with:
   - `tag_name`: `v1.0.3+4`
   - `assets[0].browser_download_url`: Link to your APK

---

## 🔍 How Update Detection Works

### Version Comparison Logic

1. **Primary Method:** Compares **build numbers** (the number after `+`)
   - Current: `1.0.2+3` → Build: 3
   - Latest: `1.0.3+4` → Build: 4
   - **Update available:** ✅ (4 > 3)

2. **Fallback Method:** If build numbers are equal, compares version strings
   - Current: `1.0.2+3` → Version: 1.0.2
   - Latest: `1.0.3+3` → Version: 1.0.3
   - **Update available:** ✅ (1.0.3 > 1.0.2)

### Update Flow

```
App Starts
    ↓
Check GitHub Releases API
    ↓
Parse tag_name (e.g., "v1.0.3+4")
    ↓
Extract version (1.0.3) and build (4)
    ↓
Compare with current app version
    ↓
If newer version found → Show Update Dialog
    ↓
User clicks "Download & Install"
    ↓
Download APK to app directory
    ↓
Open Android Package Installer
    ↓
User installs update
    ↓
App data (SQLite) is preserved automatically
```

---

## 🛡️ Data Preservation

**✅ Your data is SAFE during updates!**

- **SQLite Database:** Stored in app's private directory, automatically preserved
- **User Profile:** Preserved
- **Emergency Records:** Preserved
- **Monthly Statistics:** Preserved
- **Settings:** Preserved (SharedPreferences)

**Why?** Android preserves app data when installing an APK with the same package name (`com.nexivault.emergency_cases_saver`).

---

## ⚠️ Important Notes

### Version Tag Format

**✅ CORRECT:**
- `v1.0.2+3`
- `v1.0.3+4`
- `v2.0.0+10`

**❌ WRONG:**
- `1.0.2+3` (missing `v` prefix)
- `v1.0.2` (missing build number)
- `v1.0.2-3` (using `-` instead of `+`)

### Build Number Rules

- **Must be an integer:** `+3`, `+4`, `+10` ✅
- **Must increase:** Each release must have a higher build number
- **Can skip numbers:** `+3` → `+5` is fine (you don't need `+4`)

### APK Requirements

- **Must have `.apk` extension**
- **Must be a valid Android APK**
- **Must be signed** (release builds are automatically signed)

---

## 🚨 Troubleshooting

### Users Not Getting Update Notifications

1. **Check GitHub Release:**
   - Is the release published?
   - Is it set as "latest release"?
   - Does the tag match the format `vX.Y.Z+BUILD`?

2. **Check APK:**
   - Is the APK file attached to the release?
   - Does it have `.apk` extension?

3. **Check Version:**
   - Is the build number higher than current app version?
   - Compare: Current app `1.0.2+3` vs Release `v1.0.3+4` ✅

4. **Check Dismissal:**
   - User might have dismissed the update
   - They can manually check via Drawer Menu → "Check for Updates"

### Download Fails

- **Check Internet:** User needs internet connection
- **Check Permissions:** App needs storage/install permissions
- **Check Storage:** User needs free storage space

### Installation Fails

- **Check Android Version:** Requires Android 6.0+
- **Check Unknown Sources:** User may need to enable "Install from Unknown Sources"
- **Check FileProvider:** Ensure `file_paths.xml` is configured correctly

---

## 📝 Example Release Workflow

### Scenario: Releasing v1.0.3 with bug fixes

1. **Update `pubspec.yaml`:**
   ```yaml
   version: 1.0.3+4  # Was 1.0.2+3, now 1.0.3+4
   ```

2. **Build APK:**
   ```bash
   flutter clean && flutter pub get && flutter build apk --release
   ```

3. **Create GitHub Release:**
   - Tag: `v1.0.3+4`
   - Title: `EC Saver v1.0.3 - Bug Fixes`
   - Description:
     ```
     ## Bug Fixes
     - Fixed update notification not showing
     - Fixed crash when viewing records
     - Improved app stability
     ```
   - Upload: `build/app/outputs/flutter-apk/app-release.apk`
   - Publish

4. **Verify:**
   - Check: https://github.com/Rehancodecraft/EC-Saver/releases/latest
   - Test on a device with older version installed

---

## 🔄 Quick Reference Checklist

Before releasing, ensure:

- [ ] Version updated in `pubspec.yaml` (format: `X.Y.Z+BUILD`)
- [ ] Build number is higher than previous release
- [ ] Code tested and working
- [ ] Release APK built successfully
- [ ] GitHub release created with correct tag format (`vX.Y.Z+BUILD`)
- [ ] APK file attached to release
- [ ] Release notes written
- [ ] Release published and set as "latest"

---

## 📞 Support

If you encounter issues:

1. Check the debug logs (look for `DEBUG: UpdateService` messages)
2. Verify GitHub API response: `curl https://api.github.com/repos/Rehancodecraft/EC-Saver/releases/latest`
3. Test on a device with an older version installed
4. Check Android logs: `adb logcat | grep -i update`

---

## 🎉 That's It!

Your users will now automatically be notified when you release updates. The update process is seamless and preserves all their data.

**Remember:** Always increment the build number, and use the correct tag format (`vX.Y.Z+BUILD`) for GitHub releases!

