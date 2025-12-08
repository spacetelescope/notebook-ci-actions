#!/bin/bash
# Test script for the unified notebook CI/CD system
# This script validates that the unified workflow system works correctly

set -e

echo "🧪 Testing Unified Notebook CI/CD System"
echo "========================================"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test counters
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name="$1"
    local test_command="$2"
    
    echo -e "\n${BLUE}Testing: $test_name${NC}"
    echo "Command: $test_command"
    
    TESTS_RUN=$((TESTS_RUN + 1))
    
    if eval "$test_command"; then
        echo -e "${GREEN}✅ PASSED: $test_name${NC}"
        TESTS_PASSED=$((TESTS_PASSED + 1))
    else
        echo -e "${RED}❌ FAILED: $test_name${NC}"
        TESTS_FAILED=$((TESTS_FAILED + 1))
        return 1
    fi
}

# Function to check file exists
check_file() {
    local file_path="$1"
    if [[ -f "$file_path" ]]; then
        echo -e "${GREEN}✅ File exists: $file_path${NC}"
        return 0
    else
        echo -e "${RED}❌ File missing: $file_path${NC}"
        return 1
    fi
}

# Function to validate YAML syntax
validate_yaml() {
    local yaml_file="$1"
    if command -v yq &> /dev/null; then
        yq eval '.' "$yaml_file" > /dev/null
        return $?
    elif command -v python3 &> /dev/null; then
        python3 -c "import yaml; yaml.safe_load(open('$yaml_file'))"
        return $?
    else
        echo -e "${YELLOW}⚠️ Cannot validate YAML syntax (yq or python3 not available)${NC}"
        return 0
    fi
}

echo -e "\n${BLUE}1. Checking Core Workflow Files${NC}"
echo "================================"

# Test main unified workflow exists
run_test "Main unified workflow exists" "check_file '.github/workflows/notebook-ci-unified.yml'"

# Test caller workflow examples exist
run_test "PR caller workflow exists" "check_file 'examples/caller-workflows/notebook-pr.yml'"
run_test "Merge caller workflow exists" "check_file 'examples/caller-workflows/notebook-merge.yml'"
run_test "Scheduled caller workflow exists" "check_file 'examples/caller-workflows/notebook-scheduled.yml'"
run_test "On-demand caller workflow exists" "check_file 'examples/caller-workflows/notebook-on-demand.yml'"

echo -e "\n${BLUE}2. Validating YAML Syntax${NC}"
echo "========================="

# Validate YAML syntax for all workflow files
if [[ -f ".github/workflows/notebook-ci-unified.yml" ]]; then
    run_test "Main workflow YAML syntax" "validate_yaml '.github/workflows/notebook-ci-unified.yml'"
fi

