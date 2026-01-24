# Notification Test Screen - User Guide

## Access the Test Screen

### From Settings

1. Open the app
2. Go to **Settings** (gear icon)
3. Under **Prayer Notifications** section
4. Tap **"Test Notifications"** button

### Direct Navigation (for developers)

```dart
Get.toNamed(Routes.NOTIFICATION_TEST);
```

---

## Test Screen Features

### 🔊 Sound Tests

#### 1. Test Azan Sound (Instant)

- **What it does:** Sends notification immediately with azan sound
- **Use case:** Quick test to verify sound is working
- **Expected result:**
  - Notification appears instantly
  - Azan sound plays at alarm volume
  - If you hear the azan, configuration is correct ✅

#### 2. Test Scheduled (10 sec)

- **What it does:** Schedules notification for 10 seconds from now
- **Use case:** Test scheduled prayer notifications
- **Expected result:**
  - Notification appears after 10 seconds
  - Azan sound plays when notification triggers
  - Verifies scheduling system works ✅

---

### 🔍 System Checks

#### 3. Check Channels

- **What it does:** Verifies `prayer_channel_v2` exists
- **Use case:** Confirm channel is properly initialized
- **Expected result:**
  - Shows "✅ Channel Found: prayer_channel_v2"
  - Sends test notification on the channel
  - If channel doesn't exist, shows warning ⚠️

#### 4. Check Permissions

- **What it does:** Lists all notification permissions
- **Use case:** Diagnose permission issues
- **Expected result:** Shows permission status:
  - ✅ Notifications Allowed
  - ✅ Alert
  - ✅ Sound
  - ✅ Badge
  - ✅ Vibration
  - ✅ Critical Alert
  - ✅ Full Screen

#### 5. Open Channel Settings

- **What it does:** Opens Android notification settings for `prayer_channel_v2`
- **Use case:** Verify or change channel sound in Android settings
- **Expected result:**
  - Opens system settings
  - Shows "Prayer Times" channel
  - Can see custom sound configured

---

### 📅 Scheduled Notifications

- **View:** Shows all currently scheduled notifications
- **Details:** Displays notification ID, title, and scheduled time
- **Actions:** Cancel individual or all scheduled notifications

---

## Troubleshooting Tips (Built-in)

The test screen includes helpful tips:

1. **Turn up ALARM volume** (not notification volume)
   - Prayer notifications use alarm volume stream
   - Go to: Settings > Sound > Alarm Volume

2. **Check phone mode**
   - Phone must not be on silent/vibrate for sound
   - Or enable "Critical Alerts" to bypass DND

3. **Check channel settings**
   - Use "Open Channel Settings" button
   - Verify sound shows as "azan" (custom)

4. **Clear app data if needed**
   - Last resort: Settings > Apps > Qibla Compass > Storage > Clear Data
   - Then reinstall and test

5. **Test vs Scheduled difference**
   - Test notification: Plays instantly
   - Scheduled notification: Waits 10 seconds

---

## Understanding Test Results

### ✅ Success Indicators

**Test Azan Sound:**

```
✅ Test notification sent!
If you hear the azan sound, it's working correctly.
Make sure alarm volume is turned up!
```

**Check Channels:**

```
✅ Channel Found: prayer_channel_v2
The channel exists and is working!
```

**Check Permissions:**

```
✅ Notifications Allowed: true
✅ Alert
✅ Sound
✅ Badge
...
```

### ⚠️ Warning Indicators

**Channel Not Found:**

```
⚠️ Channel test failed!
Could not create notification on prayer_channel_v2.
Try reinstalling the app or clearing app data.
```

**Permissions Missing:**

```
❌ Notifications Allowed: false
⚠️ Permissions Required
Tap to enable notifications
```

### ❌ Error Indicators

**Error sending notification:**

```
❌ Error: [error message]
```

- Check if notification service is initialized
- Verify sound file exists in /res/raw/azan.mp3

---

## Expected Behavior

### When Everything Works ✅

1. **Instant Test:**
   - Notification appears immediately
   - Azan sound plays loudly (alarm volume)
   - Screen wakes up
   - Two buttons: "Mute" and "Prayed"

2. **Scheduled Test:**
   - Wait 10 seconds
   - Notification appears with azan sound
   - Same behavior as instant test

3. **Channel Check:**
   - Shows channel exists
   - Brief test notification appears and disappears

4. **Permissions:**
   - All permissions show ✅
   - No red ❌ indicators

### When There's an Issue ❌

1. **No Sound:**
   - Check alarm volume (not notification volume!)
   - Open channel settings, verify sound = "azan"
   - Try clearing app data

2. **Channel Not Found:**
   - App needs to be reinstalled
   - Or clear app data to reset channels

3. **Permission Denied:**
   - Tap the permission check result
   - Grant notification permissions
   - Re-test

---

## Technical Details

### Notification Configuration

**Channel Key:** `prayer_channel_v2`  
**Channel Name:** Prayer Times  
**Sound Source:** `resource://raw/azan`  
**Ringtone Type:** Alarm (uses alarm volume)  
**Importance:** Max (highest priority)  
**Critical Alerts:** true (bypasses DND)

### Test Notification IDs

- Instant Test: `99999`
- Scheduled Test: `88888`
- Channel Check: `-1` (auto-dismissed)

### File Location

**Screen:** `lib/views/test/notification_test_screen.dart`  
**Route:** `/notification-test`  
**Access:** Settings > Prayer Notifications > Test Notifications

---

## Quick Test Workflow

### For Users

1. Go to Settings
2. Tap "Test Notifications"
3. Tap "Test Azan Sound (Instant)"
4. Listen for azan sound 🔊
5. If you hear it → Everything works! ✅
6. If silent → Check alarm volume or channel settings

### For Developers

1. Run app in debug mode
2. Navigate to test screen
3. Check all system checks first
4. Verify channel exists
5. Test instant notification
6. Test scheduled notification
7. Monitor debug console for logs

---

## Integration with Main App

### Notification Service

- Uses `NotificationService.instance`
- Calls `testAzanNotification()` for instant test
- Calls `scheduleAzanNotification()` for scheduled test

### Routes

- Defined in `lib/routes/app_pages.dart`
- Route constant: `Routes.NOTIFICATION_TEST`
- Accessible from Settings screen

---

## Debug Console Output

When testing, check console for:

```
🔔 testAzanNotification: Creating test notification with azan sound...
✅ testAzanNotification: Test notification created successfully!
🔊 If you hear the azan sound, the configuration is correct.
```

---

## Version Information

**Created:** January 24, 2026  
**Version:** 1.0.0  
**Purpose:** Test azan sound notification with channel v2 update  
**Compatible:** Android 5.0+ (API 21+)

---

## Summary

The Notification Test Screen is a comprehensive diagnostic tool that allows users and developers to:

✅ Instantly test azan sound  
✅ Test scheduled notifications  
✅ Verify channel configuration  
✅ Check permissions  
✅ View scheduled notifications  
✅ Access Android settings  
✅ Troubleshoot issues

**Result:** Confident that prayer notifications with azan sound work perfectly! 🎉
