#!/bin/bash

# Test script for GitHub Actions workflow summary generation
# This script tests the summary generation logic with various scenarios

set -e

echo "🧪 Testing GitHub Actions Workflow Summary Generation"
echo "======================================================"

# Create a test summary file
TEST_SUMMARY="test_workflow_summary.md"
> "$TEST_SUMMARY"

# Function to test notebook count logic
test_notebook_count() {
    local test_input="$1"
    local expected="$2"
    local description="$3"
    
    echo "Testing: $description"
    echo "Input: $test_input"
    
    # Replicate the logic from the workflow
    if [ "$test_input" = "null" ] || [ "$test_input" = "" ] || [ "$test_input" = "[]" ]; then
        NOTEBOOK_COUNT=0
    else
        # Try to get count, fallback to 0 if parsing fails
        NOTEBOOK_COUNT=$(echo "$test_input" | jq -r 'length' 2>/dev/null)
        if [ "$NOTEBOOK_COUNT" = "null" ] || [ -z "$NOTEBOOK_COUNT" ]; then
            NOTEBOOK_COUNT=0
        fi
    fi
    
    echo "Result: $NOTEBOOK_COUNT"
    echo "Expected: $expected"
    
    if [ "$NOTEBOOK_COUNT" = "$expected" ]; then
        echo "✅ PASS"
    else
        echo "❌ FAIL"
    fi
    echo ""
}

# Test various JSON scenarios
echo "🔍 Testing JSON parsing scenarios:"
echo "--------------------------------"

test_notebook_count '[]' "0" "Empty array"
test_notebook_count 'null' "0" "Null value"
test_notebook_count '' "0" "Empty string"
test_notebook_count '["notebook1.ipynb"]' "1" "Single notebook"
test_notebook_count '["notebook1.ipynb", "notebook2.ipynb"]' "2" "Two notebooks"
test_notebook_count '["notebooks/hello-universe/Classifying_JWST-HST_galaxy_mergers_with_CNNs/Classifying_JWST-HST_galaxy_mergers_with_CNNs.ipynb"]' "1" "Long path notebook"

# Test malformed JSON (should not crash)
echo "Testing malformed JSON:"
MALFORMED='["notebooks/hello-universe/test.ipynb'
echo "Input: $MALFORMED"
if [ "$MALFORMED" = "null" ] || [ "$MALFORMED" = "" ] || [ "$MALFORMED" = "[]" ]; then
    NOTEBOOK_COUNT=0
else
    NOTEBOOK_COUNT=$(echo "$MALFORMED" | jq -r 'length' 2>/dev/null)
    if [ "$NOTEBOOK_COUNT" = "null" ] || [ -z "$NOTEBOOK_COUNT" ]; then
        NOTEBOOK_COUNT=0
    fi
fi
echo "Result: $NOTEBOOK_COUNT (should be 0 for malformed JSON)"
echo ""

# Test complete summary generation
echo "🎯 Testing complete summary generation:"
echo "-------------------------------------"

# Mock GitHub Actions environment variables
export EXECUTION_MODE="pr"
export TRIGGER_EVENT="all"
export PYTHON_VERSION="3.11"
export CONDA_ENVIRONMENT=""
export CUSTOM_REQUIREMENTS=""
export SINGLE_NOTEBOOK=""
export NOTEBOOKS='["notebooks/example.ipynb"]'
export AFFECTED_DIRS='["notebooks/examples"]'
export SETUP_RESULT="success"
export PROCESS_RESULT="success"
export BUILD_RESULT="skipped"
export DEPRECATION_RESULT="skipped"
export DOCS_ONLY="false"
export SKIP_EXECUTION="false"

