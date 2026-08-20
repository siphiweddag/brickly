# Brickly Break Launch QA Report

## Executive status

- **Result:** PASS WITH RELEASE RISKS
- **Date:** 2026-08-20
- **Product:** Brickly Break by Stratida, Flutter offline block puzzle
- **Environment:** macOS 26.6 arm64, Flutter 3.38.9, Dart 3.10.8
- **Android target tested:** Android 16 / API 36 emulator
- **Automated result:** 23/23 tests passed; static analysis passed

The game is ready for Android internal testing. Store publication should wait
until the production upload key is created and backed up, a signed bundle is
verified in Play Console, and the critical journey passes on a physical device.

## Scope completed

- drag-only placement and exact drop positioning;
- horizontal-only line completion and scoring by blocks cleared;
- repeated cascade clearing until no full row remains;
- gravity only after a row breaks, with remaining blocks settling to the base;
- top-stack game-over handling and undo behavior;
- 50-level Brickly Journey with meaningful 5-to-29-row targets, scaling par
  moves, stars, unlocks, and saved progress;
- Endless Classic mode and corrected high-score persistence;
- five-step first-run/replayable tutorial;
- functional sound, haptics, placement-guide, and progress-reset settings;
- Privacy Policy, Terms of Service, website, support email, ownership, and
  dynamic copyright integration;
- high-contrast responsive lobby, level select, gameplay, tutorial, and
  settings flows;
- Android/iOS launcher icon set, Play feature graphic, and five store
  screenshots;
- Play listing, Data Safety draft, and launch checklist.

## Verification matrix

| Area | Verification | Result |
|---|---|---|
| Engine | Place pieces, horizontal clears, cascades, gravity, top game over | PASS |
| Scoring | 10 points per broken block; no hidden combo inflation | PASS |
| Journey | Exactly 50 progressive levels, locks, completion, stars, reset | PASS |
| Persistence | Level progress and current-version best score | PASS |
| Tutorial | First-run gate and replay from Settings | PASS |
| Legal | Exact Stratida URLs, support address, attribution, copyright | PASS |
| Navigation | Journey, Endless, Levels, Settings, back/exit flows | PASS |
| Accessibility | Contrast checks, responsive layout, 150% text regression | PASS |
| Static analysis | `flutter analyze` | PASS — no issues |
| Automated tests | `flutter test` | PASS — 23/23 |
| Android debug | APK build, install, cold launch, emulator smoke | PASS |
| Android release | AAB compiles without debug certificate | PASS — unsigned by design |
| iOS | Simulator build and runtime | NOT TESTED — local platform unavailable |

## Emulator visual evidence

- `store/assets/screenshot-01-lobby.png`
- `store/assets/screenshot-02-tutorial.png`
- `store/assets/screenshot-03-levels.png`
- `store/assets/screenshot-04-gameplay.png`
- `store/assets/screenshot-05-settings.png`

Fresh-install testing reset Brickly's local emulator preferences and progress.
No data outside this app was changed.

## Release risks and required gates

1. Create a private Android upload keystore, store it outside Git, keep a secure
   backup, and configure `android/key.properties` locally.
2. Build the signed AAB and validate it through Google Play internal testing.
3. Complete Play Console App Content, content rating, target audience, ads, and
   Data Safety questionnaires using the supplied working drafts.
4. Run the full critical journey on at least one representative physical
   Android device, including drag precision, haptics, background/resume, and a
   long play session.
5. Perform iOS build, signing, simulator/device testing, and App Store privacy
   configuration before any iOS launch.
6. Reassess Data Safety and privacy disclosures before adding analytics, ads,
   crash reporting, cloud saves, accounts, or purchases.

## Artifacts

- Debug APK: `build/app/outputs/flutter-apk/app-debug.apk`
- Release AAB: `build/app/outputs/bundle/release/app-release.aab`
- Play assets: `store/assets/`
- Store copy: `store/google-play-listing.md`
- Data Safety draft: `store/data-safety.md`
- Release checklist: `store/release-checklist.md`

## Recommendation

Approve the current build for emulator demonstration and Android internal UAT.
Do not mark it production-ready until the signing, Play Console, and physical
device gates above are complete.
