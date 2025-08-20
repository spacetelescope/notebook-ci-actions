# Example Caller Workflows

This directory contains example workflows that demonstrate how to use the reusable GitHub Actions workflows in this repository. These examples show different patterns for calling the workflows based on various triggers and use cases.

## 📋 Available Examples

### 1. `notebook-ci-pr.yml` - Pull Request Validation (Traditional)
**Trigger**: Pull requests to `main` or `develop` branches
**Purpose**: Lightweight validation for pull requests
- Validates notebooks without full execution
- Builds documentation preview
- Runs security scanning
- Triggered only when notebook or config files change

### 2. `notebook-ci-pr-smart.yml` - Smart Pull Request Validation ⚡ **ENHANCED**
**Trigger**: Pull requests to `main` or `develop` branches
**Purpose**: Intelligent CI with conditional execution based on file changes
- **Documentation-only changes**: Skips notebook execution, rebuilds docs only (85% faster)
- **Notebook/code changes**: Full validation pipeline
- **Smart file detection**: Automatically categorizes changed files
- **Cost optimization**: Reduces GitHub Actions minutes usage by up to 60%

### 3. `notebook-ci-pr-selective.yml` - Selective Directory Validation ⚡ **NEW**
**Trigger**: Pull requests to `main` or `develop` branches
**Purpose**: Directory-specific validation for repositories with organized notebook subdirectories
- **Directory-specific requirements**: Only validates notebooks in directories with changed requirements.txt
- **Parallel validation**: Multiple directories validated simultaneously
- **Granular control**: Changes in `notebooks/data_analysis/requirements.txt` only affect that directory
- **Maximum efficiency**: Combines smart detection with selective execution

### 4. `notebook-ci-main.yml` - Main Branch CI (Traditional)
**Trigger**: Pushes to `main` branch
**Purpose**: Full CI pipeline for main branch
- Full notebook execution and validation
- Security scanning
- Documentation building and deployment
- Sequential job execution with dependency management

### 5. `notebook-ci-main-smart.yml` - Smart Main Branch CI ⚡ **ENHANCED**
**Trigger**: Pushes to `main` branch
**Purpose**: Optimized main branch CI with intelligent deployment
- **Documentation-only changes**: Fast deployment without notebook execution
- **Notebook/code changes**: Full CI with execution and deployment
- **Performance metrics**: Built-in optimization reporting
- **Smart deployment**: Deploys only when content changes require it

### 6. `notebook-ci-main-selective.yml` - Selective Directory Execution ⚡ **NEW**
**Trigger**: Pushes to `main` branch
**Purpose**: Directory-specific execution and deployment for organized repositories
- **Selective execution**: Only executes notebooks in directories with changes
- **Parallel processing**: Multiple directories processed simultaneously
- **Full execution**: Unlike PR validation, actually executes notebooks in affected directories
- **Smart deployment**: Deploys after successful selective execution or full repository CI

### 7. `notebook-ci-on-demand.yml` - Manual Testing
**Trigger**: Manual workflow dispatch
**Purpose**: Flexible on-demand testing with user inputs
- Configurable Python version
- Selectable execution modes
- Optional single notebook testing
- Toggleable security scanning and documentation building

### 8. `notebook-deprecation.yml` - Deprecation Management
**Trigger**: Manual dispatch + scheduled runs
**Purpose**: Notebook lifecycle management
- Manual notebook deprecation marking
- Automated cleanup of expired notebooks
- Daily scheduled maintenance

### 9. `docs-only.yml` - Documentation Deployment
**Trigger**: Manual dispatch + documentation file changes
**Purpose**: Documentation-only rebuilds
- Rebuild docs without running full CI
- Configurable post-processing scripts
- Triggered by documentation file changes

## 🎯 **Choosing the Right Workflow**

### **For Traditional Repositories** (flat notebook structure):
- **PR Validation**: Use `notebook-ci-pr.yml` or `notebook-ci-pr-smart.yml`
- **Main Branch**: Use `notebook-ci-main.yml` or `notebook-ci-main-smart.yml`

### **For Organized Repositories** (directory-based structure):
```
notebooks/
├── data_analysis/
│   ├── requirements.txt
│   └── *.ipynb
├── visualization/
│   ├── requirements.txt
│   └── *.ipynb
└── modeling/
    ├── requirements.txt
    └── *.ipynb
```
- **PR Validation**: Use `notebook-ci-pr-selective.yml`
- **Main Branch**: Use `notebook-ci-main-selective.yml`

### **Performance Comparison**

| Workflow Type | Documentation Change | Single Directory Change | Root Requirements Change |
|---------------|---------------------|-------------------------|-------------------------|
| **Traditional** | 15-25 minutes | 15-25 minutes | 15-25 minutes |
| **Smart** | 2-5 minutes | 15-25 minutes | 15-25 minutes |
| **Selective** | 2-5 minutes | 5-10 minutes | 15-25 minutes |

