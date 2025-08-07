#!/bin/bash

# Script to fix all caller workflow templates to use correct parameter names

# Define repositories
REPOS=("hst_notebooks" "jdat_notebooks" "jwst_pipeline_notebooks" "mast_notebooks")

for repo in "${REPOS[@]}"; do
    echo "Fixing workflows for $repo..."
    
    # Fix on-demand workflow
    if [[ -f "examples/caller-workflows/$repo/notebook-on-demand.yml" ]]; then
        echo "  Fixing on-demand workflow..."
        cat > "examples/caller-workflows/$repo/notebook-on-demand.yml" << 'EOF'
# On-demand workflow for REPO_NAME repository
# Copy this file to your repository's .github/workflows/ directory

name: Notebook CI - On Demand

on:
  workflow_dispatch:
    inputs:
      trigger-event:
        description: 'Execution trigger'
        required: false
        default: 'validate'
        type: choice
        options:
          - validate
          - execute
          - security
          - html
          - all
      single-notebook:
        description: 'Single notebook path (optional)'
        required: false
        default: ''
        type: string
      enable-storage:
        description: 'Enable storing outputs to gh-storage'
        required: false
        default: false
        type: boolean

jobs:
  notebook-ci:
    uses: spacetelescope/notebook-ci-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      # Required: execution mode
      execution-mode: 'on-demand'
      trigger-event: ${{ inputs.trigger-event }}
      
      # Optional: target specific notebook
      single-notebook: ${{ inputs.single-notebook }}
      
      # Environment Configuration  
      python-version: '3.11'
      custom-requirements: 'requirements.txt'
      CONDA_ENV_PLACEHOLDER
      
      # Feature flags
      enable-validation: true
      enable-security: true
      enable-execution: ${{ inputs.trigger-event == 'execute' || inputs.trigger-event == 'all' }}
      enable-storage: ${{ inputs.enable-storage && (inputs.trigger-event == 'execute' || inputs.trigger-event == 'all') }}
      enable-html-build: ${{ inputs.trigger-event == 'html' || inputs.trigger-event == 'all' }}
      
    secrets: inherit
EOF
        
        # Replace repo name and conda env
        sed -i "s/REPO_NAME/$repo/g" "examples/caller-workflows/$repo/notebook-on-demand.yml"
        if [[ "$repo" == "mast_notebooks" ]]; then
            sed -i "s/CONDA_ENV_PLACEHOLDER/conda-environment: 'environment.yml'/g" "examples/caller-workflows/$repo/notebook-on-demand.yml"
        else
            sed -i "s/CONDA_ENV_PLACEHOLDER//g" "examples/caller-workflows/$repo/notebook-on-demand.yml"
        fi
    fi
    
    # Fix scheduled workflow
    if [[ -f "examples/caller-workflows/$repo/notebook-scheduled.yml" ]]; then
        echo "  Fixing scheduled workflow..."
        cat > "examples/caller-workflows/$repo/notebook-scheduled.yml" << 'EOF'
# Scheduled workflow for REPO_NAME repository
# Copy this file to your repository's .github/workflows/ directory

name: Notebook CI - Scheduled

on:
  # Run weekly on Sundays at 2 AM UTC
  schedule:
    - cron: '0 2 * * 0'

jobs:
  notebook-ci:
    uses: spacetelescope/notebook-ci-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      # Required: execution mode
      execution-mode: 'scheduled'
      trigger-event: 'all'
      
      # Environment Configuration  
      python-version: '3.11'
      custom-requirements: 'requirements.txt'
      CONDA_ENV_PLACEHOLDER
      
      # Feature flags (scheduled does everything)
      enable-validation: true
      enable-security: true
      enable-execution: true
      enable-storage: true
      enable-html-build: true
      
      # Deprecation management for scheduled runs
      deprecation-days: 60
      
    secrets: inherit
EOF
        
        # Replace repo name and conda env
        sed -i "s/REPO_NAME/$repo/g" "examples/caller-workflows/$repo/notebook-scheduled.yml"
        if [[ "$repo" == "mast_notebooks" ]]; then
            sed -i "s/CONDA_ENV_PLACEHOLDER/conda-environment: 'environment.yml'/g" "examples/caller-workflows/$repo/notebook-scheduled.yml"
        else
            sed -i "s/CONDA_ENV_PLACEHOLDER//g" "examples/caller-workflows/$repo/notebook-scheduled.yml"
        fi
    fi
    
done

echo "All workflow templates have been updated!"
