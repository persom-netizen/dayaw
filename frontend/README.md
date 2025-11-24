# Dayaw Frontend

A Flutter application for learning Filipino language and culture, featuring Baybayin (ancient Filipino script) writing practice, word of the day, historical trivia, and AI-powered chat.

## Quick Start

### Prerequisites
- Flutter SDK (3.9.2 or higher)
- Dart SDK
- Android Studio or VS Code with Flutter extensions
- For Android device testing: USB debugging enabled on your device

### Installation

1. Install dependencies:
```bash
flutter pub get
```

2. Run the app:
```bash
# For web/desktop
flutter run

# For Android device
flutter run -d <device-id>
```

## API Configuration

The app connects to a Flask backend server. The API endpoint is configured in:
**`lib/config/app_config.dart`**

### For Web/Emulator Testing:
```dart
static const String apiBaseUrl = 'http://localhost:5000';
```

### For Real Android Device Testing:
```dart
static const String apiBaseUrl = 'http://YOUR_COMPUTER_IP:5000';
```

Replace `YOUR_COMPUTER_IP` with your development machine's local network IP address.

**📖 For detailed instructions on Android device testing, see:** [ANDROID_DEVICE_TESTING.md](../ANDROID_DEVICE_TESTING.md) in the root directory.

### Finding Your Computer's IP Address:

**Windows:**
```bash
ipconfig
```
Look for "IPv4 Address"

**Mac/Linux:**
```bash
ifconfig | grep "inet " | grep -v 127.0.0.1
```

## Project Structure

```
lib/
├── config/
│   └── app_config.dart          # API configuration
├── services/
│   ├── api_service.dart         # Main API service
│   ├── sulatin_api.dart         # Baybayin handwriting API
│   └── ...
├── screens/                     # UI screens
├── models/                      # Data models
├── providers/                   # State management
└── main.dart                    # App entry point
```

## Key Features

- **Salita**: Word of the day in Filipino
- **Alaala**: Daily historical trivia
- **Sulatin**: Baybayin handwriting practice with ML recognition
- **AI Chat**: Filipino language learning assistant
- **Practice**: Interactive lessons and quizzes

## Development

### Running in Development Mode

1. Start the backend server (in the `backend` directory):
```bash
cd ../backend
python app.py
```

2. Start the Flutter app:
```bash
flutter run
```

### Building for Production

```bash
# Android APK
flutter build apk

# Android App Bundle (for Play Store)
flutter build appbundle

# Web
flutter build web
```

## Troubleshooting

### Connection Issues on Android Device

1. **Ensure both devices are on the same Wi-Fi network**
2. **Update `app_config.dart`** with your computer's IP
3. **Check firewall settings** - Allow port 5000
4. **Verify backend is running** on `0.0.0.0:5000`
5. **Test in browser** - Visit `http://YOUR_IP:5000/api/db-ping` from your device

For more detailed troubleshooting, see [ANDROID_DEVICE_TESTING.md](../ANDROID_DEVICE_TESTING.md).

## Resources

- [Flutter Documentation](https://docs.flutter.dev/)
- [Dart Documentation](https://dart.dev/guides)
- [Project Wiki](https://github.com/persom-netizen/dayaw/wiki) (if available)

## License

[Add license information here]
