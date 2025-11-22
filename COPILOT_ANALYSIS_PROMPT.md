# 🔍 Prompt for GitHub Copilot - Workflow Analysis

Copy and paste this prompt to GitHub Copilot to analyze the GitHub Actions build failures:

---

## Prompt to Give Copilot:

```
I need you to analyze the GitHub Actions workflow failures for the repository Rehancodecraft/EC-Saver. 

Please check the latest workflow runs for the "Build and Release APK" workflow and provide me with:

1. **Latest Workflow Run Status**:
   - What is the conclusion (success/failure/cancelled)?
   - When was the last run?
   - What commit triggered it?

2. **Failing Step Analysis**:
   - Which step is failing?
   - What is the exact error message?
   - Copy the full error output from the logs

3. **Specific Issues to Check**:
   - Is the "Fix Gradle compatibility issues" step finding the app_links plugin?
   - Is the plugin fix being applied correctly?
   - Are there any Gradle build errors?
   - Is the version extraction working (should extract 1.0.9 from tag v1.0.9)?
   - Are there any memory issues (OutOfMemoryError)?
   - Is the APK being created successfully?
   - Is the release creation step failing?

4. **Error Logs**:
   - Copy the last 50-100 lines of the build log
   - Look for any "FAILURE", "ERROR", "Exception", or "failed" messages
   - Check for Gradle-specific errors
   - Check for plugin-related errors

5. **Workflow Configuration**:
   - Verify the workflow file is correct
   - Check if all steps are executing
   - Identify which step is the first to fail

6. **Common Issues to Check**:
   - Android Gradle Plugin version conflicts
   - Kotlin version issues
   - app_links plugin compatibility
   - Missing dependencies
   - Version extraction problems
   - APK file not found after build
   - Release creation permissions

Please provide:
- A summary of what's failing
- The exact error messages
- Which step is causing the failure
- Any relevant log excerpts
- Suggestions for what might be wrong

Repository: Rehancodecraft/EC-Saver
Workflow: Build and Release APK
Latest tag attempted: v1.0.9 (or check what the latest tag is)
```

---

## Alternative Shorter Prompt:

```
Analyze the GitHub Actions workflow failures for Rehancodecraft/EC-Saver repository. 

Check the latest "Build and Release APK" workflow run and tell me:
1. What step is failing?
2. What is the exact error message?
3. Copy the error output from the logs
4. Is the app_links plugin fix working?
5. Are there any Gradle build errors?
6. What's the root cause of the failure?

Provide the full error logs and suggest fixes.
```

---

## If You Want More Detailed Analysis:

```
I'm having GitHub Actions build failures for my Flutter Android app. Please:

1. Check the latest workflow run for "Build and Release APK" in Rehancodecraft/EC-Saver
2. Analyze the complete build log
3. Identify ALL errors and warnings
4. Check each step:
   - Plugin fix step: Did it find and fix app_links?
   - Gradle configuration: Are memory settings applied?
   - Version extraction: Did it extract version correctly?
   - Build step: What Gradle errors occurred?
   - APK verification: Was APK created?
   - Release step: Did it create the release?

5. Provide:
   - Full error stack traces
   - Step-by-step analysis
   - Root cause identification
   - Specific fix recommendations

Focus on:
- app_links plugin compatibility issues
- Android Gradle Plugin (AGP) version conflicts
- Kotlin version mismatches
- Build failures
- APK creation issues
```

---

## Quick Check Prompt:

```
Check the latest GitHub Actions run for Rehancodecraft/EC-Saver "Build and Release APK" workflow. 

What failed and why? Give me the error message.
```

---

## How to Use:

1. **Open GitHub Copilot Chat** in your IDE or GitHub
2. **Copy one of the prompts above** (start with the shorter one)
3. **Paste it to Copilot**
4. **Wait for analysis**
5. **Share the results** so we can fix the issues

---

## What to Look For in Copilot's Response:

✅ **Good Response Should Include:**
- Exact error messages
- Failing step name
- Error stack traces
- Log excerpts
- Root cause analysis

❌ **If Copilot Can't Access Logs:**
- Ask it to check the workflow file syntax
- Ask it to analyze potential issues based on the workflow YAML
- Ask for general troubleshooting steps

---

## After Getting Copilot's Analysis:

Share the results with me and I'll:
1. Fix the specific errors identified
2. Update the workflow if needed
3. Test the fixes
4. Ensure the build succeeds

---

**Note:** Copilot may not have direct access to private repository logs. If that's the case, you can:
- Copy the error logs manually from GitHub Actions
- Share them with me directly
- Or ask Copilot to analyze the workflow file itself for potential issues

