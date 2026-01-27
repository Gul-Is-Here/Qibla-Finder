# iOS Google Sign-In Setup Guide

## ⚠️ IMPORTANT: iOS Configuration Required

The app is crashing on iOS when attempting Google Sign-In because iOS requires specific configuration. Follow these steps:

## 1. Configure Google Sign-In Client ID

### Option A: Using Firebase (Recommended)

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Select your project
3. Go to Project Settings
4. Download `GoogleService-Info.plist`
5. Copy it to `ios/Runner/` directory
6. The `REVERSED_CLIENT_ID` from this file is needed for URL schemes

### Option B: Get from Google Cloud Console

1. Go to [Google Cloud Console](https://console.cloud.google.com)
2. Select your project
3. Go to APIs & Services → Credentials
4. Find your iOS OAuth 2.0 Client ID
5. Note the Client ID

## 2. Configure Info.plist

Add the following to `ios/Runner/Info.plist` (inside the `<dict>` tag):

```xml
<!-- Google Sign-In URL Scheme -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Replace this with your REVERSED_CLIENT_ID from GoogleService-Info.plist -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>

<!-- Google Sign-In Configuration -->
<key>GIDClientID</key>
<string>YOUR-CLIENT-ID.apps.googleusercontent.com</string>
```

## 3. Find Your REVERSED_CLIENT_ID

Open `ios/Runner/GoogleService-Info.plist` and find:

```xml
<key>REVERSED_CLIENT_ID</key>
<string>com.googleusercontent.apps.XXXXXXXXXX</string>
```

Copy this exact value to the URL scheme in Info.plist.

## 4. Example Configuration

If your `REVERSED_CLIENT_ID` is `com.googleusercontent.apps.123456789-abc123xyz`, your Info.plist should have:

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>com.googleusercontent.apps.123456789-abc123xyz</string>
        </array>
    </dict>
</array>
```

## 5. Initialize Google Sign-In with Client ID

The AuthService needs the client ID. Update it if needed:

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn(
  clientId: 'YOUR-CLIENT-ID.apps.googleusercontent.com', // iOS client ID
);
```

## 6. Enable Google Sign-In in Firebase Console

1. Go to Firebase Console → Authentication → Sign-in method
2. Enable Google provider
3. Add your iOS bundle ID
4. Add SHA-1 certificates if using Android

## 7. Clean and Rebuild

After making changes:

```bash
cd ios
pod deintegrate
pod install
cd ..
flutter clean
flutter pub get
flutter run
```

## Common Issues

### "No presentingViewController" Error

- This happens if URL schemes are not configured
- Make sure Info.plist has the correct REVERSED_CLIENT_ID

### "Sign in cancelled"

- User cancelled the sign-in flow
- This is normal behavior

### "An error occurred: 10" or similar

- Invalid client ID configuration
- Check that GIDClientID in Info.plist matches your Firebase project

## Quick Check

Your `ios/Runner/Info.plist` should have these two sections:

1. ✅ `CFBundleURLTypes` with your REVERSED_CLIENT_ID
2. ✅ `GIDClientID` with your client ID

## Need Help?

If Google Sign-In is still not working after following these steps:

1. Check Xcode console for detailed error messages
2. Verify GoogleService-Info.plist is in `ios/Runner/`
3. Make sure Firebase Authentication is enabled for Google
4. Verify iOS bundle ID matches Firebase configuration
