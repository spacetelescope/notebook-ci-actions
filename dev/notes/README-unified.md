# Unified Notebook CI/CD Actions

A comprehensive, configurable GitHub Actions workflow system for notebook-based repositories, providing automated validation, testing, execution, and documentation generation.

## 🚀 Quick Start

### 1. Repository Setup

Choose your setup method:

#### Option A: Use Migration Script (Recommended)

```bash
# Clone the notebook-ci-actions repository
git clone https://github.com/mgough-970/dev-actions.git

# Run the automated migration script
cd your-repository
../notebook-ci-actions/scripts/migrate-to-unified.sh
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

### 2. Configuration Reference

Configure the workflow for your repository type:

#### Standard Python Repository (e.g., jdat_notebooks, mast_notebooks)

```yaml
uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
with:
  execution-mode: 'pr'                    # or 'merge', 'scheduled', 'on-demand'
  python-version: '3.11'                  # Your Python version
  enable-validation: true                 # pytest nbval validation
  enable-security: true                   # bandit security scanning
  enable-execution: true                  # notebook execution
  enable-storage: true                    # store outputs to gh-storage
  enable-html-build: false                # build HTML documentation
```

#### Conda-based Repository (e.g., hst_notebooks)

```yaml
uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
with:
  execution-mode: 'pr'
  python-version: '3.11'
  conda-environment: 'hstcal'             # Auto-detected for hst_notebooks
  enable-validation: true
  enable-security: true
  enable-execution: true
  enable-storage: true
  enable-html-build: false
```

#### Educational Repository (e.g., hello_universe)

```yaml
uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
with:
  execution-mode: 'pr'
  python-version: '3.11'
  enable-validation: true
  enable-security: false                  # Lighter for educational content
  enable-execution: true
  enable-storage: true
  enable-html-build: true                 # Build documentation
```

### 3. Repository Secrets

Configure these secrets in your repository settings:

- `CASJOBS_USERID` (optional): For CasJobs database access
- `CASJOBS_PW` (optional): CasJobs password
- `GITHUB_TOKEN` (automatic): Used for gh-storage and repository access

## 📋 Features

### Core Capabilities

- **🔍 Smart Change Detection**: Automatically detects docs-only changes, affected directories, and requirements updates
- **📓 Notebook Validation**: Uses pytest nbval for notebook validation
- **🛡️ Security Scanning**: Integrates bandit for security vulnerability detection
- **▶️ Execution Testing**: In-place notebook execution with output capture
- **💾 Output Storage**: Stores executed notebooks to `gh-storage` branch
- **📖 Documentation Generation**: JupyterBook HTML generation with custom post-processing
- **🗂️ Deprecation Management**: Automated notebook deprecation workflow with expiration handling

### Execution Modes

| Mode | Purpose | Triggers | Features |
|------|---------|----------|----------|
| **PR** | Pull request validation | `pull_request` | Selective execution, validation, security scanning |
| **Merge** | Post-merge deployment | `push` to main | Full execution, HTML build, documentation deployment |
| **Scheduled** | Weekly maintenance | `cron` schedule | Full validation, deprecation management |
| **On-Demand** | Manual execution | `workflow_dispatch` | Flexible options, single/all notebook support |

## 🛠️ Configuration

### Environment Setup

#### Standard Python Environment

```yaml
python-version: '3.11'
custom-requirements: 'requirements.txt'
```

#### Conda Environments

```yaml
conda-environment: 'hstcal'    # For HST workflows
# or
conda-environment: 'stenv'     # For JWST workflows
```

#### Custom Requirements

```yaml
custom-requirements: 'path/to/custom-requirements.txt'
```

### Feature Toggles

Enable/disable features based on your needs:

```yaml
enable-validation: true        # pytest nbval validation
enable-security: true          # bandit security scanning  
enable-execution: true         # notebook execution
enable-storage: true           # store to gh-storage branch
enable-html-build: true        # JupyterBook HTML generation
```

### Advanced Configuration

```yaml
# Single notebook targeting
single-notebook: 'notebooks/example/demo.ipynb'

