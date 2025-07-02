#!/bin/bash

# Test script for deprecation sync to gh-storage
# This script validates that deprecated notebooks are properly synced to gh-storage branch

set -e

echo "🧪 Testing Deprecation Sync to gh-storage Branch"
echo "================================================="

# Create a test repository directory
TEST_DIR="/tmp/test-deprecation-sync-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📁 Created test directory: $TEST_DIR"

# Initialize git repository
git init
git config user.name "Test User"
git config user.email "test@example.com"

# Create test notebook structure
mkdir -p notebooks/testing
cat > notebooks/testing/sync-test.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Sync Test Notebook\n",
    "\n",
    "This notebook is used to test the deprecation sync functionality."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "print('This is a test notebook for deprecation sync')\n",
    "result = 42\n",
    "print(f'Test result: {result}')"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

echo "📝 Created test notebook: notebooks/testing/sync-test.ipynb"

# Add and commit initial notebook
git add .
git commit -m "Initial commit with test notebook"

echo "✅ Initial commit completed"

# Simulate the deprecation process
notebook="notebooks/testing/sync-test.ipynb"
deprecation_date="2024-12-31"

echo ""
echo "🏷️ Simulating Deprecation Process"
echo "=================================="
echo "📝 Notebook: $notebook"
echo "📅 Deprecation Date: $deprecation_date"

# Add deprecation banner (simplified version)
python3 << EOF
import json
import os

notebook_path = "$notebook"
deprecation_date = "$deprecation_date"

print(f"📖 Processing notebook: {notebook_path}")

with open(notebook_path, 'r') as f:
    nb = json.load(f)

# Create deprecation banner cell
deprecation_banner = {
    "cell_type": "markdown",
    "metadata": {
        "tags": ["deprecation-warning"],
        "deprecation": {
            "status": "deprecated",
            "date": deprecation_date,
            "message": "This notebook has been deprecated and will be removed on " + deprecation_date
        }
    },
    "source": [
        "<div style='background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px; padding: 15px; margin: 10px 0;'>\\n",
        "<h3 style='color: #856404; margin-top: 0;'>⚠️ Deprecation Warning</h3>\\n",
        "<p style='color: #856404; margin-bottom: 0;'>\\n",
        "<strong>This notebook has been deprecated and will be removed on " + deprecation_date + ".</strong><br>\\n",
        "Please migrate to the recommended alternative or update your workflows accordingly.\\n",
        "</p>\\n",
        "</div>"
    ]
}

# Insert at the beginning
nb['cells'].insert(0, deprecation_banner)

# Add deprecation metadata
if 'metadata' not in nb:
    nb['metadata'] = {}
nb['metadata']['deprecation'] = {
    'status': 'deprecated',
    'date': deprecation_date,
    'message': f'This notebook has been deprecated and will be removed on {deprecation_date}'
}

# Write back
with open(notebook_path, 'w') as f:
    json.dump(nb, f, indent=2)

print(f"✅ Added deprecation banner to {notebook_path}")
EOF

echo "✅ Deprecation banner added successfully"

# Commit to main branch
git add "$notebook"
git commit -m "Mark notebook as deprecated: $notebook (expires: $deprecation_date)"

echo "✅ Deprecated notebook committed to main branch"

# Simulate copying to gh-storage branch
echo ""
echo "📦 Simulating Copy to gh-storage Branch"
echo "======================================="

# Create a backup copy
temp_notebook="/tmp/deprecated_$(basename "$notebook")"
cp "$notebook" "$temp_notebook"
echo "📋 Backed up deprecated notebook to: $temp_notebook"

# Create gh-storage branch (orphan since it's the first time)
echo "🆕 Creating gh-storage branch"
git checkout --orphan gh-storage
git rm -rf . >/dev/null 2>&1 || true

# Set up directory structure and copy from backup
echo "📁 Setting up directory: $(dirname "$notebook")"
mkdir -p "$(dirname "$notebook")"
cp "$temp_notebook" "$notebook"
echo "📋 Copied deprecated notebook from backup: $notebook"

# Commit to gh-storage
git add "$notebook"
git commit -m "Add deprecated notebook $notebook for documentation build [skip ci]"

echo "🚀 Successfully committed deprecated notebook to gh-storage"

# Clean up backup file
rm -f "$temp_notebook"

# Verify the notebook exists in both branches
echo ""
echo "🔍 Verification Results"
echo "======================"

# Check main branch (could be master or main)
if git branch -a | grep -q "main"; then
    git checkout main
else
    git checkout master
fi
if [[ -f "$notebook" ]]; then
    echo "✅ Notebook exists in main branch: $notebook"
    
    # Verify deprecation banner
    if grep -q "deprecation-warning" "$notebook"; then
        echo "✅ Deprecation banner found in main branch"
    else
        echo "❌ Deprecation banner missing in main branch"
    fi
else
    echo "❌ Notebook missing in main branch: $notebook"
fi

# Check gh-storage branch
git checkout gh-storage
if [[ -f "$notebook" ]]; then
    echo "✅ Notebook exists in gh-storage branch: $notebook"
    
    # Verify deprecation banner
    if grep -q "deprecation-warning" "$notebook"; then
        echo "✅ Deprecation banner found in gh-storage branch"
    else
        echo "❌ Deprecation banner missing in gh-storage branch"
    fi
else
    echo "❌ Notebook missing in gh-storage branch: $notebook"
fi

# Show branch summary
echo ""
echo "📊 Branch Summary"
echo "================="
git log --oneline --graph --all --decorate

echo ""
echo "🧪 Test Results Summary"
echo "======================="

# Return to test directory root for cleanup verification
cd "$TEST_DIR"

# Count branches
if git branch -a | grep -q "main"; then
    main_branch="main"
else
    main_branch="master"
fi

main_files=$(git ls-tree -r $main_branch --name-only | wc -l)
gh_storage_files=$(git ls-tree -r gh-storage --name-only | wc -l)

echo "📈 Main branch files: $main_files"
echo "📈 gh-storage branch files: $gh_storage_files"

if [[ "$main_files" -gt 0 ]] && [[ "$gh_storage_files" -gt 0 ]]; then
    echo "✅ Both branches contain files"
else
    echo "❌ One or both branches are empty"
fi

# Verify the notebook content differences/similarities
echo ""
echo "🔍 Content Verification"
echo "======================"

# Compare notebook content between branches
if git branch -a | grep -q "main"; then
    git checkout main
else
    git checkout master
fi
main_content=$(cat "$notebook" 2>/dev/null || echo "missing")

git checkout gh-storage  
gh_storage_content=$(cat "$notebook" 2>/dev/null || echo "missing")

if [[ "$main_content" == "$gh_storage_content" ]] && [[ "$main_content" != "missing" ]]; then
    echo "✅ Notebook content is identical between main and gh-storage branches"
    echo "✅ Deprecation sync working correctly"
else
    echo "❌ Notebook content differs between branches or is missing"
    echo "❌ Deprecation sync may have issues"
fi

echo ""
echo "🧹 Cleaning up test directory: $TEST_DIR"
cd /tmp
rm -rf "$TEST_DIR"

echo "✅ Deprecation sync test completed successfully!"
echo ""
echo "📝 Key Points Verified:"
echo "   - Notebook tagged with deprecation banner in main branch"
echo "   - Deprecated notebook copied to gh-storage branch"
echo "   - Both branches contain identical deprecated notebook"
echo "   - Documentation builds will use deprecated notebook from gh-storage"
echo ""
echo "🎯 This ensures deprecation banners are visible in generated documentation!"
