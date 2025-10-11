# 📱 Android Configuration Guide

## Step 1: Add Permissions to AndroidManifest.xml

Add these permissions inside the `<manifest>` tag:

```xml
<!-- Notifications -->
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE" />
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
<uses-permission android:name="android.permission.WAKE_LOCK" />
<uses-permission android:name="android.permission.USE_FULL_SCREEN_INTENT" />
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM" />
```

## Step 2: Add Broadcast Receivers

Add inside `<application>` tag in AndroidManifest.xml:

```xml
<!-- Awesome Notifications Receivers -->
<receiver 
    android:name="me.carda.awesome_notifications.core.broadcasters.receivers.ScheduledNotificationReceiver"
    android:exported="true"
    android:enabled="true">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED" />
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON" />
    </intent-filter>
</receiver>

<receiver 
    android:name="me.carda.awesome_notifications.core.broadcasters.receivers.DismissedNotificationReceiver"
    android:exported="false"
    android:enabled="true"/>

<receiver 
    android:name="me.carda.awesome_notifications.core.broadcasters.receivers.ActionReceiver"
    android:exported="false"
    android:enabled="true"/>
```

## Step 3: Copy Azan Audio File

Create the directory and copy audio:

```bash
mkdir -p android/app/src/main/res/raw
cp assets/audio/azan.mp3 android/app/src/main/res/raw/azan.mp3
```

Or manually:
1. Create folder: `android/app/src/main/res/raw/`
2. Copy `azan.mp3` to that folder
3. File should be at: `android/app/src/main/res/raw/azan.mp3`

## Step 4: Update build.gradle (if needed)

In `android/app/build.gradle`, ensure:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
    }
}
```

## Step 5: Run Flutter Pub Get

```bash
flutter pub get
```

## Step 6: Clean and Rebuild

```bash
flutter clean
flutter pub get
flutter run
```

## ✅ Verification

1. Build the app
2. Grant notification permissions
3. Enable notifications in Prayer Times
4. Tap "Test" button in Notification Settings
5. You should see notification with Azan in 5 seconds

## 🎯 Common Issues

### Issue: Notifications don't appear
**Solution**: Check permissions granted in Android settings

### Issue: Azan doesn't play
**Solution**: Verify `azan.mp3` is in `res/raw/` folder

### Issue: Build fails
**Solution**: Run `flutter clean && flutter pub get`

### Issue: Exact alarm permission denied (Android 12+)
**Solution**: User must grant "Alarms & reminders" permission in app settings

---

**Done! Your notification system is ready! 🎉**