# Custom post-processing
post-processing-script: 'scripts/custom_processing.sh'

# Deprecation settings
deprecation-days: 60           # Days until notebook expires
```

## 📊 Workflow Examples

### Pull Request Workflow

```yaml
name: Notebook CI - Pull Request
on:
  pull_request:
    branches: [ main ]
    paths: ['notebooks/**', 'requirements.txt', '*.yml', '*.md']

jobs:
  notebook-ci:
    uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      execution-mode: 'pr'
      python-version: '3.11'
      enable-validation: true
      enable-security: true
      enable-execution: true
      enable-storage: true
      enable-html-build: false
    secrets:
      CASJOBS_USERID: ${{ secrets.CASJOBS_USERID }}
      CASJOBS_PW: ${{ secrets.CASJOBS_PW }}
```

### Merge/Deploy Workflow

```yaml
name: Notebook CI - Deploy
on:
  push:
    branches: [ main ]
    paths: ['notebooks/**', 'requirements.txt', '*.yml', '*.md']

jobs:
  deploy:
    uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      execution-mode: 'merge'
      python-version: '3.11'
      conda-environment: 'hstcal'
      enable-validation: true
      enable-security: true
      enable-execution: true
      enable-storage: true
      enable-html-build: true
      post-processing-script: 'scripts/jdaviz_image_replacement.sh'
    secrets:
      CASJOBS_USERID: ${{ secrets.CASJOBS_USERID }}
      CASJOBS_PW: ${{ secrets.CASJOBS_PW }}
```

### On-Demand Workflow

```yaml
name: Notebook CI - On-Demand
on:
  workflow_dispatch:
    inputs:
      action_type:
        type: choice
        options: ['validate-all', 'execute-single', 'build-html-only']
      single_notebook:
        type: string

jobs:
  on-demand:
    uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      execution-mode: 'on-demand'
      trigger-event: ${{ inputs.action_type }}
      single-notebook: ${{ inputs.single_notebook }}
      python-version: '3.11'
```

## 🔄 Smart Execution Logic

### Change Detection

The system automatically detects:

- **Notebook Changes**: Triggers validation and execution for affected directories
- **Requirements Changes**: Full repository processing when dependencies change
- **Documentation Changes**: Docs-only mode skips notebook execution
- **Configuration Changes**: Triggers appropriate processing based on file type

### Selective Execution

- **PR Mode**: Only processes changed notebooks and affected directories
- **Directory-Specific**: Installs and runs requirements per directory
- **Dependency Tracking**: Detects when requirements.txt changes affect notebook execution
- **Performance Optimization**: Skips unnecessary steps for docs-only changes

### Output Management

- **gh-storage Branch**: Stores executed notebooks with outputs
- **Deprecation Respect**: Prevents overwriting deprecated notebook outputs
- **Version Control**: Maintains history of executed notebook states
- **Conflict Resolution**: Handles concurrent updates with retry logic

## 📚 Deprecation Management

### Automatic Deprecation Workflow

1. **Tagging**: Use on-demand action to tag notebooks for deprecation
2. **Banner Addition**: Automatically adds deprecation notice to notebook
3. **Expiration Tracking**: Monitors deprecation dates
4. **Branch Migration**: Moves expired notebooks to `deprecated` branch
5. **Cleanup**: Removes expired notebooks from main branch

### Manual Deprecation

```yaml
# On-demand workflow
jobs:
  deprecate:
    uses: mgough-970/dev-actions/.github/workflows/notebook-ci-unified.yml@dev-actions-v2
    with:
      execution-mode: 'on-demand'
      trigger-event: 'deprecate'
      single-notebook: 'path/to/notebook.ipynb'
      deprecation-days: 60
