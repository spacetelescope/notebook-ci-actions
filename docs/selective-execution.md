# Selective Notebook Execution Guide

## :material-target: Overview

The selective execution feature enables directory-specific CI/CD for notebook repositories with organized subdirectory structures. When a `requirements.txt` file changes in a specific notebook directory, only notebooks in that directory are processed, dramatically reducing execution time and compute costs.

## :material-folder: Repository Structure Requirements

To use selective execution, organize your repository like this:

```
your-repo/
├── notebooks/
│   ├── data_analysis/
│   │   ├── requirements.txt      # Directory-specific dependencies
│   │   ├── analysis1.ipynb
│   │   ├── analysis2.ipynb
│   │   └── data_prep.py
│   ├── visualization/
│   │   ├── requirements.txt      # Different dependencies for viz
│   │   ├── plot_generator.ipynb
│   │   └── dashboard.ipynb
│   ├── modeling/
│   │   ├── requirements.txt      # ML-specific dependencies
│   │   ├── train_model.ipynb
│   │   └── evaluate.ipynb
│   └── shared_utils/
│       ├── utils.py              # Shared utilities
│       └── config.py
├── requirements.txt              # Root-level dependencies (affects all)
├── _config.yml                   # Jupyter Book configuration
├── _toc.yml                      # Table of contents
└── .github/
    └── workflows/
        ├── notebook-ci-pr-selective.yml
        └── notebook-ci-main-selective.yml
```

## :material-magnify: How Selective Detection Works

### File Change Analysis

The selective workflows analyze changed files and categorize them:

1. **Directory-specific requirements**: `notebooks/*/requirements.txt`
   - Only affects notebooks in that specific directory
   - Enables parallel processing of multiple directories

2. **Root requirements**: `requirements.txt`, `pyproject.toml`, `setup.py`
   - Affects all notebooks (safety first)
   - Triggers full repository CI

3. **Notebook files**: `notebooks/**/*.ipynb`
   - Only affects the directory containing the changed notebook

4. **Documentation files**: `*.md`, `_config.yml`, `_toc.yml`
   - Triggers documentation-only rebuild

### Execution Strategies

| Change Type | Strategy | Affected Scope | Performance |
|-------------|----------|----------------|-------------|
| `notebooks/data_analysis/requirements.txt` | `selective-directories` | Only `data_analysis/` | 5-10 minutes |
| `notebooks/viz/plot1.ipynb` | `selective-directories` | Only `viz/` | 3-8 minutes |
| `requirements.txt` (root) | `full-repository` | All notebooks | 15-25 minutes |
| `_config.yml` | `docs-only` | Documentation | 2-5 minutes |

## :material-rocket-launch: Benefits

### Performance Improvements

- **Targeted Execution**: Only process notebooks in affected directories
- **Parallel Processing**: Multiple directories can run simultaneously
- **Faster Feedback**: Developers get results for their specific changes quickly
- **Cost Optimization**: Significant reduction in GitHub Actions minutes

### Example Scenarios

#### Scenario 1: Update Data Analysis Dependencies
```bash
# Change made:
echo "pandas==2.1.0" >> notebooks/data_analysis/requirements.txt

# Result:
# - Only notebooks in data_analysis/ directory are executed
# - visualization/ and modeling/ directories are skipped
# - Execution time: ~5 minutes instead of 20 minutes
# - Cost savings: ~75%
```

#### Scenario 2: Fix Visualization Notebook
```bash
# Change made:
# Edit notebooks/visualization/dashboard.ipynb

# Result:
# - Only notebooks in visualization/ directory are validated/executed
# - Other directories remain untouched
# - Parallel execution if multiple directories affected
```

#### Scenario 3: Update Root Dependencies
```bash
# Change made:
echo "numpy==1.24.0" >> requirements.txt

# Result:
# - All notebooks are executed (safety first)
# - Full repository validation
# - Same behavior as traditional workflow
```

## :material-clipboard-text: Implementation Guide

### Step 1: Choose Selective Workflows

Replace your existing workflows with selective versions:

```bash
# Remove old workflows
rm .github/workflows/notebook-ci-pr.yml
rm .github/workflows/notebook-ci-main.yml

# Add selective workflows
cp examples/workflows/notebook-ci-pr-selective.yml .github/workflows/
cp examples/workflows/notebook-ci-main-selective.yml .github/workflows/
```

### Step 2: Organize Directory Structure

Ensure each notebook subdirectory has appropriate dependencies:

```bash
# Create directory-specific requirements
echo "pandas==2.1.0
matplotlib==3.7.0
seaborn==0.12.0" > notebooks/data_analysis/requirements.txt

echo "plotly==5.15.0
dash==2.11.0
bokeh==3.2.0" > notebooks/visualization/requirements.txt

echo "scikit-learn==1.3.0
xgboost==1.7.0
tensorflow==2.13.0" > notebooks/modeling/requirements.txt
```

### Step 3: Validate Structure

Use the validation script to check your setup:

```bash
# Run structure validation
bash scripts/validate-repository.sh your-repo-name

# Check for proper directory organization
find notebooks -name "requirements.txt" -type f
```

### Step 4: Test Selective Execution

