# Azan Sound Fix Documentation

## Issue

Azan sound was not playing when prayer time notifications were triggered.

## Root Cause

The notification channel configuration was missing critical properties for alarm-style notifications with custom sounds.

## Changes Made

### 1. **NotificationChannel Configuration** (`notification_service.dart`)

#### Updated Prayer Channel Properties:

```dart
NotificationChannel(
  channelKey: 'prayer_channel',
  channelName: 'Prayer Times',
  channelDescription: 'Notifications for prayer times with Azan',
  defaultColor: const Color(0xFFAB80FF),
  ledColor: Colors.white,
  importance: NotificationImportance.Max,
  channelShowBadge: true,
  playSound: true,
  enableVibration: true,
  soundSource: 'resource://raw/azan',
  enableLights: true,
  locked: false,
  onlyAlertOnce: false,
  defaultRingtoneType: DefaultRingtoneType.Alarm, // NEW: Ensures alarm volume
  criticalAlerts: true,                           // NEW: Critical alerts
)
```

**Key Additions:**

- `defaultRingtoneType: DefaultRingtoneType.Alarm` - Uses alarm volume channel (louder, overrides DND)
- `criticalAlerts: true` - Marks as critical alert for iOS and Android 12+

### 2. **Notification Content Colors** (`scheduleAzanNotification()`)

Updated notification appearance to match app theme:

```dart
backgroundColor: const Color(0xFF2D1B69),  // Dark purple
color: const Color(0xFFD4AF37),            // Golden accent
```

### 3. **Sound File Configuration**

**Location:**

- Android: `/android/app/src/main/res/raw/azan.mp3`
- Assets: `/assets/audio/azan.mp3`

**Format Requirements:**

- File: `azan.mp3`
- Reference: `resource://raw/azan`
- No file extension in resource path
- Must be in `/raw/` folder for Android

## How the Sound System Works

### Channel-Level Sound (Primary)

```dart
soundSource: 'resource://raw/azan'
```

- Set at channel initialization
- Applies to ALL notifications on this channel
- Cannot be changed once channel is created (Android limitation)

### Content-Level Sound (Backup)

```dart
customSound: 'resource://raw/azan'
```

- Set on individual notification
- Works if channel sound fails
- Provides fallback mechanism

### Volume Channel Priority

```dart
defaultRingtoneType: DefaultRingtoneType.Alarm
```

Uses Android's **Alarm volume stream** which:

- ✅ Bypasses Do Not Disturb (with permission)
- ✅ Uses alarm volume (not notification volume)
- ✅ More audible during silent/vibrate modes
- ✅ Higher priority than regular notifications

## Testing Instructions

### 1. **Clear App Data (Critical)**

```bash
# Android
adb shell pm clear com.example.qibla_compass_offline

# Or manually: Settings > Apps > Muslim Pro > Storage > Clear Data
```

**Why?** Notification channels are cached. Old channel config without alarm settings will persist unless cleared.

### 2. **Rebuild and Install**

```bash
flutter clean
flutter pub get
flutter build apk --release
flutter install
```

### 3. **Test Prayer Time Notification**

#### Option A: Schedule Test for Near Future

1. Open app and go to Prayer Times screen
2. Enable notifications for next prayer
3. Wait for prayer time
4. Verify azan plays

#### Option B: Use Debug Test

```dart
// In prayer_times_controller.dart or notification_service.dart
await NotificationService.instance.scheduleAzanNotification(
  id: 999,
  prayerName: 'Test',
  prayerTime: DateTime.now().add(Duration(seconds: 10)),
  locationName: 'Test Location',
);
```

### 4. **Verify Sound Settings**

#### Check Notification Channel (Android)

1. Long-press notification when it appears
2. Tap "All categories" or settings icon
3. Find "Prayer Times" channel
4. Verify:
   - Sound: `azan` (custom)
   - Importance: Urgent (makes sound and pops on screen)
   - Override Do Not Disturb: ON
   - Vibration: ON

#### Check System Settings

1. Settings > Apps > Muslim Pro > Notifications
2. Tap "Prayer Times" channel
3. Sound should show "azan" or custom sound name
4. Importance should be "Urgent" or "Make sound and pop on screen"

### 5. **Test Scenarios**

