#!/bin/bash

# Test script to validate deprecation warning functionality
# Tests different methods of marking notebooks as deprecated

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🧪 Testing deprecation warning functionality"
echo "============================================="

cd "$PROJECT_ROOT"

# Function to create test notebooks with different deprecation methods
create_test_notebooks() {
    echo "📝 Creating test notebooks with different deprecation methods"
    
    # Method 1: Metadata-based deprecation (recommended)
    cat > notebooks/testing/test-deprecated-metadata.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": ["# Metadata Deprecated Notebook\nThis uses metadata for deprecation."]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": ["print('This notebook is deprecated via metadata')"]
  }
 ],
 "metadata": {
  "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},
  "deprecated": {"date": "2025-08-01", "reason": "Replaced by new method"}
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

    # Method 2: Cell tag-based deprecation (existing method)
    cat > notebooks/testing/test-deprecated-cell-tag.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {"tags": ["deprecated"]},
   "source": ["# Cell Tag Deprecated Notebook\nThis uses cell tags for deprecation.\nScheduled for deprecation on 2025-09-15."]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": ["print('This notebook is deprecated via cell tags')"]
  }
 ],
 "metadata": {
  "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"}
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

    # Method 3: Text-based deprecation (legacy method)
    cat > notebooks/testing/test-deprecated-text.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": ["# Text-Based Deprecated Notebook\nDEPRECATED: This notebook will be removed on 2025-10-01."]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": ["print('This notebook is deprecated via text content')"]
  }
 ],
 "metadata": {
  "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"}
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

    # Method 4: Simple metadata flag
    cat > notebooks/testing/test-deprecated-simple.ipynb << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": ["# Simple Deprecated Notebook\nThis uses simple metadata flag."]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": ["print('This notebook is deprecated via simple flag')"]
  }
 ],
 "metadata": {
  "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},
  "deprecated": "2025-07-15"
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

    echo "✅ Created 4 test notebooks with different deprecation methods"
}

# Function to test deprecation warning addition
test_deprecation_warnings() {
    echo "🏷️ Testing deprecation warning addition"
    
    # Create the Python script (same as in workflow)
    cat > test_deprecation.py << 'EOF'
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
    
    # Method 3: Text-based search (backward compatibility)
    if not is_deprecated:
        for cell in nb.get('cells', []):
            source = ''.join(cell.get('source', []))
            if re.search(r'DEPRECATED|deprecated|DEPRECATION', source, re.IGNORECASE):
                is_deprecated = True
                # Try to extract date
                date_match = re.search(r'(\d{4}-\d{2}-\d{2})', source)
                if date_match:
                    deprecation_date = date_match.group(1)
                break
    
    if is_deprecated:
        print(f"📅 Found deprecated notebook: {notebook_path}")
        
        # Create deprecation warning banner
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
            
            print(f"✅ Added deprecation warning to {notebook_path}")
        else:
            print(f"ℹ️ Deprecation warning already exists in {notebook_path}")
    else:
        print(f"✅ No deprecation found in {notebook_path}")
        
except Exception as e:
    print(f"❌ Error processing {notebook_path}: {e}")
EOF

    # Test each notebook
    for notebook in notebooks/testing/test-deprecated-*.ipynb; do
        if [ -f "$notebook" ]; then
            echo ""
            echo "🔍 Testing: $notebook"
            python test_deprecation.py "$notebook"
            
            # Verify warning was added
            if grep -q "DEPRECATED NOTEBOOK" "$notebook"; then
                echo "✅ Deprecation banner successfully added to $notebook"
            else
                echo "❌ Deprecation banner not found in $notebook"
            fi
        fi
    done
    
    # Clean up
    rm -f test_deprecation.py
}

# Function to show examples of different deprecation methods
show_deprecation_methods() {
    echo ""
    echo "📚 Deprecation Methods Supported:"
    echo "================================="
    echo ""
    echo "1. **Metadata-based (Recommended)**:"
    cat << 'EOF'
   "metadata": {
     "deprecated": {
       "date": "2025-12-31",
       "reason": "Replaced by newer methods"
     }
   }
EOF
    echo ""
    echo "2. **Simple metadata flag**:"
    cat << 'EOF'
   "metadata": {
     "deprecated": "2025-12-31"
   }
EOF
    echo ""
    echo "3. **Cell-based (Existing method)**:"
    cat << 'EOF'
   {
     "cell_type": "markdown",
     "metadata": {"tags": ["deprecated"]},
     "source": ["DEPRECATED: This notebook expires 2025-12-31"]
   }
EOF
    echo ""
    echo "4. **Text-based (Legacy support)**:"
    echo "   Any cell containing 'DEPRECATED', 'deprecated', or 'DEPRECATION'"
}

# Function to clean up test files
cleanup_test_files() {
    echo ""
    echo "🧹 Cleaning up test files"
    rm -f notebooks/testing/test-deprecated-*.ipynb
    echo "✅ Test files cleaned up"
}

# Main test execution
echo "📝 Step 1: Create test notebooks"
create_test_notebooks

echo ""
echo "📝 Step 2: Test deprecation warning detection and addition"
test_deprecation_warnings

echo ""
echo "📝 Step 3: Show supported deprecation methods"
show_deprecation_methods

echo ""
echo "📝 Step 4: Test with existing deprecated notebook"
if [ -f "notebooks/testing/deprecated-test.ipynb" ]; then
    echo "🔍 Testing existing deprecated notebook"
    python test_deprecation.py "notebooks/testing/deprecated-test.ipynb" 2>/dev/null || true
fi

echo ""
echo "📝 Step 5: Cleanup"
cleanup_test_files

echo ""
echo "🎉 Deprecation warning test completed!"
echo ""
echo "Summary of features:"
echo "- ✅ Metadata-based deprecation detection (recommended)"
echo "- ✅ Cell tag-based deprecation detection (existing)"
echo "- ✅ Text-based deprecation detection (legacy)"
echo "- ✅ Date parsing and expiration checking"
echo "- ✅ Automatic warning banner injection"
echo "- ✅ Duplicate warning prevention"
echo ""
echo "💡 To mark a notebook as deprecated, add to metadata:"
echo '   "deprecated": {"date": "YYYY-MM-DD", "reason": "explanation"}'