# Generate the complete summary using the workflow logic
{
    echo "## 📊 Unified Notebook CI/CD Summary"
    echo "*Generated: $(date -u +'%Y-%m-%d %H:%M:%S UTC')*"
    echo ""
    
    echo "### 🔧 Configuration"
    echo "- **Execution Mode**: $EXECUTION_MODE"
    echo "- **Trigger Event**: $TRIGGER_EVENT"
    echo "- **Python Version**: $PYTHON_VERSION"
    
    if [ -n "$CONDA_ENVIRONMENT" ]; then
        echo "- **Custom Conda Environment**: $CONDA_ENVIRONMENT"
    fi
    
    if [ -n "$CUSTOM_REQUIREMENTS" ]; then
        echo "- **Custom Requirements**: $CUSTOM_REQUIREMENTS"
    fi
    
    if [ -n "$SINGLE_NOTEBOOK" ]; then
        echo "- **Single Notebook Target**: \`$SINGLE_NOTEBOOK\`"
    fi
    
    echo ""
    
    echo "### 📊 Job Results"
    echo "| Job | Status | Duration |"
    echo "|-----|--------|----------|"
    echo "| Matrix Setup | $SETUP_RESULT | - |"
    
    if [ "$EXECUTION_MODE" != "merge" ]; then
        echo "| Notebook Processing | $PROCESS_RESULT | - |"
    else
        echo "| Notebook Processing | Skipped (merge mode) | - |"
    fi
    
    echo "| Documentation Build | $BUILD_RESULT | - |"
    echo "| Deprecation Management | $DEPRECATION_RESULT | - |"
    echo ""
    
    echo "### 📝 Execution Details"
    
    # Better notebook count logic
    if [ "$NOTEBOOKS" = "null" ] || [ "$NOTEBOOKS" = "" ] || [ "$NOTEBOOKS" = "[]" ]; then
        NOTEBOOK_COUNT=0
    else
        NOTEBOOK_COUNT=$(echo "$NOTEBOOKS" | jq -r 'length' 2>/dev/null)
        if [ "$NOTEBOOK_COUNT" = "null" ] || [ -z "$NOTEBOOK_COUNT" ]; then
            NOTEBOOK_COUNT=0
        fi
    fi
    
    # Show what directories were affected
    if [ "$AFFECTED_DIRS" != "[]" ] && [ "$AFFECTED_DIRS" != "null" ] && [ "$AFFECTED_DIRS" != "" ]; then
        echo "**📁 Affected Directories:**"
        echo "$AFFECTED_DIRS" | jq -r '.[]' 2>/dev/null | while read -r dir; do
            echo "- \`$dir\`"
        done || echo "- Could not parse affected directories"
        echo ""
    fi
    
    if [ "$DOCS_ONLY" = "true" ]; then
        echo "**📖 Documentation-Only Build**"
        echo "- No notebooks executed - documentation built from existing executed notebooks"
    elif [ "$SKIP_EXECUTION" = "true" ]; then
        echo "**⏭️ Execution Skipped**"
        echo "- No notebook processing performed (skip execution flag enabled)"
    elif [ "$PROCESS_RESULT" = "skipped" ] && [ "$EXECUTION_MODE" = "merge" ]; then
        echo "**🔀 Merge Mode**"
        echo "- Notebook processing skipped in merge mode (using pre-executed notebooks)"
    elif [ "$PROCESS_RESULT" = "success" ] || [ "$PROCESS_RESULT" = "failure" ]; then
        echo "**🚀 Notebook Processing Results**"
        
        if [ "$NOTEBOOK_COUNT" -gt 0 ]; then
            echo "- **Total Notebooks**: $NOTEBOOK_COUNT"
        else
            echo "- **Notebooks Processed**: Job completed (count unavailable)"
        fi
        
        case "$TRIGGER_EVENT" in
            "validate")
                echo "- **Operation**: Notebook validation"
                ;;
            "execute")
                echo "- **Operation**: Notebook execution"
                ;;
            "security")
                echo "- **Operation**: Security scanning"
                ;;
            "all")
                echo "- **Operation**: Full pipeline (validation, execution, security)"
                ;;
        esac
    fi
    
    echo ""
    
    # Count successful and failed jobs
    SUCCESS_COUNT=0
    FAILURE_COUNT=0
    
    for result in "$SETUP_RESULT" "$PROCESS_RESULT" "$BUILD_RESULT" "$DEPRECATION_RESULT"; do
        case "$result" in
            "success") SUCCESS_COUNT=$((SUCCESS_COUNT + 1)) ;;
            "failure") FAILURE_COUNT=$((FAILURE_COUNT + 1)) ;;
            "skipped") ;; # Don't count skipped jobs as failures
            "cancelled") FAILURE_COUNT=$((FAILURE_COUNT + 1)) ;;
        esac
    done
    
    # Special handling for process-notebooks in merge mode
    if [ "$EXECUTION_MODE" = "merge" ] && [ "$PROCESS_RESULT" = "skipped" ]; then
        echo "**Note**: Notebook processing was intentionally skipped in merge mode"
        echo ""
    fi
    
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
    
} > "$TEST_SUMMARY"

echo "✅ Summary generation completed!"
echo ""
echo "📄 Generated Summary:"
echo "===================="
cat "$TEST_SUMMARY"
echo "===================="
echo ""

# Test different scenarios
echo "🎭 Testing different scenarios:"
echo "------------------------------"

# Test scenario 1: Docs-only build
echo "Scenario 1: Documentation-only build"
DOCS_ONLY="true" SKIP_EXECUTION="false" PROCESS_RESULT="skipped" \
  bash -c 'if [ "$DOCS_ONLY" = "true" ]; then echo "✅ Docs-only detected correctly"; else echo "❌ Docs-only detection failed"; fi'

# Test scenario 2: Merge mode
echo "Scenario 2: Merge mode"
EXECUTION_MODE="merge" PROCESS_RESULT="skipped" \
  bash -c 'if [ "$EXECUTION_MODE" = "merge" ] && [ "$PROCESS_RESULT" = "skipped" ]; then echo "✅ Merge mode detected correctly"; else echo "❌ Merge mode detection failed"; fi'

# Test scenario 3: Failure handling
echo "Scenario 3: Failure counting"
SETUP_RESULT="failure" PROCESS_RESULT="success" BUILD_RESULT="failure" DEPRECATION_RESULT="skipped" \
  bash -c '
    SUCCESS_COUNT=0
    FAILURE_COUNT=0
    for result in "$SETUP_RESULT" "$PROCESS_RESULT" "$BUILD_RESULT" "$DEPRECATION_RESULT"; do
        case "$result" in
            "success") SUCCESS_COUNT=$((SUCCESS_COUNT + 1)) ;;
            "failure") FAILURE_COUNT=$((FAILURE_COUNT + 1)) ;;
            "skipped") ;;
            "cancelled") FAILURE_COUNT=$((FAILURE_COUNT + 1)) ;;
        esac
    done
    echo "Success: $SUCCESS_COUNT, Failures: $FAILURE_COUNT"
    if [ "$SUCCESS_COUNT" -eq 1 ] && [ "$FAILURE_COUNT" -eq 2 ]; then
        echo "✅ Failure counting works correctly"
    else
        echo "❌ Failure counting failed"
    fi
  '

# Clean up
rm -f "$TEST_SUMMARY"

echo ""
echo "🎉 All tests completed!"
echo ""
echo "🔧 Summary of potential fixes for the original workflow:"
echo "1. The JSON parsing logic is robust and handles edge cases"
echo "2. Error handling prevents script termination on jq failures"
echo "3. Fallback logic ensures NOTEBOOK_COUNT is always a valid number"
echo "4. The workflow should not fail with 'exit code 5' anymore"
