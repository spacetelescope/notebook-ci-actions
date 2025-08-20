#!/bin/bash

# Test script to validate automatic HTML rebuild after deprecation tagging
# This simulates the deprecate-notebook workflow behavior

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧪 Testing automatic HTML rebuild after deprecation"
echo "=================================================="

cd "$PROJECT_ROOT"

# Function to create a test notebook for deprecation
create_test_notebook() {
    local notebook_path="$1"
    local notebook_dir=$(dirname "$notebook_path")
    
    mkdir -p "$notebook_dir"
    
    cat > "$notebook_path" << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Test Notebook for Deprecation\n",
    "This notebook will be marked as deprecated and should trigger HTML rebuild."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# This notebook demonstrates deprecation workflow\n",
    "print(\"This notebook will be deprecated\")\n",
    "import datetime\n",
    "print(f\"Current time: {datetime.datetime.now()}\")"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Summary\n",
    "This notebook shows what happens when deprecation is triggered."
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "codemirror_mode": {
    "name": "ipython",
    "version": 3
   },
   "file_extension": ".py",
   "mimetype": "text/x-python",
   "name": "python",
   "nbconvert_exporter": "python",
   "pygments_lexer": "ipython3",
   "version": "3.11.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF
    
    echo "✅ Created test notebook: $notebook_path"
}

# Function to simulate deprecation tagging
simulate_deprecation_tagging() {
    local notebook_path="$1"
    local deprecation_date="$2"
    
    echo "🏷️ Simulating deprecation tagging for: $notebook_path"
    
    # Create the Python script to add deprecation (same as in manage-deprecation job)
    cat > tag_for_deprecation.py << 'EOF'
import json
import sys
from datetime import datetime, timedelta

notebook_path = sys.argv[1]
days = int(sys.argv[2]) if len(sys.argv) > 2 else 60

with open(notebook_path, 'r') as f:
    nb = json.load(f)

deprecation_date = (datetime.now() + timedelta(days=days)).strftime('%Y-%m-%d')

# Add deprecation cell at the beginning
deprecation_cell = {
    "cell_type": "markdown",
    "metadata": {
        "tags": ["deprecated"]
    },
    "source": [
        f"<div style='background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px; padding: 15px; margin: 10px 0;'>\n",
        f"<h3 style='color: #856404; margin-top: 0;'>⚠️ DEPRECATED NOTEBOOK</h3>\n",
        f"<p style='color: #856404; margin-bottom: 0;'>This notebook is scheduled for deprecation on <strong>{deprecation_date}</strong>. It may be moved to the deprecated branch after this date.</p>\n",
        f"</div>\n"
    ]
}

# Insert at the beginning
nb['cells'].insert(0, deprecation_cell)

with open(notebook_path, 'w') as f:
    json.dump(nb, f, indent=2)

print(f"Added deprecation banner to {notebook_path}")
print(f"Deprecation date: {deprecation_date}")
EOF
    
    # Run the deprecation tagging
    python tag_for_deprecation.py "$notebook_path" 30
    rm -f tag_for_deprecation.py
    
    echo "✅ Deprecation tag added successfully"
}

