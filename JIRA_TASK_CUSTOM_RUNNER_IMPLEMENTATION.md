# JIRA Note: Implement Custom Runner Configuration for Unified Workflow

**Task:** Add custom runner configuration support to enable different notebooks to run on different GitHub runners based on computational requirements.

**Description:**
Implemented a new feature that allows repositories to specify custom GitHub runners for individual notebooks through a `ci_config.txt` configuration file. This enables optimal resource allocation where heavy computational notebooks can run on powerful runners while simple tutorials use standard runners.

**Implementation Details:**
- Added new `custom-runner-config` boolean input parameter to unified workflow
- Enhanced matrix generation to create include-style matrix with both notebook and runner information
- Updated process-notebooks job to use dynamic runner selection via `${{ matrix.runner }}`
- Implemented fallback logic to use default runners for unconfigured notebooks
- Maintained full backward compatibility - works exactly as before when feature is disabled

**Configuration Format:**
```
# ci_config.txt
notebook_path:runner_name
notebooks/heavy/processing.ipynb:ubuntu-latest-16-cores
notebooks/tutorial/intro.ipynb:ubuntu-latest
```

**Benefits:**
- Cost optimization by using expensive runners only when needed
- Performance improvement for computationally intensive notebooks
- Automatic fallback to default runners
- Zero changes required for existing workflows
- Supports any GitHub runner labels (standard, larger, or organization custom)

**Files Created/Modified:**
- `.github/workflows/notebook-ci-unified.yml` - Core implementation
- `examples/caller-workflows/jwst-validation-notebooks.yml` - Example usage
- `examples/ci_config.txt` - Sample configuration
- `docs/custom-runner-configuration.md` - Complete documentation
- `README-clean.md` - Updated with new feature documentation

**Results:**
The custom runner configuration feature is now available and fully documented. Repositories can enable it by adding `custom-runner-config: true` to their workflow and creating a `ci_config.txt` file. The feature provides intelligent resource allocation while maintaining complete backward compatibility.

---
Generated: 2025-08-07
