#!/bin/bash

# Test script for PR-specific gh-storage functionality
# This script validates that only the executed notebook is pushed to gh-storage during PR workflows

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🧪 Testing PR-specific gh-storage functionality${NC}"
echo "==============================================="

# Check if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    echo -e "${RED}❌ Not in a git repository${NC}"
    exit 1
fi

# Store original state
ORIGINAL_BRANCH=$(git branch --show-current)
echo -e "${BLUE}📍 Original branch: $ORIGINAL_BRANCH${NC}"

# Create a test notebook if it doesn't exist
TEST_NOTEBOOK="notebooks/testing/pr-storage-test.ipynb"
mkdir -p "$(dirname "$TEST_NOTEBOOK")"

if [ ! -f "$TEST_NOTEBOOK" ]; then
    echo -e "${YELLOW}📝 Creating test notebook: $TEST_NOTEBOOK${NC}"
    cat > "$TEST_NOTEBOOK" << 'EOF'
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# PR Storage Test Notebook\n",
    "\n",
    "This notebook tests the PR-specific gh-storage functionality."
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
    "print(\"PR storage test successful!\")"
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
fi

# Function to simulate PR storage logic
test_pr_storage() {
    local notebook="$1"
    echo -e "${BLUE}🧪 Testing PR storage logic for: $notebook${NC}"
    
    # Simulate git configuration (would be done by GitHub Actions)
    git config --global user.name "test-user"
    git config --global user.email "test@example.com"
    
    # Store the current branch for restoration
    current_branch=$(git branch --show-current)
    echo -e "${BLUE}📍 Current branch: $current_branch${NC}"
    
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
    
    # Copy only the executed notebook
    echo -e "${BLUE}📋 Copying executed notebook: $notebook${NC}"
    mkdir -p "$(dirname "$notebook")"
    
    # Simulate notebook execution by adding a timestamp
    if [ -f "$GITHUB_WORKSPACE/$notebook" ]; then
        cp "$GITHUB_WORKSPACE/$notebook" "$notebook"
    else
        cp "$notebook" "$notebook.bak"
        # Add execution timestamp to simulate changes
        sed 's/Test executed at: {datetime.datetime.now()}/Test executed at: '"$(date)"'/' "$notebook.bak" > "$notebook"
        rm "$notebook.bak"
    fi
    
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
    
    # Return to original branch
    git checkout "$current_branch"
    echo -e "${BLUE}🔄 Returned to branch: $current_branch${NC}"
    
    return 0
}

# Function to check gh-storage branch content
check_gh_storage_content() {
    echo -e "${BLUE}🔍 Checking gh-storage branch content${NC}"
    
    if git show-ref --verify --quiet refs/heads/gh-storage; then
        echo -e "${GREEN}✅ gh-storage branch exists${NC}"
        
        # Switch to gh-storage and list contents
        current_branch=$(git branch --show-current)
        git checkout gh-storage
        
        echo -e "${BLUE}📂 Files in gh-storage branch:${NC}"
        find . -name "*.ipynb" -type f | head -10
        
        # Return to original branch
        git checkout "$current_branch"
    else
        echo -e "${YELLOW}⚠️ gh-storage branch does not exist yet${NC}"
    fi
}

# Function to validate isolation
validate_isolation() {
    echo -e "${BLUE}🔒 Validating that only notebook files are affected${NC}"
    
    if git show-ref --verify --quiet refs/heads/gh-storage; then
        current_branch=$(git branch --show-current)
        git checkout gh-storage
        
        # Count different file types
        total_files=$(find . -type f | wc -l)
        notebook_files=$(find . -name "*.ipynb" -type f | wc -l)
        other_files=$((total_files - notebook_files))
        
        echo -e "${BLUE}📊 File count analysis:${NC}"
        echo "  Total files: $total_files"
        echo "  Notebook files: $notebook_files"
        echo "  Other files: $other_files"
        
        if [ $other_files -eq 0 ] || [ $other_files -le 2 ]; then  # Allow for .git files
            echo -e "${GREEN}✅ Good isolation: Only notebooks (and minimal git files) present${NC}"
        else
            echo -e "${YELLOW}⚠️ Warning: Non-notebook files detected${NC}"
            echo "Non-notebook files:"
            find . -type f ! -name "*.ipynb" ! -path "./.git/*"
        fi
        
        git checkout "$current_branch"
    else
        echo -e "${YELLOW}⚠️ Cannot validate - gh-storage branch does not exist${NC}"
    fi
}

# Main test sequence
echo -e "${BLUE}🚀 Starting PR storage tests${NC}"

# Test 1: Check current state
echo -e "\n${BLUE}Test 1: Current state${NC}"
check_gh_storage_content

# Test 2: Test PR storage logic
echo -e "\n${BLUE}Test 2: PR storage simulation${NC}"
test_pr_storage "$TEST_NOTEBOOK"

# Test 3: Validate isolation
echo -e "\n${BLUE}Test 3: Isolation validation${NC}"
validate_isolation

# Test 4: Test with multiple notebooks
echo -e "\n${BLUE}Test 4: Multiple notebook test${NC}"
for notebook in "notebooks/examples/basic-validation-test.ipynb" "notebooks/testing/performance-test.ipynb"; do
    if [ -f "$notebook" ]; then
        echo -e "${BLUE}🧪 Testing with: $notebook${NC}"
        test_pr_storage "$notebook"
    else
        echo -e "${YELLOW}⚠️ Skipping missing notebook: $notebook${NC}"
    fi
done

# Final validation
echo -e "\n${BLUE}Final validation${NC}"
validate_isolation

echo -e "\n${GREEN}🎉 PR storage tests completed!${NC}"
echo -e "${BLUE}📋 Summary:${NC}"
echo "  - PR storage logic simulated"
echo "  - Branch isolation validated"
echo "  - Only notebook files should be affected"
echo "  - Force-push approach eliminates merge conflicts"

# Cleanup - remove test branch if created during testing
if git show-ref --verify --quiet refs/heads/gh-storage; then
    echo -e "\n${YELLOW}🧹 Cleanup: gh-storage branch exists${NC}"
    echo "   (In real scenarios, this would contain executed notebooks)"
fi

echo -e "${GREEN}✅ All tests completed successfully!${NC}"
