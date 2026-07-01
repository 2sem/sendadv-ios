---
name: appstore-screenshots
description: Use when creating, updating, reviewing, or regenerating SendAdv App Store screenshots, including /update-screenshots, screenshots/device, screenshots/appstore, Korean/English localization, simulator capture, and designer/marketer approval loops.
---

# App Store Screenshots for SendAdv

Use this skill when the user asks to create, update, regenerate, review, or polish App Store screenshots for this project.

## Goal

Produce App Store-ready screenshot sets that are:

- localized for Korean and English
- visually aligned with the Soft Friendly design direction
- safe for App Store review: no spam, auto-send, or unattended SMS implication
- organized by language under `screenshots/`
- approved by both Designer and Marketer reviewers before final handoff

## Expected output structure

```text
screenshots/
  device/
    ko/
      01-main-list.png
      02-filter-detail.png
      03-ready-to-send.png
      04-continue-batch.png
      05-edit-mode.png
    en/
      01-main-list.png
      02-filter-detail.png
      03-ready-to-send.png
      04-continue-batch.png
      05-edit-mode.png
  appstore/
    ko/
      01-filtered-sms.png
      02-smart-filter.png
      03-review-before-send.png
      04-batch-sending.png
      05-manage-filters.png
    en/
      01-filtered-sms.png
      02-smart-filter.png
      03-review-before-send.png
      04-batch-sending.png
      05-manage-filters.png
```

Also sync the final App Store images to Fastlane deliver's screenshot paths:

```text
fastlane/screenshots/en-US/
  01-filtered-sms.png
  02-smart-filter.png
  03-review-before-send.png
  04-batch-sending.png
  05-manage-filters.png
fastlane/screenshots/ko/
  01-filtered-sms.png
  02-smart-filter.png
  03-review-before-send.png
  04-batch-sending.png
  05-manage-filters.png
```

Expected dimensions:

- `screenshots/device/**`: `1242x2688` from iPhone 11 Pro Max simulator
- `screenshots/appstore/**`: `1242x2688` App Store Connect accepted portrait size
- `fastlane/screenshots/**`: `1242x2688` App Store Connect accepted portrait size

Hard guardrail: never generate or upload `1290x2796` screenshots. App Store Connect rejects that size for this app/device class. Valid screenshot sizes for this workflow are:

- `1242x2688` portrait — preferred and currently used
- `2688x1242` landscape
- `1284x2778` portrait
- `2778x1284` landscape

If any screenshot is not one of those sizes, stop and fix the image dimensions before asking for review or syncing to Fastlane.

## Source-of-truth design and constraints

- Primary design source: `design/project/SendAdv Soft Friendly.dc.html`
- Reference-only design source: `design/project/SendAdv Filter Designs.dc.html`
- Keep visual language: warm background, rounded cards, soft purple accent, clean hierarchy.
- Avoid committing `design/` unless explicitly requested.
- `screenshots/` may be generated/untracked until the user decides to commit.

## Compliance-safe positioning

Always frame the app as preparing recipients and opening Messages, not sending automatically.

Preferred wording:

- prepare recipients
- review before sending
- open Messages
- split into batches for Messages
- send directly in Messages
- app never sends SMS automatically

Avoid or replace:

- send at once
- bulk send / mass send / blast
- automatic send
- auto classification if it sounds like automation
- large lists if it sounds like spam marketing

Approved current overlay copy:

### Korean

1. `필요한 연락처만 골라\n문자 준비` / `회사, 부서, 직책 기준으로 빠르게 선택하세요`
2. `필터로 수신자\n분류` / `부서 · 직책 · 회사 조건을 조합해보세요`
3. `보내기 전\n한 번 더 확인` / `수신자 수와 배치를 확인하고 메시지 앱을 여세요`
4. `여러 수신자도\n나누어 준비` / `메시지 앱에 맞춰 묶음으로 준비합니다`
5. `필터를 쉽게\n관리` / `필요 없는 필터는 빠르게 정리하세요`

Badge: `연락처 필터 문자`

### English

1. `Choose the right\ncontacts` / `Filter recipients by company, team, or role`
2. `Build reusable\nfilters` / `Combine department, position, and company rules`
3. `Check before\nyou send` / `Review recipients and batches before Messages opens`
4. `Prepare batches\nfor Messages` / `Split recipient groups to fit the iOS Messages app`
5. `Manage saved\nfilters` / `Update or remove filters whenever you need`

