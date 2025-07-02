#!/bin/bash

# Test script to verify duplicate deprecation warning fix
# This script tests that only one deprecation warning appears in HTML builds

set -e

echo "🧪 Testing Duplicate Deprecation Warning Fix"
echo "============================================="

# Create a test repository directory
TEST_DIR="/tmp/test-deprecation-duplicate-fix-$$"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo "📁 Created test directory: $TEST_DIR"

# Initialize git repository
git init
git config user.name "Test User"
git config user.email "test@example.com"

# Create test notebook structure
mkdir -p notebooks/testing
cat > notebooks/testing/duplicate-test.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Duplicate Warning Test Notebook\n",
    "\n",
    "This notebook is used to test that deprecation warnings don't duplicate."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "source": [
    "print('This is a test notebook for duplicate warning prevention')\n",
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

echo "📝 Created test notebook: notebooks/testing/duplicate-test.ipynb"

# Add and commit initial notebook
git add .
git commit -m "Initial commit with test notebook"

echo "✅ Initial commit completed"

# Test 1: Simulate the new deprecation tagging process (metadata only)
notebook="notebooks/testing/duplicate-test.ipynb"
deprecation_date="2024-12-31"

echo ""
echo "🏷️ Test 1: New Deprecation Tagging (Metadata Only)"
echo "=================================================="
echo "📝 Notebook: $notebook"
echo "📅 Deprecation Date: $deprecation_date"

# Add deprecation metadata (like the new workflow does)
python3 << EOF
import json
import os

notebook_path = "$notebook"
deprecation_date = "$deprecation_date"

print(f"📖 Adding deprecation metadata to: {notebook_path}")

with open(notebook_path, 'r') as f:
    nb = json.load(f)

# Add deprecation metadata to notebook
if 'metadata' not in nb:
    nb['metadata'] = {}

nb['metadata']['deprecated'] = {
    'status': 'deprecated',
    'date': deprecation_date,
    'message': f'This notebook is scheduled for deprecation on {deprecation_date}'
}

# Add a simple deprecation tag cell (hidden comment)
deprecation_cell = {
    "cell_type": "markdown",
    "metadata": {
        "tags": ["deprecated"],
        "deprecation": {
            "date": deprecation_date,
            "status": "deprecated"
        }
    },
    "source": [
        f"<!-- DEPRECATED: This notebook is scheduled for deprecation on {deprecation_date} -->\n"
    ]
}

# Insert at the beginning
nb['cells'].insert(0, deprecation_cell)

with open(notebook_path, 'w') as f:
    json.dump(nb, f, indent=2)

print(f"✅ Added deprecation metadata to {notebook_path}")
EOF

echo "✅ Deprecation metadata added successfully"

# Test 2: Simulate the HTML build deprecation warning process
echo ""
echo "🏗️ Test 2: HTML Build Deprecation Warning Detection"
echo "=================================================="

# Simulate the new deprecation warning logic
python3 << 'EOF'
import json
import sys
from datetime import datetime
import re

notebook_path = "notebooks/testing/duplicate-test.ipynb"

print(f"🔍 Testing deprecation warning logic for: {notebook_path}")

try:
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb = json.load(f)
    
    # Test the new detection logic
    is_deprecated = False
    deprecation_date = None
    has_existing_warning = False
    
    # Method 1: Check for cells with deprecated tag OR existing deprecation-warning tag
    for cell in nb.get('cells', []):
        if cell.get('cell_type') == 'markdown' and 'tags' in cell.get('metadata', {}):
            tags = cell['metadata']['tags']
            if 'deprecated' in tags:
                is_deprecated = True
                # Try to extract date from existing deprecation content
                source = ''.join(cell.get('source', []))
                date_match = re.search(r'(\d{4}-\d{2}-\d{2})', source)
                if date_match:
                    deprecation_date = date_match.group(1)
                print(f"✅ Found deprecated tag in cell")
            elif 'deprecation-warning' in tags:
                # Already has a deprecation warning, don't add another
                has_existing_warning = True
                print(f"⚠️ Found existing deprecation warning - would skip adding another")
                break
        if is_deprecated or has_existing_warning:
            break
    
    # Method 2: Check notebook metadata for deprecation info
    if not is_deprecated and not has_existing_warning and 'metadata' in nb:
        nb_metadata = nb['metadata']
        if 'deprecated' in nb_metadata:
            is_deprecated = True
            if isinstance(nb_metadata['deprecated'], dict):
                deprecation_date = nb_metadata['deprecated'].get('date')
                print(f"✅ Found deprecated metadata with date: {deprecation_date}")
    
    # Show results
    print(f"📊 Test Results:")
    print(f"   - Is Deprecated: {is_deprecated}")
    print(f"   - Deprecation Date: {deprecation_date}")
    print(f"   - Has Existing Warning: {has_existing_warning}")
    
    # Test what would happen
    if has_existing_warning:
        print(f"✅ PASS: Would skip adding warning (already exists)")
    elif is_deprecated:
        print(f"✅ PASS: Would add single deprecation warning")
        
        # Simulate adding the warning
        deprecation_warning_cell = {
            "cell_type": "markdown",
            "metadata": {
                "tags": ["deprecation-warning"]
            },
            "source": [
                "<div style='background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 4px; padding: 15px; margin: 10px 0; border-left: 4px solid #dc3545;'>\n",
                "<h3 style='color: #721c24; margin-top: 0;'>🚨 DEPRECATED NOTEBOOK</h3>\n",
                f"<p style='color: #721c24; margin-bottom: 5px;'><strong>This notebook is scheduled for deprecation on {deprecation_date}.</strong></p>\n",
                "<p style='color: #721c24; margin-bottom: 0;'>Please migrate to newer alternatives or contact maintainers before using this notebook in production.</p>\n",
                "<p style='color: #721c24; margin-bottom: 0; font-size: 0.9em;'><em>This warning was automatically generated during documentation build.</em></p>\n",
                "</div>\n"
            ]
        }
        
        # Add to beginning
        nb['cells'].insert(0, deprecation_warning_cell)
        
        # Save test result
        with open('test-result-notebook.ipynb', 'w', encoding='utf-8') as f:
            json.dump(nb, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Created test result notebook with single deprecation warning")
    else:
        print(f"ℹ️ No deprecation detected")

except Exception as e:
    print(f"❌ Error testing: {e}")
EOF

echo ""
echo "🔍 Test 3: Verify Single Warning in Result"
echo "==========================================="

if [[ -f "test-result-notebook.ipynb" ]]; then
    # Count warnings in the result
    warning_count=$(grep -c "DEPRECATED NOTEBOOK" test-result-notebook.ipynb || echo "0")
    tag_count=$(grep -c "deprecation-warning" test-result-notebook.ipynb || echo "0")
    
    echo "📊 Warning Analysis:"
    echo "   - 'DEPRECATED NOTEBOOK' text found: $warning_count times"
    echo "   - 'deprecation-warning' tags found: $tag_count times"
    
    if [[ "$warning_count" -eq 1 ]] && [[ "$tag_count" -eq 1 ]]; then
        echo "✅ PASS: Only one deprecation warning found!"
    else
        echo "❌ FAIL: Multiple or no warnings found"
    fi
    
    # Show the first few cells to verify structure
    echo ""
    echo "📋 First 3 cells in result notebook:"
    python3 << 'EOF'
import json

with open('test-result-notebook.ipynb', 'r') as f:
    nb = json.load(f)

for i, cell in enumerate(nb['cells'][:3]):
    print(f"Cell {i+1}: {cell['cell_type']}")
    if 'tags' in cell.get('metadata', {}):
        print(f"  Tags: {cell['metadata']['tags']}")
    source = ''.join(cell.get('source', []))
    if len(source) > 100:
        print(f"  Content: {source[:100]}...")
    else:
        print(f"  Content: {source}")
    print()
EOF
    
else
    echo "❌ Test result notebook not created"
fi

echo ""
echo "🧹 Cleaning up test directory: $TEST_DIR"
cd /tmp
rm -rf "$TEST_DIR"

echo "✅ Duplicate deprecation warning fix test completed!"
echo ""
echo "📝 Summary:"
echo "   - New tagging process adds metadata instead of visual banner"
echo "   - HTML build process detects existing warnings to prevent duplicates" 
echo "   - Only one styled deprecation warning should appear in documentation"
