# Repository Name Update: jwst_notebooks → jwst-pipeline-notebooks

## 🎯 Update Summary

Successfully updated all references from `jwst_notebooks` to `jwst-pipeline-notebooks` throughout the entire codebase.

## 📝 Files Updated

### Documentation Files
1. **`README.md`** - Updated package manager strategy tables (2 instances)
2. **`docs/repository-migration-checklist.md`** - Updated all migration documentation
3. **`IMPLEMENTATION_SUMMARY.md`** - Updated technical architecture descriptions
4. **`DEPLOYMENT_CHECKLIST.md`** - Updated deployment plans and rollout schedule
5. **`PACKAGE_MANAGER_STRATEGY.md`** - Updated package manager strategy tables
6. **`scripts/README.md`** - Updated script documentation and examples

### Script Files
1. **`scripts/migrate-repository.sh`** - Updated repository configuration and case handling
2. **`scripts/validate-repository.sh`** - Updated repository-specific validation logic

## 🔧 Specific Changes Made

### Repository Lists
Updated all instances where the 5 STScI repositories are listed:
```diff
- `jwst_notebooks`
+ `jwst-pipeline-notebooks`
```

### Configuration Tables
Updated package manager strategy tables:
```diff
- | **jwst_notebooks** | uv | JWST pipeline, jdaviz | Python + uv |
+ | **jwst-pipeline-notebooks** | uv | JWST pipeline, jdaviz | Python + uv |
```

### Migration Documentation
Updated repository-specific migration sections:
```diff
- ### jwst_notebooks Migration
+ ### jwst-pipeline-notebooks Migration

- **Repository URL**: `https://github.com/spacetelescope/jwst_notebooks`
+ **Repository URL**: `https://github.com/spacetelescope/jwst-pipeline-notebooks`
```

### Script Configuration
Updated automation scripts to handle the new repository name:
```diff
- REPO_CONFIGS[jwst_notebooks]="..."
+ REPO_CONFIGS[jwst-pipeline-notebooks]="..."

- "jwst_notebooks")
+ "jwst-pipeline-notebooks")
```

### Batch Operations
Updated batch operation examples:
```diff
- REPOS=("hello_universe" "mast_notebooks" "jdat_notebooks" "hst_notebooks" "jwst_notebooks")
+ REPOS=("hello_universe" "mast_notebooks" "jdat_notebooks" "hst_notebooks" "jwst-pipeline-notebooks")
```

## ✅ Verification

- **Total instances found**: 23 across 8 files
- **Total instances updated**: 23 (100% completion)
- **Files affected**: 8 documentation and script files
- **No remaining references**: Confirmed via comprehensive search

## 🚀 Impact

### Repository-Specific Features Maintained
- **Package Manager**: Still uses `uv` as primary package manager
- **Special Features**: jdaviz image replacement and JWST pipeline support unchanged
- **Workflows**: Full CI with post-processing scripts maintained
- **Post-processing**: Automatic jdaviz widget replacement in HTML preserved

### Migration Process
- **Automated scripts**: Updated to recognize `jwst-pipeline-notebooks`
- **Configuration**: Repository-specific settings preserved
- **Validation**: Validation logic updated for new repository name
- **Documentation**: All migration guides reflect the new name

### No Breaking Changes
- **Workflow logic**: No changes to actual GitHub Actions workflows
- **Package management**: No changes to uv/micromamba strategy
- **Repository detection**: Updated to match new repository name
- **Functionality**: All features and capabilities preserved

## 🎯 Repository Status

| Repository | Status | Notes |
|------------|--------|-------|
| **jdat_notebooks** | ✅ Ready | No changes needed |
| **mast_notebooks** | ✅ Ready | No changes needed |
| **hst_notebooks** | ✅ Ready | No changes needed |
| **hello_universe** | ✅ Ready | No changes needed |
| **jwst-pipeline-notebooks** | ✅ Ready | **Updated from jwst_notebooks** |

## 📋 Next Steps

1. **Repository Creation**: Ensure `spacetelescope/jwst-pipeline-notebooks` repository exists
2. **Migration Testing**: Test automated scripts with new repository name
3. **Documentation Review**: Verify all documentation reflects the new name correctly
4. **Workflow Deployment**: Deploy updated workflows to production

---

**Update Completed**: June 11, 2025  
**Files Modified**: 8  
**Total Changes**: 23 instances  
**Status**: ✅ Complete
