#!/bin/bash

# Repository cleanup script - Update all references to new repository
# Updates from mgough-970/dev-actions to mgough-970/dev-actions

set -e

echo "🧹 Cleaning up repository references..."
echo "From: mgough-970/dev-actions"
echo "To: mgough-970/dev-actions"
echo "Branch: dev-actions-v2"
echo ""

# Function to update files
update_files() {
    local pattern="$1"
    local description="$2"
    
    echo "📋 Updating $description..."
    
    find . -name "$pattern" -not -path "./.git/*" | while read -r file; do
        if grep -q "mgough-970/dev-actions" "$file" 2>/dev/null; then
            echo "  ✏️  $file"
            sed -i 's/spacetelescope\/notebook-ci-actions/mgough-970\/dev-actions/g' "$file"
            sed -i 's/@dev-actions-v2/@dev-actions-v2/g' "$file"
        fi
    done
}

# Update workflow files
update_files "*.yml" "YAML workflow files"
update_files "*.yaml" "YAML configuration files"

# Update documentation
update_files "*.md" "Markdown documentation"

# Update scripts
update_files "*.sh" "Shell scripts"

# Update any remaining text files
update_files "*.txt" "Text files"

# Update specific files that might have been missed
echo "📋 Updating specific configuration files..."

# Update deployment checklist
if [ -f "DEPLOYMENT_CHECKLIST.md" ]; then
    echo "  ✏️  DEPLOYMENT_CHECKLIST.md"
    sed -i 's/spacetelescope\/notebook-ci-actions/mgough-970\/dev-actions/g' DEPLOYMENT_CHECKLIST.md
    sed -i 's/notebook-ci-actions/dev-actions/g' DEPLOYMENT_CHECKLIST.md
fi

# Update implementation summary
if [ -f "IMPLEMENTATION_SUMMARY.md" ]; then
    echo "  ✏️  IMPLEMENTATION_SUMMARY.md"
    sed -i 's/spacetelescope\/notebook-ci-actions/mgough-970\/dev-actions/g' IMPLEMENTATION_SUMMARY.md
    sed -i 's/@dev-actions-v2/@dev-actions-v2/g' IMPLEMENTATION_SUMMARY.md
fi

echo ""
echo "✅ Repository cleanup completed!"
echo ""
echo "📊 Summary of changes:"
echo "  - Repository: mgough-970/dev-actions → mgough-970/dev-actions"
echo "  - Branch: main → dev-actions-v2"
echo "  - Updated workflow files, documentation, and scripts"
echo ""
echo "💡 Next steps:"
echo "  - Review changes: git diff"
echo "  - Test workflows with new repository references"
echo "  - Commit changes: git add . && git commit -m 'Update repository references'"
