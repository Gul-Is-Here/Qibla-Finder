# Qibla Compass - Project Structure

## Overview
This is a Flutter application for finding Qibla direction with prayer times, Quran reading, and notifications.

## Architecture
- **Pattern**: GetX (State Management + Dependency Injection + Routing)
- **Language**: Dart 3.8.1+
- **Framework**: Flutter

## Folder Structure

```
lib/
├── core/                          # Core functionality shared across features
│   ├── config/                    # App configuration
│   │   └── app_config.dart       # App-level constants and feature flags
│   ├── theme/                     # Theme configuration
│   │   └── app_theme.dart        # App theme and colors
│   └── utils/                     # Core utilities
│       └── logger.dart           # Logging utility
│
├── constants/                     # App constants
│   ├── app_constants.dart        # General constants
│   └── strings.dart              # String constants
│
├── models/                        # Data models
│   ├── location_model.dart       # Location data model
│   ├── prayer_times_model.dart   # Prayer times data model
│   └── quran_model.dart          # Quran data model
│
├── controllers/                   # GetX Controllers (Business Logic)
│   ├── notification_settings_controller.dart
│   ├── optimized_qibla_controller.dart
│   ├── prayer_times_controller.dart
│   ├── qibla_controller.dart
│   └── quran_controller.dart
│
├── services/                      # Services (API, Database, etc.)
│   ├── ad_service.dart           # Google Ads integration
│   ├── app_update_service.dart   # In-app updates
│   ├── connectivity_service.dart # Network connectivity
│   ├── location_service.dart     # Location services
│   ├── notification_service.dart # Push notifications
│   ├── performance_service.dart  # Performance monitoring
│   ├── prayer_times_database.dart # Local database for prayer times
│   ├── prayer_times_service.dart # Prayer times calculation
│   ├── quran_audio_handler.dart  # Audio playback
│   └── quran_service.dart        # Quran data service
│
├── views/                         # UI Screens
│   ├── about_screen.dart
│   ├── feedback_screen.dart
│   ├── home_screen.dart
│   ├── main_navigation_screen.dart
│   ├── notification_settings_screen.dart
│   ├── notification_test_screen.dart
│   ├── optimized_home_screen.dart
│   ├── prayer_times_screen.dart
│   ├── quran_list_screen.dart
│   ├── quran_reader_screen.dart
│   ├── settings_screen.dart
│   └── splash_screen.dart
│
├── widgets/                       # Reusable widgets
│   ├── compass_widget.dart
│   ├── customized_drawer.dart
│   ├── drawer_item.dart
│   ├── optimized_banner_ad.dart
│   ├── shimmer_loading_widgets.dart
│   └── simple_compass_widget.dart
│
├── routes/                        # App routing
│   └── app_pages.dart            # Route definitions
│
├── bindings/                      # GetX Bindings (Dependency Injection)
│   └── qibla_binding.dart        # Initial bindings
│
├── utils/                         # Utility functions
│   └── qibla_calculator.dart     # Qibla direction calculations
│
└── main.dart                      # App entry point
```

## Key Features

### 1. Qibla Direction
- Real-time compass with Qibla direction
- Offline calculation using device sensors
- Visual indicators and animations

### 2. Prayer Times
- Automatic prayer time calculation based on location
- Local database caching
- Prayer time notifications
- Multiple calculation methods

### 3. Quran Reader
- Quran text display
- Audio playback with background support
- Bookmark and progress tracking

### 4. Notifications
- Prayer time reminders
- Customizable notification settings
- Background notification support

### 5. Additional Features
- Google Ads integration
- In-app updates
- Offline support
- Performance optimization
- Network connectivity monitoring

## Dependencies

### Core
- `get`: State management, routing, and dependency injection
- `get_storage`: Local storage
- `geolocator`: Location services
- `geocoding`: Reverse geocoding

### UI/UX
- `google_fonts`: Custom fonts
- `flutter_animate`: Animations
- `shimmer`: Loading effects
- `velocity_x`: UI utilities

### Sensors & Hardware
- `flutter_compass`: Compass sensor
- `vibration`: Haptic feedback

### Media
- `just_audio`: Audio playback
- `audio_service`: Background audio
- `audio_session`: Audio session management

### Networking
- `http`: HTTP requests
- `connectivity_plus`: Network status
- `internet_connection_checker`: Internet connectivity

### Monetization
- `google_mobile_ads`: Google Ads

### Storage
- `sqflite`: Local database
- `path_provider`: File system paths
- `cached_network_image`: Image caching
- `flutter_cache_manager`: Cache management

### Notifications
- `awesome_notifications`: Rich notifications

### Updates
- `in_app_update`: Play Store in-app updates

## Development Guidelines

### Code Organization
1. Follow feature-based organization for scalability
2. Keep business logic in controllers
3. Keep UI code in views
4. Use services for external integrations
5. Use models for data structures

### Naming Conventions
- Files: `snake_case.dart`
- Classes: `PascalCase`
- Variables/Functions: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE` or `camelCase` for private

### State Management
- Use GetX controllers for state management
- Use GetX bindings for dependency injection
- Use GetX routing for navigation

### Best Practices
1. Always handle errors gracefully
2. Use const constructors where possible
3. Implement proper loading states
4. Cache data for offline support
5. Optimize performance for low-end devices
6. Use logger instead of print statements
7. Follow Material Design 3 guidelines

## Build & Release

### Debug Build
```bash
flutter run
```

### Release Build
```bash
./build_release.sh
```

### Version Management
Update version in `pubspec.yaml`:
```yaml
version: 2.0.0+9  # version+buildNumber
```

## Testing
```bash
flutter test
```

## Performance Optimization
- Lazy loading for heavy widgets
- Image caching
- Database indexing
- Background service optimization
- Memory leak prevention

## Platform Support
- ✅ Android
- ✅ iOS
- ⚠️ Web (Limited sensor support)
- ⚠️ Windows (Limited sensor support)
- ⚠️ Linux (Limited sensor support)
- ⚠️ macOS (Limited sensor support)

## License
Private - Not published to pub.dev
