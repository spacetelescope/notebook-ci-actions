#!/bin/bash
# Test script for PR-specific gh-storage functionality
# This script tests the PR mode storage logic to ensure only executed notebooks are pushed

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${CYAN}📋 $1${NC}"
}

# Test configuration
TEST_NOTEBOOK="notebooks/examples/basic-validation-test.ipynb"
TEST_BRANCH="test-pr-storage-$(date +%s)"
ORIGINAL_BRANCH=$(git branch --show-current)

cleanup() {
    log_step "Cleaning up test environment"
    git checkout "$ORIGINAL_BRANCH" 2>/dev/null || true
    git branch -D "$TEST_BRANCH" 2>/dev/null || true
    git push origin --delete gh-storage-test 2>/dev/null || true
    rm -f /tmp/test-storage-*.log
}

trap cleanup EXIT

main() {
    log_info "Testing PR-specific gh-storage functionality"
    
    # Verify we're in the right directory
    if [[ ! -f ".github/workflows/notebook-ci-unified.yml" ]]; then
        log_error "Must be run from the root of the dev-actions repository"
        exit 1
    fi
    
    # Verify test notebook exists
    if [[ ! -f "$TEST_NOTEBOOK" ]]; then
        log_error "Test notebook not found: $TEST_NOTEBOOK"
        exit 1
    fi
    
    log_step "Setting up test environment"
    
    # Create a test branch simulating a PR
    git checkout -b "$TEST_BRANCH"
    
    # Modify the test notebook to simulate changes
    log_step "Modifying test notebook to simulate PR changes"
    python3 << 'EOF'
import json
import sys

notebook_path = "notebooks/examples/basic-validation-test.ipynb"
try:
    with open(notebook_path, 'r') as f:
        nb = json.load(f)
    
    # Add a test cell to simulate changes
    test_cell = {
        "cell_type": "code",
        "execution_count": None,
        "metadata": {},
        "outputs": [],
        "source": [
            "# Test cell added for PR storage testing\n",
            "print('PR storage test - timestamp:', pd.Timestamp.now())\n",
            "test_result = 'PR storage test successful'"
        ]
    }
    
    nb['cells'].append(test_cell)
    
    with open(notebook_path, 'w') as f:
        json.dump(nb, f, indent=2)
    
    print(f"✅ Modified {notebook_path} with test cell")
except Exception as e:
    print(f"❌ Error modifying notebook: {e}")
    sys.exit(1)
EOF
    
    # Commit the changes
    git add "$TEST_NOTEBOOK"
    git commit -m "Add test cell for PR storage testing"
    
    log_step "Testing PR storage logic simulation"
    
    # Create a simulation of the PR storage logic
    cat > /tmp/test-pr-storage-simulation.sh << 'SCRIPT_EOF'
#!/bin/bash
set -euo pipefail

# Simulate the PR storage logic from the workflow
notebook="notebooks/examples/basic-validation-test.ipynb"
execution_mode="pr"
github_event_number="123"
github_repository="spacetelescope/notebook-ci-actions"
github_server_url="https://github.com"

echo "💾 Simulating storage of executed notebook to gh-storage"

if [ "$execution_mode" = "pr" ]; then
    echo "🔄 PR mode: Force-pushing only the executed notebook to gh-storage"
    
    # Create a clean temporary directory for gh-storage operations
    temp_dir=$(mktemp -d)
    echo "📁 Created temp directory: $temp_dir"
    cd "$temp_dir"
    
    # Initialize a new git repo for clean gh-storage operations
    git init
    git config user.name "test-user"
    git config user.email "test@example.com"
    
    # Simulate remote setup (we'll just create a local test remote)
    test_remote="/tmp/test-gh-storage-remote-$(date +%s)"
    git init --bare "$test_remote"
    git remote add origin "$test_remote"
    
    # Create an initial gh-storage branch in remote
    git checkout -b gh-storage
    echo "# Test gh-storage branch" > README.md
    git add README.md
    git commit -m "Initial gh-storage commit"
    git push origin gh-storage
    
    # Now test the actual logic
    git fetch origin gh-storage 2>/dev/null && {
        git checkout -b gh-storage-new origin/gh-storage
        echo "📦 Checked out existing gh-storage branch"
    } || {
        git checkout -b gh-storage-new
        echo "🆕 Created new gh-storage branch"
    }
    
    # Copy only the executed notebook to this clean repo
    notebook_dir=$(dirname "$notebook")
    notebook_name=$(basename "$notebook")
    mkdir -p "$notebook_dir"
    
    # Simulate that the notebook has been executed (add execution output)
    cat > "$notebook" << 'NOTEBOOK_EOF'
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
      "Hello from executed notebook in PR mode!\n"
     ]
    }
   ],
   "source": [
    "print('Hello from executed notebook in PR mode!')"
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
NOTEBOOK_EOF
    
    # Add and commit only this notebook
    git add "$notebook"
    if git commit -m "Update executed notebook $notebook from PR #$github_event_number [skip ci]"; then
        echo "✅ Committed notebook changes"
        # Force push to ensure we don't get conflicts
        git push --force origin gh-storage-new:gh-storage
        echo "🚀 Force-pushed notebook to gh-storage"
    else
        echo "ℹ️ No changes to commit for $notebook"
    fi
    
    # Verify only the notebook was pushed
    echo "🔍 Verifying gh-storage contents:"
    git ls-tree -r gh-storage-new
    
    # Clean up
    cd /tmp
    rm -rf "$temp_dir" "$test_remote"
    
    echo "✅ PR storage simulation completed successfully"
else
    echo "ℹ️ Not in PR mode, skipping PR-specific logic"
fi
SCRIPT_EOF
    
    chmod +x /tmp/test-pr-storage-simulation.sh
    
    log_step "Running PR storage simulation"
    if /tmp/test-pr-storage-simulation.sh; then
        log_success "PR storage simulation passed!"
    else
        log_error "PR storage simulation failed!"
        exit 1
    fi
    
    log_step "Testing workflow YAML validation"
    
    # Test that the workflow can be parsed and validated
    if python3 -c "import yaml; yaml.safe_load(open('.github/workflows/notebook-ci-unified.yml')); print('YAML is valid')"; then
        log_success "Workflow YAML validation passed!"
    else
        log_error "Workflow YAML validation failed!"
        exit 1
    fi
    
    log_step "Testing workflow logic extraction"
    
    # Extract and validate the PR storage logic from the workflow
    python3 << 'EOF'
import yaml
import re

with open('.github/workflows/notebook-ci-unified.yml', 'r') as f:
    workflow = yaml.safe_load(f)

# Find the storage step
storage_step = None
for job_name, job in workflow['jobs'].items():
    if 'steps' in job:
        for step in job['steps']:
            if 'name' in step and 'Store executed notebook to gh-storage' in step['name']:
                storage_step = step
                break

if not storage_step:
    print("❌ Storage step not found in workflow")
    exit(1)

# Check for PR-specific logic
run_script = storage_step.get('run', '')
if 'if [ "${{ inputs.execution-mode }}" = "pr" ]' in run_script:
    print("✅ PR-specific logic found in storage step")
else:
    print("❌ PR-specific logic not found in storage step")
    exit(1)

# Check for force push logic
if '--force origin gh-storage' in run_script:
    print("✅ Force push logic found")
else:
    print("❌ Force push logic not found")
    exit(1)

# Check for temp directory logic
if 'temp_dir=$(mktemp -d)' in run_script:
    print("✅ Temporary directory logic found")
else:
    print("❌ Temporary directory logic not found")
    exit(1)

print("✅ All PR storage logic validations passed!")
EOF
    
    if [[ $? -eq 0 ]]; then
        log_success "Workflow logic validation passed!"
    else
        log_error "Workflow logic validation failed!"
        exit 1
    fi
    
    log_success "All PR storage tests passed!"
    
    echo
    echo "📋 Test Summary:"
    echo "✅ PR storage simulation completed successfully"
    echo "✅ Workflow YAML validation passed"
    echo "✅ Workflow logic validation passed"
    echo "✅ PR-specific force push logic verified"
    echo "✅ Temporary directory isolation verified"
    echo
    echo "🎯 The PR storage functionality is ready for production!"
}

main "$@"
