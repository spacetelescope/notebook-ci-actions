# Setting Up a Notebook Repository with This CI

*For scientists who want to stand up a **new** notebook repository wired to
`spacetelescope/notebook-ci-actions`, without configuring the CI by hand.*

You do not need to copy workflow files or learn the YAML. Two front doors get you
a working repo with validation, execution, security scanning, and the published
docs site already connected. Pick the one that matches you.

## Which path are you on?

| You are | Use | What you get |
| --- | --- | --- |
| **STScI staff** (internal) | The Slack bot | A repo created and onboarded for you, with internal defaults and access already set |
| **Anyone else** (general public) | The template repository | A repo you create yourself from a ready-made template, CI included |

Both end in the same place: a repo where opening a pull request runs the checks
and merging to `main` publishes your notebooks. From there, the
[Quick Reference](quick-reference.md) and [Full Guide](guide.md) cover day-to-day
work.

## Internal: use the Slack bot

If you are inside STScI, the fastest path is the Slack bot. It provisions the
repository, applies the standard CI configuration, and wires up the pieces you
would otherwise request by hand (access, secrets placeholders, the docs deploy).

Send the bot a one-line command in Slack:

```
!CreateRepoFromTemplate spacetelescope <your-repo-name> notebook-ci-template
```

The three arguments are:

| Argument | Value | Meaning |
| --- | --- | --- |
| Organization | `spacetelescope` | Where the new repo is created |
| Repository name | `<your-repo-name>` | Your new repo's name, no spaces |
| Template | `notebook-ci-template` | The CI-ready template to copy from |

For example:

```
!CreateRepoFromTemplate spacetelescope jwst-coron-demo notebook-ci-template
```

creates `spacetelescope/jwst-coron-demo` from the template, with the caller
workflows already committed. When the bot confirms the repo is ready, clone it,
drop your notebooks under its notebook directory, and open a pull request. The CI
takes over from there.

!!! tip "Internal only"
    The Slack bot lives behind STScI's Slack and access controls. If you are not
    on the internal workspace, use the template repository below instead.

## General public: use the template repository

If you are outside STScI, start from the template repository,
[**spacetelescope/notebook-ci-template**](https://github.com/spacetelescope/notebook-ci-template).
GitHub's "Use this template" turns it into a brand-new repo of your own, with the
CI workflows, example structure, and docs deploy already in place.

1. Open the template:
   [github.com/spacetelescope/notebook-ci-template](https://github.com/spacetelescope/notebook-ci-template).
2. Click **Use this template → Create a new repository**.
3. Name your repo, choose the owner, and create it.
4. Clone your new repo:

    ```bash
    git clone https://github.com/<your-account>/<your-repo-name>.git
    ```

5. In your new repo, set **Settings → Pages → Source** to **GitHub Actions** (one
   time) so the docs site can publish.
6. Add your notebooks, declare dependencies in `requirements.txt`, and open a pull
   request to see the CI run.

!!! warning "Use the template, do not fork"
    "Use this template" gives you a clean, independent repository with no upstream
    fork relationship, which is what you want for your own science. Forking keeps
    a link to the source repo and is meant for contributing changes back, not for
    starting a new project.

## What you get either way

- **Pull-request checks** — each changed notebook is validated, security-scanned,
  and executed in a clean environment before review.
- **Publish on merge** — merging to `main` runs the full pipeline and builds the
  HTML docs site from your notebooks.
- **Local testing** — the repo ships the `scripts/test-local-ci.sh` harness so you
  can reproduce CI on your laptop before pushing.
- **Pinned, maintained CI** — the workflows reference a pinned version (for
  example `@v1`); you never edit them, and updates come from upstream.

## Next steps

- New to the contract your notebooks must satisfy? Start with the
  [Quick Reference](quick-reference.md).
- Want the full picture of what the CI does to your notebook? Read the
  [Full Guide](guide.md).
- Test before you push: [Local Testing (Cheatsheet)](../local-testing-quick-reference.md)
  and [Local Testing (Full Guide)](../local-testing-guide.md).
