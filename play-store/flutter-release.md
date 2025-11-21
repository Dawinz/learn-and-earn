# Flutter Release Build (AAB)

## Prerequisites
- Ensure your Flutter version matches CI/local target: `flutter --version`
- Android SDK installed; `sdk.dir` set in `android/local.properties`
- Versioning updated in `pubspec.yaml` (e.g., `version: 1.2.0+12`)

## Build commands
```bash
flutter clean
flutter pub get
flutter build appbundle --release --target-platform=android-arm,android-arm64,android-x64
```

The AAB will be at `build/app/outputs/bundle/release/app-release.aab`.

## Proguard/R8 (optional)
If using minify, ensure `proguard-rules.pro` is configured and keep rules for Flutter, plugins, and reflection.

## Post-build
- Verify `versionCode` increased
- Upload AAB to internal testing in Play Console
- Fill release notes (`release-notes.md`)
