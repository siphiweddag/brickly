# Brickly Break launch checklist

## Product

- [x] Endless Classic is playable.
- [x] 50-level Journey exists with saved unlocks and stars.
- [x] First-run tutorial exists and can be replayed.
- [x] Settings include functional effects, placement guide, reset, help, and legal links.
- [x] Terms, Privacy, website, contact, and dynamic Stratida copyright are discoverable.
- [x] Shop, rewards, fake currency, ads, and unavailable modes are absent.

## Store assets

- [x] 512 × 512 Play icon: `store/assets/app-icon-512.png`
- [x] 1024 × 500 feature graphic: `store/assets/feature-graphic-1024x500.png`
- [ ] Capture at least four current phone screenshots from the signed release build.
- [x] Listing copy drafted in `store/google-play-listing.md`.
- [x] Data Safety working declaration drafted in `store/data-safety.md`.
- [ ] Complete Play Console content-rating questionnaire.
- [ ] Confirm target audience and whether the app is directed to children.

## Android release

- [x] Package ID: `com.brickly.game.brickly`
- [x] Target SDK: API 36.
- [x] Debug signing fallback removed from the release build.
- [ ] Create and securely back up the upload keystore outside Git.
- [ ] Copy `android/key.properties.example` to `android/key.properties` and enter local secrets.
- [ ] Enroll in Google Play App Signing.
- [ ] Build the signed bundle: `flutter build appbundle --release`.
- [ ] Verify the signing certificate is not `Android Debug`.
- [ ] Upload to Play internal testing and complete a tester journey.

## Verification

- [ ] `flutter analyze`
- [ ] `flutter test`
- [ ] Android release bundle build
- [ ] Fresh-install emulator smoke test
- [ ] Physical Android device smoke test
- [ ] Screen-reader and large-text smoke test
- [ ] Long-session performance check
- [ ] Review Privacy and Terms links from the packaged app

## iOS, if included in launch

- [x] iOS icon set updated.
- [ ] Configure Apple signing and final bundle ID ownership.
- [ ] Build and test on an installed iOS simulator.
- [ ] Test on a physical iPhone.
- [ ] Complete App Privacy answers and provide the Privacy Policy URL.
- [ ] Prepare App Store screenshots and submit for review.