✅ **Phone in silent mode** - Should play (alarm channel)
✅ **Phone in vibrate mode** - Should play (alarm channel)
✅ **Do Not Disturb ON** - Should play (requires USE_EXACT_ALARM permission)
✅ **Screen locked** - Should wake screen and play
✅ **App in background** - Should play
✅ **App closed** - Should play (scheduled notification)

## Troubleshooting

### Sound Not Playing

**1. Clear Notification Channel Cache**

```bash
adb shell pm clear com.example.qibla_compass_offline
```

**2. Check Sound File Exists**

```bash
# Verify file is in APK
unzip -l build/app/outputs/flutter-apk/app-release.apk | grep azan
```

Should show: `res/raw/azan.mp3`

**3. Check File Format**

- Must be `.mp3` format
- Sample rate: 44.1kHz or 48kHz recommended
- Bitrate: 128kbps or higher
- Mono or Stereo: Both work

**4. Check Permissions**
AndroidManifest.xml should have:

```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT"/>
```

**5. Test with Default Sound**
Temporarily remove `soundSource` from channel to use default:

```dart
// soundSource: 'resource://raw/azan',  // Comment out
```

If default works but custom doesn't, it's a sound file issue.

### Sound File Size Optimization

Current: `azan.mp3` (~5.1MB)
Recommended: <2MB for faster loading

**Compress without quality loss:**

```bash
ffmpeg -i azan.mp3 -b:a 96k -ar 44100 azan_optimized.mp3
```

## Android Version Compatibility

| Android Version     | Notification Behavior                                |
| ------------------- | ---------------------------------------------------- |
| 5.0-7.1 (API 21-25) | Channel settings ignored, uses notification settings |
| 8.0+ (API 26+)      | Channel settings apply, custom sound works           |
| 10+ (API 29+)       | Full screen intent requires permission               |
| 12+ (API 31+)       | Exact alarm requires special permission              |
| 13+ (API 33+)       | POST_NOTIFICATIONS permission required               |

## Key Differences from Previous Implementation

### Before:

- ❌ No `defaultRingtoneType` - used notification volume
- ❌ No `criticalAlerts` - lower priority
- ❌ Colors didn't match app theme
- ❌ No fallback sound configuration

### After:

- ✅ Uses alarm volume stream (louder)
- ✅ Critical alerts for higher priority
- ✅ Purple/gold theme colors
- ✅ Both channel and content-level sound
- ✅ Better DND bypass capabilities

## Files Modified

1. `lib/services/notifications/notification_service.dart`
   - Updated `prayer_channel` configuration (line ~29-47)
   - Updated fallback channel initialization (line ~76-90)
   - Updated `scheduleAzanNotification()` colors (line ~413-433)

## Additional Notes

### Why Two Sound Configurations?

1. **Channel-level** (`soundSource`): Primary, persistent
2. **Content-level** (`customSound`): Backup, per-notification

This dual approach ensures maximum compatibility across Android versions.

### Do Not Disturb (DND) Behavior

With `USE_EXACT_ALARM` permission:

- ✅ Plays during DND if "Alarms only" mode
- ✅ Plays during DND if "Priority only" mode
- ❌ Silent if "Total silence" mode (user choice)

Without permission:

- ❌ Silent during any DND mode

### Battery Optimization

Prayer notifications use:

- `SCHEDULE_EXACT_ALARM` - Precise timing
- `WAKE_LOCK` - Wake device
- `FOREGROUND_SERVICE` - Background operation

These may trigger battery optimization warnings. Users should:

1. Settings > Battery > Battery Optimization
2. Find "Muslim Pro"
3. Select "Don't optimize"

## Success Metrics

After fix, users should experience:

- ✅ Azan plays at exact prayer time
- ✅ Sound audible in silent/vibrate mode
- ✅ Screen wakes with full-screen notification
- ✅ Notification persists until user action
- ✅ Consistent behavior across Android versions

## Future Enhancements

Consider adding:

1. Volume control for azan
2. Multiple azan sound options
3. Fade-in/fade-out effects
4. Duration control (e.g., loop until dismissed)
5. Separate volume from alarm volume

## Support

If sound still doesn't play after these fixes:

1. Check device's alarm volume (must be > 0)
2. Verify notification permission granted
3. Check battery optimization disabled
4. Ensure DND allows alarms
5. Test with device speaker (not Bluetooth)

---

**Last Updated:** January 24, 2026
**Version:** 1.0.0
**Status:** ✅ Fixed and Tested
