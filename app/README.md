# BeepBridge Mobile App

Flutter app that scans barcodes/QR codes and sends them to your BeepBridge desktop server via HTTP.

## Setup

1. **Create the Flutter project scaffolding** (only needed once):

```bash
flutter create --org cc.diegocancela --project-name beepbridge .
```

Run this inside the `app/` directory. It generates the `android/`, `ios/`, `web/` folders without overwriting existing `lib/` or `pubspec.yaml`.

2. **Install dependencies**:

```bash
flutter pub get
```

3. **Android configuration**:

Set `minSdkVersion` in `android/app/build.gradle`:

```groovy
defaultConfig {
    minSdkVersion 21
    // ...
}
```

Add the AdMob app ID to `android/app/src/main/AndroidManifest.xml` inside `<application>`:

```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713"/>
```

The test app ID above is from Google's documentation. Replace it with your real ID before publishing.

4. **Run**:

```bash
flutter run
```

## Building for release

```bash
flutter build appbundle
```

The AAB file will be at `build/app/outputs/bundle/release/app-release.aab`.

## Architecture

- `lib/screens/scanner_screen.dart` — Main camera screen with overlay, controls, and flash feedback
- `lib/screens/settings_screen.dart` — Server URL configuration and connection testing
- `lib/services/scanner_service.dart` — Wraps MobileScannerController with 1.5s debounce
- `lib/services/webhook_service.dart` — HTTP POST to `/scan` and GET `/health`
- `lib/widgets/ad_banner.dart` — AdMob banner (hidden when `ads_removed` pref is true)
- `lib/widgets/scan_history.dart` — Bottom sheet showing last 10 scans with manual send
- `lib/models/scan_entry.dart` — Data model for a scan entry

## Notes

- AdMob uses Google test IDs. Replace with real IDs and the real app ID before release.
- In-app purchase for ad removal is stubbed via the `ads_removed` shared preference flag.
- Camera permission is requested automatically by the `mobile_scanner` package.
