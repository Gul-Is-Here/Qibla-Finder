# 🚀 Quick Start Guide - Notification System

## For Users

### 1️⃣ Enable Notifications (First Time)
1. Open the app
2. Go to **Prayer Times** tab
3. Tap the **🔔 bell icon** at the top
4. Grant notification permissions when prompted
5. Done! You'll now receive Azan notifications

### 2️⃣ Customize Your Notifications
1. Tap the **🔔 bell icon** again
2. You'll see the **Notification Settings** page
3. Customize:
   - **Turn off Azan** if you want silent notifications
   - **Enable Silent Mode** for notifications without sound
   - **Adjust Volume** (0-100%)
   - **Disable specific prayers** you don't want notifications for
   - **Turn off vibration** if preferred

### 3️⃣ Test Your Settings
1. In Notification Settings
2. Tap the green **"Test"** button (bottom right)
3. Wait 5 seconds
4. You'll receive a test notification with Azan

### 4️⃣ Individual Prayer Control
- Toggle any prayer ON/OFF:
  - Fajr (Dawn)
  - Dhuhr (Noon)
  - Asr (Afternoon)
  - Maghrib (Sunset)
  - Isha (Night)

---

## For Developers

### Setup (One-Time)

#### 1. Install Packages
```bash
flutter pub get
```

#### 2. Configure Android
```bash
# Copy Azan audio to Android resources
mkdir -p android/app/src/main/res/raw
cp assets/audio/azan.mp3 android/app/src/main/res/raw/azan.mp3
```

Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
<uses-permission android:name="android.permission.VIBRATE" />
```

See `ANDROID_SETUP.md` for complete configuration.

#### 3. Build & Run
```bash
flutter clean
flutter pub get
flutter run
```

### Usage in Code

#### Initialize (Already done in main.dart)
```dart
await NotificationService.instance.initialize();
```

#### Schedule Notifications
```dart
final controller = Get.find<PrayerTimesController>();
await controller.fetchAndCacheMonthlyPrayerTimes();
```

#### Open Settings
```dart
Get.to(() => const NotificationSettingsScreen());
```

#### Check Status
```dart
final enabled = await NotificationService.instance.areNotificationsEnabled();
```

#### Schedule Single Prayer
```dart
await NotificationService.instance.scheduleAzanNotification(
  id: 12345,
  prayerName: 'Fajr',
  prayerTime: DateTime(2025, 10, 12, 5, 30),
  locationName: 'Lahore, Pakistan',
);
```

#### Cancel All Notifications
```dart
await NotificationService.instance.cancelAllNotifications();
```

### Database Operations

#### Insert Prayer Times
```dart
final db = PrayerTimesDatabase.instance;
await db.insertPrayerTimes(
  prayerTimes,
  latitude,
  longitude,
  locationName,
);
```

#### Get Cached Prayer Times
```dart
final prayerTimes = await db.getPrayerTimes(
  '12 October 2025',
  31.5204,
  74.3587,
);
```

#### Get Monthly Data
```dart
final monthlyTimes = await db.getMonthlyPrayerTimes(
  2025,
  10,
  31.5204,
  74.3587,
);
```

---

## Features at a Glance

| Feature | Status | Description |
|---------|--------|-------------|
| **Azan Notifications** | ✅ | Auto-play Azan at prayer time |
| **Silent Mode** | ✅ | Notifications without sound |
| **Individual Controls** | ✅ | Toggle each prayer separately |
| **Offline Support** | ✅ | Works without internet |
| **Volume Control** | ✅ | Adjust Azan volume |
| **Vibration** | ✅ | Optional vibration |
| **Test Feature** | ✅ | Test notifications anytime |
| **Monthly Caching** | ✅ | 60 days of prayer times |
| **Auto-Sync** | ✅ | Updates when online |
| **Beautiful UI** | ✅ | Modern Material Design |

---

## Common Use Cases

### Use Case 1: Enable All Notifications
```dart
// User taps notification icon
// System requests permissions
// Controller schedules all prayers
final controller = Get.find<PrayerTimesController>();
await controller.enableNotifications();
```

### Use Case 2: Silent Notifications Only
```dart
// User enables silent mode in settings
final settingsController = Get.find<NotificationSettingsController>();
await settingsController.toggleSilentMode(true);
// Azan will NOT play, only notification appears
```

### Use Case 3: Disable Fajr Notification
```dart
// User toggles Fajr off in settings
await settingsController.togglePrayer('Fajr', false);
// All other prayers continue, Fajr is skipped
```

### Use Case 4: Offline Usage
```dart
// Internet is OFF
// App checks connectivity
// Loads prayer times from SQLite
// Shows "Offline mode" indicator
// Notifications still work from cached data
```

### Use Case 5: Change Location
```dart
// User moves to new city
// App detects location change
// Fetches new prayer times
// Updates database
// Reschedules all notifications
```

---

## Notification Actions

When notification appears, user can:
- **Stop Azan**: Stops audio immediately
- **Mark as Prayed**: Dismisses notification
- **Dismiss**: Removes notification

---

## Permissions Needed

### Android
- ✅ POST_NOTIFICATIONS (Android 13+)
- ✅ SCHEDULE_EXACT_ALARM
- ✅ VIBRATE
- ✅ WAKE_LOCK
- ✅ RECEIVE_BOOT_COMPLETED

### iOS
- ✅ Local Notifications
- ✅ Background Audio

---

## Troubleshooting

### Issue: Notifications not appearing
**Solution**: 
1. Check app has notification permission
2. Verify notifications enabled in settings
3. Test with "Test" button

### Issue: Azan not playing
**Solution**:
1. Verify azan.mp3 exists in assets
2. Check volume not at 0%
3. Ensure not in silent mode
4. Test audio file separately

### Issue: Works online but not offline
**Solution**:
1. Ensure app was online at least once
2. Check database has cached data
3. Verify location permissions granted

---

## Performance Tips

1. **Battery Optimization**: Disable battery optimization for the app
2. **Background Restrictions**: Allow background data
3. **Auto-Start**: Enable auto-start on boot
4. **Do Not Disturb**: Configure DND exceptions

---

## Files Reference

| File | Purpose |
|------|---------|
| `notification_service.dart` | Handles all notifications |
| `prayer_times_database.dart` | SQLite operations |
| `notification_settings_controller.dart` | Settings management |
| `notification_settings_screen.dart` | Settings UI |

---

## API Reference

### NotificationService
- `initialize()` - Setup notification system
- `scheduleAzanNotification()` - Schedule single prayer
- `scheduleMonthlyPrayers()` - Schedule multiple prayers
- `cancelAllNotifications()` - Clear all
- `areNotificationsEnabled()` - Check status

### PrayerTimesDatabase
- `insertPrayerTimes()` - Save single day
- `insertMultiplePrayerTimes()` - Save multiple days
- `getPrayerTimes()` - Get specific date
- `getMonthlyPrayerTimes()` - Get month
- `deleteOldPrayerTimes()` - Cleanup

---

## Support

- 📖 Full Docs: `NOTIFICATION_SYSTEM_DOCS.md`
- 🔧 Setup Guide: `ANDROID_SETUP.md`
- 📊 Summary: `IMPLEMENTATION_SUMMARY.md`

---

**Happy Coding! 🎉**
