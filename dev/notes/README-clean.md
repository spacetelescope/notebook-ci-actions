# Unified Notebook CI/CD Actions

A comprehensive, streamlined GitHub Actions workflow system for notebook-based repositories. Provides automated validation, testing, execution, documentation generation, and deprecation management through a single, configurable workflow.

## 🎯 Overview

The unified workflow system replaces multiple individual workflows with one powerful, configurable workflow that handles all notebook CI/CD needs:

- **Unified Architecture**: Single workflow (`notebook-ci-unified.yml`) handles all operations
- **Flexible Execution Modes**: PR, merge, scheduled, and on-demand modes
- **Comprehensive Features**: Validation, execution, security scanning, documentation building, deprecation management
- **Cost Effective**: Optimized to reduce GitHub Actions usage and costs
- **Local Testing**: Full local testing capabilities to catch issues before CI

## 🚀 Quick Start

### 1. Repository Setup

#### Option A: Use Migration Script (Recommended)

```bash
# Clone the actions repository
git clone https://github.com/mgough-970/dev-actions.git

# Run the automated migration script
cd your-repository
../dev-actions/scripts/migrate-to-unified.sh
```

#### Option B: Manual Setup

```bash
# Copy the caller workflows to your repository
mkdir -p .github/workflows
cp examples/caller-workflows/notebook-pr.yml .github/workflows/
cp examples/caller-workflows/notebook-merge.yml .github/workflows/
# Optional: Add scheduled and on-demand workflows
cp examples/caller-workflows/notebook-scheduled.yml .github/workflows/
cp examples/caller-workflows/notebook-on-demand.yml .github/workflows/
```

### 2. Basic Configuration

#### Standard Python Repository

```yaml
# .github/workflows/notebook-pr.yml
name: Notebook PR Validation
on:
  pull_request:
    branches: [main]

jobs:
  validate-notebooks:
    uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      execution-mode: 'pr'
      python-version: '3.11'
      enable-validation: true
      enable-security: true
      enable-execution: true
      enable-storage: true
      enable-html-build: false
```

#### Documentation Repository (like jdat_notebooks)

```yaml
# .github/workflows/notebook-merge.yml
name: Build and Deploy Documentation
on:
  push:
    branches: [main]

jobs:
  build-docs:
    uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      execution-mode: 'merge'
      python-version: '3.11'
      enable-validation: true
      enable-execution: true
      enable-storage: true
      enable-html-build: true
    secrets:
      GITHUB_TOKEN: ${{ secrets.GITHUB_TOKEN }}
```

## 📋 Execution Modes

| Mode | Purpose | When to Use | Key Features |
|------|---------|-------------|--------------|
| **PR** | Pull request validation | PRs, code review | Fast validation, selective execution, no deployment |
| **Merge** | Production deployment | Main branch pushes | Full processing, documentation deployment |
| **Scheduled** | Maintenance tasks | Cron schedule | Bulk validation, deprecation cleanup |
| **On-demand** | Manual operations | Manual trigger | Single notebook focus, debugging, deprecation |

## ⚙️ Configuration Options

### Core Settings

```yaml
with:
  # Execution mode (required)
  execution-mode: 'pr'              # pr, merge, scheduled, on-demand
  
  # Python environment
  python-version: '3.11'            # Python version to use
  conda-environment: ''             # Optional conda packages
  custom-requirements: ''           # Custom requirements file path
  
  # Features (all optional, default: false)
  enable-validation: true           # pytest nbval validation
  enable-security: true             # bandit security scanning  
  enable-execution: true            # notebook execution
  enable-storage: true              # store to gh-storage branch
  enable-html-build: true           # build HTML documentation
```

### Advanced Settings

```yaml
with:
  # Targeting (on-demand mode)
  single-notebook: 'my-notebook.ipynb'    # Target specific notebook
  trigger-event: 'execute'                # all, validate, execute, security, html, deprecate
  
  # Directory control
  affected-directories: '["notebooks"]'   # JSON array of directories
  
  # Documentation
  post-processing-script: 'scripts/post-build.sh'  # Custom post-processing
  
  # Deprecation management
  deprecation-days: 30              # Days until deprecation expires
```

## 🛠️ Common Use Cases

### 1. Pull Request Validation

**Goal**: Validate notebooks in PRs without heavy processing

```yaml
uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
with:
  execution-mode: 'pr'
  enable-validation: true
  enable-security: true
  enable-execution: true
  enable-storage: true
  enable-html-build: false  # Skip docs for PRs
```

