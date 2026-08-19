# Test Report

## Executive status

- Result: PASS WITH RISKS
- Project type: Flutter offline block-puzzle game
- Environment: macOS 26.6 arm64, Flutter 3.38.9, Dart 3.10.8
- Android target tested: Android 16 / API 36 emulator
- Date: 2026-08-19
- Commit or working-tree state: workspace is not a Git repository

## Scope

Tested the core Brickly Break journey and the requested remediation areas:

- lobby navigation and removal of Shop, rewards, coins, and dead-end modes;
- Classic-mode entry, drag placement, exit, restart-related controls, and settings;
- horizontal-only row clearing, gravity, cascade clearing, top-row game over, and undo;
- score calculation, score feedback, and best-score model migration;
- color contrast, small-screen layout, and 150% text scaling;
- Android debug/release builds, offline dependency health, and source secret scan.

## Tools and commands used

- `flutter pub outdated`
- `flutter analyze`
- `flutter test`
- `flutter test --coverage`
- `flutter build apk --debug`
- `flutter build apk --release`
- `flutter build ios --simulator --no-codesign`
- Android `adb` install, launch, focus inspection, screen capture, and smoke input
- Source scan with `rg`

## Baseline results

- Dependencies: direct and development dependencies current within resolved constraints.
- Static analysis: passed with no issues.
- Tests: failed at 7 passed / 1 failed because the free-drag widget test did not reliably complete placement.
- Android baseline build: not run in the chained baseline command because tests failed first.
- Product review confirmed misleading Shop/reward/currency UI, unclear scoring, low-contrast button text, and fake settings state.

## Test matrix

| Area | Scenario | Expected result | Level | Priority | Final status |
|---|---|---|---|---|---|
| Lobby | Fresh launch | Clear title, rules, and one primary play action | Widget + emulator | P0 | PASS |
| Journey | Lobby → Classic → lobby | Enters gameplay and returns correctly | Widget | P0 | PASS |
| Input | Drag a tray piece onto an empty board | Piece places and leaves the tray | Widget | P0 | PASS |
| Scoring | One horizontal row | 8 blocks × 10 = 80 points | Unit | P0 | PASS |
| Scoring | Two cascade rows | 16 blocks × 10 = 160 points | Unit | P0 | PASS |
| Rules | Vertical line | Does not clear or score | Unit | P0 | PASS |
| Gravity | Row breaks with blocks above | Remaining blocks settle to the base | Unit | P0 | PASS |
| Game over | Stack reaches top after cascades | Game ends | Unit | P0 | PASS |
| Persistence | Old and new best-score keys coexist | Only versioned current score is shown | Widget | P1 | PASS |
| Settings | Toggle effects | Preference is persisted | Widget | P1 | PASS |
| Navigation | Shop/reward access | No Shop, reward, or currency UI remains | Widget + emulator | P1 | PASS |
| Accessibility | Core text/action colors | WCAG AA ratio of at least 4.5:1 | Unit + visual | P1 | PASS |
| Responsive UI | 360×640 at 150% text | No layout overflow | Widget | P1 | PASS |
| Android build | Debug and release APK | Both compile successfully | Build | P0 | PASS |
| iOS build | Simulator build | Compiles for installed simulator SDK | Build | P1 | BLOCKED |

## Confirmed defects

### QA-001 · P1 · Free-drag regression test was flaky

- Environment: Flutter widget test
- Preconditions: lobby loaded; Classic mode opened
- Reproduction: start a gesture on the first tray piece, move directly to the board center, release
- Expected: piece leaves the tray and appears on the board
- Actual: tray occasionally retained all three pieces
- Evidence: baseline test expected 2 `Draggable<BlockPiece>` widgets but found 3
- Likely area: test gesture timing and gesture-arena settlement
- Fix status: FIXED; gesture now pumps after touch-down and moves through an intermediate point
- Regression-test status: PASS

### QA-002 · P1 · Equal cleared blocks produced unequal scores

