---
description: Regenerate SendAdv KO/EN App Store screenshots and repeat designer/marketer review until approved.
---

Load and follow the `appstore-screenshots` skill.

Goal: update the SendAdv App Store screenshot sets for both Korean and English.

Workflow:
1. Inspect current `git status --short` and preserve unrelated local/untracked files.
2. Build only if source/localization changes are needed. When building, use `xcodebuild ... 2>&1 | xcsift -f toon -w`.
3. Launch the Debug app with explicit language arguments:
   - Korean: `-AppleLanguages '(ko)' -AppleLocale ko_KR`
   - English: `-AppleLanguages '(en)' -AppleLocale en_US`
4. Seed simulator data as needed for screenshot-only capture.
5. Keep raw device screenshots under:
   - `screenshots/device/ko/`
   - `screenshots/device/en/`
6. Generate App Store marketing screenshots under:
   - `screenshots/appstore/ko/`
   - `screenshots/appstore/en/`
7. Sync final App Store images to Fastlane deliver paths:
   - `fastlane/screenshots/ko/`
   - `fastlane/screenshots/en-US/`
8. Remove all debug, ad, and localization artifacts.
9. Run both designer and marketer reviews.
10. Apply every must-fix item, regenerate affected screenshots, and repeat both reviews until both return `Verdict: approve`.
11. Verify dimensions and report final status.

Constraints:
- Do not commit unless explicitly asked.
- Do not add commands to `opencode.json`.
- Preserve `design/` as local/untracked unless explicitly asked.
- Use compliance-safe copy: prepare/review/open Messages, never automatic SMS or spam-like phrasing.
- Review and modify App Store screenshots only. Do not inspect or edit App Store metadata unless explicitly asked.
- Final raw device screenshots must be `1242x2688`.
- Final App Store screenshots must be `1242x2688`, an App Store Connect accepted portrait size.
- Fastlane screenshot copies must be `1242x2688` and placed under `fastlane/screenshots/ko/` and `fastlane/screenshots/en-US/`.
- Never generate or upload `1290x2796`; App Store Connect rejects that size for this workflow.
- Before reporting done, run the dimension validation from the `appstore-screenshots` skill and stop if any screenshot is not one of the accepted sizes: `1242x2688`, `2688x1242`, `1284x2778`, `2778x1284`.
