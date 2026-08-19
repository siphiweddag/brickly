# Brickly Break by Stratida

Brickly Break is an offline 8×8 block puzzle built with Flutter. Place the three
available pieces, complete rows or columns, chain clears for combo bonuses, and
beat your locally saved best score.

## Play

- Drag a piece onto the board, or tap a piece and then tap a highlighted cell.
- Complete a full row or column to clear it.
- Use all three tray pieces to receive a new set.
- The game ends when none of the available pieces can fit.

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
```

The debug Android package is generated at
`build/app/outputs/flutter-apk/app-debug.apk`.