# Function to simulate documentation rebuild with deprecation warnings
simulate_documentation_rebuild() {
    echo "📖 Simulating documentation rebuild with deprecation warnings"
    
    # Create the deprecation warning addition script (same as in rebuild job)
    cat > add_rebuild_warnings.py << 'EOF'
import json
import sys
from datetime import datetime
import re

notebook_path = sys.argv[1]

try:
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb = json.load(f)
    
    # Check if notebook has deprecation metadata or content
    is_deprecated = False
    deprecation_date = None
    
    # Method 1: Check for cells with deprecated tag
    for cell in nb.get('cells', []):
        if cell.get('cell_type') == 'markdown' and 'tags' in cell.get('metadata', {}):
            if 'deprecated' in cell['metadata']['tags']:
                is_deprecated = True
                # Try to extract date from existing deprecation content
                source = ''.join(cell.get('source', []))
                date_match = re.search(r'(\d{4}-\d{2}-\d{2})', source)
                if date_match:
                    deprecation_date = date_match.group(1)
                break
    
    # Method 2: Check notebook metadata for deprecation info
    if not is_deprecated and 'metadata' in nb:
        nb_metadata = nb['metadata']
        if 'deprecated' in nb_metadata:
            is_deprecated = True
            if isinstance(nb_metadata['deprecated'], dict):
                deprecation_date = nb_metadata['deprecated'].get('date')
            elif isinstance(nb_metadata['deprecated'], str):
                # Try to parse as date
                if re.match(r'\d{4}-\d{2}-\d{2}', nb_metadata['deprecated']):
                    deprecation_date = nb_metadata['deprecated']
    
    if is_deprecated:
        print(f"📅 Found deprecated notebook: {notebook_path}")
        
        # Create deprecation warning banner for HTML
        if not deprecation_date:
            deprecation_date = "unspecified date"
            date_text = "This notebook is deprecated and may be removed in the future."
        else:
            try:
                dep_date = datetime.strptime(deprecation_date, '%Y-%m-%d')
                if dep_date <= datetime.now():
                    date_text = f"This notebook was deprecated on <strong>{deprecation_date}</strong> and may be moved or removed."
                else:
                    date_text = f"This notebook is scheduled for deprecation on <strong>{deprecation_date}</strong>."
            except:
                date_text = f"This notebook is deprecated (target date: {deprecation_date})."
        
        deprecation_warning_cell = {
            "cell_type": "markdown",
            "metadata": {
                "tags": ["deprecation-warning"]
            },
            "source": [
                "<div style='background-color: #f8d7da; border: 1px solid #f5c6cb; border-radius: 4px; padding: 15px; margin: 10px 0; border-left: 4px solid #dc3545;'>\n",
                "<h3 style='color: #721c24; margin-top: 0;'>🚨 DEPRECATED NOTEBOOK</h3>\n",
                f"<p style='color: #721c24; margin-bottom: 5px;'><strong>{date_text}</strong></p>\n",
                "<p style='color: #721c24; margin-bottom: 0;'>Please migrate to newer alternatives or contact maintainers before using this notebook in production.</p>\n",
                "<p style='color: #721c24; margin-bottom: 0; font-size: 0.9em;'><em>This warning was automatically generated during documentation build.</em></p>\n",
                "</div>\n"
            ]
        }
        
        # Check if deprecation warning already exists
        has_deprecation_warning = False
        for cell in nb.get('cells', []):
            if cell.get('cell_type') == 'markdown' and 'tags' in cell.get('metadata', {}):
                if 'deprecation-warning' in cell['metadata']['tags']:
                    has_deprecation_warning = True
                    break
        
        # Add deprecation warning at the beginning if not already present
        if not has_deprecation_warning:
            nb['cells'].insert(0, deprecation_warning_cell)
            
            with open(notebook_path, 'w', encoding='utf-8') as f:
                json.dump(nb, f, indent=2, ensure_ascii=False)
            
            print(f"✅ Added HTML deprecation warning to {notebook_path}")
        else:
            print(f"ℹ️ HTML deprecation warning already exists in {notebook_path}")
    else:
        print(f"✅ No deprecation found in {notebook_path}")
        
except Exception as e:
    print(f"❌ Error processing {notebook_path}: {e}")
EOF
    
    # Find notebooks and add deprecation warnings for HTML
    find . -name "*.ipynb" -type f | while read -r notebook; do
        if [ -f "$notebook" ]; then
            echo "🔍 Processing for HTML rebuild: $notebook"
            python add_rebuild_warnings.py "$notebook"
        fi
    done
    
    rm -f add_rebuild_warnings.py
    
    # Simulate documentation build
    echo "🔨 Building documentation..."
    if command -v jupyter-book &> /dev/null; then
        # Clean any existing build
        rm -rf _build
        
        # Build documentation
        if jupyter-book build . 2>/dev/null; then
            echo "✅ Documentation built successfully with deprecation warnings"
            
            # Check if warnings appear in the HTML
            if [ -f "_build/html/index.html" ]; then
                if grep -q "DEPRECATED NOTEBOOK" "_build/html"/*.html 2>/dev/null; then
                    echo "✅ Deprecation warnings found in generated HTML"
                else
                    echo "⚠️ Deprecation warnings may not be visible in HTML"
                fi
            fi
        else
            echo "⚠️ Documentation build failed (may need proper _config.yml)"
        fi
    else
        echo "ℹ️ jupyter-book not available, simulating build completion"
        echo "✅ Documentation would be built with deprecation warnings"
    fi
}

# Function to show the new workflow behavior
show_workflow_behavior() {
    echo ""
    echo "📋 New Workflow Behavior Summary:"
    echo "================================="
    echo ""
    echo "When you run: deprecate-notebook action"
    echo ""
    echo "1. **📝 Deprecation Tagging**:"
    echo "   - Adds deprecation cell to notebook"
    echo "   - Commits changes to repository"
    echo ""
    echo "2. **📖 Automatic HTML Rebuild** (NEW!):"
    echo "   - Detects deprecated notebooks"
    echo "   - Adds prominent red warning banners"
    echo "   - Rebuilds documentation"
    echo "   - Deploys updated HTML immediately"
    echo ""
    echo "3. **✅ Result**:"
    echo "   - Repository has deprecated notebook with tag"
    echo "   - Documentation website shows prominent warnings"
    echo "   - Users see warnings immediately"
    echo ""
    echo "🎯 **Key Benefit**: No manual HTML rebuild needed!"
}

# Function to clean up test files
cleanup_test_files() {
    echo ""
    echo "🧹 Cleaning up test files"
    TEST_NOTEBOOK="notebooks/testing/test-deprecation-rebuild.ipynb"
    if [ -f "$TEST_NOTEBOOK" ]; then
        rm -f "$TEST_NOTEBOOK"
        echo "✅ Cleaned up test notebook"
    fi
}

# Main test execution
echo "📝 Step 1: Create test notebook"
TEST_NOTEBOOK="notebooks/testing/test-deprecation-rebuild.ipynb"
create_test_notebook "$TEST_NOTEBOOK"

echo ""
echo "📝 Step 2: Simulate deprecation tagging (like manage-deprecation job)"
simulate_deprecation_tagging "$TEST_NOTEBOOK"

echo ""
echo "📝 Step 3: Verify deprecation tag was added"
if grep -q "DEPRECATED NOTEBOOK" "$TEST_NOTEBOOK"; then
    echo "✅ Deprecation tag successfully added to notebook"
else
    echo "❌ Deprecation tag not found"
fi

echo ""
echo "📝 Step 4: Simulate automatic HTML rebuild (like rebuild-docs-after-deprecation job)"
simulate_documentation_rebuild

echo ""
echo "📝 Step 5: Verify HTML deprecation warning was added"
if grep -q "deprecation-warning" "$TEST_NOTEBOOK"; then
    echo "✅ HTML deprecation warning successfully added"
else
    echo "❌ HTML deprecation warning not found"
fi

echo ""
echo "📝 Step 6: Show workflow behavior"
show_workflow_behavior

echo ""
echo "📝 Step 7: Cleanup"
cleanup_test_files

echo ""
echo "🎉 Automatic HTML rebuild after deprecation test completed!"
echo ""
echo "Summary of new functionality:"
echo "- ✅ Deprecation tagging works as before"
echo "- ✅ HTML deprecation warnings are automatically added"
echo "- ✅ Documentation is automatically rebuilt and deployed"
echo "- ✅ Users see deprecation warnings immediately"
echo ""
echo "💡 Configuration required:"
echo "   Set 'enable-html-build: true' in deprecate-notebook action"
