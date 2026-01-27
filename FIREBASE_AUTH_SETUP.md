# Firebase Authentication Setup

## Overview

This document describes the Firebase authentication implementation for the Qibla Compass app.

## Features Implemented

### 1. Authentication Methods

- **Email/Password Authentication**: Users can sign up and sign in using email and password
- **Google Sign-In**: One-tap Google authentication
- **Guest Mode**: Users can use the app without creating an account

### 2. Onboarding Flow

- First-time users see the onboarding screens (Spiritual Goal, Notifications, Location)
- After completing onboarding, users are directed to the sign-in screen
- Onboarding is shown only once (stored in `hasCompletedOnboarding` flag)

### 3. User Flow

```
App Start
    ↓
Splash Screen
    ↓
Has Completed Onboarding?
    ├─ No → Onboarding Screens → Sign In
    └─ Yes → Is Authenticated?
              ├─ Yes → Main App
              └─ No → Sign In Screen
```

## Files Created/Modified

### New Files

1. **`lib/services/auth/auth_service.dart`**
   - Core authentication service using Firebase Auth
   - Methods: signUpWithEmail, signInWithEmail, signInWithGoogle, continueAsGuest, signOut, resetPassword
   - Reactive state management with GetX

2. **`lib/views/auth/sign_in_screen.dart`**
   - Sign-in UI with email/password form
   - Google sign-in button
   - Guest mode button
   - Forgot password dialog
   - Link to sign-up page

3. **`lib/views/auth/sign_up_screen.dart`**
   - Sign-up UI with name, email, password, confirm password fields
   - Form validation
   - Terms & conditions notice
   - Link back to sign-in page

### Modified Files

1. **`pubspec.yaml`**
   - Added Firebase dependencies:
     - firebase_core: ^3.8.1
     - firebase_auth: ^5.3.4
     - google_sign_in: ^6.2.2
     - cloud_firestore: ^5.5.2

2. **`lib/main.dart`**
   - Initialize Firebase in main()
   - Initialize AuthService
   - Added error handling for Firebase initialization

3. **`lib/routes/app_pages.dart`**
   - Added Routes.SIGN_IN and Routes.SIGN_UP
   - Added corresponding GetPage entries

4. **`lib/views/splash_screen.dart`**
   - Updated to check authentication status
   - Navigate based on onboarding and auth state

5. **`lib/views/onboarding/location_permission_screen.dart`**
   - Navigate to sign-in after onboarding completion
   - Changed flag name to `hasCompletedOnboarding`

## Storage Keys

The app uses GetStorage for local persistence:

- `hasCompletedOnboarding` (bool): Whether user has completed onboarding
- `isGuest` (bool): Whether user is in guest mode
- `location_permission_granted` (bool): Location permission status

## Next Steps (Optional Enhancements)

1. **Add Google Icon Asset**
   - Add `assets/icons/google.png` to the project
   - Update pubspec.yaml to include it in assets

2. **Profile Management**
   - Create user profile screen
   - Allow users to update profile information
   - Add profile picture support

3. **Password Reset**
   - The forgot password functionality is implemented in AuthService
   - Currently shows a dialog in SignInScreen

4. **Email Verification**
   - Add email verification after sign-up
   - Require email verification before full access

5. **Social Auth Expansion**
   - Add Facebook login
   - Add Apple Sign-In for iOS

6. **Guest to Registered Conversion**
   - Allow guest users to create an account
   - Migrate guest data to registered account

## Firebase Configuration

**Important**: Make sure you have completed the Firebase setup:

1. Created a Firebase project
2. Added Android app to Firebase project (with package name)
3. Downloaded and placed `google-services.json` in `android/app/`
4. Added iOS app to Firebase project (with bundle ID)
5. Downloaded and placed `GoogleService-Info.plist` in `ios/Runner/`
6. Enabled Email/Password and Google authentication in Firebase Console

## Testing

### Email/Password Sign-Up

1. Launch app
2. Complete onboarding
3. On sign-in screen, click "Sign Up"
4. Fill in name, email, password, confirm password
5. Click "Sign Up"
6. Should navigate to main app

### Google Sign-In

1. On sign-in screen, click "Continue with Google"
2. Select Google account
3. Should navigate to main app

### Guest Mode

1. On sign-in screen, click "Continue as Guest"
2. Should navigate to main app immediately

### Sign Out

- Use `Get.find<AuthService>().signOut()` to sign out
- This will return user to sign-in screen

## Error Handling

The AuthService provides user-friendly error messages for:

- Invalid email format
- Weak passwords
- Email already in use
- User not found
- Wrong password
- Network errors
- Too many requests

## Security Considerations

1. Passwords are handled by Firebase Auth (never stored locally)
2. Google Sign-In uses OAuth 2.0
3. Guest mode has limited functionality (optional to implement)
4. User session is persistent across app restarts

## Color Theme

The auth screens use the app's color scheme:

- Primary Purple: #8F66FF
- Dark Purple: #2D1B69
- Gold Accent: #D4AF37 (defined but not currently used)
- Background: Light grey (#F5F5F5)
