# 🔥 Firebase Firestore User Storage

## Overview

User details are now automatically saved to Firebase Firestore when users sign up or sign in. Each user has a unique document identified by their Firebase Authentication UID.

## Database Structure

### Collection: `users`

Each user document is stored with their Firebase UID as the document ID:

```
users/
  └── {uid}/
      ├── uid: String (Firebase Auth UID)
      ├── email: String (User's email)
      ├── name: String (Display name)
      ├── photoUrl: String? (Profile picture URL - for Google sign-in)
      ├── authProvider: String ('email', 'google', or 'guest')
      ├── createdAt: Timestamp (Account creation date)
      ├── lastLoginAt: Timestamp (Last login timestamp)
      └── isGuest: Boolean (Guest mode flag)
```

## Features Implemented

### 1. **Email/Password Sign-Up**

When a user signs up with email:

- ✅ Creates Firebase Authentication account
- ✅ Creates Firestore document with user details
- ✅ Stores: uid, email, name, authProvider='email', createdAt, lastLoginAt

Example document:

```json
{
  "uid": "abc123xyz",
  "email": "user@example.com",
  "name": "John Doe",
  "photoUrl": null,
  "authProvider": "email",
  "createdAt": "2026-01-27T10:30:00Z",
  "lastLoginAt": "2026-01-27T10:30:00Z",
  "isGuest": false
}
```

### 2. **Email/Password Sign-In**

When a user signs in:

- ✅ Authenticates with Firebase Auth
- ✅ Updates `lastLoginAt` timestamp in Firestore
- ✅ If document doesn't exist (legacy user), creates it automatically

### 3. **Google Sign-In/Sign-Up**

When a user signs in with Google:

- ✅ Authenticates with Google OAuth
- ✅ Checks if user document exists
- ✅ **New user**: Creates document with Google profile data
- ✅ **Existing user**: Updates lastLoginAt and photoUrl
- ✅ Stores Google profile picture URL

Example Google user document:

```json
{
  "uid": "google123",
  "email": "user@gmail.com",
  "name": "John Doe",
  "photoUrl": "https://lh3.googleusercontent.com/...",
  "authProvider": "google",
  "createdAt": "2026-01-27T10:30:00Z",
  "lastLoginAt": "2026-01-27T11:45:00Z",
  "isGuest": false
}
```

### 4. **Guest Mode**

Guest users:

- ❌ NOT stored in Firestore (no permanent record)
- ✅ Only stored locally via GetStorage
- ✅ Can be converted to permanent account later

## Code Implementation

### UserModel Class

Location: `lib/models/user_model.dart`

Features:

- ✅ Type-safe user data structure
- ✅ Conversion to/from Firestore Map
- ✅ Factory constructors for different sources
- ✅ Timestamp handling for dates

### AuthService Methods

#### `_createUserDocument()`

Creates a new user document in Firestore during sign-up.

#### `_updateLastLogin()`

Updates the `lastLoginAt` timestamp when user signs in.

#### `_createOrUpdateGoogleUser()`

Smart method that:

- Creates document if new Google user
- Updates existing document if returning user
- Keeps Google profile picture in sync

#### `getUserData()`

Retrieves user data from Firestore:

```dart
final userData = await AuthService.instance.getUserData(uid);
print(userData?.name); // User's name
```

#### `getUserDataStream()`

Real-time stream of user data:

```dart
AuthService.instance.getUserDataStream(uid).listen((user) {
  print('User updated: ${user?.name}');
});
```

## Console Logs

The system now prints detailed logs for debugging:

### Sign-Up Logs:

```
📝 Attempting sign up with email: user@example.com
🔥 Creating Firebase Auth user...
📝 Creating user document in Firestore...
✅ User document created: abc123xyz
✅ Sign Up Successful!
```

### Sign-In Logs:

```
📝 Attempting sign in with email: user@example.com
🔥 Signing in with email...
📝 Updating last login time...
✅ Last login updated for: abc123xyz
✅ Sign In Successful!
```

### Google Sign-In Logs:

```
🔷 Attempting Google sign in...
🍎 iOS: Attempting Google Sign-In... (iOS only)
📝 Creating/updating user document in Firestore...
✅ Google user updated: google123
✅ User document saved!
✅ Google Sign In Successful!
```

## Firestore Security Rules

**⚠️ IMPORTANT:** Set up Firestore Security Rules in Firebase Console:

### Recommended Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      // Users can read their own data
      allow read: if request.auth != null && request.auth.uid == userId;

      // Users can write their own data
      allow write: if request.auth != null && request.auth.uid == userId;

      // Alternative: Allow service to write during sign-up
      allow create: if request.auth != null;
      allow update: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

### How to Set Rules:

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **Firestore Database** in left menu
4. Click **Rules** tab
5. Paste the rules above
6. Click **Publish**

## Testing User Storage

### 1. Check Firebase Console

After sign-up/sign-in:

1. Go to Firebase Console
2. Click **Firestore Database**
3. Look for `users` collection
4. Click on a user document to see stored data

### 2. Query User Data in Code

```dart
final authService = AuthService.instance;
final currentUid = authService.currentUser.value?.uid;

if (currentUid != null) {
  final userData = await authService.getUserData(currentUid);
  print('User Name: ${userData?.name}');
  print('Email: ${userData?.email}');
  print('Auth Provider: ${userData?.authProvider}');
  print('Created: ${userData?.createdAt}');
  print('Last Login: ${userData?.lastLoginAt}');
}
```

### 3. Real-time Updates

```dart
AuthService.instance.getUserDataStream(currentUid!).listen((user) {
  if (user != null) {
    print('Live user data: ${user.name}');
  }
});
```

## Error Handling

The system gracefully handles Firestore errors:

- ✅ Auth succeeds even if Firestore write fails
- ✅ Logs errors but doesn't crash the app
- ✅ Auto-creates missing documents on sign-in
- ✅ Detailed console logging for debugging

Example error log:

```
❌ Error creating user document: [FirebaseException]...
⚠️ Note: User authentication was still successful
```

## User Data Privacy

- ✅ Each user can only access their own data (via Security Rules)
- ✅ Passwords are NOT stored in Firestore (handled by Firebase Auth)
- ✅ Guest users leave no permanent trace
- ✅ User data is tied to UID (unique identifier)

## Future Enhancements

Potential additions:

- 📱 Store user preferences (prayer notifications, theme, etc.)
- 📍 Store favorite locations
- 📊 Store prayer statistics
- 🕌 Store bookmarked mosques
- 📖 Store Quran reading progress

## Troubleshooting

### Issue: "Permission denied" error

**Solution:** Check Firestore Security Rules - ensure users can write to their own documents

### Issue: User document not created

**Solution:** Check console logs - may be Firestore permission or network issue

### Issue: lastLoginAt not updating

**Solution:** Document might not exist - sign out and sign in again to auto-create

### Issue: Google users have no name

**Solution:** Check if Google account has display name set

## Summary

✅ **Complete user storage system implemented**

- All sign-up/sign-in methods save user data
- Unique document per user (by UID)
- Automatic timestamp tracking
- Google profile sync
- Type-safe data models
- Comprehensive error handling
- Detailed logging for debugging

**Next Steps:**

1. Set up Firestore Security Rules (see above)
2. Test sign-up with email
3. Test sign-in with email
4. Test Google sign-in
5. Check Firebase Console to see stored users

---

**Last Updated:** 2026-01-27
**Project:** Qibla Compass Offline
**Files Modified:**

- `lib/services/auth/auth_service.dart`
- `lib/models/user_model.dart` (new)
