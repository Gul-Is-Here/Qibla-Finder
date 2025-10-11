# Prayer Times Feature

## Overview
A comprehensive prayer times feature integrated with the Qibla Compass app, providing accurate Islamic prayer times based on user location.

## Features

### ✅ Implemented Features

1. **Real-time Prayer Times**
   - Displays all 5 daily prayers (Fajr, Dhuhr, Asr, Maghrib, Isha)
   - Shows sunrise time
   - Uses Aladhan API for accurate calculations

2. **Location-Based**
   - Automatic location detection
   - Shows prayer times for current location
   - Displays coordinates

3. **Date Navigation**
   - Previous/Next day navigation
   - Date picker for selecting specific dates
   - "Go to Today" functionality
   - Shows both Gregorian and Hijri dates

4. **Next Prayer Indicator**
   - Highlights the upcoming prayer
   - Shows countdown timer
   - Prominent display in header card

5. **Modern UI Design**
   - Gradient app bar with flexible space
   - Card-based layout
   - Custom icons for each prayer
   - Pull-to-refresh functionality
   - Smooth animations

6. **Bottom Navigation**
   - Three tabs: Qibla, Prayer Times, Settings
   - Modern Material Design
   - Smooth tab switching

7. **Offline Support**
   - Caches prayer times locally
   - Works without internet after initial load

## API Integration

### Aladhan Prayer Times API
- **Base URL**: `http://api.aladhan.com/v1`
- **Endpoints Used**:
  - `/timings/{timestamp}` - Get prayer times for specific date
  - `/calendar/{year}/{month}` - Get monthly prayer times
- **Method**: Islamic Society of North America (ISNA) - Method 2

## File Structure

```
lib/
├── model/
│   └── prayer_times_model.dart       # Prayer times data model
├── services/
│   └── prayer_times_service.dart     # API service layer
├── controller/
│   └── prayer_times_controller.dart  # State management
├── view/
│   ├── prayer_times_screen.dart      # Main prayer times UI
│   └── main_navigation_screen.dart   # Bottom navigation
└── routes/
    └── app_pages.dart                # Route configuration
```

## Dependencies Added

```yaml
dependencies:
  http: ^1.1.0      # For API calls
  intl: ^0.19.0     # For date formatting
```

## Usage

### Basic Usage

The app automatically loads prayer times on startup:

1. App requests location permission
2. Fetches prayer times from API
3. Caches data locally
4. Displays times with next prayer highlighted

### Date Navigation

- Tap the date to open date picker
- Use arrow buttons for next/previous day
- Pull down to refresh

### Features to Enhance

1. **Notifications**
   - Add prayer time notifications
   - Reminder before prayer time
   - Customizable notification sounds

2. **Customization**
   - Multiple calculation methods
   - Custom prayer time adjustments
   - Different madhabs for Asr time

3. **Additional Features**
   - Qiyam time calculation
   - Monthly calendar view
   - Prayer tracking/logging
   - Qibla direction integration

## Color Scheme

- Primary: `#00332F` (Dark Green)
- Secondary: `#8BC34A` (Light Green)
- Accent: `#00695C` (Medium Green)
- Background: `#004D40` (Deep Green)

## API Response Example

```json
{
  "data": {
    "timings": {
      "Fajr": "05:30",
      "Sunrise": "06:45",
      "Dhuhr": "12:15",
      "Asr": "15:30",
      "Maghrib": "17:45",
      "Isha": "19:00"
    },
    "date": {
      "gregorian": {
        "day": "11",
        "month": {"en": "October"},
        "year": "2025"
      },
      "hijri": {
        "day": "18",
        "month": {"en": "Rabi' al-awwal"},
        "year": "1447"
      }
    }
  }
}
```

## Testing

Test the feature with:

```bash
flutter run
```

Navigate to the Prayer Times tab to see:
- Current prayer times
- Next prayer countdown
- Date navigation
- Pull-to-refresh

## Credits

- **API**: [Aladhan Prayer Times API](https://aladhan.com/prayer-times-api)
- **Design**: Custom Material Design implementation
- **Icons**: Material Icons with custom prayer-specific selections
