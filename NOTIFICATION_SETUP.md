# Prayer Times Notification Setup

## Overview
This app now includes comprehensive prayer time notifications with Azan audio playback, offline support, and local database caching.

## Features Implemented

### 1. **Scheduled Azan Notifications**
- Automatic notifications at each of the 5 daily prayer times (Fajr, Dhuhr, Asr, Maghrib, Isha)
- Full-screen notifications with high priority
- Azan audio plays automatically when notification appears
- Action buttons: "Stop Azan" and "Mark as Prayed"

### 2. **Offline Support with SQLite Database**
- Prayer times for the next 30+ days cached locally
- Works completely offline once data is downloaded
- Automatic fallback to cached data when no internet
- Intelligent data management (removes old data automatically)

### 3. **Audio Playback**
- Uses `just_audio` package for reliable audio playback
- Azan audio file: `assets/audio/azan.mp3`
- Android: Audio copied to `res/raw/azan.mp3` for native notifications
- iOS: Background audio mode enabled

### 4. **Smart Data Management**
- Fetches current month + next month prayer times
- Stores in SQLite database with location coordinates
- Checks internet connectivity before fetching
- Falls back to local database when offline
- Auto-schedules notifications for all cached prayers

## Technical Implementation

### Packages Used
```yaml
awesome_notifications: ^0.9.3+1  # Advanced notification system
just_audio: ^0.9.40              # Audio playback
sqflite: ^2.4.1                  # Local database
path_provider: ^2.1.5            # File system paths
connectivity_plus: ^6.1.1        # Internet connectivity check
```

### Files Created/Modified

#### New Services
1. **`lib/services/notification_service.dart`**
   - Initializes Awesome Notifications
   - Schedules prayer notifications
   - Handles audio playback
   - Manages notification channels

2. **`lib/services/prayer_times_database.dart`**
   - SQLite database operations
   - CRUD operations for prayer times
   - Query methods for date ranges
   - Cleanup old data

#### Modified Files
1. **`lib/controller/prayer_times_controller.dart`**
   - Added offline/online detection
   - Integrated database caching
   - Auto-schedule notifications
   - Monthly data fetching

2. **`lib/model/prayer_times_model.dart`**
   - Added `fromDatabase` factory constructor
   - Added hijri month and year fields

3. **`lib/view/prayer_times_screen.dart`**
   - Added notification toggle button
   - Notification settings dialog
   - Offline indicator

4. **`lib/main.dart`**
   - Initialize notification service on app start

### Android Configuration

#### AndroidManifest.xml Permissions
```xml
<!-- Notification Permissions -->
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
```

#### Broadcast Receivers
```xml
<receiver android:name="me.carda.awesome_notifications.core.broadcasters.receivers.ScheduledNotificationReceiver"
    android:exported="false"
    android:enabled="true" />
    
<receiver android:name="me.carda.awesome_notifications.core.broadcasters.receivers.DismissedNotificationReceiver"
    android:exported="false"
    android:enabled="true" />
    
<receiver android:name="me.carda.awesome_notifications.core.broadcasters.receivers.KeepOnTopActionReceiver"
    android:exported="false"
    android:enabled="true" />
```

#### Audio File
- Location: `android/app/src/main/res/raw/azan.mp3`
- Used for notification sound

### iOS Configuration

#### Info.plist Background Modes
```xml
<key>UIBackgroundModes</key>
<array>
    <string>location</string>
    <string>audio</string>
    <string>fetch</string>
</array>
```

#### Notification Permission
```xml
<key>NSUserNotificationsUsageDescription</key>
<string>We need notifications to remind you of prayer times with Azan</string>
```

## Usage

### For Users

1. **Enable Notifications**
   - Tap the bell icon in the Prayer Times screen
   - Click "Enable" in the dialog
   - Grant permission when prompted

2. **Offline Mode**
   - App automatically downloads prayer times for 30+ days
   - Works completely offline after initial download
   - Shows "Offline mode" indicator when no internet

3. **Notification Actions**
   - **Stop Azan**: Stops the audio playback
   - **Mark as Prayed**: Dismisses notification (can be extended for tracking)

### For Developers

#### Schedule Notifications Manually
```dart
final controller = Get.find<PrayerTimesController>();
await controller.enableNotifications();
```

#### Check Notification Status
```dart
final isEnabled = await NotificationService.instance.areNotificationsEnabled();
```

