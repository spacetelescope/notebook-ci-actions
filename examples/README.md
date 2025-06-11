# Example Caller Workflows

This directory contains example workflows that demonstrate how to use the reusable GitHub Actions workflows in this repository. These examples show different patterns for calling the workflows based on various triggers and use cases.

## 📋 Available Examples

### 1. `notebook-ci-pr.yml` - Pull Request Validation
**Trigger**: Pull requests to `main` or `develop` branches
**Purpose**: Lightweight validation for pull requests
- Validates notebooks without full execution
- Builds documentation preview
- Runs security scanning
- Triggered only when notebook or config files change

### 2. `notebook-ci-main.yml` - Main Branch CI
**Trigger**: Pushes to `main` branch
**Purpose**: Full CI pipeline for main branch
- Full notebook execution and validation
- Security scanning
- Documentation building and deployment
- Sequential job execution with dependency management

### 3. `notebook-ci-on-demand.yml` - Manual Testing
**Trigger**: Manual workflow dispatch
**Purpose**: Flexible on-demand testing with user inputs
- Configurable Python version
- Selectable execution modes
- Optional single notebook testing
- Toggleable security scanning and documentation building

### 4. `notebook-deprecation.yml` - Deprecation Management
**Trigger**: Manual dispatch + scheduled runs
**Purpose**: Notebook lifecycle management
- Manual notebook deprecation marking
- Automated cleanup of expired notebooks
- Daily scheduled maintenance

### 5. `docs-only.yml` - Documentation Deployment
**Trigger**: Manual dispatch + documentation file changes
**Purpose**: Documentation-only rebuilds
- Rebuild docs without running full CI
- Configurable post-processing scripts
- Triggered by documentation file changes

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
Update the `uses` field in each workflow to point to your organization's dev-actions repository:

```yaml
# Change this:
uses: your-org/dev-actions/.github/workflows/ci_pipeline.yml@main

# To this (example):
uses: spacetelescope/dev-actions/.github/workflows/ci_pipeline.yml@main
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
    uses: org/dev-actions/.github/workflows/ci_pipeline.yml@main
    # ... configuration
  
  deploy-docs:
    needs: ci-pipeline
    if: success()
    uses: org/dev-actions/.github/workflows/ci_html_builder.yml@main
    # ... configuration
```

**Parallel (for independent tasks):**
```yaml
jobs:
  validate-notebooks:
    uses: org/dev-actions/.github/workflows/ci_pipeline.yml@main
    # ... configuration
  
  build-docs:
    uses: org/dev-actions/.github/workflows/ci_html_builder.yml@main
    # ... configuration
```

### Conditional Execution
```yaml
jobs:
  build-docs:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    uses: org/dev-actions/.github/workflows/ci_html_builder.yml@main
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
    uses: org/dev-actions/.github/workflows/ci_pipeline.yml@main
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

For more help, refer to the main README.md or create an issue in the dev-actions repository.
