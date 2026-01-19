# Instructions to Remove Foreground Service (NOT RECOMMENDED)

If you want to remove foreground service permissions entirely:

## 1. Remove from AndroidManifest.xml

Remove these lines from `android/app/src/main/AndroidManifest.xml`:

```xml
<!-- Remove these permissions -->
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE_MEDIA_PLAYBACK"/>

<!-- Remove this service -->
<service android:name="com.ryanheise.audioservice.AudioService"
    android:exported="true"
    android:foregroundServiceType="mediaPlayback"
    tools:ignore="Instantiatable">
    <intent-filter>
        <action android:name="android.media.browse.MediaBrowserService" />
    </intent-filter>
</service>

<!-- Remove this receiver -->
<receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
    android:exported="true"
    tools:ignore="Instantiatable">
    <intent-filter>
        <action android:name="android.intent.action.MEDIA_BUTTON" />
    </intent-filter>
</receiver>
```

## 2. Remove from MainActivity.kt

Change `MainActivity.kt` back to:

```kotlin
class MainActivity: FlutterFragmentActivity()
```

## 3. Consequences

⚠️ **WARNING: This will break:**

- Background Quran audio playback
- Audio controls in notification area
- Continued playback when screen is off
- Media controls on lock screen

## Recommendation

✅ **KEEP THE FOREGROUND SERVICE** and just complete the declaration in Play Console.

It's legitimate for media playback and improves user experience significantly.
