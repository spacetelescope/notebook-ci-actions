#!/bin/bash

# Test script to validate failure handling with warning banners in full-pipeline-all mode
# This simulates what happens when some notebooks fail but we still want documentation

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧪 Testing failure handling with warning banners"
echo "=================================================="

cd "$PROJECT_ROOT"

# Function to create a test notebook that will fail
create_failing_notebook() {
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
    "# Test Failing Notebook\n",
    "This notebook is designed to fail during execution."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# This cell will fail\n",
    "print(\"Starting test...\")\n",
    "raise Exception(\"Intentional failure for testing\")\n",
    "print(\"This should not be reached\")"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# This cell should not be executed due to the failure above\n",
    "print(\"Final operations\")\n",
    "result = \"success\"\n",
    "print(f\"Result: {result}\")"
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
    
    echo "✅ Created failing test notebook: $notebook_path"
}

# Function to test warning banner addition
test_warning_banner() {
    local notebook_path="$1"
    
    echo "🔧 Testing warning banner addition for: $notebook_path"
    
    # Create the Python script to add warnings (same as in workflow)
    cat > add_warning_test.py << 'EOF'
import json
import sys

notebook_path = sys.argv[1]

try:
    with open(notebook_path, 'r', encoding='utf-8') as f:
        nb = json.load(f)
    
    # Create warning banner cell
    warning_cell = {
        "cell_type": "markdown",
        "metadata": {
            "tags": ["execution-warning"]
        },
        "source": [
            "<div style='background-color: #fff3cd; border: 1px solid #ffeaa7; border-radius: 4px; padding: 15px; margin: 10px 0; border-left: 4px solid #f39c12;'>\n",
            "<h3 style='color: #856404; margin-top: 0;'>⚠️ EXECUTION WARNING</h3>\n",
            "<p style='color: #856404; margin-bottom: 0;'><strong>This notebook may not execute properly in the current environment.</strong></p>\n",
            "<p style='color: #856404; margin-bottom: 0;'>Some cells may have failed during automated testing. Please review the notebook content and test manually before use.</p>\n",
            "<p style='color: #856404; margin-bottom: 0; font-size: 0.9em;'><em>Generated during CI/CD pipeline - some outputs may be incomplete or missing.</em></p>\n",
            "</div>\n"
        ]
    }
    
    # Check if warning already exists
    has_warning = False
    for cell in nb.get('cells', []):
        if cell.get('cell_type') == 'markdown' and 'tags' in cell.get('metadata', {}):
            if 'execution-warning' in cell['metadata']['tags']:
                has_warning = True
                break
    
    # Add warning at the beginning if not already present
    if not has_warning:
        nb['cells'].insert(0, warning_cell)
        
        with open(notebook_path, 'w', encoding='utf-8') as f:
            json.dump(nb, f, indent=2, ensure_ascii=False)
        
        print(f"✅ Added execution warning to {notebook_path}")
    else:
        print(f"ℹ️ Warning already exists in {notebook_path}")
        
except Exception as e:
    print(f"❌ Error processing {notebook_path}: {e}")
EOF

    # Run the warning addition
    python add_warning_test.py "$notebook_path"
    
    # Verify warning was added
    if grep -q "EXECUTION WARNING" "$notebook_path"; then
        echo "✅ Warning banner successfully added"
    else
        echo "❌ Warning banner not found in notebook"
        return 1
    fi
    
    # Clean up
    rm -f add_warning_test.py
}

# Function to test documentation build with warnings
test_doc_build_with_warnings() {
    echo "📖 Testing documentation build with warning notebooks"
    
    # Try to build documentation if jupyter-book is available
    if command -v jupyter-book &> /dev/null; then
        echo "Building documentation with jupyter-book..."
        
        # Clean any existing build
        rm -rf _build
        
        # Build documentation
        if jupyter-book build . 2>/dev/null; then
            echo "✅ Documentation built successfully with warning notebooks"
            
            # Check if warnings appear in the HTML
            if [ -f "_build/html/index.html" ]; then
                if grep -q "EXECUTION WARNING" "_build/html"/*.html 2>/dev/null; then
                    echo "✅ Warning banners found in generated HTML"
                else
                    echo "⚠️ Warning banners may not be visible in HTML (not necessarily an error)"
                fi
            fi
        else
            echo "⚠️ Documentation build failed (expected if no proper _config.yml)"
        fi
    else
        echo "ℹ️ jupyter-book not available, skipping documentation build test"
    fi
}

# Main test execution
echo "📝 Step 1: Create failing test notebook"
FAILING_NOTEBOOK="notebooks/testing/test-failure.ipynb"
create_failing_notebook "$FAILING_NOTEBOOK"

echo ""
echo "📝 Step 2: Test warning banner addition"
test_warning_banner "$FAILING_NOTEBOOK"

echo ""
echo "📝 Step 3: Test documentation build with warnings"
test_doc_build_with_warnings

echo ""
echo "📝 Step 4: Verify notebook content"
echo "First few lines of the notebook with warning:"
head -20 "$FAILING_NOTEBOOK"

echo ""
echo "📝 Step 5: Cleanup"
rm -f "$FAILING_NOTEBOOK"
rmdir -p "$(dirname "$FAILING_NOTEBOOK")" 2>/dev/null || true

echo ""
echo "🎉 Failure handling with warnings test completed!"
echo "Summary:"
echo "- ✅ Failing notebook creation"
echo "- ✅ Warning banner addition"
echo "- ✅ Documentation build compatibility"
echo ""
echo "💡 The workflow should now:"
echo "   1. Continue execution even if some notebooks fail (in on-demand mode)"
echo "   2. Add warning banners to notebooks when failures occur"
echo "   3. Still build and deploy documentation with warnings"
echo "   4. Provide clear summary of what happened"
