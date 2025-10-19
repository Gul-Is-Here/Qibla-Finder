# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2025-10-17

### Added
- Material Design 3 UI implementation
- Core architecture with config, theme, and utilities
- Logger utility for better debugging
- Centralized app configuration
- Comprehensive project documentation
- Development guidelines and contributing guide
- Project structure documentation
- Organized folder structure following Flutter best practices

### Changed
- Restructured project folders (controller → controllers, view → views, etc.)
- Moved theme configuration to dedicated file
- Updated main.dart to use centralized theme and config
- Improved code organization and maintainability
- Enhanced .gitignore with comprehensive exclusions

### Fixed
- Removed misplaced image file from services folder
- Fixed deprecated Material API usage (MaterialState → WidgetState)
- Fixed deprecated color API usage (withOpacity → withValues)
- Replaced print statements with Logger utility

### Improved
- Better separation of concerns
- More maintainable codebase
- Clearer project structure
- Enhanced developer experience

## [1.x.x] - Previous Versions

### Features
- Qibla direction finder with compass
- Prayer times calculation and display
- Quran reader with audio playback
- Prayer time notifications
- Offline support
- Google Ads integration
- In-app updates
- Location services
- Audio playback with background support
- Customizable notification settings
- Multiple prayer time calculation methods
- Shimmer loading effects
- Network connectivity monitoring
- Performance optimizations

---

## Version History

### Version Format
- **Major.Minor.Patch+BuildNumber**
- Example: 2.0.0+9

### Release Types
- **Major**: Breaking changes, major new features
- **Minor**: New features, backwards compatible
- **Patch**: Bug fixes, small improvements
- **Build**: Internal build number for stores

## Upcoming Features

### Planned for 2.1.0
- [ ] Multiple language support
- [ ] Custom themes
- [ ] Widget support
- [ ] Quran translations
- [ ] Tafsir integration
- [ ] Hijri calendar
- [ ] Qibla finder improvements

### Under Consideration
- [ ] Apple Watch support
- [ ] Wear OS support
- [ ] Tablet optimization
- [ ] Dark/Light theme toggle
- [ ] Prayer time calculation method selection
- [ ] Custom notification sounds
- [ ] Backup and restore settings
- [ ] Social sharing features

## Migration Guides

### Migrating to 2.0.0

#### Import Path Changes
If you have custom code, update imports:
```dart
// Old
import 'package:qibla_compass_offline/controller/qibla_controller.dart';
import 'package:qibla_compass_offline/view/home_screen.dart';
import 'package:qibla_compass_offline/widget/compass_widget.dart';
import 'package:qibla_compass_offline/model/location_model.dart';

// New
import 'package:qibla_compass_offline/controllers/qibla_controller.dart';
import 'package:qibla_compass_offline/views/home_screen.dart';
import 'package:qibla_compass_offline/widgets/compass_widget.dart';
import 'package:qibla_compass_offline/models/location_model.dart';
```

#### Theme Usage
```dart
// Old
theme: ThemeData(...)

// New
import 'package:qibla_compass_offline/core/theme/app_theme.dart';
theme: AppTheme.darkTheme
```

#### Logging
```dart
// Old
print('Debug message');

// New
import 'package:qibla_compass_offline/core/utils/logger.dart';
Logger.log('Debug message');
Logger.error('Error message', error: e);
```

## Support

For issues or questions about specific versions:
1. Check the documentation
2. Review closed issues
3. Open a new issue with version information

---

**Note**: This changelog is maintained manually. Please update it with each release.
