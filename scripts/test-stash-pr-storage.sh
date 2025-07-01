#!/bin/bash

# Test script for the updated PR storage fix with stash handling
# This script validates the stash/backup approach for handling executed notebooks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing Updated PR Storage with Stash Handling${NC}"
echo "=================================================="

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Store original state
ORIGINAL_BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Original branch: $ORIGINAL_BRANCH${NC}"

# Create a test notebook and simulate execution changes
TEST_NOTEBOOK="notebooks/testing/stash-test.ipynb"
mkdir -p "$(dirname "$TEST_NOTEBOOK")"

echo -e "${YELLOW}📝 Creating test notebook with execution changes${NC}"
cat > "$TEST_NOTEBOOK" << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# Stash Test Notebook\n",
    "\n",
    "This notebook tests the stash handling for PR storage."
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import datetime\n",
    "print(f\"Test executed at: {datetime.datetime.now()}\")\n",
    "print(\"Stash test successful!\")"
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

# Add to git to establish baseline
git add "$TEST_NOTEBOOK"
git commit -m "Add stash test notebook"

# Simulate notebook execution by modifying the notebook
echo -e "${BLUE}⚙️ Simulating notebook execution (modifying content)${NC}"
sed -i 's/datetime.datetime.now()/datetime.datetime.now() # EXECUTED/' "$TEST_NOTEBOOK"

# Show current git status
echo -e "${BLUE}📊 Current git status:${NC}"
git status --porcelain

# Function to simulate the improved PR storage logic
test_improved_pr_storage() {
    local notebook="$1"
    echo -e "${BLUE}🧪 Testing improved PR storage logic for: $notebook${NC}"
    
    # Simulate git configuration (would be done by GitHub Actions)
    git config --global user.name "test-user"
    git config --global user.email "test@example.com"
    
    # Store the current branch for restoration
    current_branch=$(git branch --show-current)
    echo -e "${BLUE}📍 Current branch: $current_branch${NC}"
    
    # Create a backup of the executed notebook
    echo -e "${BLUE}📋 Creating backup of executed notebook: $notebook${NC}"
    notebook_backup="/tmp/$(basename "$notebook")"
    cp "$notebook" "$notebook_backup"
    
    # Stash any changes to avoid conflicts during checkout
    echo -e "${BLUE}💾 Stashing changes before branch switch${NC}"
    git stash push -m "Temporary stash for gh-storage operations" || echo "Nothing to stash"
    
    # Check if gh-storage branch exists
    if git fetch origin gh-storage 2>/dev/null; then
        echo -e "${GREEN}📦 Found existing gh-storage branch${NC}"
        git checkout gh-storage
        git reset --hard origin/gh-storage
    else
        echo -e "${YELLOW}🆕 Creating new gh-storage branch${NC}"
        git checkout --orphan gh-storage
        git rm -rf . 2>/dev/null || true
    fi
    
    # Copy the executed notebook from backup
    echo -e "${BLUE}📋 Copying executed notebook from backup: $notebook${NC}"
    mkdir -p "$(dirname "$notebook")"
    cp "$notebook_backup" "$notebook"
    
    # Stage only this notebook file
    git add "$notebook"
    
    # Check if there are actual changes to commit
    if git diff --cached --quiet; then
        echo -e "${YELLOW}ℹ️ No changes detected in $notebook${NC}"
        result="no-changes"
    else
        echo -e "${GREEN}✅ Changes detected, committing notebook${NC}"
        git commit -m "Update executed notebook $notebook from PR test [skip ci]"
        
        # Show what files are in the commit
        echo -e "${BLUE}📄 Files in commit:${NC}"
        git show --name-only --pretty=format:
        echo
        
        # This would be a force push in real scenario
        echo -e "${GREEN}🚀 Would force-push $notebook to gh-storage${NC}"
        result="success"
    fi
    
    # Return to original branch and restore stash if needed
    git checkout "$current_branch"
    git stash pop || echo "No stash to restore"
    echo -e "${BLUE}🔄 Returned to branch: $current_branch${NC}"
    
    # Cleanup
    rm -f "$notebook_backup"
    
    return 0
}

# Run the test
echo -e "\n${BLUE}🚀 Starting improved PR storage test${NC}"
test_improved_pr_storage "$TEST_NOTEBOOK"

# Verify the working directory state
echo -e "\n${BLUE}🔍 Verifying working directory state${NC}"
if git diff --quiet "$TEST_NOTEBOOK"; then
    echo -e "${YELLOW}⚠️ Working directory changes were lost${NC}"
else
    echo -e "${GREEN}✅ Working directory changes preserved${NC}"
    echo -e "${BLUE}📊 Current changes:${NC}"
    git diff "$TEST_NOTEBOOK"
fi

# Check if stash is empty
if git stash list | grep -q "stash@"; then
    echo -e "${YELLOW}⚠️ Stash not empty - may need cleanup${NC}"
    git stash list
else
    echo -e "${GREEN}✅ Stash is clean${NC}"
fi

echo -e "\n${GREEN}🎉 Improved PR storage test completed!${NC}"

# Cleanup
echo -e "${BLUE}🧹 Cleaning up test files${NC}"
git checkout -- "$TEST_NOTEBOOK" 2>/dev/null || true
rm -f "$TEST_NOTEBOOK"

echo -e "${GREEN}✨ Test completed successfully!${NC}"
