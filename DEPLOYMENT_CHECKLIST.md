# Deployment Checklist

## 🚀 Pre-Deployment Setup

### Step 1: Create Production Repository
- [ ] Create `mgough-970/dev-actions` repository
- [ ] Set up repository description: "Centralized GitHub Actions workflows for STScI notebook repositories"
- [ ] Configure repository visibility (recommend: Public)
- [ ] Add appropriate topics: `github-actions`, `jupyter-notebooks`, `stsci`, `workflows`

### Step 2: Copy Development Content
```bash
# Clone this development repository
git clone https://github.com/your-username/dev-actions.git

# Create and setup production repository
cd dev-actions
git remote add origin https://github.com/mgough-970/dev-actions.git

# Copy all files (excluding .git)
cp -r ../dev-actions/* .
cp -r ../dev-actions/.github .

# Initial commit
git add .
git commit -m "Initial release: Centralized workflows for notebook repositories

Features:
- 3 core reusable workflows (CI pipeline, HTML builder, deprecation manager)
- 5 example caller workflows for different use cases
- Complete semantic versioning system with automated releases
- Repository-specific migration tools and validation
- Comprehensive documentation and migration guides

Supports: jdat_notebooks, mast_notebooks, hst_notebooks, hello_universe, jwst-pipeline-notebooks"

git push origin main
```

### Step 3: Create Initial Release
```bash
# Create and push initial version tags
git tag -a v1.0.0 -m "Initial release

Core workflows:
- ci_pipeline.yml: Comprehensive notebook validation and execution
- ci_html_builder.yml: JupyterBook documentation building with post-processing
- ci_deprecation_manager.yml: Notebook lifecycle management

Example workflows:
- notebook-ci-pr.yml: Pull request validation
- notebook-ci-main.yml: Main branch full CI/CD
- notebook-ci-on-demand.yml: Manual testing
- notebook-deprecation.yml: Lifecycle management
- docs-only.yml: Documentation-only builds

Migration tools:
- validate-repository.sh: Pre-migration validation
- migrate-repository.sh: Automated migration

Documentation:
- Complete setup and usage guides
- Semantic versioning strategy
- Repository-specific migration checklists"

git tag -a v1 -m "Major version 1 pointer"
git push origin v1.0.0 v1
```

### Step 4: Configure Repository Settings
- [ ] **GitHub Pages**: Enable if planning to host documentation
- [ ] **Actions**: Ensure GitHub Actions is enabled
- [ ] **Security**: 
  - [ ] Enable security advisories
  - [ ] Configure dependabot (if desired)
  - [ ] Set branch protection rules for main branch
- [ ] **Secrets**: No secrets needed for core workflows

## 🧪 Testing Phase

### Phase 1: Single Repository Test (hello_universe)
```bash
# Clone hello_universe repository
git clone https://github.com/spacetelescope/hello_universe.git
cd hello_universe

# Run validation
../dev-actions/scripts/validate-repository.sh hello_universe spacetelescope

# Run migration
../dev-actions/scripts/migrate-repository.sh hello_universe spacetelescope

# Test workflows
git push origin migrate-to-centralized-actions
# Create PR and test all workflows
```

### Phase 2: Gradual Rollout
1. **Week 1**: hello_universe (educational, lowest risk)
2. **Week 2**: mast_notebooks (standard configuration)  
3. **Week 3**: jdat_notebooks (moderate complexity)
4. **Week 4**: hst_notebooks (micromamba environment)
5. **Week 5**: jwst-pipeline-notebooks (highest complexity)

### Phase 3: Monitoring and Optimization
- [ ] Monitor workflow execution times
- [ ] Collect feedback from repository maintainers
- [ ] Document any issues or improvements needed
- [ ] Plan first minor release (v1.1.0) with improvements

## 📋 Repository Migration Checklist

For each repository, complete the following:

### Pre-Migration
- [ ] Run `validate-repository.sh` and achieve score ≥80%
- [ ] Backup existing workflows
- [ ] Create migration branch
- [ ] Notify repository maintainers

### Migration
- [ ] Run `migrate-repository.sh` 
- [ ] Review generated workflows
- [ ] Test workflows on migration branch
- [ ] Create pull request with migration

### Post-Migration
- [ ] Merge migration PR
- [ ] Verify workflows run successfully on main branch
- [ ] Update repository documentation
- [ ] Mark repository as migrated in progress tracker

## 🔧 Emergency Rollback Procedure

If issues arise during migration:

```bash
# Rollback to original workflows
cd repository-name
git checkout main
git checkout pre-migration-backup -- .github/workflows/
git commit -m "Rollback: Restore original workflows"
git push origin main
```

## 📊 Success Metrics

Track these metrics for successful deployment:

### Technical Metrics
- [ ] **Workflow Success Rate**: >95% for all migrated repositories
- [ ] **Execution Time**: No significant increase in CI/CD time
- [ ] **Error Rate**: <5% for workflow-related issues
- [ ] **Migration Success**: All 5 repositories successfully migrated

### Process Metrics  
- [ ] **Documentation Usage**: README views, issue resolution time
- [ ] **Maintainer Satisfaction**: Feedback from repository maintainers
- [ ] **Contribution Rate**: No decrease in PR/contribution activity
- [ ] **Issue Resolution**: Migration-related issues resolved within 48 hours

## 📞 Support During Rollout

### Points of Contact
- **Primary**: [Implementation Lead Name]
- **Technical**: [Technical Lead Name]  
- **STScI Contact**: [STScI Representative Name]

### Communication Channels
- **Issues**: Create issues in `dev-actions` repository
- **Questions**: Use GitHub Discussions or appropriate Slack channels
- **Urgent**: Direct contact with implementation team

### Documentation
- **Quick Start**: [examples/README.md](examples/README.md)
- **Full Documentation**: [README.md](README.md)
- **Troubleshooting**: [docs/migration-guide.md](docs/migration-guide.md)

---

**Deployment Lead**: [Your Name]  
**Target Completion**: [Date]  
**Status**: ⏳ Ready for Production Deployment
