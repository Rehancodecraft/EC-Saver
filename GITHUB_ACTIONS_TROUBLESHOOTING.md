# GitHub Actions APK Build Troubleshooting Guide

## Common Issues and Solutions

### 1. **Build Fails with "Android SDK not found"**

**Solution:**
The workflow now includes proper Android SDK setup. If it still fails:
- Check that the Flutter version (3.24.5) is available
- Verify the workflow uses `subosito/flutter-action@v2`

### 2. **Build Fails with "License not accepted"**

**Solution:**
The workflow now automatically accepts Android licenses. If issues persist:
- The workflow includes a fallback license acceptance step
- Check the workflow logs for specific license errors

### 3. **Build Fails with "Gradle build failed"**

**Common Causes:**
- Missing dependencies
- Version conflicts
- Memory issues

**Solutions:**
```yaml
# Add to workflow if needed:
- name: Increase Gradle memory
  run: |
    echo "org.gradle.jvmargs=-Xmx4096m -XX:MaxMetaspaceSize=1024m" >> android/gradle.properties
```

### 4. **APK File Not Found After Build**

**Solution:**
The workflow now includes a verification step that:
- Checks if APK exists
- Lists directory contents if not found
- Provides clear error messages

### 5. **Version Extraction Fails**

**Solution:**
The workflow now uses robust version extraction:
```bash
VERSION=$(grep '^version:' pubspec.yaml | sed 's/version: //' | cut -d '+' -f1 | tr -d ' ')
```

Make sure your `pubspec.yaml` has:
```yaml
version: 1.0.2+3
```

### 6. **Release Creation Fails**

**Common Causes:**
- Missing `GITHUB_TOKEN` permissions
- Tag already exists
- Insufficient permissions

**Solutions:**
- Ensure workflow has `contents: write` permission
- Delete existing tag if recreating release
- Check repository settings for workflow permissions

### 7. **Build Times Out**

**Solution:**
- The workflow uses caching (`cache: true`)
- Consider using `--split-per-abi` for faster builds
- Increase runner timeout if needed

### 8. **Dependencies Fail to Install**

**Solution:**
- Check `pubspec.yaml` for valid dependencies
- Run `flutter pub get` locally to verify
- Check for network issues in workflow logs

## Workflow Improvements Made

✅ **Added proper permissions** (`contents: write`)
✅ **Added Android SDK setup** with license acceptance
✅ **Added APK verification** step
✅ **Improved version extraction** with error handling
✅ **Added build verification** steps
✅ **Better error messages** throughout
✅ **Removed deprecated actions** (create-release@v1, upload-release-asset@v1)

## Testing the Workflow

1. **Manual Trigger:**
   - Go to Actions tab
   - Select "Build and Release APK"
   - Click "Run workflow"

2. **Tag Trigger:**
   ```bash
   git tag v1.0.3
   git push origin v1.0.3
   ```

3. **Check Logs:**
   - View detailed logs in Actions tab
   - Look for specific error messages
   - Check each step's output

## Debugging Tips

1. **Enable Debug Logging:**
   Add to workflow:
   ```yaml
   env:
     ACTIONS_STEP_DEBUG: true
     ACTIONS_RUNNER_DEBUG: true
   ```

2. **Check Flutter Doctor:**
   The workflow runs `flutter doctor -v` to show environment details

3. **Verify Dependencies:**
   Check that all dependencies in `pubspec.yaml` are valid

4. **Test Locally:**
   ```bash
   flutter clean
   flutter pub get
   flutter build apk --release
   ```

## Common Error Messages

### "Error: Process completed with exit code 1"
- Check the step that failed
- Look for specific error messages above this line

### "Gradle build failed"
- Check Android SDK setup
- Verify Gradle version compatibility
- Check for dependency conflicts

### "APK file not found"
- Check build output directory
- Verify build completed successfully
- Check for build errors in previous steps

### "Permission denied"
- Check workflow permissions
- Verify GITHUB_TOKEN has write access
- Check repository settings

## Next Steps

If the build still fails:
1. Check the Actions tab for detailed error logs
2. Compare with local build (should work the same)
3. Verify all dependencies are up to date
4. Check Flutter and Android SDK versions
5. Review recent changes to codebase

## Support

If issues persist:
- Check GitHub Actions documentation
- Review Flutter build documentation
- Check Android Gradle plugin compatibility
- Verify all environment requirements