```

## 🚀 Performance Features

### Optimization Strategies

- **Docs-Only Detection**: Skips notebook execution for documentation changes
- **Selective Directory Processing**: Only processes affected directories
- **Conditional Execution**: Configurable feature enablement
- **Caching**: Leverages GitHub Actions caching for dependencies
- **Parallel Processing**: Matrix-based execution for multiple notebooks

### Resource Management

- **Memory Optimization**: Efficient notebook execution with cleanup
- **Time Limits**: Configurable timeout settings
- **Error Handling**: Graceful failure handling with detailed reporting
- **Retry Logic**: Automatic retry for transient failures

## 🔧 Customization

### Post-Processing Scripts

Add custom processing after notebook execution:

```bash
#!/bin/bash
# scripts/custom_processing.sh

echo "Running custom post-processing..."

# Example: Image optimization
find _build -name "*.png" -exec optipng {} \;

# Example: Custom file manipulation
python scripts/process_outputs.py

echo "Post-processing complete"
```

### Environment-Specific Configuration

#### HST Notebooks

```yaml
conda-environment: 'hstcal'
post-processing-script: 'scripts/hst_processing.sh'
```

#### JWST Notebooks

```yaml
conda-environment: 'stenv'  
post-processing-script: 'scripts/jwst_processing.sh'
```

#### Custom Scientific Environments

```yaml
custom-requirements: 'environments/science-requirements.txt'
post-processing-script: 'scripts/science_processing.sh'
```

## 📈 Monitoring and Reporting

### Workflow Summaries

Each workflow run generates detailed summaries including:

- Configuration used
- Performance metrics
- Execution strategy
- Results and status
- Optimization insights

### Error Reporting

- Detailed error logs for debugging
- Performance metrics and optimization suggestions
- Resource usage reporting
- Failure analysis and recommendations

## 🤝 Contributing

### Repository Structure

```text
notebook-ci-actions/
├── .github/workflows/
│   └── notebook-ci-unified.yml          # Main reusable workflow
├── examples/
│   └── caller-workflows/                 # Example caller workflows
│       ├── notebook-pr.yml
│       ├── notebook-merge.yml
│       ├── notebook-scheduled.yml
│       ├── notebook-on-demand.yml
│       └── README.md
├── docs/                                 # Documentation
├── scripts/                              # Utility scripts
└── README.md                             # This file
```

### Development Workflow

1. Fork the repository
2. Create a feature branch
3. Test changes with example workflows
4. Update documentation
5. Submit pull request

## 📞 Support

### Documentation

- [Caller Workflows Guide](examples/caller-workflows/README.md)
- [Configuration Reference](docs/configuration-reference.md)
- [Migration Guide](docs/migration-guide-unified.md)
- [Troubleshooting Guide](docs/troubleshooting.md)

### Quick Start Scripts

- [Migration Script](scripts/migrate-to-unified.sh) - Automated migration from existing workflows
- [Test Script](scripts/test-unified-system.sh) - Validate setup and configuration

### Getting Help

1. **Check Documentation**: Review the comprehensive guides above
2. **Run Diagnostics**: Use the test script to validate your setup
3. **Review Logs**: Check GitHub Actions workflow logs for detailed errors
4. **Search Issues**: Look for similar problems in existing issues
5. **Open New Issue**: Provide configuration details, logs, and error messages

### Common Issues

| Issue | Quick Fix | Documentation |
|-------|-----------|---------------|
| **Workflow not triggering** | Check paths and branch names | [Troubleshooting](docs/troubleshooting.md#workflow-not-triggering) |
| **Environment setup failure** | Verify conda environment name | [Troubleshooting](docs/troubleshooting.md#environment-setup-failures) |
| **Notebook execution timeout** | Optimize notebooks or increase timeout | [Troubleshooting](docs/troubleshooting.md#notebook-execution-failures) |
| **Permission errors** | Check GitHub token permissions | [Troubleshooting](docs/troubleshooting.md#secrets-and-authentication) |
| **Migration issues** | Use migration script and guide | [Migration Guide](docs/migration-guide-unified.md) |

## 📄 License

This project is licensed under the BSD 3-Clause License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Built for the Space Telescope Science Institute notebook ecosystem
- Designed for astronomical data analysis workflows
- Optimized for GitHub Actions performance and cost efficiency