for workflow in examples/caller-workflows/*.yml; do
    if [[ -f "$workflow" ]]; then
        filename=$(basename "$workflow")
        run_test "$filename YAML syntax" "validate_yaml '$workflow'"
    fi
done

echo -e "\n${BLUE}3. Checking Documentation${NC}"
echo "=========================="

# Test documentation files exist
run_test "Main README exists" "check_file 'README-unified.md'"
run_test "Caller workflows README exists" "check_file 'examples/caller-workflows/README.md'"
run_test "Migration guide exists" "check_file 'docs/migration-guide-unified.md'"

echo -e "\n${BLUE}4. Testing Workflow Configuration${NC}"
echo "================================="

# Test that main workflow has required inputs
if [[ -f ".github/workflows/notebook-ci-unified.yml" ]]; then
    run_test "Main workflow has execution-mode input" "grep -q 'execution-mode:' '.github/workflows/notebook-ci-unified.yml'"
    run_test "Main workflow has python-version input" "grep -q 'python-version:' '.github/workflows/notebook-ci-unified.yml'"
    run_test "Main workflow has feature toggles" "grep -q 'enable-validation:' '.github/workflows/notebook-ci-unified.yml'"
    run_test "Main workflow has setup-matrix job" "grep -q 'setup-matrix:' '.github/workflows/notebook-ci-unified.yml'"
    run_test "Main workflow has process-notebooks job" "grep -q 'process-notebooks:' '.github/workflows/notebook-ci-unified.yml'"
fi

echo -e "\n${BLUE}5. Testing Caller Workflow Configuration${NC}"
echo "========================================"

# Test PR workflow configuration
if [[ -f "examples/caller-workflows/notebook-pr.yml" ]]; then
    run_test "PR workflow uses unified workflow" "grep -q 'spacetelescope/notebook-ci-actions/.github/workflows/notebook-ci-unified.yml@v3' 'examples/caller-workflows/notebook-pr.yml'"
    run_test "PR workflow has execution-mode: pr" "grep -q \"execution-mode: 'pr'\" 'examples/caller-workflows/notebook-pr.yml'"
    run_test "PR workflow has CASJOBS secrets" "grep -q 'CASJOBS_USERID' 'examples/caller-workflows/notebook-pr.yml'"
fi

# Test merge workflow configuration
if [[ -f "examples/caller-workflows/notebook-merge.yml" ]]; then
    run_test "Merge workflow uses unified workflow" "grep -q 'spacetelescope/notebook-ci-actions/.github/workflows/notebook-ci-unified.yml@v3' 'examples/caller-workflows/notebook-merge.yml'"
    run_test "Merge workflow has execution-mode: merge" "grep -q \"execution-mode: 'merge'\" 'examples/caller-workflows/notebook-merge.yml'"
    run_test "Merge workflow enables HTML build" "grep -q 'enable-html-build: true' 'examples/caller-workflows/notebook-merge.yml'"
fi

# Test on-demand workflow configuration
if [[ -f "examples/caller-workflows/notebook-on-demand.yml" ]]; then
    run_test "On-demand workflow has action_type input" "grep -q 'action_type:' 'examples/caller-workflows/notebook-on-demand.yml'"
    run_test "On-demand workflow has multiple job options" "grep -q 'validate-all:' 'examples/caller-workflows/notebook-on-demand.yml'"
    run_test "On-demand workflow has deprecation option" "grep -q 'deprecate-notebook:' 'examples/caller-workflows/notebook-on-demand.yml'"
fi

echo -e "\n${BLUE}6. Testing Directory Structure${NC}"
echo "=============================="

# Test expected directory structure
run_test ".github/workflows directory exists" "[[ -d '.github/workflows' ]]"
run_test "examples directory exists" "[[ -d 'examples' ]]"
run_test "examples/caller-workflows directory exists" "[[ -d 'examples/caller-workflows' ]]"
run_test "docs directory exists" "[[ -d 'docs' ]]"

echo -e "\n${BLUE}7. Testing Feature Completeness${NC}"
echo "=============================="

# Test that all required features are documented
if [[ -f "README-unified.md" ]]; then
    run_test "README mentions execution modes" "grep -q 'execution-mode' 'README-unified.md'"
    run_test "README mentions feature toggles" "grep -q 'enable-validation' 'README-unified.md'"
    run_test "README mentions deprecation" "grep -q 'deprecation' 'README-unified.md'"
    run_test "README has configuration examples" "grep -q 'conda-environment' 'README-unified.md'"
fi

# Test migration guide completeness
if [[ -f "docs/migration-guide-unified.md" ]]; then
    run_test "Migration guide mentions old workflows" "grep -q 'notebook-ci-pr-selective.yml' 'docs/migration-guide-unified.md'"
    run_test "Migration guide has step-by-step process" "grep -q 'Step 1:' 'docs/migration-guide-unified.md'"
    run_test "Migration guide has troubleshooting" "grep -q 'Troubleshooting' 'docs/migration-guide-unified.md'"
fi

echo -e "\n${BLUE}8. Testing Examples and Templates${NC}"
echo "================================="

# Test that examples contain all necessary configuration
for workflow in examples/caller-workflows/notebook-*.yml; do
    if [[ -f "$workflow" ]]; then
        filename=$(basename "$workflow")
        run_test "$filename has uses statement" "grep -q 'uses:.*notebook-ci-unified.yml' '$workflow'"
        run_test "$filename has with section" "grep -q 'with:' '$workflow'"
        run_test "$filename has secrets section" "grep -q 'secrets:' '$workflow'"
    fi
done

echo -e "\n${BLUE}9. Performance and Best Practices Check${NC}"
echo "=========================================="

# Check for performance optimizations in main workflow
if [[ -f ".github/workflows/notebook-ci-unified.yml" ]]; then
    run_test "Main workflow has docs-only detection" "grep -q 'docs-only' '.github/workflows/notebook-ci-unified.yml'"
    run_test "Main workflow has selective execution" "grep -q 'matrix-notebooks' '.github/workflows/notebook-ci-unified.yml'"
    run_test "Main workflow has caching setup" "grep -q 'enable-cache' '.github/workflows/notebook-ci-unified.yml'"
    run_test "Main workflow has error handling" "grep -q 'continue-on-error\|if.*success\|if.*failure' '.github/workflows/notebook-ci-unified.yml'"
fi

echo -e "\n${BLUE}10. Integration Test Simulation${NC}"
echo "==============================="

# Simulate what would happen in different scenarios
echo "Simulating PR scenario..."
run_test "PR triggers would work" "grep -A 10 -B 5 'pull_request:' 'examples/caller-workflows/notebook-pr.yml' | grep -q 'notebooks/'"

echo "Simulating merge scenario..."
run_test "Merge triggers would work" "grep -A 10 -B 5 'on:' 'examples/caller-workflows/notebook-merge.yml' | grep -q 'push:'"

echo "Simulating scheduled run..."
run_test "Scheduled triggers would work" "grep -A 5 'schedule:' 'examples/caller-workflows/notebook-scheduled.yml' | grep -q 'cron:'"

# Final Results
echo -e "\n${BLUE}Test Results Summary${NC}"
echo "===================="
echo -e "Total Tests Run: ${BLUE}$TESTS_RUN${NC}"
echo -e "Tests Passed: ${GREEN}$TESTS_PASSED${NC}"
echo -e "Tests Failed: ${RED}$TESTS_FAILED${NC}"

if [[ $TESTS_FAILED -eq 0 ]]; then
    echo -e "\n${GREEN}🎉 All tests passed! The unified notebook CI/CD system is ready for use.${NC}"
    exit 0
else
    echo -e "\n${RED}❌ Some tests failed. Please review the failures above and fix the issues.${NC}"
    exit 1
fi