#### Cancel All Notifications
```dart
await NotificationService.instance.cancelAllNotifications();
```

#### Access Database Directly
```dart
final db = PrayerTimesDatabase.instance;
final prayerTimes = await db.getPrayerTimes('12 October 2025', 31.5204, 74.3587);
```

## Database Schema

### Table: `prayer_times`
```sql
CREATE TABLE prayer_times (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT NOT NULL,
    fajr TEXT NOT NULL,
    sunrise TEXT NOT NULL,
    dhuhr TEXT NOT NULL,
    asr TEXT NOT NULL,
    maghrib TEXT NOT NULL,
    isha TEXT NOT NULL,
    hijri_date TEXT NOT NULL,
    hijri_month TEXT NOT NULL,
    hijri_year TEXT NOT NULL,
    latitude REAL NOT NULL,
    longitude REAL NOT NULL,
    location_name TEXT NOT NULL,
    UNIQUE(date, latitude, longitude)
)
```

## Notification Channels

### 1. Prayer Channel (`prayer_channel`)
- **Purpose**: Main prayer time notifications
- **Priority**: Maximum
- **Sound**: Azan audio
- **Vibration**: Enabled
- **LED**: White
- **Full Screen**: Yes (for Azan alerts)

### 2. Silent Channel (`silent_channel`)
- **Purpose**: Reminders without sound
- **Priority**: High
- **Sound**: Disabled
- **Vibration**: Disabled

## Flow Diagram

```
App Start
    ↓
Initialize NotificationService
    ↓
Check Location Permission
    ↓
Fetch Location
    ↓
Check Internet Connectivity
    ↓
┌─────────────┬─────────────┐
│   Online    │   Offline   │
└─────────────┴─────────────┘
    ↓               ↓
Fetch from API   Load from DB
    ↓               ↓
Save to DB      Display Data
    ↓               ↓
Schedule Notifications
    ↓
Update UI
```

## Troubleshooting

### Notifications Not Appearing
1. Check app notification permissions in device settings
2. Ensure "Do Not Disturb" is disabled
3. Verify notification channels are created (check debug logs)
4. For Android 12+, verify SCHEDULE_EXACT_ALARM permission

### Audio Not Playing
1. Check audio file exists at `assets/audio/azan.mp3`
2. Verify audio copied to `android/app/src/main/res/raw/`
3. Check device volume settings
4. Ensure notification channel has `playSound: true`

### Offline Mode Not Working
1. Ensure internet was available for initial download
2. Check database file exists
3. Verify location permissions granted
4. Check logs for database errors

### iOS Notifications
1. Ensure proper signing and provisioning
2. Test on physical device (simulator limitations)
3. Verify Info.plist configuration
4. Check iOS notification settings

## Testing

### Test Notification
```dart
// Test immediate notification
await NotificationService.instance.scheduleAzanNotification(
  id: 999,
  prayerName: 'Test',
  prayerTime: DateTime.now().add(Duration(seconds: 10)),
  locationName: 'Test Location',
);
```

### View Scheduled Notifications
```dart
final scheduled = await NotificationService.instance.getScheduledNotifications();
print('Total scheduled: ${scheduled.length}');
for (var notification in scheduled) {
  print('ID: ${notification.id}, Time: ${notification.schedule?.toMap()}');
}
```

### Database Query
```dart
final db = PrayerTimesDatabase.instance;
final upcoming = await db.getUpcomingPrayerTimes(
  DateTime.now(),
  31.5204,
  74.3587,
);
print('Upcoming prayers cached: ${upcoming.length}');
```

## Performance Optimizations

1. **Batch Database Operations**: Uses batch inserts for monthly data
2. **Lazy Loading**: Notifications scheduled only when needed
3. **Auto Cleanup**: Old prayer times deleted automatically
4. **Location Caching**: Reuses location data within app session
5. **Connectivity Check**: Avoids unnecessary API calls when offline

## Future Enhancements

- [ ] Prayer tracking (mark prayers as completed)
- [ ] Multiple Azan audio options
- [ ] Custom notification times (before prayer)
- [ ] Prayer statistics and history
- [ ] Qibla direction in notification
- [ ] Widget support for home screen
- [ ] Wear OS support
- [ ] Multiple location support

## Support

For issues or questions:
- Check the troubleshooting section above
- Review device notification settings
- Check app logs for errors
- Ensure all permissions are granted

## License

Part of Qibla Compass - Offline application.
