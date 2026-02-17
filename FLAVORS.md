# SendMe Outlet - Flavor Configuration

This app uses the same flavor/white-label system as the SendMe customer app. Each flavor represents a different platform (SendMe, SendMe6, Eatoz, etc.) with its own package name, app name, and configuration.

**No dart-define needed** – the correct config is detected automatically from the app's package/bundle ID at runtime.

## Available Flavors

| Flavor | Package ID |
|--------|------------|
| sendme | today.sendme.outlet |
| sendme6 | today.sendme6app.outlet |
| eatoz | com.eatozfood_outlet |
| sendmelebanon | today.sendmelebanondev.outlet |
| sendmetalabetak | today.talabetak.outlet |
| sendmeshrirampur | today.sendmeshrirampur.outlet |
| tyeb | today.tyeb.outlet |
| hopshop | today.hopshop.outlet |
| sendmetest | today.sendmetest.outlet |

## Run Commands

You only need to pass `--flavor`:

```bash
flutter run --flavor sendme
flutter run --flavor sendme6
flutter run --flavor eatoz -d <device_id>
```

## Build Commands

```bash
flutter build apk --flavor sendme
flutter build apk --release --flavor sendme6

# iOS (requires Xcode schemes for each flavor)
flutter build ios --flavor sendme
```

## Adding Firebase

For flavors that need Firebase, add `google-services.json` in:
```
android/app/src/<flavor>/google-services.json
```

And add the Google Services plugin in `android/app/build.gradle.kts` when ready.
