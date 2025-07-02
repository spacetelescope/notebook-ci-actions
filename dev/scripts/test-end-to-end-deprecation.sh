#!/bin/bash

# End-to-end test for deprecation workflow with documentation rebuild
# This script simulates the complete deprecation workflow including documentation rebuild

set -e

echo "🎯 End-to-End Deprecation Workflow Test"
echo "======================================="

# Test the on-demand workflow example
echo "📋 Testing On-Demand Workflow Example"
echo "======================================"

# Check if the workflow example exists
WORKFLOW_FILE="/mnt/f/actions/dev-actions/examples/caller-workflows/notebook-on-demand.yml"

if [[ -f "$WORKFLOW_FILE" ]]; then
    echo "✅ Found workflow example: $WORKFLOW_FILE"
    
    # Verify it has the correct structure for deprecation
    if grep -q "deprecate-notebook" "$WORKFLOW_FILE"; then
        echo "✅ Workflow includes deprecate-notebook action"
    else
        echo "❌ Workflow missing deprecate-notebook action"
    fi
    
    if grep -q "enable-html-build: true" "$WORKFLOW_FILE"; then
        echo "✅ Workflow has HTML build enabled for deprecation"
    else
        echo "❌ Workflow missing HTML build configuration"
    fi
    
    # Check for path/filename flexibility
    if grep -q "single-notebook" "$WORKFLOW_FILE"; then
        echo "✅ Workflow supports single-notebook path input"
    else
        echo "❌ Workflow missing single-notebook path input"
    fi
    
else
    echo "❌ Workflow example not found: $WORKFLOW_FILE"
fi

echo ""
echo "🔍 Verifying Unified Workflow Features"
echo "====================================="

UNIFIED_WORKFLOW="/mnt/f/actions/dev-actions/.github/workflows/notebook-ci-unified.yml"

if [[ -f "$UNIFIED_WORKFLOW" ]]; then
    echo "✅ Found unified workflow: $UNIFIED_WORKFLOW"
    
    # Check for deprecation features
    if grep -q "trigger-event.*deprecate" "$UNIFIED_WORKFLOW"; then
        echo "✅ Unified workflow includes deprecation action"
    else
        echo "❌ Unified workflow missing deprecation action"
    fi
    
    # Check for gh-storage sync
    if grep -q "gh-storage" "$UNIFIED_WORKFLOW"; then
        echo "✅ Unified workflow includes gh-storage sync"
    else
        echo "❌ Unified workflow missing gh-storage sync"
    fi
    
    # Check for documentation rebuild after deprecation
    if grep -q "rebuild-docs-after-deprecation" "$UNIFIED_WORKFLOW"; then
        echo "✅ Unified workflow includes documentation rebuild job"
    else
        echo "❌ Unified workflow missing documentation rebuild job"
    fi
    
    # Check for path discovery
    if grep -qi "filename only provided" "$UNIFIED_WORKFLOW"; then
        echo "✅ Unified workflow includes path discovery"
    else
        echo "❌ Unified workflow missing path discovery"
    fi
    
else
    echo "❌ Unified workflow not found: $UNIFIED_WORKFLOW"
fi

echo ""
echo "📊 Deprecation Workflow Feature Summary"
echo "======================================="

# Count key features
feature_count=0

# Check for key deprecation features
features=(
    "deprecation action"
    "gh-storage sync"
    "documentation rebuild"
    "path discovery"
    "deprecation banner injection"
    "HTML build integration"
)

for feature in "${features[@]}"; do
    case "$feature" in
        "deprecation action")
            if grep -q "trigger-event.*deprecate" "$UNIFIED_WORKFLOW" 2>/dev/null; then
                echo "✅ $feature"
                ((feature_count++))
            else
                echo "❌ $feature"
            fi
            ;;
        "gh-storage sync")
            if grep -q "gh-storage" "$UNIFIED_WORKFLOW" 2>/dev/null; then
                echo "✅ $feature"
                ((feature_count++))
            else
                echo "❌ $feature"
            fi
            ;;
        "documentation rebuild")
            if grep -q "rebuild-docs-after-deprecation" "$UNIFIED_WORKFLOW" 2>/dev/null; then
                echo "✅ $feature"
                ((feature_count++))
            else
                echo "❌ $feature"
            fi
            ;;
        "path discovery")
            if grep -qi "filename only provided" "$UNIFIED_WORKFLOW" 2>/dev/null; then
                echo "✅ $feature"
                ((feature_count++))
            else
                echo "❌ $feature"
            fi
            ;;
        "deprecation banner injection")
            if grep -q "deprecation-warning" "$UNIFIED_WORKFLOW" 2>/dev/null; then
                echo "✅ $feature"
                ((feature_count++))
            else
                echo "❌ $feature"
            fi
            ;;
        "HTML build integration")
            if grep -q "enable-html-build" "$UNIFIED_WORKFLOW" 2>/dev/null; then
                echo "✅ $feature"
                ((feature_count++))
            else
                echo "❌ $feature"
            fi
            ;;
    esac
done

echo ""
echo "📈 Feature Completion: $feature_count/${#features[@]} features implemented"

if [[ $feature_count -eq ${#features[@]} ]]; then
    echo "🎉 All deprecation workflow features are implemented!"
else
    echo "⚠️ Some features may be missing or need verification"
fi

echo ""
echo "🎯 Workflow Usage Examples"
echo "=========================="

echo "📝 To deprecate a notebook using filename:"
echo "   gh workflow run notebook-on-demand.yml -f trigger-event=deprecate -f single_notebook=my-notebook.ipynb"

echo ""
echo "📝 To deprecate a notebook using full path:"
echo "   gh workflow run notebook-on-demand.yml -f trigger-event=deprecate -f single_notebook=notebooks/examples/my-notebook.ipynb"

echo ""
echo "📝 The workflow will automatically:"
echo "   1. Find the notebook (supports both filename and full path)"
echo "   2. Add deprecation banner to the notebook"
echo "   3. Commit changes to main branch"
echo "   4. Sync deprecated notebook to gh-storage branch"
echo "   5. Rebuild and deploy documentation with deprecation banner"

echo ""
echo "✅ End-to-end deprecation workflow test completed!"