Badge: `Contact Filters`

## App UI strings that matter for screenshots

These source strings were intentionally made compliance-safe and should generally remain aligned with screenshots:

- `send.action.with.count`
  - EN: `Review %d filters`
  - KO: `%d개 필터 확인`
- `rules.header.summary`
  - EN: `%d turned on · ready to prepare messages`
  - KO: `%d개 켜짐 · 문자 준비 가능`
- KO send confirmation:
  - `메시지를 열까요?`
  - `메시지 앱에서 보낼 수 있도록 준비합니다`
  - helper says the app does not send SMS automatically and the user sends in Messages.

Also preserve the localized multi-keyword summary behavior:

- KO must show `대표 외 1`, not `대표 and 1 others`.

## Simulator and build workflow

Preferred simulator used in the current project history:

- Device: iPhone 11 Pro Max
- UDID: `9E7F20C3-A8F5-4AEA-8419-6F95264C267D`
- Bundle ID: `com.credif.sendadv`

Build with structured output:

```bash
xcodebuild -workspace sendadv.xcworkspace \
  -scheme App \
  -configuration Debug \
  -sdk iphonesimulator \
  -derivedDataPath "/var/folders/6x/l8h411bn30xd7f7ptkpc48mr0000gn/T/opencode/sendadv-screenshot-dd" \
  CODE_SIGNING_ALLOWED=NO build 2>&1 | xcsift -f toon -w
```

Install:

```bash
xcrun simctl install "9E7F20C3-A8F5-4AEA-8419-6F95264C267D" \
  "/var/folders/6x/l8h411bn30xd7f7ptkpc48mr0000gn/T/opencode/sendadv-screenshot-dd/Build/Products/Debug-iphonesimulator/App.app"
```

Launch by language:

```bash
# Korean
xcrun simctl launch "9E7F20C3-A8F5-4AEA-8419-6F95264C267D" \
  com.credif.sendadv -AppleLanguages '(ko)' -AppleLocale ko_KR

# English
xcrun simctl launch "9E7F20C3-A8F5-4AEA-8419-6F95264C267D" \
  com.credif.sendadv -AppleLanguages '(en)' -AppleLocale en_US
```

Clean status bar for screenshots:

```bash
xcrun simctl status_bar "9E7F20C3-A8F5-4AEA-8419-6F95264C267D" override \
  --time 9:41 --batteryState charged --batteryLevel 100 \
  --wifiBars 3 --cellularBars 4
```

Suppress ads for capture by setting the existing ad-free timestamp in app preferences:

```python
import plistlib, time
from pathlib import Path

pref = Path(APP_CONTAINER) / "Library/Preferences/com.credif.sendadv.plist"
try:
	data = plistlib.load(pref.open("rb"))
except FileNotFoundError:
	data = {}
data["LastRewardShown"] = time.time()
plistlib.dump(data, pref.open("wb"))
```

## Seed data workflow

Use simulator SwiftData store only for screenshot capture. Do not hard-code screenshot data into app source.

Store path:

```text
$APP_CONTAINER/Library/Application Support/default.store
```

Important tables:

- `ZRECIPIENTSRULE`
- `ZRECIPIENTSFILTER`

Recommended KO filter seed:

- `영업팀` enabled, dept `영업팀`
- `고객지원팀` enabled, dept `고객지원팀`
- `마케팅 담당자` enabled, dept `마케팅팀`
- `대표님들` disabled, job `대표,CEO`
- `개발팀` disabled, dept `개발팀`

Recommended EN filter seed:

- `Sales` enabled, dept `Sales`
- `Support` enabled, dept `Support`
- `Marketing` enabled, dept `Marketing`
- `Executives` disabled, job `CEO,President`
- `Dev Team` disabled, dept `Development`

For send confirmation screenshots only, it is acceptable to temporarily set enabled filters' `ZALL=1` in simulator data so the sheet reliably shows a batch count. Restore or reseed afterwards if needed.

## Capturing screens

Capture raw device screenshots using:

```bash
xcrun simctl io "9E7F20C3-A8F5-4AEA-8419-6F95264C267D" screenshot "screenshots/device/<lang>/<name>.png"
```

Use accessibility/semantic controls when available. If direct IDB navigation fails, use targeted `idb ui tap` with known stable simulator coordinates as a fallback.

Required screens:

1. Main list
2. Existing or new filter detail with a selected condition
3. First send confirmation sheet
4. Continue/batch sheet, visually distinct from #3
5. Edit/delete mode

