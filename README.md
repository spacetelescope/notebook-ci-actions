# GitHub Actions Workflows

This repository contains a collection of reusable GitHub Actions workflows designed for managing Jupyter Notebook projects, specifically focused on validation, execution, building documentation, and deprecation management.

## 📋 Table of Contents

- [Overview](#overview)
- [Quick Start: Local Testing](#quick-start-local-testing) 🚀 **NEW**
- [Workflows](#workflows)
  - [CI Pipeline (`ci_pipeline.yml`)](#ci-pipeline-ci_pipelineyml)
  - [HTML Builder (`ci_html_builder.yml`)](#html-builder-ci_html_builderyml)
  - [Deprecation Manager (`ci_deprecation_manager.yml`)](#deprecation-manager-ci_deprecation_manageryml)
- [Scripts](#scripts)
- [Usage Examples](#usage-examples)
- [Local Testing](#local-testing) ⚡ **NEW**
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

## 🚀 Quick Start: Local Testing

**New to local testing?** Get started in 3 commands:

```bash
# 1. Validate workflows (30 seconds)
./scripts/validate-workflows.sh

# 2. Test notebooks locally (2-5 minutes)
./scripts/test-local-ci.sh

# 3. Full workflow simulation with Docker (optional)
./scripts/test-with-act.sh pull_request
```

**Benefits**: Save 70-80% on GitHub Actions costs, get immediate feedback, test offline

**📚 Detailed Guides**:
- **[Quick Start Guide](QUICK_START.md)** - 5-minute setup and essential commands
- **[Testing Decision Tree](TESTING_DECISION_TREE.md)** - Choose the right testing approach
- **[Complete Testing Guide](docs/local-testing-guide.md)** - Comprehensive documentation

**Repository-Specific Quick Setup**:
```bash
# JDAT Notebooks (JWST/CRDS)
export CRDS_SERVER_URL="https://jwst-crds.stsci.edu"
./scripts/test-local-ci.sh

# Educational repos (faster testing)
RUN_SECURITY_SCAN=false ./scripts/test-local-ci.sh

# HST Notebooks (validation only)
EXECUTION_MODE=validation-only ./scripts/test-local-ci.sh
```

## 🔧 Package Manager Strategy

These workflows use a **dual package manager approach** for optimal performance and compatibility:

### Primary: uv (Fast Python Package Manager)
- **Used for**: Python package installation and virtual environment management  
- **Benefits**: 10-100x faster than pip, built in Rust, reliable dependency resolution
- **Default for**: All repositories unless specific conda packages are required

### Secondary: micromamba (Conda-Compatible)
- **Used for**: Repositories requiring conda-specific packages or environments
- **Benefits**: Fast conda-compatible package manager, smaller footprint than conda/mamba  
- **Automatic detection**: Special handling for `hst_notebooks` (hstcal environment)

### Repository-Specific Package Management

| Repository | Primary Manager | Special Requirements | Environment Type |
|------------|----------------|---------------------|------------------|
| **jdat_notebooks** | uv | CRDS, astronomical tools | Python + uv |
| **mast_notebooks** | uv | astroquery, MAST tools | Python + uv |  
| **hst_notebooks** | micromamba | hstcal, STScI stack | Conda environment |
| **hello_universe** | uv | Basic packages only | Python + uv |
| **jwst-pipeline-notebooks** | uv | JWST pipeline, jdaviz | Python + uv |

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
- 🔧 Dual package manager support: `uv` (primary) and `micromamba` (for conda environments)

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

1. **Environment Setup**: Sets up Python environment with `uv` (primary) and `micromamba` (for conda environments)
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
    uses: spacetelescope/notebook-ci-actions/.github/workflows/ci_pipeline.yml@main
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
    uses: spacetelescope/notebook-ci-actions/.github/workflows/ci_html_builder.yml@main
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
    uses: spacetelescope/notebook-ci-actions/.github/workflows/ci_deprecation_manager.yml@main    with:
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
   ```yaml   # Change from:
   uses: spacetelescope/notebook-ci-actions/.github/workflows/ci_pipeline.yml@main
   # To your actual organization:
   uses: spacetelescope/notebook-ci-actions/.github/workflows/ci_pipeline.yml@main
   ```

3. **Configure repository secrets** (see [Prerequisites](#prerequisites))

For detailed setup instructions and customization options, see the [`examples/README.md`](examples/README.md) file.

## 🧪 Local Testing ⚡ **NEW**

Test GitHub Actions workflows locally before pushing changes to reduce CI costs and speed up development.

### Quick Start

```bash
# 1. Validate workflow syntax and structure
./scripts/validate-workflows.sh

# 2. Simulate CI pipeline locally
./scripts/test-local-ci.sh

# 3. Test workflows with Act (requires Docker)
./scripts/test-with-act.sh pull_request
```

### Available Testing Scripts

| Script | Purpose | Requirements |
|--------|---------|-------------|
| `validate-workflows.sh` | Validate YAML syntax and structure | Python 3 |
| `test-local-ci.sh` | Simulate CI pipeline execution | Python 3, uv |
| `test-with-act.sh` | Run workflows with Act | Docker, Act |

### Local CI Simulation

```bash
# Basic validation (fast)
EXECUTION_MODE=validation-only ./scripts/test-local-ci.sh

# Full execution test
EXECUTION_MODE=full ./scripts/test-local-ci.sh

# Test single notebook
SINGLE_NOTEBOOK=notebooks/example.ipynb ./scripts/test-local-ci.sh

# Repository-specific testing (e.g., for JDAT notebooks)
export CRDS_SERVER_URL="https://jwst-crds.stsci.edu"
export CRDS_PATH="/tmp/crds_cache"
./scripts/test-local-ci.sh

# When using the centralized notebook CI workflow from a caller repository,
# the same CRDS configuration can be passed via inputs:
#
# execute-all:
#   uses: spacetelescope/notebook-ci-actions/.github/workflows/notebook-ci-unified.yml@v1
#   with:
#     execution-mode: 'on-demand'
#     trigger-event: 'execute'
#     python-version: '3.11'
#     # Optional CRDS configuration (only for JWST-style pipelines)
#     crds-server-url: 'https://jwst-crds.stsci.edu'
#     crds-context: 'jwst_1234.pmap'
#     crds-path: '/tmp/crds_cache'

```

### Act-based Workflow Testing

```bash
# Test different event types
./scripts/test-with-act.sh pull_request
./scripts/test-with-act.sh push
./scripts/test-with-act.sh workflow_dispatch

# Test specific workflow file
./scripts/test-with-act.sh pull_request .github/workflows/notebook-ci-pr.yml

# Dry run validation
DRY_RUN=true ./scripts/test-with-act.sh pull_request
```

### Benefits

- **💰 Cost Reduction**: Avoid consuming GitHub Actions minutes during development
- **⚡ Faster Feedback**: Test changes immediately without waiting for GitHub runners
- **🐛 Better Debugging**: Access to local environment for detailed troubleshooting
- **🔒 Safe Testing**: Test with secrets and sensitive data locally

### Documentation

- **📚 [Complete Local Testing Guide](docs/local-testing-guide.md)** - Comprehensive testing methods and tools
- **🛠️ [Scripts Documentation](scripts/README.md)** - Detailed script usage and examples

## 🏷️ Versioning & Releases

This repository uses semantic versioning for stable, predictable releases of workflow updates.

### Version Format: `MAJOR.MINOR.PATCH`

- **MAJOR** - Breaking changes requiring caller workflow updates
- **MINOR** - New backwards-compatible features  
- **PATCH** - Backwards-compatible bug fixes

### Using Versions in Your Workflows

```yaml
# Recommended: Pin to major version (gets bug fixes automatically)
uses: spacetelescope/notebook-ci-actions/.github/workflows/ci_pipeline.yml@v1

# Conservative: Pin to exact version (most stable)
uses: spacetelescope/notebook-ci-actions/.github/workflows/ci_pipeline.yml@v1.2.3

# Development: Use main branch (not recommended for production)
uses: spacetelescope/notebook-ci-actions/.github/workflows/ci_pipeline.yml@main
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
- **uv**: Fast Python package manager (primary package manager)
- **micromamba**: Conda-compatible package manager (for repositories requiring conda environments)
- **jupyter**: Jupyter notebook environment
- **nbval**: Notebook validation plugin for pytest
- **nbconvert**: Notebook conversion tools
- **bandit**: Security linter for Python
- **jupyter-book**: Documentation building tool

### GitHub Repository Settings

For the HTML builder workflow to work properly:

1. **GitHub Pages**: Enable GitHub Pages in repository settings
2. **Actions Permissions**: Ensure GitHub Actions can write to the repository
3. **Secrets**: Configure required secrets (like `GITHUB_TOKEN`)

## 🔧 Package Manager Strategy

### Dual Package Manager Approach

These workflows use a **dual package manager strategy** to provide optimal performance and compatibility:

#### Primary: UV (Fast Python Package Manager)
- **Used for**: Python package installation and virtual environment management
- **Benefits**: 10-100x faster than pip, built in Rust, reliable dependency resolution
- **Default for**: All repositories unless specific conda packages are required

#### Secondary: Micromamba (Conda-Compatible)
- **Used for**: Repositories requiring conda-specific packages or environments
- **Benefits**: Fast conda-compatible package manager, smaller footprint than conda/mamba
- **Automatic detection**: Special handling for `hst_notebooks` (hstcal environment)

### Repository-Specific Package Management

| Repository | Primary Manager | Special Packages | Environment |
|------------|----------------|------------------|-------------|
| **jdat_notebooks** | uv | CRDS, astronomical tools | Python + uv |
| **mast_notebooks** | uv | astroquery, MAST tools | Python + uv |  
| **hst_notebooks** | micromamba | hstcal, STScI stack | Conda + micromamba |
| **hello_universe** | uv | Basic packages only | Python + uv |
| **jwst-pipeline-notebooks** | uv | JWST pipeline, jdaviz | Python + uv |

### Environment Setup Process

1. **UV Setup**: Always configured for fast Python package management
2. **Micromamba Setup**: Configured when conda packages are needed
3. **Repository Detection**: Automatic detection of repository-specific needs
4. **Package Installation**: Uses appropriate manager based on requirements

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

1. **Local Testing** (Recommended):
   ```bash
   # Validate workflow syntax
   ./scripts/validate-workflows.sh
   
   # Test CI pipeline locally
   ./scripts/test-local-ci.sh
   
   # Test with Act (Docker-based GitHub Actions runner)
   ./scripts/test-with-act.sh pull_request
   ```

2. **GitHub Testing**:
   - Test workflows in a fork or test repository
   - Use manual workflow dispatch for controlled testing
   - Create test PRs to verify automatic triggers

3. **Verification Checklist**:
   - ✅ Verify all input parameters work as expected
   - ✅ Ensure error conditions are handled gracefully
   - ✅ Test with different Python versions and notebook structures
   - ✅ Validate with repository-specific configurations

For detailed local testing instructions, see [`docs/local-testing-guide.md`](docs/local-testing-guide.md).

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