### 2. Documentation Deployment

**Goal**: Build and deploy notebook documentation on merge

```yaml
uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
with:
  execution-mode: 'merge'
  enable-validation: true
  enable-execution: true
  enable-storage: true
  enable-html-build: true   # Build and deploy docs
```

### 3. Manual Notebook Testing

**Goal**: Test a specific notebook manually

```yaml
# In on-demand workflow
with:
  execution-mode: 'on-demand'
  trigger-event: 'execute'
  single-notebook: 'notebooks/examples/my-test.ipynb'
  enable-execution: true
```

### 4. Deprecation Management

**Goal**: Mark a notebook as deprecated and update documentation

```yaml
# Manual trigger with deprecation
with:
  execution-mode: 'on-demand'
  trigger-event: 'deprecate'
  single-notebook: 'old-notebook.ipynb'
  deprecation-days: 30
  enable-html-build: true   # Rebuild docs with warning
```

## 🎯 Migration from Old Workflows

### Old → New Workflow Mapping

| Old Workflow | Replaced By | New Configuration |
|-------------|-------------|-------------------|
| `ci_pipeline.yml` | `notebook-ci-unified.yml` | `execution-mode: 'pr'` |
| `ci_html_builder.yml` | `notebook-ci-unified.yml` | `execution-mode: 'merge'` + `enable-html-build: true` |
| `ci_deprecation_manager.yml` | `notebook-ci-unified.yml` | `execution-mode: 'on-demand'` + `trigger-event: 'deprecate'` |

### Migration Steps

1. **Backup existing workflows**:
   ```bash
   mkdir -p .github/workflows/backup
   mv .github/workflows/ci_*.yml .github/workflows/backup/
   ```

2. **Copy new caller workflows**:
   ```bash
   cp examples/caller-workflows/*.yml .github/workflows/
   ```

3. **Update configuration** in the new workflows for your repository needs

4. **Test the migration**:
   ```bash
   # Local validation
   ./scripts/validate-workflows.sh
   
   # Test with act (optional)
   ./scripts/test-with-act.sh pull_request
   ```

## 🧪 Local Testing

### Quick Validation

```bash
# Validate all workflows (30 seconds)
./scripts/validate-workflows.sh

# Test notebooks locally (2-5 minutes)  
./scripts/test-local-ci.sh

# Full workflow simulation with Docker (optional)
./scripts/test-with-act.sh pull_request
```

### Local Testing Benefits

- ✅ **Save costs**: Avoid 70-80% of GitHub Actions usage
- ✅ **Faster feedback**: Immediate results vs waiting for CI
- ✅ **Offline development**: Test without internet/GitHub access
- ✅ **Debugging**: Direct access to intermediate files and logs

## 📊 Workflow Summary

The unified workflow provides comprehensive reporting:

- **Job status**: Matrix setup, notebook processing, documentation build
- **Execution details**: Notebooks processed, success/failure counts
- **Error reporting**: Detailed failure information and debugging tips
- **Deprecation tracking**: Automatic documentation updates for deprecated notebooks

## 🔧 Advanced Features

### Selective Execution

The workflow intelligently selects notebooks to process:

- **PR mode**: Only notebooks in changed files or affected directories
- **Merge mode**: All notebooks in repository
- **On-demand**: Single notebook or all notebooks based on input

### Deprecation Management

Comprehensive deprecation workflow:

1. **Mark for deprecation**: Add metadata and hidden markers
2. **Sync to documentation**: Copy deprecated notebook to gh-storage  
3. **Update documentation**: Rebuild with visible deprecation warnings
4. **Automatic cleanup**: Move expired notebooks to deprecated branch

### Error Handling

Robust error handling and recovery:

- **Continue on error**: On-demand mode continues processing other steps
- **Failure warnings**: Visual warnings added to failed notebooks
- **Detailed reporting**: Comprehensive error information in workflow summary

## 📖 Additional Resources

- **[Quick Start Guide](QUICK_START.md)** - 5-minute setup guide
- **[Migration Guide](docs/migration-guide-unified.md)** - Detailed migration instructions
- **[Local Testing Guide](docs/local-testing-guide.md)** - Complete local testing setup
- **[Configuration Reference](docs/configuration-reference.md)** - All configuration options
- **[Troubleshooting](docs/troubleshooting-unified.md)** - Common issues and solutions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Test locally using `./scripts/test-local-ci.sh`
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