Simulator cannot actually send SMS, and `MFMessageComposeViewController.canSendText()` may block natural advancement to the next batch. If needed, create #4 by carefully deriving from #3 and making only screenshot-state edits such as:

- EN: `Continue sending`, `Batch 2 of 6 · 20 recipients`
- KO: `6번 중 2번째 · 20명`

Make the result visually clean; no overlapping or leftover text.

## Generating App Store frames

Generate `1242x2688` App Store Connect accepted marketing screenshots from `screenshots/device/<lang>`. Keep:

- warm vertical gradient
- subtle accent blob
- badge at top-left
- 2-line headline and one-line subtitle
- rounded phone screenshot mockup centered lower on the canvas
- no debug/ad artifacts

Do not use arbitrary marketing canvas sizes. The output canvas itself must be App Store Connect accepted, not just the embedded device screenshot. Preferred output canvas:

```text
1242x2688
```

When resizing an existing generated set after a dimension mistake, resize both:

- `screenshots/appstore/<lang>/*.png`
- `fastlane/screenshots/<locale>/*.png`

Then run the validation script below.

## Required dimension validation

Run this exact validation before reporting success and before any Fastlane upload:

```bash
python3 - <<'PY'
from pathlib import Path
from PIL import Image

accepted = {(1242, 2688), (2688, 1242), (1284, 2778), (2778, 1284)}
folders = [
    'screenshots/device/ko',
    'screenshots/device/en',
    'screenshots/appstore/ko',
    'screenshots/appstore/en',
    'fastlane/screenshots/ko',
    'fastlane/screenshots/en-US',
]
failed = []
for folder in folders:
    for path in sorted(Path(folder).glob('*.png')):
        with Image.open(path) as img:
            if img.size not in accepted:
                failed.append(f'{path}: {img.size[0]}x{img.size[1]}')
if failed:
    raise SystemExit('Invalid App Store screenshot dimensions:\n' + '\n'.join(failed))
print('All screenshots use App Store Connect accepted dimensions.')
PY
```

If the script fails, do not proceed to reviewer approval or Fastlane upload.

Before finalizing, visually inspect at least the changed screenshots with the image reader.

## Review loop: mandatory

After generating screenshots, ask both agents to review:

- `designer`: visual design, localization, hierarchy, crop/preview, duplicate states
- `marketer`: ASO and compliance safety, especially no spam/auto-send implication

The review scope is the screenshot set only. If reviewers mention App Store metadata as a nice-to-have, report it separately but do not inspect, edit, or rewrite metadata unless the user explicitly asks for metadata work.

Repeat until both return `Verdict: approve`.

Suggested review prompt requirements:

- list all KO and EN file paths
- mention compliance constraint
- mention recent fixes
- require exact sections:
  1. `Verdict: approve / approve with changes / reject`
  2. must-fix items
  3. nice-to-have items
  4. one-sentence rationale

If either reviewer says `approve with changes` or `reject`, apply must-fix items, regenerate affected screenshots, and run both reviews again.

## Verification checklist

Before reporting done:

- [ ] Build succeeds after any source/localization changes.
- [ ] No unintended debug/ad artifacts in screenshots.
- [ ] `screenshots/device/**` are `1242x2688`.
- [ ] `screenshots/appstore/**` are `1242x2688`.
- [ ] `fastlane/screenshots/en-US/**` and `fastlane/screenshots/ko/**` are synced from `screenshots/appstore/**` and are `1242x2688`.
- [ ] No screenshot is `1290x2796`.
- [ ] The required dimension validation script passed.
- [ ] `fastlane/Fastfile` does not skip screenshots for App Store review uploads (`skip_screenshots: false`).
- [ ] KO and EN sets are both present.
- [ ] KO does not contain English fallback text like `and 1 others`.
- [ ] EN does not contain Korean UI text.
- [ ] #3 and #4 are visually distinguishable.
- [ ] Designer approved.
- [ ] Marketer approved.
- [ ] Any non-screenshot feedback, such as metadata suggestions, is reported as out-of-scope unless explicitly requested.
- [ ] `git status --short` is reported, including `design/` and `screenshots/` if untracked.

## Reporting format

Final response should include:

- goal and success criteria
- files generated/updated
- reviewer verdicts
- verification results
- current git status summary
- next step: whether to commit `screenshots/` and source localization fixes
