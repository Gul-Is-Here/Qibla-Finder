# Qibla Compass Offline

A comprehensive Flutter application for Muslims to find Qibla direction, view prayer times, and read the Quran - all with offline support.

## Features

### 🧭 Qibla Direction
- Real-time compass with accurate Qibla direction
- Works completely offline using device sensors
- Beautiful animations and visual indicators
- Optimized performance for smooth rotation

### 🕌 Prayer Times
- Automatic calculation based on your location
- Support for multiple calculation methods
- Local database caching for offline access
- Customizable prayer time notifications
- Azan audio playback

### 📖 Quran Reader
- Complete Quran text
- Audio playback with background support
- Bookmark and progress tracking
- Smooth reading experience

### 🔔 Smart Notifications
- Prayer time reminders
- Customizable notification settings
- Background notification support
- Azan audio notifications

### 🎯 Additional Features
- Offline-first architecture
- Google Ads integration
- Automatic app updates (Play Store)
- Network connectivity monitoring
- Performance optimized for all devices
- Material Design 3 UI

## Screenshots

[Add screenshots here]

## Getting Started

### Prerequisites
- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / VS Code
- Android SDK (for Android builds)
- Xcode (for iOS builds, macOS only)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/qibla_compass_offline.git
cd qibla_compass_offline
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Build Release

For Android:
```bash
./build_release.sh
```

Or manually:
```bash
flutter build apk --release
flutter build appbundle --release
```

For iOS:
```bash
flutter build ios --release
```

## Project Structure

See [PROJECT_STRUCTURE.md](PROJECT_STRUCTURE.md) for detailed information about the project architecture and organization.

## Configuration

### Google Ads
Update your AdMob App ID in:
- Android: `android/app/src/main/AndroidManifest.xml`
- iOS: `ios/Runner/Info.plist`

### Notifications
Notification channels are configured in `lib/services/notification_service.dart`

### Prayer Time Calculation
Calculation methods can be configured in `lib/services/prayer_times_service.dart`

## Technologies Used

- **Framework**: Flutter
- **State Management**: GetX
- **Local Storage**: GetStorage, SQLite
- **Sensors**: Flutter Compass, Geolocator
- **Audio**: Just Audio, Audio Service
- **Notifications**: Awesome Notifications
- **Ads**: Google Mobile Ads
- **UI**: Material Design 3, Google Fonts

## Permissions

### Android
- Location (for Qibla direction and prayer times)
- Internet (for updates and ads)
- Vibration (for haptic feedback)
- Wake Lock (for notifications)
- Foreground Service (for audio playback)

### iOS
- Location (for Qibla direction and prayer times)
- Notifications (for prayer time alerts)

## Performance Optimization

- Lazy loading for heavy widgets
- Image and data caching
- Database indexing
- Background service optimization
- Memory leak prevention
- Optimized compass calculations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Development Guidelines

- Follow the project structure defined in PROJECT_STRUCTURE.md
- Use GetX for state management
- Write clean, documented code
- Test on both Android and iOS
- Optimize for performance
- Use the Logger utility instead of print statements

## Troubleshooting

### Common Issues

**Compass not working:**
- Ensure location permissions are granted
- Check if device has magnetometer sensor
- Calibrate device compass

**Prayer times not showing:**
- Grant location permissions
- Check internet connectivity for first-time setup
- Verify location services are enabled

**Notifications not working:**
- Grant notification permissions
- Check notification settings in app
- Verify battery optimization is disabled

## License

This project is private and not published to pub.dev.

## Support

For support, email [your-email@example.com] or open an issue in the repository.

## Acknowledgments

- Prayer time calculation algorithms
- Qibla direction calculation methods
- Open source Flutter community
- All package contributors

## Version History

- **2.0.0** - Current version
  - Material Design 3 UI
  - Performance optimizations
  - Enhanced offline support
  - Improved notification system

---

Made with ❤️ for the Muslim community
