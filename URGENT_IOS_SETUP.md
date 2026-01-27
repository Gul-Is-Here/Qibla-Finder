# 🚨 CRITICAL: Firebase iOS Setup Required!

## The app is crashing because Firebase is not configured for iOS!

You've successfully added Firebase to Android, but **iOS setup is incomplete**. Here's what you need to do:

---

## Step 1: Download GoogleService-Info.plist

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **Qibla Compass / Muslim Pro**
3. Click the **gear icon** → **Project settings**
4. Scroll down to **Your apps** section
5. Find your **iOS app** (or add one if it doesn't exist)
   - Bundle ID: `com.example.qiblaCompassOffline` (check `ios/Runner.xcodeproj/project.pbxproj`)
6. Click **Download GoogleService-Info.plist**
7. **Move the file to**: `ios/Runner/GoogleService-Info.plist`

---

## Step 2: Add iOS App to Firebase (if not added yet)

If you haven't added an iOS app to Firebase:

1. In Firebase Console → Project Settings
2. Click **Add app** → Choose **iOS**
3. Enter your iOS Bundle ID (found in Xcode or `project.pbxproj`)
4. Register app
5. Download `GoogleService-Info.plist`
6. Place it in `ios/Runner/` directory

---

## Step 3: Configure Google Sign-In in Info.plist

After adding `GoogleService-Info.plist`:

1. Open `ios/Runner/GoogleService-Info.plist`
2. Find these two values:
   - `REVERSED_CLIENT_ID` (looks like: `com.googleusercontent.apps.123456-abc...`)
   - `CLIENT_ID` (looks like: `123456-abc...apps.googleusercontent.com`)

3. Open `ios/Runner/Info.plist`
4. Replace the placeholder values:

   ```xml
   <!-- Replace YOUR-CLIENT-ID-HERE with your REVERSED_CLIENT_ID -->
   <string>com.googleusercontent.apps.YOUR-CLIENT-ID-HERE</string>

   <!-- Replace YOUR-IOS-CLIENT-ID with your CLIENT_ID -->
   <string>YOUR-IOS-CLIENT-ID.apps.googleusercontent.com</string>
   ```

---

## Step 4: Enable Google Sign-In in Firebase

1. Firebase Console → **Authentication** → **Sign-in method**
2. Click **Google** provider
3. Click **Enable**
4. Select a support email
5. Click **Save**

---

## Step 5: Install Pods and Clean Build

```bash
cd ios
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

---

## Example Configuration

### From GoogleService-Info.plist:

```xml
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.123456789-abcdefg</string>
<key>CLIENT_ID</key>
<string>123456789-abcdefg.apps.googleusercontent.com</string>
```

### Update in Info.plist:

```xml
<key>CFBundleURLSchemes</key>
<array>
    <string>com.googleusercontent.apps.123456789-abcdefg</string>
</array>

<key>GIDClientID</key>
<string>123456789-abcdefg.apps.googleusercontent.com</string>
```

---

## Quick Checklist

- [ ] Download `GoogleService-Info.plist` from Firebase Console
- [ ] Place it in `ios/Runner/` directory
- [ ] Copy `REVERSED_CLIENT_ID` to Info.plist URL schemes
- [ ] Copy `CLIENT_ID` to Info.plist GIDClientID
- [ ] Enable Google Sign-In in Firebase Authentication
- [ ] Run `cd ios && pod install`
- [ ] Run `flutter clean && flutter pub get`
- [ ] Test the app

---

## Testing Without Google Sign-In

If you want to test other features first, you can:

1. **Use Email/Password Sign-In**: Works without additional configuration
2. **Use Guest Mode**: Click "Continue as Guest" button
3. **Disable Google Sign-In Button**: Comment out the Google button in sign-in screen (temporary)

---

## Need Help?

The crash log shows:

```
Exception: No presentingViewController was provided for Google Sign-In
```

This means the iOS Google Sign-In SDK can't find the required configuration in Info.plist.

**The fix**: Add `GoogleService-Info.plist` and configure URL schemes in `Info.plist` as described above.

---

## Alternative: Disable Google Sign-In on iOS (Temporary)

If you want to test other features, you can temporarily disable Google Sign-In:

In `lib/services/auth/auth_service.dart`:

```dart
Future<String?> signInWithGoogle() async {
  // Temporary: Return error on iOS
  if (Platform.isIOS) {
    return 'Google Sign-In not configured for iOS yet';
  }
  // ... rest of the code
}
```

Then import `dart:io` at the top.