Create test PRs to verify the selective behavior:

```bash
# Test 1: Directory-specific change
git checkout -b test-selective-data
echo "# Test change" >> notebooks/data_analysis/analysis1.ipynb
git add . && git commit -m "test: data analysis change"
git push origin test-selective-data
# Should only run data_analysis validation

# Test 2: Root requirements change
git checkout -b test-full-repo
echo "requests==2.31.0" >> requirements.txt
git add . && git commit -m "test: root requirements change"
git push origin test-full-repo
# Should run full repository validation
```

## :material-wrench: Advanced Configuration

### Custom Directory Patterns

Modify the workflow to support custom directory structures:

```yaml
# In detect-changes job, add custom patterns:
case "$file" in
  notebooks/experiments/*/requirements.txt)
    echo "  → Experiment-specific requirements changed: $file"
    dir=$(dirname "$file")
    AFFECTED_DIRECTORIES+=("$dir")
    ;;
```

### Dependency Inheritance

Create a hierarchy where subdirectories inherit from parent requirements:

```bash
# Root requirements (base dependencies)
echo "jupyter
nbval
pytest" > requirements.txt

# Directory adds specific dependencies
echo "-r ../../requirements.txt
pandas==2.1.0
matplotlib==3.7.0" > notebooks/data_analysis/requirements.txt
```

### Parallel Execution Limits

Control the number of parallel directory executions:

```yaml
strategy:
  matrix:
    directory: ${{ fromJson(needs.detect-changes.outputs.affected-directories) }}
  max-parallel: 3  # Limit concurrent jobs
  fail-fast: false  # Continue even if one directory fails
```

## :material-alert: Troubleshooting

### Common Issues

#### 1. Directory Not Detected
**Problem**: Changes in subdirectory don't trigger selective execution
**Solution**: Ensure the directory path matches the pattern `notebooks/*/`

#### 2. All Directories Running
**Problem**: Expected selective execution but all notebooks run
**Solution**: Check if root `requirements.txt` was modified (triggers full execution)

#### 3. Missing Dependencies
**Problem**: Directory-specific notebooks fail due to missing packages
**Solution**: Ensure each directory has complete `requirements.txt` or inherits from root

#### 4. Matrix Strategy Errors
**Problem**: Workflow fails with empty matrix
**Solution**: Check that `affected-directories` output contains valid directory paths

### Debug Mode

Enable detailed logging in workflows:

```yaml
- name: Debug selective execution
  run: |
    echo "Execution strategy: ${{ needs.detect-changes.outputs.execution-strategy }}"
    echo "Affected directories: ${{ needs.detect-changes.outputs.affected-directories }}"
    echo "Changed notebooks: ${{ needs.detect-changes.outputs.changed-notebooks }}"
```

## :material-chart-box: Performance Comparison

### Traditional vs Selective Execution

| Repository Size | Traditional Time | Selective Time | Savings |
|----------------|------------------|----------------|---------|
| Small (5 directories, 20 notebooks) | 15 minutes | 3-5 minutes | 67-80% |
| Medium (10 directories, 50 notebooks) | 25 minutes | 5-8 minutes | 68-80% |
| Large (20 directories, 100 notebooks) | 45 minutes | 8-12 minutes | 73-82% |

### Cost Analysis

Assuming GitHub Actions pricing of $0.008/minute:

| Change Type | Traditional Cost | Selective Cost | Monthly Savings* |
|-------------|------------------|----------------|------------------|
| Single directory change | $0.20 | $0.04 | $48/month |
| Documentation only | $0.20 | $0.024 | $52.8/month |
| Root requirements | $0.20 | $0.20 | $0/month |

*Based on 30 changes per month

## :material-road: Migration Path

### Phase 1: Assessment
1. Analyze current repository structure
2. Identify logical notebook groupings
3. Document existing dependencies

### Phase 2: Preparation
1. Organize notebooks into directories
2. Create directory-specific requirements files
3. Test local execution with new structure

### Phase 3: Implementation
1. Deploy selective workflows to staging
2. Test with various change scenarios
3. Monitor performance improvements

### Phase 4: Optimization
1. Fine-tune directory organization
2. Optimize parallel execution settings
3. Document best practices for team

## :material-note-text: Best Practices

1. **Logical Grouping**: Organize directories by functionality, not arbitrary splits
2. **Dependency Isolation**: Each directory should have self-contained requirements
3. **Shared Resources**: Use a common directory for shared utilities and configurations
4. **Testing Strategy**: Always test both selective and full execution paths
5. **Documentation**: Keep README files in each directory explaining the purpose and dependencies
6. **Monitoring**: Track performance improvements and adjust as needed

## :material-link-variant: Related Documentation

- [Unified Workflow Guide](https://github.com/spacetelescope/notebook-ci-actions/blob/main/README.md)
- [Migration Checklist](repository-migration-checklist.md)
- [Configuration Reference](configuration-reference.md)
- [Example Workflows](https://github.com/spacetelescope/notebook-ci-actions/blob/main/examples/README.md)

---

**Implementation Date**: July 2025  
**Status**: :material-check-circle: Ready for Production  
**Compatibility**: Repositories with organized directory structures
