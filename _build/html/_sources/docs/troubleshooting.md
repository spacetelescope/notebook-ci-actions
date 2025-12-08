# Troubleshooting Guide for Unified Notebook CI/CD

This guide helps you diagnose and resolve common issues with the unified notebook CI/CD system.

## Quick Diagnostics

### 1. Workflow Not Triggering

**Symptoms:**
- PR created but no CI workflow runs
- Push to main branch doesn't trigger deployment
- Scheduled workflow doesn't run

**Common Causes & Solutions:**

#### File Paths Don't Match Triggers
```yaml
# Check your trigger paths in the workflow file
on:
  pull_request:
    paths:
      - 'notebooks/**'    # Must match your notebook location
      - 'requirements.txt' # Must exist in root
```

**Solution:** Verify the `paths:` configuration matches your repository structure.

#### Branch Name Mismatch
```yaml
on:
  pull_request:
    branches: [ main ]    # Must match your default branch
```

**Solution:** Update branch names if your default branch is `master` or something else.

#### Workflow File Location
**Problem:** Workflow file in wrong location

**Solution:** Ensure caller workflows are in `.github/workflows/` directory:
```
.github/
└── workflows/
    ├── notebook-pr.yml
    ├── notebook-merge.yml
    └── notebook-scheduled.yml
```

### 2. Environment Setup Failures

**Symptoms:**
- "Environment not found" errors
- Package installation failures
- Python version conflicts

**Common Causes & Solutions:**

#### Conda Environment Issues
```yaml
# Check conda environment name
with:
  conda-environment: 'hstcal'  # Must exist on conda-forge
```

**Valid environments:**
- `hstcal` - HST calibration tools
- `stenv` - Space Telescope environment
- `astropy` - General astronomy environment

**Solution:** Verify environment exists on conda-forge or use standard Python setup.

#### Requirements File Not Found
```yaml
with:
  custom-requirements: 'requirements.txt'  # File must exist
```

**Solution:** Check file path and ensure it exists in repository.

#### Python Version Compatibility
```yaml
with:
  python-version: '3.11'  # Must be supported
```

**Supported versions:** 3.8, 3.9, 3.10, 3.11, 3.12

### 3. Notebook Execution Failures

**Symptoms:**
- Notebooks fail to execute
- Timeout errors during execution
- Memory or resource errors

**Common Causes & Solutions:**

#### Long-Running Notebooks
**Problem:** Notebooks exceed timeout limits

**Solution:** Configure longer timeouts in your notebooks:
```python
# Add to notebook cell
import os
os.environ['NBVAL_CELL_TIMEOUT'] = '600'  # 10 minutes
```

#### Missing Dependencies
**Problem:** Notebooks require packages not in requirements

**Solution:** Add missing packages to appropriate requirements.txt:
```txt
# In notebooks/your-directory/requirements.txt
missing-package==1.0.0
another-package>=2.0
```

#### Resource Limitations
**Problem:** Notebooks require too much memory/CPU

**Solution:** 
1. Optimize notebooks for CI environment
2. Use smaller datasets for testing
3. Consider skipping resource-intensive cells in CI

### 4. Validation Failures

**Symptoms:**
- pytest nbval failures
- Notebook validation errors
- Cell execution timeouts

**Common Causes & Solutions:**

#### Cell Output Mismatches
**Problem:** Expected outputs don't match actual outputs

**Solution:** Update notebook outputs or use nbval tags:
```python
# In notebook cell, add metadata tag
{"tags": ["nbval-skip"]}  # Skip validation for this cell
```

#### Flaky Tests
**Problem:** Tests pass locally but fail in CI

**Solution:** Make notebooks deterministic:
```python
# Set random seeds
import numpy as np
np.random.seed(42)

import random
random.seed(42)
```

### 5. Storage and gh-storage Issues

**Symptoms:**
- Executed notebooks not stored
- Git push failures to gh-storage
- Conflicts when pushing outputs

**Common Causes & Solutions:**

#### Branch Permissions
**Problem:** No permissions to create/push to gh-storage branch

**Solution:** Ensure workflow has proper permissions:
```yaml
permissions:
  contents: write  # Required for git operations
```

#### Deprecated Notebook Overwrite
**Problem:** Deprecated notebooks being overwritten

**Solution:** Check notebook deprecation tags:
```python
# Notebook should have deprecation metadata
# The workflow automatically detects and skips these
```

#### Git Conflicts
**Problem:** Multiple concurrent pushes to gh-storage

**Solution:** The workflow includes retry logic, but check for:
- Multiple simultaneous PR builds
- Manual pushes to gh-storage branch

### 6. HTML Build Failures

**Symptoms:**
- JupyterBook build errors
- Documentation deployment failures
- Missing or broken documentation

**Common Causes & Solutions:**

#### Missing Table of Contents
**Problem:** No `_toc.yml` file

**Solution:** Create basic table of contents:
```yaml
# _toc.yml
format: jb-book
root: index
chapters:
  - file: notebooks/README
    sections:
      - glob: notebooks/*/*.ipynb
```

#### JupyterBook Configuration Issues
**Problem:** Invalid `_config.yml`

**Solution:** Check configuration syntax:
```yaml
# _config.yml
title: "Your Repository"
author: "Your Name"
logo: logo.png

execute:
  execute_notebooks: "off"  # Use pre-executed notebooks
```

#### Post-Processing Script Failures
**Problem:** Custom post-processing script errors

**Solution:** Debug script permissions and logic:
```bash
# Make script executable
chmod +x scripts/your_script.sh

# Test script locally
./scripts/your_script.sh
```

