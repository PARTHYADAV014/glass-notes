# Glass Notes

A production-ready, fully offline Flutter notes app with an iOS-style "Liquid Glass" UI. Built with Riverpod, Hive, flutter_animate, uuid and google_fonts. Min SDK 21.

## Features

- Full-screen animated gradient wallpaper (Ocean / Sunset / Forest / Rose, light + dark)
- Frosted glass note cards: blur 18, translucent white gradient, 24px corners, moving water shine
- Swipe right to pin/unpin, swipe left to archive with an Undo snackbar
- Archive view (archive icon in the app bar)
- Note editor with 600 ms debounced auto-save, pin and delete with confirmation
- Settings sheet for dark mode and wallpaper; all preferences stored locally in Hive
- No backend, no login, no account, no required network access

## Setup

```bash
cd glass_notes
python3 scripts/bootstrap_android.py
flutter pub get
flutter analyze
```

`bootstrap_android.py` runs `flutter create --platforms=android` if the platform folder is missing and pins `minSdk` to 21 in the generated Gradle file (works with both Groovy and Kotlin DSL templates). This is needed because the Gradle wrapper JAR is binary and is not checked into this repository.

No `build_runner` step is required — the Hive adapter in `lib/features/notes/data/note_model.g.dart` is hand-written and registered in `main.dart`.

## Run and build

```bash
flutter run
flutter build apk --debug                       # quick test build
flutter build apk --release                     # app-release.apk
flutter build apk --split-per-abi --release     # smaller per-architecture APKs
```

APK output: `build/app/outputs/flutter-apk/`.

`minSdk` 21 is applied by `scripts/bootstrap_android.py`.

### Performance check (60 fps)

Run on a physical device and confirm there is no jank on the home list:

```bash
flutter run --profile
flutter run --profile --trace-skia
```

In DevTools → Performance, the raster/UI thread should stay near 16 ms per frame while scrolling the glass cards. BackdropFilter is only created for visible cards (ListView.builder) and each card is wrapped in a RepaintBoundary; the blur filter is cached once in `kGlassBlur`.

### App launcher icon

1. Add a 1024×1024 PNG at `assets/icon/app_icon.png`.
2. Add to `pubspec.yaml` (dev_dependencies):

```yaml
dev_dependencies:
  flutter_launcher_icons: ^0.14.1
flutter_launcher_icons:
  android: true
  ios: false
  image_path: "assets/icon/app_icon.png"
  adaptive_icon_background: "#1B2340"
```

3. Run:

```bash
flutter pub get
flutter pub run flutter_launcher_icons
```

### Build on GitHub Actions (no Flutter SDK needed locally)

Push to `main`/`master` and `.github/workflows/build.yml` builds the release APK and uploads it as the `glass-notes-apk` artifact. Push a `v*` tag to publish the APK on a GitHub Release. Download the artifact on your phone and tap it to install (enable "Install unknown apps" for your browser/file manager).

## Notes

- Fonts use `google_fonts` (Inter). If the device is offline, Flutter falls back to the system font — all app functionality remains fully offline.
- Blur is capped at sigma 18 and the shine opacity at 0.15 to keep rendering smooth on mid-range phones.
- Notes live in the Hive box `notes`; preferences live in the Hive box `settings`.

## Project structure

```
lib/
  main.dart
  app.dart
  core/
    theme/app_theme.dart
    constants/wallpapers.dart
  features/notes/
    data/note_model.dart
    data/note_model.g.dart
    data/notes_repository.dart
    providers/notes_provider.dart
    presentation/home_screen.dart
    presentation/note_detail_screen.dart
    presentation/widgets/glass_card.dart
    presentation/widgets/water_shine.dart
    presentation/widgets/note_tile.dart
    presentation/widgets/animated_wallpaper.dart
  features/settings/settings_sheet.dart
```
