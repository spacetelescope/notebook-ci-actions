# Migration Guide for Versioned Workflows

This guide explains how to update caller workflows when new versions of the dev-actions workflows are released.

## 📋 Table of Contents

- [Overview](#overview)
- [Version Update Process](#version-update-process)
- [Migration Examples](#migration-examples)
- [Breaking Changes by Version](#breaking-changes-by-version)
- [Automated Migration Tools](#automated-migration-tools)
- [Testing Migration](#testing-migration)
- [Rollback Strategy](#rollback-strategy)

## 🎯 Overview

When dev-actions workflows are updated, caller repositories need to be updated to use the new versions. This guide provides step-by-step instructions for safe migration.

## 🔄 Version Update Process

### Step 1: Check Current Version
```bash
# Check what version you're currently using
grep -r "dev-actions" .github/workflows/
```

### Step 2: Review Release Notes
- Visit the [releases page](../../releases)
- Read the changelog for breaking changes
- Identify required updates to your workflows

### Step 3: Update Workflow References

#### For Patch/Minor Updates (Safe)
```yaml
# From:
uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v1.0.0

# To (automatic updates within v1.x.x):
uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v1
```

#### For Major Updates (Breaking Changes)
```yaml
# From:
uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v1

# To (requires manual verification):
uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v2
```

## 🚀 Migration Examples

### Example 1: v1.0.0 → v1.1.0 (Minor Update)

**Changes in v1.1.0:**
- Added `post-run-script` input to HTML builder
- No breaking changes

**Migration Steps:**
```yaml
# No changes required for existing workflows
# Optional: Add new feature
jobs:
  build-docs:
    uses: your-org/dev-actions/.github/workflows/ci_html_builder.yml@v1
    with:
      python-version: "3.11"
      post-run-script: "scripts/custom-processing.sh"  # New optional feature
```

### Example 2: v1.2.0 → v2.0.0 (Major Update)

**Breaking Changes in v2.0.0:**
- `execution-mode` input removed from ci_pipeline.yml
- `build-html` input moved to separate workflow
- New required input: `validation-level`

**Before (v1.x):**
```yaml
jobs:
  ci:
    uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v1
    with:
      python-version: "3.11"
      execution-mode: "full"
      build-html: true
      security-scan: true
```

**After (v2.0):**
```yaml
jobs:
  ci:
    uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v2
    with:
      python-version: "3.11"
      validation-level: "comprehensive"  # New required input
      security-scan: true
      # build-html removed - use separate job
  
  build-docs:
    needs: ci
    uses: your-org/dev-actions/.github/workflows/ci_html_builder.yml@v2
    with:
      python-version: "3.11"
```

## 📚 Breaking Changes by Version

### v2.0.0 (Hypothetical)
- **Removed:** `execution-mode` input from ci_pipeline.yml
- **Added:** `validation-level` input (required)
- **Changed:** `build-html` moved to separate workflow
- **Migration:** Split CI and HTML building into separate jobs

### v3.0.0 (Hypothetical)
- **Removed:** `python-version` default (now required)
- **Changed:** Secret names (`CASJOBS_*` → `ASTRONOMICAL_*`)
- **Added:** New required permission scopes

## 🤖 Automated Migration Tools

### Migration Script for v1 → v2
```bash
#!/bin/bash
# migrate-to-v2.sh

echo "Migrating workflows from v1 to v2..."

# Find all workflow files
workflow_files=$(find .github/workflows -name "*.yml" -o -name "*.yaml")

for file in $workflow_files; do
    if grep -q "dev-actions.*@v1" "$file"; then
        echo "Migrating $file..."
        
        # Create backup
        cp "$file" "$file.backup"
        
        # Update version reference
        sed -i 's|dev-actions.*@v1|dev-actions/.github/workflows/ci_pipeline.yml@v2|g' "$file"
        
        # Remove deprecated execution-mode
        sed -i '/execution-mode:/d' "$file"
        
        # Add required validation-level
        sed -i '/python-version:/a\      validation-level: "comprehensive"' "$file"
        
        echo "✅ Migrated $file"
    fi
done

echo "Migration complete! Please review changes and test."
```

### GitHub Action for Migration
```yaml
name: Migrate Workflows

on:
  workflow_dispatch:
    inputs:
      target_version:
        description: 'Target version to migrate to'
        required: true
        type: string

jobs:
  migrate:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      
    - name: Migrate Workflows
      run: |
        # Download migration script
        curl -sSL https://raw.githubusercontent.com/your-org/dev-actions/main/scripts/migrate.sh | bash -s ${{ github.event.inputs.target_version }}
        
    - name: Create PR
      uses: peter-evans/create-pull-request@v5
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        commit-message: "Migrate workflows to dev-actions@${{ github.event.inputs.target_version }}"
        title: "Migrate to dev-actions ${{ github.event.inputs.target_version }}"
        body: |
          Automated migration to dev-actions ${{ github.event.inputs.target_version }}
          
          Please review changes carefully before merging.
        branch: migrate-workflows-${{ github.event.inputs.target_version }}
```

## 🧪 Testing Migration

### Local Testing
```bash
# 1. Create test branch
git checkout -b test-migration-v2

# 2. Update workflow files
# (make changes)

# 3. Test with workflow dispatch
# Trigger workflows manually to verify they work

# 4. Check workflow run logs
# Ensure no errors or warnings
```

### Staging Environment
```yaml
# Use separate workflow for testing
name: Test Migration

on:
  workflow_dispatch:
    inputs:
      test_version:
        description: 'Version to test'
        required: true
        type: string

jobs:
  test-migration:
    uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@${{ github.event.inputs.test_version }}
    with:
      # Test with your parameters
      python-version: "3.11"
      validation-level: "comprehensive"
```

### Gradual Rollout
```yaml
# Deploy to different environments gradually
jobs:
  # Test on feature branches first
  test-env:
    if: github.ref != 'refs/heads/main'
    uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v2
    
  # Deploy to main after testing
  prod-env:
    if: github.ref == 'refs/heads/main'
    uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v1  # Keep stable version initially
```

## 🔙 Rollback Strategy

### Quick Rollback
```yaml
# If issues occur, quickly revert to previous version
jobs:
  ci:
    uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v1  # Rollback to v1
    with:
      # Revert to old parameters
      python-version: "3.11"
      execution-mode: "full"
      build-html: true
```

### Automated Rollback
```yaml
name: Rollback Migration

on:
  workflow_dispatch:
    inputs:
      rollback_to:
        description: 'Version to rollback to'
        required: true
        type: string

jobs:
  rollback:
    runs-on: ubuntu-latest
    steps:
    - name: Checkout
      uses: actions/checkout@v4
      
    - name: Rollback Changes
      run: |
        # Restore from backup files
        find .github/workflows -name "*.backup" | while read backup; do
          original=${backup%.backup}
          cp "$backup" "$original"
          echo "Restored $original"
        done
        
    - name: Create Rollback PR
      uses: peter-evans/create-pull-request@v5
      with:
        token: ${{ secrets.GITHUB_TOKEN }}
        commit-message: "Rollback workflows to ${{ github.event.inputs.rollback_to }}"
        title: "🔙 Rollback to dev-actions ${{ github.event.inputs.rollback_to }}"
        body: |
          Emergency rollback to dev-actions ${{ github.event.inputs.rollback_to }}
          
          Reason: Issues found in newer version
        branch: rollback-workflows-${{ github.event.inputs.rollback_to }}
```

## 📋 Migration Checklist

### Before Migration
- [ ] Review release notes and breaking changes
- [ ] Backup current workflow files
- [ ] Identify all repositories using dev-actions
- [ ] Plan migration timeline
- [ ] Notify team of upcoming changes

### During Migration
- [ ] Update workflow references
- [ ] Update input parameters
- [ ] Update secret names (if changed)
- [ ] Test in staging environment
- [ ] Verify all workflows trigger correctly
- [ ] Check for deprecation warnings

### After Migration
- [ ] Monitor workflow runs for errors
- [ ] Update documentation
- [ ] Remove backup files
- [ ] Update migration guide
- [ ] Share migration results with team

## 🚨 Common Issues and Solutions

### Issue 1: Workflow Not Found
```
Error: .github/workflows/ci_pipeline.yml@v2 not found
```
**Solution:** Check if the version tag exists in the dev-actions repository.

### Issue 2: Input Validation Failed
```
Error: Required input 'validation-level' not provided
```
**Solution:** Add missing required inputs from the new version.

### Issue 3: Secret Not Found
```
Error: Secret 'ASTRONOMICAL_TOKEN' not found
```
**Solution:** Update secret names in repository settings.

### Issue 4: Permission Denied
```
Error: Insufficient permissions to access workflow
```
**Solution:** Update repository permissions or GITHUB_TOKEN scope.

## 📞 Getting Help

### Support Channels
- **Issues:** Create issue in dev-actions repository
- **Discussions:** Use GitHub Discussions for questions
- **Documentation:** Check docs/ folder for detailed guides

### Emergency Contacts
- For critical issues: Create issue with `priority:high` label
- For security issues: Use private vulnerability reporting

---

## 📝 Version History

| Version | Date | Migration Complexity | Key Changes |
|---------|------|---------------------|-------------|
| v1.0.0 | 2024-01-15 | N/A | Initial release |
| v1.1.0 | 2024-02-01 | Low | Added optional features |
| v2.0.0 | 2024-03-01 | High | Breaking input changes |

For the latest migration information, see the [releases page](../../releases).