### 7. Secrets and Authentication

**Symptoms:**
- CASJOBS authentication failures
- Permission denied errors
- Secret not found errors

**Common Causes & Solutions:**

#### Missing Repository Secrets
**Problem:** Required secrets not configured

**Solution:** Add secrets in repository settings:
1. Go to Settings > Secrets and variables > Actions
2. Add required secrets:
   - `CASJOBS_USERID`
   - `CASJOBS_PW`

#### Incorrect Secret Names
```yaml
# Check secret names match exactly
secrets:
  CASJOBS_USERID: ${{ secrets.CASJOBS_USERID }}  # Must match exactly
  CASJOBS_PW: ${{ secrets.CASJOBS_PW }}          # Must match exactly
```

### 8. Performance Issues

**Symptoms:**
- Slow workflow execution
- Timeout errors
- High resource usage

**Common Solutions:**

#### Enable Selective Execution
```yaml
# For PR workflows, ensure selective execution is working
execution-mode: 'pr'  # Only processes changed notebooks
```

#### Optimize Feature Flags
```yaml
# Disable unnecessary features
with:
  enable-security: false     # If security scanning not needed
  enable-html-build: false   # If HTML not needed for PRs
```

#### Use Appropriate Execution Mode
```yaml
# Use docs-only mode when appropriate
# Automatically detected for documentation changes
```

## Debugging Tools

### 1. Enable Debug Logging

Add to repository variables:
```
ACTIONS_STEP_DEBUG=true
ACTIONS_RUNNER_DEBUG=true
```

### 2. Check Workflow Logs

1. Go to Actions tab in GitHub
2. Click on failed workflow run
3. Expand failed steps to see detailed logs
4. Look for error messages and stack traces

### 3. Validate YAML Syntax

Use online YAML validators or local tools:
```bash
# Using yq (if installed)
yq eval '.github/workflows/notebook-pr.yml'

# Using Python
python -c "import yaml; yaml.safe_load(open('.github/workflows/notebook-pr.yml'))"
```

### 4. Test Locally

Run the test script to validate setup:
```bash
# From the unified CI/CD repository
./scripts/test-unified-system.sh
```

## Common Error Messages

### "Error: Unable to process file command 'output' successfully"

**Cause:** Invalid JSON format in workflow outputs

**Solution:** Check JSON formatting:
```bash
# JSON should be compact, no pretty-printing
echo "matrix_notebooks=[\"notebook1.ipynb\",\"notebook2.ipynb\"]" >> $GITHUB_OUTPUT
```

### "Error: conda environment 'xyz' not found"

**Cause:** Invalid conda environment name

**Solution:** Use valid environment names:
```yaml
conda-environment: 'hstcal'  # Valid
# conda-environment: 'invalid-env'  # Invalid
```

### "Error: requirements.txt not found"

**Cause:** Specified requirements file doesn't exist

**Solution:** Check file paths:
```yaml
custom-requirements: 'requirements.txt'  # Must exist in repo root
# custom-requirements: 'path/to/requirements.txt'  # Check path
```

### "Error: workflow exceeded timeout"

**Cause:** Workflow or notebooks take too long

**Solution:** Optimize or increase timeouts:
```python
# In notebook
import os
os.environ['NBVAL_CELL_TIMEOUT'] = '1200'  # 20 minutes
```

## Migration-Specific Issues

### Old Workflow Conflicts

**Problem:** Old and new workflows both running

**Solution:** Remove old workflow files:
```bash
# Remove old workflows
rm .github/workflows/notebook-ci-pr-selective.yml
rm .github/workflows/notebook-ci-main-selective.yml
# etc.
```

### Configuration Mapping Issues

**Problem:** Old configuration doesn't map to new system

**Solution:** Use migration mapping:

| Old Setting | New Configuration |
|-------------|-------------------|
| Manual Python setup | `python-version: '3.11'` |
| Hardcoded conda env | `conda-environment: 'hstcal'` |
| Always-on features | Feature toggles |

### Missing Features

**Problem:** Feature from old system not available

**Solution:** Check configuration options:
```yaml
# Most features are now configurable
with:
  enable-validation: true
  enable-security: true
  enable-execution: true
  enable-storage: true
  enable-html-build: true
```

## Getting Help

### 1. Check Documentation

- [Configuration Reference](configuration-reference.md)
- [Migration Guide](migration-guide-unified.md)
- [Main README](../README-unified.md)

### 2. Review Examples

Check example workflows in `examples/caller-workflows/`

### 3. Test Systematically

1. Start with simplest configuration
2. Add features one at a time
3. Test each change with a draft PR

### 4. Open Issues

If problems persist:
1. Check existing issues in the repository
2. Gather relevant logs and configuration
3. Open a new issue with detailed information

### 5. Contact Support

For urgent issues or assistance with migration:
- Tag maintainers in issues
- Provide full error logs
- Include repository configuration details

## Prevention Best Practices

### 1. Regular Testing

- Test workflows with draft PRs before merging
- Validate configuration changes
- Monitor workflow performance

### 2. Documentation

- Document custom configurations
- Keep repository README updated
- Document any custom post-processing scripts

### 3. Monitoring

- Watch for deprecation warnings
- Monitor execution times
- Check for failed scheduled runs

### 4. Gradual Migration

- Migrate one workflow at a time
- Test thoroughly before removing old workflows
- Keep backups during migration

This troubleshooting guide should help you resolve most common issues with the unified notebook CI/CD system. For specific problems not covered here, refer to the detailed logs and consider opening an issue for assistance.
