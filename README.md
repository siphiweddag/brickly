# Brickly Break by Stratida

Brickly Break is an offline Flutter block-matching game. Players drag pieces
onto an 8×8 board, complete horizontal rows, and keep the stack away from the
top. Cleared rows break repeatedly while matches remain; gravity only applies
after a break.

## Game modes

- **Brickly Journey:** 50 progressively harder levels with line targets,
  par-move goals, star ratings, unlocks, and locally saved progress.
- **Endless Classic:** an open-ended high-score mode using the same placement,
  clearing, cascade, and game-over rules.

The first launch includes a five-step tutorial. It can be replayed from
Settings, where players can also control sound, haptics, and the placement
guide.

## Run locally

```sh
flutter pub get
flutter run
```

## Quality checks

```sh
flutter analyze
flutter test
flutter build apk --debug
flutter build appbundle --release
```

The release bundle is intentionally unsigned until a private Stratida upload
keystore is configured in `android/key.properties`. Copy
`android/key.properties.example`, fill it with local secret values, and never
commit the completed file or keystore.

## Release resources

- Store listing and Data Safety draft: `store/`
- Store artwork and screenshots: `store/assets/`
- Release checklist: `store/release-checklist.md`
- Legal and ownership links: `LEGAL.md`

Privacy Policy: <https://stratida.com/privacy-policy/>

Terms of Service: <https://stratida.com/terms-of-service/>

Support: <hello@stratida.com>

© 2026 Stratida. All rights reserved.
