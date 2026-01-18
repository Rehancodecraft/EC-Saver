# GitHub Secrets Setup for APK Signing

## ⚠️ CRITICAL: Fix "App Not Installed" Error

The "app not installed" error happens because **GitHub Actions builds APKs with debug signing**, while your local builds use **release signing**. When you try to install one over the other, Android rejects it due to **signature mismatch**.

### Solution: Add Keystore to GitHub Secrets

Follow these steps to make GitHub Actions sign APKs with the same keystore as your local builds:

---

## Step 1: Get Keystore Base64 Encoding

Your keystore has already been encoded. The base64 string is saved in: `/tmp/keystore_base64.txt`

To view it:
```bash
cat /tmp/keystore_base64.txt
```

---

## Step 2: Add Secrets to GitHub

1. Go to your repository: https://github.com/Rehancodecraft/EC-Saver

2. Click **Settings** → **Secrets and variables** → **Actions**

3. Click **New repository secret** and add each of these:

### Secret 1: KEYSTORE_BASE64
- **Name:** `KEYSTORE_BASE64`
- **Value:** Paste the entire content from `/tmp/keystore_base64.txt`

### Secret 2: KEYSTORE_PASSWORD
- **Name:** `KEYSTORE_PASSWORD`
- **Value:** `rescue1122`

### Secret 3: KEY_ALIAS
- **Name:** `KEY_ALIAS`
- **Value:** `upload`

### Secret 4: KEY_PASSWORD
- **Name:** `KEY_PASSWORD`
- **Value:** `rescue1122`

---

## Step 3: Verify Secrets

After adding all secrets, you should see:
- ✅ KEYSTORE_BASE64
- ✅ KEYSTORE_PASSWORD
- ✅ KEY_ALIAS
- ✅ KEY_PASSWORD

---

## Step 4: Push New Tag

Once secrets are added, the next GitHub Actions build will sign APKs properly:

```bash
# The assistant will do this automatically after you confirm
git push origin v1.3.4
```

---

## Step 5: Test Installation

After GitHub Actions builds the APK:

1. **If you have the old app installed:**
   - **Uninstall it first** (Settings → Apps → EC Saver → Uninstall)
   - This is necessary because old app has a different signature

2. **Download and install the new APK**
   - The new APK from GitHub will be properly signed
   - Future updates will work seamlessly

---

## Why This Fixes the Problem

### Before (Broken):
- Local builds: Signed with `upload-keystore.jks` ✅
- GitHub builds: Signed with debug key ❌
- Result: **Signature mismatch → "App not installed"**

### After (Fixed):
- Local builds: Signed with `upload-keystore.jks` ✅
- GitHub builds: Signed with `upload-keystore.jks` ✅
- Result: **Same signature → Installation works!**

---

## Security Notes

- GitHub Secrets are encrypted and never exposed in logs
- Only workflows in your repository can access them
- Never commit keystore files to Git (they're in .gitignore)
- The base64 encoding is just for storage; GitHub decodes it during builds

---

## Next Steps

After adding secrets:
1. Push new tag (v1.3.4)
2. Wait for GitHub Actions to build (~5-10 minutes)
3. Uninstall old app (if installed)
4. Install new APK
5. Future updates will work automatically!

