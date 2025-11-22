#!/bin/bash
# Script to fetch and analyze GitHub Actions workflow logs

echo "🔍 Fetching GitHub Actions Workflow Logs..."
echo ""

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) is not installed."
    echo "📥 Install it: https://cli.github.com/"
    echo ""
    echo "Alternatively, manually download logs from:"
    echo "https://github.com/Rehancodecraft/EC-Saver/actions"
    exit 1
fi

# Check if authenticated
if ! gh auth status &> /dev/null; then
    echo "🔐 Not authenticated. Please run: gh auth login"
    exit 1
fi

REPO="Rehancodecraft/EC-Saver"
WORKFLOW_FILE=".github/workflows/build-release.yml"

echo "📋 Listing latest workflow runs..."
echo ""

# List latest runs
gh run list --workflow "$WORKFLOW_FILE" -R "$REPO" --limit 5

echo ""
echo "📥 Fetching latest run details..."
LATEST_RUN=$(gh run list --workflow "$WORKFLOW_FILE" -R "$REPO" --limit 1 --json databaseId,conclusion,status,createdAt,headBranch,displayTitle --jq '.[0]')

if [ -z "$LATEST_RUN" ] || [ "$LATEST_RUN" == "null" ]; then
    echo "❌ No workflow runs found!"
    exit 1
fi

RUN_ID=$(echo "$LATEST_RUN" | jq -r '.databaseId')
CONCLUSION=$(echo "$LATEST_RUN" | jq -r '.conclusion')
STATUS=$(echo "$LATEST_RUN" | jq -r '.status')
CREATED=$(echo "$LATEST_RUN" | jq -r '.createdAt')
BRANCH=$(echo "$LATEST_RUN" | jq -r '.headBranch')
TITLE=$(echo "$LATEST_RUN" | jq -r '.displayTitle')

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "📊 Latest Workflow Run Summary"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Run ID: $RUN_ID"
echo "Status: $STATUS"
echo "Conclusion: $CONCLUSION"
echo "Created: $CREATED"
echo "Branch: $BRANCH"
echo "Title: $TITLE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Download full logs
LOG_FILE="workflow_log_${RUN_ID}.txt"
echo "📥 Downloading full logs to: $LOG_FILE"
gh run view "$RUN_ID" --log -R "$REPO" > "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "✅ Logs downloaded successfully!"
    echo ""
    
    # Analyze logs
    echo "🔍 Analyzing logs for errors..."
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ ERRORS FOUND:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    grep -nE 'FAILURE|ERROR|Exception|failed|OutOfMemoryError|BUILD FAILED' "$LOG_FILE" | head -20
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🔧 PLUGIN FIX CHECK:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    grep -nE 'app_links|Fix Gradle|plugin fix' "$LOG_FILE" | head -10
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📦 VERSION EXTRACTION:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    grep -nE 'Version|version|TAG|tag|Extracted' "$LOG_FILE" | head -10
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📱 APK BUILD STATUS:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    grep -nE 'APK|apk|BUILD SUCCESSFUL|BUILD FAILED|outputs/apk' "$LOG_FILE" | head -10
    echo ""
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📄 LAST 50 LINES:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    tail -50 "$LOG_FILE"
    echo ""
    
    echo "✅ Full log saved to: $LOG_FILE"
    echo "📋 View in browser: https://github.com/$REPO/actions/runs/$RUN_ID"
else
    echo "❌ Failed to download logs"
    exit 1
fi

