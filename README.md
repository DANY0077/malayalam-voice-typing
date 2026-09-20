# Malayalam Voice Typing

AI-powered voice typing app for Malayalam that turns natural speech into clean, properly punctuated, and formatted text.

## Features

- 🎤 **Real-time speech recognition** for Malayalam (ml-IN)
- 📝 **Auto punctuation** - adds periods, commas automatically
- 🔤 **Auto capitalization** - capitalizes sentence beginnings
- 📋 **Copy to clipboard** - one tap to copy text
- 📤 **Share text** - share directly to other apps
- 🕐 **History** - keeps recent transcriptions
- 🌙 **Dark mode** support
- 📱 **Works offline** (uses on-device speech recognition)

## Supported Languages

- Malayalam (ml-IN) - Primary
- English (en-IN)
- Hindi (hi-IN)
- Tamil (ta-IN)
- Kannada (kn-IN)
- Telugu (te-IN)

## Building for iOS (No Mac Required)

Since you don't have Xcode/Mac access, use **Codemagic** or **GitHub Actions** for cloud builds:

### Option 1: Codemagic (Recommended)

1. Push this repo to GitHub
2. Go to [codemagic.io](https://codemagic.io) and connect your repo
3. It will auto-detect the `codemagic.yaml` config
4. Add your App Store Connect API keys in Codemagic settings
5. Build! Download IPA from artifacts

### Option 2: GitHub Actions

1. Push to GitHub
2. Go to Actions tab → "iOS Build" workflow
3. Click "Run workflow" → select "release"
4. Download IPA from artifacts when done

### Option 3: Local Build (if you get Mac access)

```bash
flutter build ios --release
```

## Building for Android

```bash
flutter build apk --release
flutter build appbundle --release
```

## Development Setup

```bash
# Install dependencies
flutter pub get

# Run code generation
flutter packages pub run build_runner build --delete-conflicting-outputs

# Run on device/emulator
flutter run
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── src/
│   ├── models/
│   │   └── app_state.dart    # State management
│   ├── services/
│   │   ├── speech_service.dart  # Speech recognition
│   │   └── storage_service.dart # Local storage
│   ├── widgets/
│   │   ├── language_selector.dart
│   │   ├── text_display.dart
│   │   ├── control_buttons.dart
│   │   └── history_panel.dart
│   ├── screens/
│   │   └── home_screen.dart
│   └── utils/
│       └── constants.dart
```

## iOS Permissions Required

The app requests these permissions (configured in `ios/Runner/Info.plist`):
- Microphone access
- Speech recognition

## Tech Stack

- **Flutter** 3.22+
- **speech_to_text** - On-device speech recognition
- **provider** - State management
- **shared_preferences** - Local storage

## Notes

- This is a **standalone app**, not a system keyboard extension
- iOS keyboard extensions require Mac + Xcode to build
- The app copies text to clipboard for pasting anywhere
- For system-wide keyboard, you'd need a Mac for the extension target

## License

MIT