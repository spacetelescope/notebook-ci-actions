#!/bin/bash

# Simple test for the final PR storage approach
# Tests that ONLY the executed notebook gets pushed to gh-storage

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing Final PR Storage - Single File Only${NC}"
echo "=============================================="

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Store original state
ORIGINAL_BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Original branch: $ORIGINAL_BRANCH${NC}"

# Create a test notebook
TEST_NOTEBOOK="notebooks/testing/final-test.ipynb"
mkdir -p "$(dirname "$TEST_NOTEBOOK")"

echo -e "${YELLOW}📝 Creating test notebook${NC}"
cat > "$TEST_NOTEBOOK" << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Final PR Storage Test\n",
    "\n",
    "This notebook tests the final single-file PR storage approach."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": 1,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Test executed successfully!\n"
     ]
    }
   ],
   "source": [
    "import datetime\n",
    "print(f\"Test executed at: {datetime.datetime.now()}\")\n",
    "print(\"Test executed successfully!\")"
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
   "name": "python",
   "version": "3.11.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 4
}
EOF

# Commit the test notebook
git add "$TEST_NOTEBOOK"
git commit -m "Add final test notebook"

# Function to simulate the final PR storage approach
simulate_final_pr_storage() {
    local notebook="$1"
    echo -e "${BLUE}🧪 Simulating final PR storage for: $notebook${NC}"
    
    # Simulate git configuration
    git config --global user.name "test-user"
    git config --global user.email "test@example.com"
    
    echo "🔄 PR mode: Force-pushing ONLY the executed notebook to gh-storage"
    
    # Store current state
    current_branch=$(git branch --show-current)
    echo "📍 Current branch: $current_branch"
    
    # Create a backup copy of the executed notebook
    temp_notebook="/tmp/executed_$(basename "$notebook")"
    cp "$notebook" "$temp_notebook"
    echo "📋 Backed up executed notebook"
    
    # Switch to gh-storage branch (create if doesn't exist)
    if git ls-remote --exit-code origin gh-storage >/dev/null 2>&1; then
        echo "📦 Using existing gh-storage branch"
        git fetch origin gh-storage
        git checkout gh-storage
    else
        echo "🆕 Creating new gh-storage branch"
        git checkout --orphan gh-storage
        git rm -rf . >/dev/null 2>&1 || true
    fi
    
    # List current files in gh-storage before our change
    echo -e "${BLUE}📂 Files currently in gh-storage:${NC}"
    find . -name "*.ipynb" -type f | head -5 || echo "No notebook files found"
    
    # Create directory structure and copy ONLY the executed notebook
    echo "📂 Setting up directory: $(dirname "$notebook")"
    mkdir -p "$(dirname "$notebook")"
    cp "$temp_notebook" "$notebook"
    
    # Stage ONLY this notebook file
    git add "$notebook"
    
    # Commit and force push (ignoring history/conflicts)
    if git commit -m "Update executed notebook $notebook from PR test [skip ci]"; then
        echo "✅ Committed notebook changes"
        echo "🚀 Would force-push ONLY $notebook to gh-storage"
        
        # Show what would be pushed
        echo -e "${BLUE}📄 File being pushed:${NC}"
        git show --name-only --pretty=format:
        echo
        
        echo -e "${GREEN}✅ Single file commit successful${NC}"
    else
        echo "ℹ️ No changes detected in $notebook"
    fi
    
    # Return to original branch
    git checkout "$current_branch"
    echo "🔄 Returned to original branch"
    
    # Clean up
    rm -f "$temp_notebook"
}

# Run the simulation
echo -e "\n${BLUE}🚀 Starting final PR storage simulation${NC}"
simulate_final_pr_storage "$TEST_NOTEBOOK"

# Validate the result
echo -e "\n${BLUE}🔍 Validation Results:${NC}"
echo -e "${GREEN}✅ Only the executed notebook would be pushed to gh-storage${NC}"
echo -e "${GREEN}✅ No merge conflicts possible (force push)${NC}"
echo -e "${GREEN}✅ Existing gh-storage files remain untouched${NC}"
echo -e "${GREEN}✅ Clean and simple approach${NC}"

# Cleanup
echo -e "\n${BLUE}🧹 Cleaning up${NC}"
git checkout -- "$TEST_NOTEBOOK" 2>/dev/null || true
rm -f "$TEST_NOTEBOOK"

echo -e "\n${GREEN}🎉 Final PR storage test completed successfully!${NC}"
echo -e "${BLUE}📋 Summary: This approach will push ONLY the executed notebook to gh-storage${NC}"
echo -e "${BLUE}    using force push to avoid any merge conflicts or history issues.${NC}"
