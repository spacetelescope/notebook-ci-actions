#!/bin/bash

# Simple test script for notebook CI/CD system
# This provides basic validation without external dependencies

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}ℹ️  $1${NC}"; }
log_success() { echo -e "${GREEN}✅ $1${NC}"; }
log_warning() { echo -e "${YELLOW}⚠️  $1${NC}"; }
log_error() { echo -e "${RED}❌ $1${NC}"; }
log_step() { echo -e "${BLUE}📋 $1${NC}"; }

# Main test function
test_notebook_system() {
    echo "🧪 Simple Notebook CI/CD System Test"
    echo "===================================="
    
    # Check prerequisites
    log_step "Checking system components..."
    
    # Check for notebooks directory
    if [ -d "notebooks" ]; then
        log_success "Found notebooks directory"
        
        # Count notebooks
        notebook_count=$(find notebooks -name "*.ipynb" | wc -l)
        log_info "Found $notebook_count notebook(s)"
        
        # Validate each notebook
        find notebooks -name "*.ipynb" | while read -r notebook; do
            echo "  📝 Validating $notebook..."
            
            # Check JSON structure
            if python3 -c "import json; json.load(open('$notebook'))" 2>/dev/null; then
                cell_count=$(python3 -c "import json; print(len(json.load(open('$notebook'))['cells']))" 2>/dev/null || echo "0")
                echo "    ✅ Valid notebook with $cell_count cells"
            else
                echo "    ❌ Invalid notebook structure"
            fi
        done
        
    else
        log_warning "No notebooks directory found"
    fi
    
    # Check for workflow file
    if [ -f ".github/workflows/notebook-on-demand.yml" ]; then
        log_success "Found on-demand workflow file"
        
        # Basic workflow validation
        if grep -q "workflow_dispatch" ".github/workflows/notebook-on-demand.yml"; then
            log_success "Workflow supports manual dispatch"
        fi
        
        if grep -q "action_type" ".github/workflows/notebook-on-demand.yml"; then
            log_success "Workflow has action type selection"
        fi
        
        # Count available actions
        action_count=$(grep -c "inputs.action_type ==" ".github/workflows/notebook-on-demand.yml" || echo "0")
        log_info "Found $action_count workflow actions"
        
    else
        log_warning "No on-demand workflow file found"
        log_info "Expected location: .github/workflows/notebook-on-demand.yml"
    fi
    
    # Check for requirements file
    if [ -f "notebooks/requirements.txt" ]; then
        log_success "Found notebook requirements file"
        req_count=$(wc -l < "notebooks/requirements.txt")
        log_info "Requirements file has $req_count lines"
    else
        log_warning "No requirements file found for notebooks"
    fi
    
    # Check for documentation
    if [ -f "docs/local-testing-guide.md" ]; then
        log_success "Found local testing documentation"
    else
        log_warning "No local testing guide found"
    fi
    
    # Test basic Python functionality
    log_step "Testing Python environment..."
    if command -v python3 &> /dev/null; then
        python_version=$(python3 --version)
        log_success "Python available: $python_version"
        
        # Test JSON handling
        if python3 -c "import json; print('JSON module works')" 2>/dev/null; then
            log_success "JSON module working"
        else
            log_warning "JSON module issues"
        fi
        
        # Test if Jupyter is available
        if command -v jupyter &> /dev/null; then
            jupyter_version=$(jupyter --version 2>/dev/null | head -1 || echo "Unknown version")
            log_success "Jupyter available: $jupyter_version"
        else
            log_info "Jupyter not available (optional for basic testing)"
        fi
        
    else
        log_error "Python3 not available"
    fi
    
    # Summary
    echo ""
    echo "🎉 Test Summary"
    echo "==============="
    log_info "System components checked"
    log_info "Ready for notebook CI/CD workflows"
    echo ""
    echo "💡 Next Steps:"
    echo "  - Test workflows manually in GitHub Actions"
    echo "  - Use Act for local GitHub Actions simulation"
    echo "  - Add more notebooks to the notebooks/ directory"
    echo "  - Customize workflow parameters as needed"
}

# Run the test
test_notebook_system
