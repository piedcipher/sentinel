# Sentinel

Sentinel is a Flutter app for tracking time away from habits. It currently
includes separate trackers for cigarettes and fapping, with themed progress
levels, a live streak timer, and relapse and best-streak statistics.

## Features

- Swipe between the two habit trackers.
- See elapsed days, hours, minutes, and seconds, plus progress toward the next
  level.
- Browse the level milestones for each tracker.
- Record a relapse after confirmation. The current streak restarts, the best
  streak is retained, and the relapse count increases.
- Keep tracker data on the device using `shared_preferences`.

No account or network connection is needed. Removing the app's local data will
also remove its saved tracker history.

## Requirements

- Flutter SDK with a Dart SDK that satisfies the constraint in `pubspec.yaml`.
- A platform toolchain for the target you want to run (for example, Android
  Studio for Android or Xcode for iOS and macOS).

## Run locally

```sh
flutter pub get
flutter run
```

To choose a specific connected device or emulator, list available targets and
pass its ID:

```sh
flutter devices
flutter run -d <device-id>
```

## Tests

Run the Flutter test suite with:

```sh
flutter test
```

## Project structure

- `lib/main.dart` — app UI, habit definitions, streak calculations, and local
  persistence.
- `test/widget_test.dart` — widget test for both trackers.
- `pubspec.yaml` — SDK constraints and package dependencies.
