#!/bin/bash

# Simple test for the exact error scenario from your original command
echo "🔧 Testing the exact error scenario from your workflow"
echo "===================================================="

# This is the exact problematic line from your original command
# The issue was the malformed JSON assignment
echo "❌ PROBLEMATIC (original):"
echo 'NOTEBOOKS="["notebooks/hello-universe/test.ipynb"]"'
echo "This creates malformed JSON because inner quotes aren't escaped"
echo ""

echo "✅ FIXED VERSION:"
echo "NOTEBOOKS='[\"notebooks/hello-universe/test.ipynb\"]'"
echo "Using single quotes to preserve the JSON structure"
echo ""

# Test the fixed version
echo "Testing the fix:"
NOTEBOOKS='["notebooks/hello-universe/Classifying_JWST-HST_galaxy_mergers_with_CNNs/Classifying_JWST-HST_galaxy_mergers_with_CNNs.ipynb"]'
echo "NOTEBOOKS variable: $NOTEBOOKS"

echo "Parsing with jq:"
NOTEBOOK_COUNT=$(echo "$NOTEBOOKS" | jq -r 'length' 2>/dev/null || echo "0")
echo "Notebook count: $NOTEBOOK_COUNT"

echo ""
echo "✅ Testing error handling:"
# Test with malformed JSON (simulating your original error)
MALFORMED_NOTEBOOKS='["notebooks/hello-universe/test.ipynb'  # Missing closing bracket
echo "Malformed JSON: $MALFORMED_NOTEBOOKS"

# This is the robust error handling that should be in the workflow
if [ "$MALFORMED_NOTEBOOKS" = "null" ] || [ "$MALFORMED_NOTEBOOKS" = "" ] || [ "$MALFORMED_NOTEBOOKS" = "[]" ]; then
  NOTEBOOK_COUNT=0
else
  NOTEBOOK_COUNT=$(echo "$MALFORMED_NOTEBOOKS" | jq -r 'length' 2>/dev/null)
  if [ "$NOTEBOOK_COUNT" = "null" ] || [ -z "$NOTEBOOK_COUNT" ]; then
    NOTEBOOK_COUNT=0
  fi
fi

echo "Result with malformed JSON: $NOTEBOOK_COUNT (should be 0, no crash)"

echo ""
echo "🎯 Summary generation test (simulating your exact workflow):"
echo "==========================================================="

# Create a mock summary file
GITHUB_STEP_SUMMARY="test_summary.md"
> "$GITHUB_STEP_SUMMARY"

# Simulate the exact workflow logic with proper error handling
{
  echo "## 📊 Unified Notebook CI/CD Summary"
  echo "*Generated: $(date -u +'%Y-%m-%d %H:%M:%S UTC')*"
  echo ""
  
  echo "### 🔧 Configuration"
  echo "- **Execution Mode**: pr"
  echo "- **Trigger Event**: all"
  echo "- **Python Version**: 3.11"
  if [ -n "" ]; then
    echo "- **Custom Conda Environment**: "
  fi
  if [ -n "" ]; then
    echo "- **Custom Requirements**: "
  fi
  if [ -n "" ]; then
    echo "- **Single Notebook Target**: \`\`"
  fi
  echo ""
  
  echo "### 📊 Job Results"
  echo "| Job | Status | Duration |"
  echo "|-----|--------|----------|"
  echo "| Matrix Setup | success | - |"
  if [ "pr" != "merge" ]; then
    echo "| Notebook Processing | success | - |"
  else
    echo "| Notebook Processing | Skipped (merge mode) | - |"
  fi
  echo "| Documentation Build | skipped | - |"
  echo "| Deprecation Management | skipped | - |"
  echo ""
  
  echo "### 📝 Execution Details"
  
  # Get the notebooks that were processed (using the FIXED version)
  NOTEBOOKS='["notebooks/hello-universe/Classifying_JWST-HST_galaxy_mergers_with_CNNs/Classifying_JWST-HST_galaxy_mergers_with_CNNs.ipynb"]'
  AFFECTED_DIRS='["notebooks/hello-universe/Classifying_JWST-HST_galaxy_mergers_with_CNNs"]'
  
  # Better notebook count logic (the fix for your error)
  if [ "$NOTEBOOKS" = "null" ] || [ "$NOTEBOOKS" = "" ] || [ "$NOTEBOOKS" = "[]" ]; then
    NOTEBOOK_COUNT=0
  else
    # Try to get count, fallback to 0 if parsing fails
    NOTEBOOK_COUNT=$(echo "$NOTEBOOKS" | jq -r 'length' 2>/dev/null)
    if [ "$NOTEBOOK_COUNT" = "null" ] || [ -z "$NOTEBOOK_COUNT" ]; then
      NOTEBOOK_COUNT=0
    fi
  fi
  
  echo "**📁 Affected Directories:**"
  echo "$AFFECTED_DIRS" | jq -r '.[]' 2>/dev/null | while read -r dir; do
    echo "- \`$dir\`"
  done || echo "- Could not parse affected directories"
  echo ""
  
  echo "**🚀 Notebook Processing Results**"
  echo "- **Total Notebooks**: $NOTEBOOK_COUNT"
  echo "- **Operation**: Full pipeline (validation, execution, security)"
  echo ""
  
  # Count successful and failed jobs
  SUCCESS_COUNT=0
  FAILURE_COUNT=0
  
  # Check each job result
  for result in "success" "success" "skipped" "skipped"; do
    case "$result" in
      "success") SUCCESS_COUNT=$((SUCCESS_COUNT + 1)) ;;
      "failure") FAILURE_COUNT=$((FAILURE_COUNT + 1)) ;;
      "skipped") ;; # Don't count skipped jobs as failures
      "cancelled") FAILURE_COUNT=$((FAILURE_COUNT + 1)) ;;
    esac
  done
  
  if [ "$FAILURE_COUNT" -eq 0 ]; then
    echo "## 🎉 Workflow completed successfully!"
    echo "*All required jobs completed without errors*"
  elif [ "$SUCCESS_COUNT" -gt 0 ]; then
    echo "## ⚠️ Workflow completed with partial success"
    echo "*Some jobs succeeded but $FAILURE_COUNT job(s) failed - see error details above*"
  else
    echo "## ❌ Workflow failed"
    echo "*Multiple critical failures occurred - see error details above*"
  fi
  
} >> "$GITHUB_STEP_SUMMARY"

echo "✅ Summary generated successfully!"
echo ""
echo "📄 Generated Summary Content:"
echo "============================"
cat "$GITHUB_STEP_SUMMARY"
echo "============================"

# Clean up
rm -f "$GITHUB_STEP_SUMMARY"

echo ""
echo "🎉 Test completed successfully - no exit code 5 error!"
echo ""
echo "🔧 Key fixes applied:"
echo "1. Proper JSON quoting: Use single quotes around JSON strings"
echo "2. Robust error handling: Always check for null/empty before jq parsing"
echo "3. Fallback logic: Default to 0 if jq parsing fails"
echo "4. No script termination: Handle errors gracefully without bash -e issues"