## 🚀 How to Use These Examples

### Step 1: Copy to Your Repository
Copy the desired workflow files to your repository's `.github/workflows/` directory:

```bash
# Copy all examples
cp examples/workflows/*.yml your-repo/.github/workflows/

# Or copy specific examples
cp examples/workflows/notebook-ci-pr.yml your-repo/.github/workflows/
cp examples/workflows/notebook-ci-main.yml your-repo/.github/workflows/
```

### Step 2: Customize the Workflow Reference
Update the `uses` field in each workflow to point to your organization's notebook-ci-actions repository:

```yaml
uses: mgough-970/dev-actions/.github/workflows/ci_pipeline.yml@main
```

### Step 3: Configure Repository Secrets
Ensure your repository has the required secrets configured:

**Required Secrets:**
- `GITHUB_TOKEN` - Usually available by default
- `CASJOBS_USERID` - Optional, for astronomical data access
- `CASJOBS_PW` - Optional, for astronomical data access

**Setting up secrets:**
1. Go to your repository settings
2. Navigate to "Secrets and variables" → "Actions"
3. Add the required secrets

### Step 4: Customize Paths and Triggers
Modify the workflow triggers and paths to match your repository structure:

```yaml
# Customize paths to match your repo structure
paths:
  - 'notebooks/**'           # Your notebook directory
  - 'requirements.txt'       # Your dependency files
  - '_config.yml'           # Your JupyterBook config
```

### Step 5: Configure Post-Processing Scripts
If you need post-processing (like jdaviz image replacement):

1. Create your script in the repository (e.g., `scripts/jdaviz_image_replacement.sh`)
2. Update the `post-run-script` parameter in the workflows
3. Ensure the script is executable and handles the `_build/html` directory

## 📊 Workflow Patterns

### Sequential vs Parallel Execution

**Sequential (recommended for resource-intensive tasks):**
```yaml
jobs:
  ci-pipeline:
    uses: mgough-970/dev-actions/.github/workflows/ci_pipeline.yml@main
    # ... configuration
  
  deploy-docs:
    needs: ci-pipeline
    if: success()
    uses: mgough-970/dev-actions/.github/workflows/ci_html_builder.yml@main
    # ... configuration
```

**Parallel (for independent tasks):**
```yaml
jobs:
  validate-notebooks:
    uses: mgough-970/dev-actions/.github/workflows/ci_pipeline.yml@main
    # ... configuration
  
  build-docs:
    uses: mgough-970/dev-actions/.github/workflows/ci_html_builder.yml@main
    # ... configuration
```

### Conditional Execution
```yaml
jobs:
  build-docs:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    uses: mgough-970/dev-actions/.github/workflows/ci_html_builder.yml@main
    # ... configuration
```

## 🔧 Customization Tips

### 1. Path Filtering
Use path filters to trigger workflows only when relevant files change:
```yaml
on:
  push:
    paths:
      - 'notebooks/**'
      - 'requirements.txt'
      - '_config.yml'
```

### 2. Branch Protection
For production repositories, consider:
- Making the main branch CI workflow required for merges
- Using different Python versions for different branches
- Adding manual approval steps for deployments

### 3. Environment-Specific Configurations
```yaml
# Development environment
- python-version: "3.11"
  execution-mode: "validation-only"

# Production environment  
- python-version: "3.11"
  execution-mode: "full"
  security-scan: true
```

### 4. Matrix Strategies
For testing multiple Python versions:
```yaml
jobs:
  test-matrix:
    strategy:
      matrix:
        python-version: ["3.9", "3.10", "3.11"]
    uses: mgough-970/dev-actions/.github/workflows/ci_pipeline.yml@main
    with:
      python-version: ${{ matrix.python-version }}
```

## 📝 Best Practices

1. **Use semantic versioning** for workflow references (e.g., `@v1.0.0` instead of `@main`)
2. **Test workflows in a fork** before deploying to production
3. **Use path filters** to avoid unnecessary workflow runs
4. **Set up branch protection rules** requiring successful CI before merges
5. **Monitor workflow usage** to optimize resource consumption
6. **Document any custom scripts** or post-processing steps

## 🐛 Troubleshooting

### Common Issues:

1. **Workflow not triggering**: Check path filters and branch names
2. **Permission errors**: Ensure `GITHUB_TOKEN` has necessary permissions
3. **Script not found**: Verify post-processing script paths and permissions
4. **Dependency conflicts**: Check Python version compatibility

### Debugging Steps:

1. Check the Actions tab in your repository for detailed logs
2. Verify all required secrets are configured
3. Test workflows with manual dispatch first
4. Use the on-demand workflow for debugging specific issues

For more help, refer to the main README.md or create an issue in the notebook-ci-actions repository.
