# Package Manager Strategy: uv + micromamba

## 🎯 Overview

The centralized workflows implement a **dual package manager strategy** that optimizes for both performance and compatibility across all STScI notebook repositories.

## 🚀 Package Manager Selection

### Primary: uv (Ultra-fast Python Package Manager)
- **Purpose**: Fast Python package installation and virtual environment management
- **Benefits**: 
  - 10-100x faster than pip
  - Built in Rust for performance and reliability
  - Excellent dependency resolution
  - Full pip compatibility
- **Used for**: All repositories by default

### Secondary: micromamba (Conda-Compatible Package Manager)
- **Purpose**: Conda environment management for repositories requiring conda-specific packages
- **Benefits**:
  - Faster than conda/mamba
  - Smaller footprint and faster downloads
  - Full conda compatibility
  - Excellent for scientific packages
- **Used for**: Repositories with conda-specific requirements (primarily `hst_notebooks`)

## 🏗️ Repository-Specific Implementation

### Automatic Environment Detection

The workflows automatically detect repository requirements and configure the appropriate package managers:

| Repository | Primary Manager | Secondary Manager | Special Packages |
|------------|----------------|-------------------|------------------|
| `jdat_notebooks` | **uv** | - | astropy, CRDS tools |
| `mast_notebooks` | **uv** | - | astroquery, MAST APIs |
| `hst_notebooks` | **micromamba** | uv (validation tools) | hstcal, STScI stack |
| `hello_universe` | **uv** | - | basic packages only |
| `jwst_notebooks` | **uv** | - | JWST pipeline, jdaviz |

### Environment Setup Logic

```yaml
# 1. Always set up uv for fast Python package management
- name: Set up uv
  uses: astral-sh/setup-uv@v6.0.1

# 2. Set up micromamba when conda packages are needed
- name: Set up micromamba for HST environment
  if: ${{ github.repository == 'spacetelescope/hst_notebooks' }}
  uses: mamba-org/setup-micromamba@v2.0.4
  with:
    create-args: python=${{ inputs.python-version }} hstcal

# 3. Standard micromamba for other repositories (if needed)
- name: Set up micromamba for standard environment  
  if: ${{ github.repository != 'spacetelescope/hst_notebooks' }}
  uses: mamba-org/setup-micromamba@v2.0.4
```

## 📦 Package Installation Strategy

### Primary Package Installation (uv)
```bash
# Fast installation of validation and common tools
uv pip install jupyter nbval nbconvert bandit

# Repository-specific packages via uv when possible
uv pip install astropy photutils specutils  # jdat_notebooks
uv pip install astroquery                   # mast_notebooks  
uv pip install jwst jdaviz                  # jwst_notebooks
```

### Conda Package Installation (micromamba)
```bash
# HST-specific scientific software stack
micromamba install -c conda-forge hstcal stsci
```

## 🔧 Migration Considerations

### For Repository Maintainers

When migrating to the centralized workflows:

1. **Dependencies Review**: Determine if your repository needs conda-specific packages
2. **Environment Files**: Keep existing `environment.yml` for conda packages, `requirements.txt` for pip packages
3. **Testing**: The workflows will automatically use the appropriate package manager
4. **Performance**: Expect faster builds due to uv's speed for Python packages

### Special Cases

#### HST Notebooks
- **Automatic Detection**: The workflow detects `hst_notebooks` repository name
- **Conda Environment**: Automatically sets up micromamba with `hstcal`
- **Scientific Stack**: Full STScI software environment via conda-forge

#### Educational Repositories (hello_universe)
- **Lightweight Setup**: Uses uv for minimal package installation
- **Fast Builds**: Optimized for quick feedback in educational context
- **Simple Dependencies**: Avoids complex conda environments

## 📊 Performance Benefits

### Speed Improvements
- **uv package installation**: 10-100x faster than pip
- **micromamba environments**: 2-5x faster than conda
- **Parallel setup**: Both package managers can run in parallel when needed
- **Intelligent caching**: Both tools support advanced caching strategies

### Resource Optimization
- **Memory usage**: micromamba uses less memory than conda
- **Disk space**: uv creates smaller virtual environments
- **Network usage**: Both tools optimize download and caching

## 🧪 Testing and Validation

### Environment Validation
The validation script checks for appropriate dependency files:

```bash
# Detects conda requirements
if [ -f "environment.yml" ]; then
    log_info "Conda environment detected - micromamba will be used"
fi

# Detects Python package requirements  
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
    log_info "Python packages detected - uv will be primary manager"
fi
```

### Repository-Specific Testing
- **uv repositories**: Standard Python package installation and testing
- **micromamba repositories**: Conda environment creation and scientific package availability
- **Hybrid setups**: Both package managers working together

## 🚀 Future Enhancements

### Planned Improvements
1. **Dynamic Detection**: More sophisticated detection of conda vs pip requirements
2. **Caching Optimization**: Advanced caching strategies for both package managers
3. **Environment Sharing**: Reusable environments across similar repositories
4. **Performance Monitoring**: Tracking installation times and optimization opportunities

### Extension Possibilities
- **Custom environments**: Repository-specific environment definitions
- **Package pinning**: Automated dependency version management
- **Security scanning**: Enhanced security analysis for both package ecosystems

---

## 📋 Quick Reference

### For uv-based repositories (most repositories)
```yaml
# Fast Python package management
- uses: astral-sh/setup-uv@v6.0.1
- run: uv pip install <packages>
```

### For micromamba-based repositories (hst_notebooks)
```yaml
# Conda environment with scientific packages
- uses: mamba-org/setup-micromamba@v2.0.4
  with:
    create-args: python=3.11 hstcal
```

### For hybrid setups (if needed)
```yaml
# Both package managers available
- uses: astral-sh/setup-uv@v6.0.1      # For fast Python packages
- uses: mamba-org/setup-micromamba@v2.0.4  # For conda-specific packages
```

This strategy provides the best of both worlds: **speed** from uv for most operations and **compatibility** from micromamba for specialized scientific computing environments.
