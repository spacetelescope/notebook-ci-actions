# Scripts Directory

This directory contains automation scripts for migrating STScI notebook repositories to use the centralized GitHub Actions workflows.

## 📋 Table of Contents

- [Overview](#overview)
- [Scripts](#scripts)
  - [validate-repository.sh](#validate-repositorysh)
  - [migrate-repository.sh](#migrate-repositorysh)
- [Usage Examples](#usage-examples)
- [Repository-Specific Configurations](#repository-specific-configurations)
- [Troubleshooting](#troubleshooting)
- [Advanced Usage](#advanced-usage)

## 🎯 Overview

These scripts automate the migration process for the following STScI notebook repositories:

- **`jdat_notebooks`** - JWST Data Analysis Tools
- **`mast_notebooks`** - MAST Archive Tools and Examples  
- **`hst_notebooks`** - Hubble Space Telescope Analysis Tools
- **`hello_universe`** - Educational Astronomy Content
- **`jwst-pipeline-notebooks`** - JWST Pipeline and Analysis Tools

## 🔧 Scripts

### `validate-repository.sh`

**Purpose**: Pre-migration validation and readiness assessment

**Usage**:
```bash
./validate-repository.sh <repository_name> [org_name]
```

**What it checks**:
- ✅ Repository structure and required directories
- ✅ Notebook files and formats
- ✅ Existing workflow configurations
- ✅ Dependency files and package requirements
- ✅ Repository-specific requirements (CRDS, MAST APIs, etc.)
- ✅ Git status and branch cleanliness

**Output**: 
- Detailed validation report
- Readiness score (0-100%)
- Specific recommendations for preparation

**Example**:
```bash
# Validate jdat_notebooks repository
./validate-repository.sh jdat_notebooks spacetelescope

# Expected output:
# ========================================
# Migration Readiness Check: jdat_notebooks  
# ========================================
# 
# [✓] Repository structure validated
# [✓] Notebooks directory found (45 notebooks)
# [⚠] Some notebooks may need output stripping
# [✓] CRDS-specific tools detected
# 
# Readiness Score: 85% - Ready for migration
```

### `migrate-repository.sh`

**Purpose**: Automated migration to centralized workflows

**Usage**:
```bash
./migrate-repository.sh <repository_name> [org_name]
```

**What it does**:
1. **Creates migration branch** with backup of existing workflows
2. **Installs centralized workflows** from example templates
3. **Configures repository-specific settings** automatically
4. **Updates workflow references** to use the correct organization
5. **Creates migration tracking file** for progress monitoring
6. **Generates summary report** with next steps

**Safety features**:
- ✅ Automatic backup of existing workflows
- ✅ Branch-based migration (no direct main branch changes)
- ✅ Repository-specific validation before changes
- ✅ Detailed logging and error handling
- ✅ Rollback instructions in case of issues

**Example**:
```bash
# Migrate hello_universe repository
./migrate-repository.sh hello_universe spacetelescope

# Expected output:
# [INFO] Starting migration for hello_universe...
# [SUCCESS] Migration branch created: migrate-to-centralized-actions
# [SUCCESS] Workflows backed up to: .github/workflows-backup/
# [SUCCESS] New workflows installed: notebook-ci-pr.yml, notebook-ci-main.yml
# [SUCCESS] Repository-specific configuration applied
# [SUCCESS] Migration completed successfully
```

## 💡 Usage Examples

### Basic Migration Workflow

```bash
# Step 1: Validate repository readiness
cd /path/to/target/repository
../notebook-ci-actions/scripts/validate-repository.sh $(basename $(pwd)) spacetelescope

# Step 2: Run migration if readiness score > 80%
../notebook-ci-actions/scripts/migrate-repository.sh $(basename $(pwd)) spacetelescope

# Step 3: Review changes and test workflows
git log --oneline -5
git diff main..migrate-to-centralized-actions

# Step 4: Create pull request when ready
git push origin migrate-to-centralized-actions
```

### Batch Migration (All Repositories)

```bash
#!/bin/bash
# Migrate all STScI notebook repositories

REPOS=("hello_universe" "mast_notebooks" "jdat_notebooks" "hst_notebooks" "jwst-pipeline-notebooks")
ORG="spacetelescope"

for repo in "${REPOS[@]}"; do
    echo "=== Processing $repo ==="
    
    # Clone if not exists
    if [ ! -d "$repo" ]; then
        git clone "https://github.com/$ORG/$repo.git"
    fi
    
    cd "$repo"
    
    # Validate first
    echo "Validating $repo..."
    ../notebook-ci-actions/scripts/validate-repository.sh "$repo" "$ORG"
    
    # Migrate if validation passes
    echo "Migrating $repo..."
    ../notebook-ci-actions/scripts/migrate-repository.sh "$repo" "$ORG"
    
    cd ..
    echo "Completed $repo"
    echo
done
```

### Dry Run Validation

```bash
# Check all repositories without making changes
for repo in jdat_notebooks mast_notebooks hst_notebooks hello_universe jwst-pipeline-notebooks; do
    echo "=== $repo ==="
    if [ -d "$repo" ]; then
        cd "$repo"
        ../notebook-ci-actions/scripts/validate-repository.sh "$repo" spacetelescope | grep -E "(Score|WARNING|ERROR)"
        cd ..
    else
        echo "Repository not found: $repo"
    fi
    echo
done
```

## 🏗️ Repository-Specific Configurations

The migration script automatically applies repository-specific configurations:

### `jdat_notebooks`
- **Package Manager**: uv (primary)
- **Special Features**: CRDS cache support, CasJobs integration
- **Workflows**: Full CI pipeline with security scanning
- **Secrets**: `CASJOBS_USERID`, `CASJOBS_PW`

### `mast_notebooks`  
- **Package Manager**: uv (primary)
- **Special Features**: MAST API access, archive queries
- **Workflows**: Standard CI pipeline with API testing
- **Secrets**: Repository-specific authentication tokens

### `hst_notebooks`
- **Package Manager**: micromamba (conda environment)
- **Special Features**: Auto-detected hstcal environment setup
- **Workflows**: Conda-based CI with STScI software stack
- **Environment**: Automatic `hstcal` installation via micromamba

### `hello_universe`
- **Package Manager**: uv (lightweight)
- **Special Features**: Educational focus, simplified validation
- **Workflows**: Reduced security scanning for educational content
- **Configuration**: Optimized for beginner-friendly experience

### `jwst-pipeline-notebooks`
- **Package Manager**: uv (primary)
- **Special Features**: jdaviz image replacement, JWST pipeline
- **Workflows**: Full CI with post-processing scripts
- **Post-processing**: Automatic jdaviz widget replacement in HTML

## 🚨 Troubleshooting

### Common Issues and Solutions

#### Issue 1: Permission Denied
```bash
# Error: Permission denied when running scripts
# Solution: Make scripts executable
chmod +x scripts/validate-repository.sh
chmod +x scripts/migrate-repository.sh
```

#### Issue 2: Repository Not Found
```bash
# Error: Repository directory not found
# Solution: Ensure you're in the correct directory
pwd  # Should show path containing target repository
ls   # Should show repository directory
```

#### Issue 3: Git Branch Already Exists
```bash
# Error: Branch 'migrate-to-centralized-actions' already exists
# Solution: Delete existing branch or use different name
git branch -D migrate-to-centralized-actions
# Then re-run migration script
```

#### Issue 4: Workflow Validation Fails
```bash
# Error: YAML syntax errors in generated workflows
# Solution: Check generated workflows and fix syntax
yamllint .github/workflows/*.yml
```

#### Issue 5: Low Readiness Score
```bash
# Error: Readiness score < 80%
# Solution: Address issues mentioned in validation output
# Common fixes:
# - Strip notebook outputs: nbstripout notebooks/*.ipynb
# - Add missing dependency files: requirements.txt or environment.yml
# - Clean up git status: git add .; git commit -m "Pre-migration cleanup"
```

### Emergency Rollback

If migration causes issues:

```bash
# Option 1: Rollback using backup (if migration script was used)
rm .github/workflows/*.yml
cp .github/workflows-backup/*.yml .github/workflows/
git add .github/workflows/
git commit -m "Rollback: Restore original workflows"

# Option 2: Hard reset to previous state
git checkout main
git branch -D migrate-to-centralized-actions
```

## 🚀 Advanced Usage

### Custom Organization

```bash
# Use with different organization
./migrate-repository.sh my_notebooks my-organization
```

### Custom Workflow Templates

```bash
# Use custom workflow templates (modify script)
# Edit migrate-repository.sh line ~150:
# Change: cp ../notebook-ci-actions/examples/workflows/*.yml
# To: cp /path/to/custom/workflows/*.yml
```

### Debugging Mode

```bash
# Run with verbose debugging
bash -x ./migrate-repository.sh jdat_notebooks spacetelescope
```

### Testing Mode

```bash
# Test migration without making changes (modify script)
# Add DRY_RUN=true at top of migrate-repository.sh
# All git commands will be echoed but not executed
```

## 📋 Script Exit Codes

Both scripts use standard exit codes:

- **0**: Success - operation completed without errors
- **1**: General error - invalid arguments or runtime error  
- **2**: Validation failure - repository not ready for migration
- **3**: Git error - repository state issues
- **4**: File system error - missing files or permission issues

## 📊 Validation Criteria

The validation script scores repositories based on:

| Criteria | Weight | Points | Description |
|----------|--------|--------|-------------|
| **Repository Structure** | 20% | 20 | Required directories and files |
| **Notebook Quality** | 25% | 25 | Valid notebooks, stripped outputs |
| **Dependencies** | 20% | 20 | requirements.txt or environment.yml |
| **Git Status** | 15% | 15 | Clean working directory |
| **Repository-Specific** | 20% | 20 | Special requirements (CRDS, APIs) |

**Minimum score for migration**: 80%

## 📝 Logging and Reports

### Validation Report Location
```
validation-report-<repository>-<timestamp>.txt
```

### Migration Log Location  
```
migration-log-<repository>-<timestamp>.txt
```

### Migration Status File
```
migration-status.md  # Created in repository root
```

---

## 🤝 Contributing

To improve these scripts:

1. **Test thoroughly** with repository forks
2. **Add error handling** for new edge cases
3. **Update repository-specific configurations** as needed
4. **Maintain backwards compatibility** with existing migrations
5. **Document new features** in this README

## 📞 Support

- **Issues**: Create issues in the `notebook-ci-actions` repository
- **Documentation**: See `docs/` folder for detailed migration guides
- **Emergency**: Contact repository maintainers directly

---

**Last Updated**: June 11, 2025  
**Script Version**: 1.0.0  
**Compatible with**: notebook-ci-actions v1.x
