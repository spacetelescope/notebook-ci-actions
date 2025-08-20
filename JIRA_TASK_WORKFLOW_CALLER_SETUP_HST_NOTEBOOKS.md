# JIRA Note: Setup of Workflow Caller for hst_notebooks

**Task:** Set up workflow caller in notebook-ci-testing for hst_notebooks

**Summary:**
The workflow caller was successfully configured in the notebook-ci-testing repository for the hst_notebooks project. This enables the repository to trigger and utilize the centralized notebook CI/CD workflows for all supported events.

**Details:**
- Workflow caller YAML was added and configured for hst_notebooks.
- Inputs and parameters were verified for compatibility with the unified workflow.
- All workflow types (PR, merge, scheduled, on-demand) are now supported for hst_notebooks.
- Initial test runs confirmed correct triggering and execution of the centralized workflow.

**Outcome:**
- hst_notebooks is now fully integrated with the centralized notebook CI/CD system.
- Ready for ongoing development and CI/CD validation using the new workflow structure.

**Next Steps:**
- Monitor workflow runs for any issues.
- Share setup details with the team and update documentation as needed.

---
Generated: 2025-07-15
