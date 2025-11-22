# 🚀 Release v1.0.8 - Step by Step Guide

## ✅ Step 1: Update Version (Already Done)
- `pubspec.yaml` has been updated to `version: 1.0.8+8`

## 📝 Step 2: Commit and Push Changes

```bash
# Add all changes
git add pubspec.yaml

# Commit with descriptive message
git commit -m "Prepare release v1.0.8+8"

# Push to main branch
git push origin main
```

## 🏷️ Step 3: Create and Push Tag

**Option A: Simple Tag (Recommended)**
```bash
# Create tag v1.0.8
git tag v1.0.8

# Push the tag to trigger GitHub Actions
git push origin v1.0.8
```

**Option B: Tag with Build Number (Explicit)**
```bash
# Create tag v1.0.8+8
git tag v1.0.8+8

# Push the tag
git push origin v1.0.8+8
```

## ⚙️ Step 4: Automatic Process (GitHub Actions)

Once you push the tag, GitHub Actions will automatically:

1. ✅ **Extract Version**: Gets `1.0.8` from tag `v1.0.8`
2. ✅ **Get Build Number**: Uses `8` from `pubspec.yaml` (since version matches)
3. ✅ **Update pubspec.yaml**: Sets to `1.0.8+8`
4. ✅ **Verify Version**: Confirms version is correct
5. ✅ **Build APK**: Creates APK with version `1.0.8` (build `8`)
6. ✅ **Create Release**: Creates GitHub release `v1.0.8`
7. ✅ **Upload APK**: Uploads `ec-saver-v1.0.8-release.apk`

## 🔍 Step 5: Verify Release

1. **Check GitHub Actions**:
   - Go to: https://github.com/Rehancodecraft/EC-Saver/actions
   - Wait for workflow to complete (usually 5-10 minutes)
   - Check for green checkmark ✅

2. **Check GitHub Releases**:
   - Go to: https://github.com/Rehancodecraft/EC-Saver/releases
   - Verify `v1.0.8` release exists
   - Verify APK file is attached

3. **Check Landing Page**:
   - Visit your landing page
   - Should show: `Version: v1.0.8`
   - Download button should work

## 📱 Step 6: Test Installation

1. **Download from Landing Page**:
   - Click download button
   - Should download `ec-saver-v1.0.8-release.apk`

2. **Install on Device**:
   - Uninstall old version (if upgrading)
   - Install new APK
   - Open app

3. **Verify Version**:
   - Go to About screen
   - Should show: `Version 1.0.8+8`
   - Check app info in device settings
   - Should show: `1.0.8`

## 🎯 Quick Command Summary

```bash
# Complete release process in one go:
git add pubspec.yaml
git commit -m "Prepare release v1.0.8+8"
git push origin main
git tag v1.0.8
git push origin v1.0.8
```

## 🔄 How Automatic Detection Works

1. **Landing Page**:
   - Fetches latest release from GitHub API
   - Automatically shows `v1.0.8` when release is created
   - Downloads correct APK automatically

2. **App Update Check**:
   - On app start, checks GitHub releases API
   - Compares installed version (`1.0.7+7`) with latest (`1.0.8+8`)
   - Shows update dialog if newer version available

3. **Version Display**:
   - About screen reads from installed APK
   - Shows `Version 1.0.8+8` after installation
   - App info shows `1.0.8`

## ⚠️ Important Notes

- **Always update `pubspec.yaml` first** before creating tag
- **Tag format**: Use `v1.0.8` (workflow handles build number automatically)
- **Build number**: Increments automatically if version changes
- **Release overwrite**: Workflow can overwrite existing releases if needed
- **No manual intervention**: Everything is automatic after tag push

## 🐛 Troubleshooting

**If workflow fails:**
- Check GitHub Actions logs
- Verify tag format is correct (`v1.0.8`)
- Ensure `pubspec.yaml` has correct version

**If landing page shows old version:**
- Clear browser cache
- Check GitHub releases page
- Verify release exists and has APK

**If app shows wrong version:**
- Uninstall completely
- Download fresh APK
- Reinstall

---

**That's it!** Once you push the tag, everything happens automatically. 🎉

