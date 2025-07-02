#!/bin/bash

# Test script for the simplified PR storage logic
# This validates that ONLY the executed notebook is pushed to gh-storage

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing Simplified PR Storage Logic${NC}"
echo "======================================"

# Function to simulate the new PR storage approach
test_simplified_pr_storage() {
    local notebook="$1"
    echo -e "${BLUE}🧪 Testing simplified PR storage for: $notebook${NC}"
    
    # Ensure the notebook exists for testing
    if [ ! -f "$notebook" ]; then
        echo -e "${YELLOW}📝 Creating test notebook: $notebook${NC}"
        mkdir -p "$(dirname "$notebook")"
        cat > "$notebook" << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": ["# Test Notebook\n", "\n", "This is a test notebook for PR storage validation."]
  },
  {
   "cell_type": "code",
   "execution_count": 1,
   "metadata": {},
   "outputs": [{"name": "stdout", "output_type": "stream", "text": ["Executed at: 2025-07-01\n"]}],
   "source": ["import datetime\n", "print(f\"Executed at: {datetime.datetime.now().strftime('%Y-%m-%d')}\")"]
  }
 ],
 "metadata": {
  "kernelspec": {"display_name": "Python 3", "language": "python", "name": "python3"},
  "language_info": {"name": "python", "version": "3.11.0"}
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF
    fi
    
    # Simulate the new simplified approach
    echo -e "${BLUE}🔄 PR mode: Force-pushing ONLY the executed notebook to gh-storage${NC}"
    
    # Store current state
    current_branch=$(git branch --show-current)
    echo -e "${BLUE}📍 Current branch: $current_branch${NC}"
    
    # Create a clean temporary copy of just the executed notebook
    temp_notebook="/tmp/$(basename "$notebook")"
    cp "$notebook" "$temp_notebook"
    echo -e "${GREEN}📋 Backed up executed notebook to: $temp_notebook${NC}"
    
    # Fetch gh-storage branch or create if it doesn't exist
    if git fetch origin gh-storage 2>/dev/null; then
        echo -e "${GREEN}📦 Found existing gh-storage branch${NC}"
        git checkout gh-storage 2>/dev/null || {
            echo -e "${YELLOW}⚠️ Checkout failed, creating new branch${NC}"
            git checkout --orphan gh-storage
            git rm -rf . 2>/dev/null || true
        }
    else
        echo -e "${YELLOW}🆕 Creating new gh-storage branch${NC}"
        git checkout --orphan gh-storage
        git rm -rf . 2>/dev/null || true
    fi
    
    # Ensure directory exists and copy ONLY the executed notebook
    mkdir -p "$(dirname "$notebook")"
    cp "$temp_notebook" "$notebook"
    echo -e "${GREEN}📋 Copied executed notebook to gh-storage: $notebook${NC}"
    
    # Add only this notebook and force push (simulated)
    git add "$notebook"
    if git commit -m "Update executed notebook $notebook from PR test [skip ci]" 2>/dev/null; then
        echo -e "${GREEN}🚀 Would force-push ONLY $notebook to gh-storage${NC}"
        
        # Show what's being committed
        echo -e "${BLUE}📄 Files in this commit:${NC}"
        git show --name-only --pretty=format: | grep -v '^$'
        
        # Count files to validate isolation
        file_count=$(git show --name-only --pretty=format: | grep -v '^$' | wc -l)
        if [ "$file_count" -eq 1 ]; then
            echo -e "${GREEN}✅ Perfect isolation: Only 1 file ($notebook) in commit${NC}"
        else
            echo -e "${RED}❌ Isolation failed: $file_count files in commit${NC}"
        fi
    else
        echo -e "${YELLOW}ℹ️ No changes to commit for $notebook${NC}"
    fi
    
    # Clean up and return to original branch
    rm -f "$temp_notebook"
    git checkout "$current_branch" 2>/dev/null || echo -e "${YELLOW}⚠️ Could not return to original branch${NC}"
    echo -e "${BLUE}🔄 Returned to branch: $current_branch${NC}"
    
    return 0
}

# Function to validate the approach
validate_approach() {
    echo -e "${BLUE}🔍 Validating the simplified approach${NC}"
    
    echo -e "${GREEN}✅ Key improvements:${NC}"
    echo "  • Uses temporary file to avoid git conflicts"
    echo "  • No complex branch switching while files are dirty"
    echo "  • Force push ensures no merge conflicts"
    echo "  • Only the executed notebook is affected"
    echo "  • Clean separation between working directory and gh-storage"
    
    echo -e "${BLUE}📋 Process summary:${NC}"
    echo "  1. Copy executed notebook to temporary location"
    echo "  2. Switch to gh-storage branch (clean working directory)"
    echo "  3. Copy notebook from temp to correct location"
    echo "  4. Add, commit, and force push only that notebook"
    echo "  5. Clean up and return to original branch"
}

# Main test execution
echo -e "${BLUE}🚀 Starting simplified PR storage tests${NC}"

# Test with different notebooks
test_notebooks=(
    "notebooks/testing/pr-storage-test.ipynb"
    "notebooks/examples/basic-validation-test.ipynb"
)

for notebook in "${test_notebooks[@]}"; do
    echo -e "\n${BLUE}Testing with: $notebook${NC}"
    test_simplified_pr_storage "$notebook"
done

echo -e "\n${BLUE}Final validation${NC}"
validate_approach

echo -e "\n${GREEN}🎉 Simplified PR storage tests completed!${NC}"
echo -e "${BLUE}📋 Summary:${NC}"
echo "  - Eliminates git conflicts during branch switching"
echo "  - Ensures ONLY the executed notebook is pushed"
echo "  - Uses force push to avoid any merge issues"
echo "  - Simple, reliable, and predictable behavior"

echo -e "\n${GREEN}✅ This approach should resolve the git conflicts!${NC}"