- Environment: game engine
- Preconditions: cascade or consecutive clear multiplier above 1
- Reproduction: clear equal-size horizontal rows at different combo depths
- Expected: every broken block contributes the same 10 points
- Actual: score multiplied by persistent combo depth
- Likely area: `GameEngine.place`
- Fix status: FIXED; score is now `blocksCleared × 10` for every wave
- Regression-test status: PASS for single-row and cascade clears

### QA-003 · P1 · Old scoring contaminated best score

- Environment: shared preferences
- Preconditions: `best_score` saved by the previous scoring model
- Reproduction: update app and enter Classic mode
- Expected: best score uses the corrected model
- Actual: inflated legacy score remained visible
- Fix status: FIXED with versioned `best_score_v2`
- Regression-test status: PASS

### QA-004 · P1 · Misleading and dead-end user journey

- Environment: lobby and navigation
- Reproduction: open Shop, reward cards, coins, or disabled future modes
- Expected: every prominent option supports the current playable product
- Actual: several controls had no meaningful completion path
- Fix status: FIXED; removed Shop, rewards, coins, fake level progress, and disabled modes; added one Play Classic action and clear rules
- Regression-test status: PASS

### QA-005 · P1 · Primary action failed text contrast

- Environment: lobby
- Reproduction: view white Play Classic text on the yellow button
- Expected: at least 4.5:1 contrast
- Actual: approximately 1.6:1
- Fix status: FIXED with navy text on yellow (approximately 10.9:1); widget test confirms the rendered label color
- Regression-test status: PASS

### QA-006 · P1 · Small-screen large-text overflow

- Environment: 360×640 logical pixels at 150% text
- Reproduction: launch lobby
- Expected: no clipped or overflowing content
- Actual: fixed header/navigation content overflowed by 10 pixels
- Fix status: FIXED with bounded adaptive navigation height and single-line safe header text
- Regression-test status: PASS

### QA-007 · P1 · Settings displayed a non-functional disabled switch

- Environment: settings dialog
- Expected: effects setting reflects and changes actual game preference
- Actual: disabled switch always displayed as enabled
- Fix status: FIXED with shared-preference-backed state
- Regression-test status: PASS

## Risks and untested areas

- iOS was not built or run because the local Xcode installation has no iOS 26.5 simulator platform installed.
- No physical Android or iOS device testing was performed.
- Android emulator black-box drag evidence was interrupted when another installed app repeatedly stole focus. The same drag journey passes reliably as a Flutter widget test; the final Brickly lobby focus and rendering were verified separately.
- Long-session memory, battery, landscape orientation, screen readers, and real-device haptics were not tested.
- No dedicated dependency vulnerability scanner was available; dependency resolution and source secret-pattern checks passed.

## Changes made

- Removed Shop, rewards, coins, fake player progression, and disabled future-mode actions.
- Simplified the journey to Lobby, Inventory, and Play Classic.
- Added an explicit four-step gameplay explanation.
- Changed scoring to a flat 10 points per broken block and exposed cleared-block counts in move results.
- Versioned persisted best scores to avoid legacy inflation.
- Added exact score feedback after clears.
- Corrected primary button, navigation, segmented-tab, and active-label contrast.
- Made bottom navigation text-scale aware and protected the header from wrapping overflow.
- Made sound/haptic settings functional and persistent.
- Added scoring, contrast, persistence, navigation, settings, drag, and responsive-layout regression tests.

## Final verification

- Static analysis: PASS, no issues.
- Automated tests: PASS, 13/13.
- Line coverage: 550/611, 90.0% on the final code and test suite.
- Android debug APK: PASS.
- Android release APK: PASS, 44.8 MB.
- Source credential-pattern scan: PASS, no matches.
- Visual evidence: `qa/brickly-final-lobby.png`.
- Final release APK: `build/app/outputs/flutter-apk/app-release.apk`.

## Release recommendation

Approve this build for Android emulator/demo and physical-device UAT. Do not call the cross-platform release production-ready until the iOS platform is installed and tested and at least one representative physical Android device completes the critical play journey.
