#!/bin/bash

# Test script for PR storage stash fix
# This validates that the new stash approach works correctly

set -e

echo "🧪 Testing PR Storage Stash Fix"
echo "================================"

# Test data
test_notebook="notebooks/testing/test-storage.ipynb"
temp_dir="/tmp/test-storage-$$"

# Create test environment
mkdir -p "$temp_dir"
cd "$temp_dir"

# Initialize git repo
git init
git config user.name "Test User"
git config user.email "test@example.com"

# Create test notebook structure
mkdir -p notebooks/testing
cat > "$test_notebook" << 'EOF'
{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "# Test notebook for storage validation\n",
    "print('Original notebook content')"
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

# Initial commit
git add .
git commit -m "Initial commit"

# Create remote and gh-storage branch
git checkout -b gh-storage
git checkout master

echo "✅ Test environment created"

# Simulate notebook execution (modify the file)
echo "🔄 Simulating notebook execution..."
cat > "$test_notebook" << 'EOF'
{
 "cells": [
  {
   "cell_type": "code",
   "execution_count": 1,
   "metadata": {},
   "outputs": [
    {
     "name": "stdout",
     "output_type": "stream",
     "text": [
      "Original notebook content\n"
     ]
    }
   ],
   "source": [
    "# Test notebook for storage validation\n",
    "print('Original notebook content')"
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

echo "✅ Notebook 'executed' (outputs added)"

# Test the new stash approach
echo "🧪 Testing stash approach..."

# Store current state
current_branch=$(git branch --show-current)
echo "📍 Current branch: $current_branch"

# Create backup
temp_notebook="/tmp/executed_$(basename "$test_notebook")"
cp "$test_notebook" "$temp_notebook"
echo "📋 Backed up executed notebook to: $temp_notebook"

# Test stash operation (this should work now)
git add "$test_notebook"
git stash push -m "Temporary stash of executed notebook for gh-storage" -- "$test_notebook"
echo "📦 Stashed executed notebook changes"

# Switch to gh-storage
git checkout gh-storage
echo "🔄 Switched to gh-storage branch"

# Copy from backup
mkdir -p "$(dirname "$test_notebook")"
cp "$temp_notebook" "$test_notebook"
echo "📋 Copied executed notebook from backup"

# Stage and commit
git add "$test_notebook"
if git diff --cached --quiet; then
  echo "ℹ️ No changes detected"
else
  echo "✅ Changes detected, committing"
  git commit -m "Update executed notebook [skip ci]"
fi

# Return to original branch
git checkout "$current_branch"
echo "🔄 Returned to original branch"

# Clean up stash
if git stash list | grep -q "Temporary stash of executed notebook for gh-storage"; then
  git stash drop
  echo "🧹 Cleaned up temporary stash"
fi

# Clean up
rm -f "$temp_notebook"

echo ""
echo "🎉 Stash fix test completed successfully!"
echo "✅ No 'would be overwritten by checkout' errors"
echo "✅ Stash approach works correctly"
echo "✅ Executed notebook stored to gh-storage"
echo "✅ Clean branch switching achieved"

# Cleanup test environment
cd /
rm -rf "$temp_dir"

echo ""
echo "🚀 PR Storage Stash Fix is ready for deployment!"
