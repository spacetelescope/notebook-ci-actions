# JIRA Note: Modify Deprecation Task to Create PR

**Task:** Modify the deprecation management workflow to automatically create a pull request (PR) when a notebook is marked for deprecation.

**Description:**
Update the unified notebook CI/CD workflow so that when a notebook is marked for deprecation (using the on-demand mode with the `deprecate` trigger), the workflow will:
- Add deprecation metadata and hidden markers to the notebook.
- Sync the deprecated notebook to the `gh-storage` branch.
- Rebuild documentation with visible deprecation warnings.
- Automatically create a pull request proposing the deprecation changes, including documentation updates and any affected files.
- Assign reviewers or labels as needed for deprecation review.

This automation streamlines the deprecation process, ensures visibility, and enforces review before finalizing deprecation.

**Acceptance Criteria:**
- Deprecation workflow triggers a PR with all relevant changes.
- PR includes updated documentation and notebook files.
- Reviewers/labels are assigned automatically.
- Manual merging required to finalize deprecation.

---
**Results Comment:**
The deprecation workflow was successfully updated. When a notebook is marked for deprecation, a pull request is now created automatically with all required changes and documentation. This ensures that deprecation actions are reviewed and tracked through the standard GitHub PR process.

---
Generated: 2025-07-15
