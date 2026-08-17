---
description: Prepare a version release PR and deploy that branch to TestFlight.
---

Goal: prepare a versioned iOS release branch, create a release PR, deploy that branch to TestFlight, monitor the deploy workflow, and report done only after the workflow succeeds.

Workflow:
1. Check `git status --short --branch`, confirm the current branch is `main`, and ensure `main` is synced with `origin/main`. If tracked unrelated changes exist, stop and ask before continuing.
2. Determine the release version. If the user provided `a.b.c`, use it exactly; otherwise increment the patch component of the current `MARKETING_VERSION` from `Projects/App/Configs/debug.xcconfig` and `Projects/App/Configs/release.xcconfig`.
3. Create a branch named exactly the version string, for example `2.1.2`.
4. Update only `MARKETING_VERSION` in `Projects/App/Configs/debug.xcconfig` and `Projects/App/Configs/release.xcconfig`. Do not change `CURRENT_PROJECT_VERSION`.
5. Generate concise release notes from relevant merged PRs/commits unless the user supplied release notes.
6. Inspect `git diff`, `git status`, and `git log --oneline -10`; commit only the two version config files with `chore(release): prepare <a.b.c>`.
7. Push the branch and create a PR into `main` titled `Release <a.b.c>` with the release notes as the PR body.
8. Run `.github/workflows/deploy-ios.yml` on that version branch with `isReleasing=false` and `body` set to the release notes:

```bash
gh workflow run deploy-ios.yml --ref <a.b.c> -f isReleasing=false -f body='<release notes>'
```

9. Monitor the run with `gh run list --workflow deploy-ios.yml --branch <a.b.c> --limit 5` and `gh run watch <run-id> --exit-status` until completion.
10. Report done only if the deploy action succeeds. Include the version, branch, PR URL, deploy run URL, and final status.

Constraints:
- Keep this command project-local only.
- Load and follow the `release-ios-testflight` skill for details.
- Preserve unrelated untracked files unless explicitly asked to include them.
- Do not include unrelated `.package.resolved`, `.opencode`, workbook, photo, or secret changes in the release commit.
- Do not merge the release PR unless the user explicitly asks.
- Do not submit for App Store review unless the user explicitly asks; TestFlight uses `isReleasing=false`.
