# GitHub Actions Workflows

This repository contains a collection of reusable GitHub Actions workflows designed for managing Jupyter Notebook projects, specifically focused on validation, execution, building documentation, and deprecation management.

## 📋 Table of Contents

- [Overview](#overview)
- [Workflows](#workflows)
  - [CI Pipeline (`ci_pipeline.yml`)](#ci-pipeline-ci_pipelineyml)
  - [HTML Builder (`ci_html_builder.yml`)](#html-builder-ci_html_builderyml)
  - [Deprecation Manager (`ci_deprecation_manager.yml`)](#deprecation-manager-ci_deprecation_manageryml)
- [Scripts](#scripts)
- [Usage Examples](#usage-examples)
- [Example Caller Workflows](#example-caller-workflows)
- [Prerequisites](#prerequisites)
- [Versioning & Releases](#versioning--releases)
- [Contributing](#contributing)

## 🎯 Overview

These workflows are designed to support notebook-based projects with comprehensive CI/CD capabilities including:

- **Notebook Validation & Execution**: Automated testing and execution of Jupyter notebooks
- **Documentation Building**: Converting notebooks to HTML documentation using JupyterBook
- **Security Scanning**: Automated security analysis of notebook code
- **Deprecation Management**: Systematic handling of deprecated notebooks
- **Artifact Management**: Handling of failed notebooks and build artifacts

## 🔧 Workflows

### CI Pipeline (`ci_pipeline.yml`)

**Purpose**: Comprehensive notebook validation, execution, and testing pipeline.

**Trigger**: `workflow_call` (reusable workflow)

**Key Features**:
- ✅ Notebook validation using `nbval`
- 🏃‍♂️ Notebook execution with timeout controls
- 🔒 Security scanning with `bandit`
- 📦 Artifact upload on failures
- 🐍 Multiple Python version support
- 🔧 Support for both `uv` and `micromamba` environments

#### Inputs

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `python-version` | string | ✅ | - | Python version to use (e.g., "3.11") |
| `execution-mode` | string | ✅ | - | Execution mode for notebooks |
| `single-filename` | string | ❌ | - | Path to a single notebook file to process |
| `build-html` | boolean | ❌ | `true` | Whether to build HTML documentation |
| `security-scan` | boolean | ❌ | `true` | Whether to perform security scanning |

#### Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `CASJOBS_USERID` | ❌ | CasJobs user ID for astronomical data access |
| `CASJOBS_PW` | ❌ | CasJobs password for astronomical data access |

#### Workflow Steps

1. **Environment Setup**: Sets up Python environment with `uv` and/or `micromamba`
2. **Dependency Installation**: Installs validation tools (`jupyter`, `nbval`, `nbconvert`, `bandit`)
3. **Notebook Validation**: Validates notebooks using pytest with nbval
4. **Notebook Execution**: Executes notebooks in-place with timeout controls
5. **Security Scanning**: Converts notebooks to scripts and runs security analysis
6. **Artifact Upload**: Uploads failed notebooks for debugging

### HTML Builder (`ci_html_builder.yml`)

**Purpose**: Build and deploy JupyterBook documentation to GitHub Pages.

**Trigger**: `workflow_call` (reusable workflow)

**Key Features**:
- 📚 JupyterBook building
- 🚀 Automatic GitHub Pages deployment
- ⚡ Fast dependency management with `uv`
- 📖 Full git history preservation

#### Inputs

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `python-version` | string | ❌ | `"3.11"` | Python version for building |
| `post-run-script` | string | ❌ | - | Path to a post-processing script to run after building HTML (e.g., `jdaviz_image_replacement.sh`) |

#### Secrets

| Secret | Required | Description |
|--------|----------|-------------|
| `github-token` | ✅ | GitHub token for Pages deployment |

#### Workflow Steps

1. **Checkout**: Full repository checkout with complete git history
2. **Environment Setup**: Configure `uv` with specified Python version
3. **JupyterBook Installation**: Install JupyterBook and dependencies
4. **Build**: Generate HTML documentation from notebooks
5. **Post-Processing**: Run optional post-processing script on generated HTML
6. **Deploy**: Deploy built documentation to GitHub Pages

### Deprecation Manager (`ci_deprecation_manager.yml`)

**Purpose**: Manage notebook lifecycle through deprecation and cleanup processes.

**Trigger**: 
- `workflow_call` (manual deprecation)
- `schedule` (daily at 3 AM UTC for cleanup)

**Key Features**:
- 📝 Manual notebook deprecation marking
- 🗂️ Automated cleanup of expired deprecated notebooks
- ⏰ Scheduled maintenance operations
- 🏷️ Metadata-driven deprecation management

#### Inputs

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `notebook-path` | string | ❌ | Path to notebook to deprecate |
| `removal-date` | string | ❌ | Date when notebook should be removed |

#### Jobs

- **`deprecate-manual`**: Triggered on workflow dispatch to mark notebooks as deprecated
- **`move-deprecated`**: Scheduled job to clean up expired deprecated notebooks

## 📜 Scripts

### `nbstripout.sh`

**Purpose**: Strip output from Jupyter notebooks for cleaner version control.

**Location**: `.github/scripts/nbstripout.sh`

**Usage**: Recursively finds and strips output from all notebooks in the `notebooks/` directory.

```bash
#!/bin/bash
find notebooks/ -name '*.ipynb' -exec nbstripout {} \;
```

## 💡 Usage Examples

### Basic Notebook CI Pipeline

```yaml
# .github/workflows/notebook-ci.yml
name: Notebook CI

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  test-notebooks:
    uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@main
    with:
      python-version: "3.11"
      execution-mode: "full"
      build-html: true
      security-scan: true
    secrets:
      CASJOBS_USERID: ${{ secrets.CASJOBS_USERID }}
      CASJOBS_PW: ${{ secrets.CASJOBS_PW }}
```

### Documentation Deployment

```yaml
# .github/workflows/docs.yml
name: Deploy Documentation

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    uses: your-org/dev-actions/.github/workflows/ci_html_builder.yml@main
    with:
      python-version: "3.11"
      post-run-script: "scripts/jdaviz_image_replacement.sh"  # Optional post-processing
    secrets:
      github-token: ${{ secrets.GITHUB_TOKEN }}
```

### Notebook Deprecation

```yaml
# .github/workflows/deprecate.yml
name: Deprecate Notebook

on:
  workflow_dispatch:
    inputs:
      notebook_path:
        description: 'Path to notebook to deprecate'
        required: true
        type: string
      removal_date:
        description: 'Date for removal (YYYY-MM-DD)'
        required: true
        type: string

jobs:
  deprecate:
    uses: your-org/dev-actions/.github/workflows/ci_deprecation_manager.yml@main    with:
      notebook-path: ${{ inputs.notebook_path }}
      removal-date: ${{ inputs.removal_date }}
```

## 📁 Example Caller Workflows

This repository includes a collection of example workflows in the `examples/workflows/` directory that demonstrate how to use these reusable workflows in your own repositories. These examples cover common patterns and use cases:

### 🔗 Available Examples

- **`notebook-ci-pr.yml`** - Lightweight validation for pull requests
- **`notebook-ci-main.yml`** - Full CI pipeline for main branch deployments  
- **`notebook-ci-on-demand.yml`** - Manual testing with configurable options
- **`notebook-deprecation.yml`** - Notebook lifecycle management
- **`docs-only.yml`** - Documentation-only rebuilds

### 🚀 Quick Start

1. **Copy examples to your repository:**
   ```bash
   cp examples/workflows/*.yml your-repo/.github/workflows/
   ```

2. **Update workflow references:**
   ```yaml
   # Change from:
   uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@main
   # To your actual organization:
   uses: spacetelescope/dev-actions/.github/workflows/ci_pipeline.yml@main
   ```

3. **Configure repository secrets** (see [Prerequisites](#prerequisites))

For detailed setup instructions and customization options, see the [`examples/README.md`](examples/README.md) file.

## 🏷️ Versioning & Releases

This repository uses semantic versioning for stable, predictable releases of workflow updates.

### Version Format: `MAJOR.MINOR.PATCH`

- **MAJOR** - Breaking changes requiring caller workflow updates
- **MINOR** - New backwards-compatible features  
- **PATCH** - Backwards-compatible bug fixes

### Using Versions in Your Workflows

```yaml
# Recommended: Pin to major version (gets bug fixes automatically)
uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v1

# Conservative: Pin to exact version (most stable)
uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@v1.2.3

# Development: Use main branch (not recommended for production)
uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@main
```

### Release Process

1. **PR Labels**: Add version labels to PRs (`version:major`, `version:minor`, `version:patch`)
2. **Automated Release**: Merging PR triggers automatic version bump and release
3. **Tag Management**: Major version tags (v1, v2) are automatically updated

### Documentation

- **📚 [Semantic Versioning Guide](docs/semantic-versioning.md)** - Comprehensive versioning documentation
- **🚀 [Migration Guide](docs/migration-guide.md)** - How to update caller workflows for new versions
- **📋 [Repository Migration Checklist](docs/repository-migration-checklist.md)** - Complete checklist for migrating STScI notebook repositories

## 📋 Prerequisites

### Repository Structure

These workflows expect the following repository structure:

```
your-repo/
├── notebooks/           # Jupyter notebooks directory
├── _config.yml         # JupyterBook configuration (for HTML builder)
├── _toc.yml           # Table of contents (for HTML builder)
└── .github/
    └── workflows/
        └── your-workflow.yml
```

### Required Dependencies

The workflows automatically install the following dependencies:

- **Python**: Specified version (default: 3.11)
- **uv**: Fast Python package manager
- **jupyter**: Jupyter notebook environment
- **nbval**: Notebook validation plugin for pytest
- **nbconvert**: Notebook conversion tools
- **bandit**: Security linter for Python
- **jupyter-book**: Documentation building tool
- **micromamba**: Conda-compatible package manager (for specific repositories)

### GitHub Repository Settings

For the HTML builder workflow to work properly:

1. **GitHub Pages**: Enable GitHub Pages in repository settings
2. **Actions Permissions**: Ensure GitHub Actions can write to the repository
3. **Secrets**: Configure required secrets (like `GITHUB_TOKEN`)

## 🤝 Contributing

### Adding New Workflows

1. Create new workflow files in `.github/workflows/`
2. Follow the established patterns for reusable workflows
3. Document inputs, outputs, and secrets clearly
4. Add comprehensive examples to this README

### Workflow Best Practices

- ✅ Use `workflow_call` for reusable workflows
- ✅ Provide sensible defaults for optional inputs
- ✅ Include proper error handling and artifact uploads
- ✅ Use consistent shell configuration: `bash -leo pipefail {0}`
- ✅ Enable caching where appropriate
- ✅ Document all parameters and their purposes

### Testing Workflows

Before submitting changes:

1. Test workflows in a fork or test repository
2. Verify all input parameters work as expected
3. Ensure error conditions are handled gracefully
4. Test with different Python versions and notebook structures

---

## 📊 Workflow Status

| Workflow | Purpose | Status | Last Updated |
|----------|---------|--------|--------------|
| CI Pipeline | Notebook validation & execution | ✅ Active | Latest |
| HTML Builder | Documentation deployment | ✅ Active | Latest |
| Deprecation Manager | Notebook lifecycle management | ✅ Active | Latest |

---

## 📝 Notes

- All workflows use Ubuntu 24.04 runners
- Python environments are managed with `uv` for speed and reliability
- Special support for `hstcal` environment in HST notebook repositories
- Security scanning is performed on converted Python scripts from notebooks
- Failed notebook artifacts are automatically uploaded for debugging

For questions or issues, please create an issue in this repository or refer to the individual workflow files for detailed implementation.
