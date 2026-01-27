# 🎯 Firebase Firestore Setup - Quick Start

## What Was Implemented

✅ **User data is now automatically saved to Firestore database!**

### Automatic Storage Happens:

1. **Email Sign-Up** → Creates user document with name, email, timestamps
2. **Email Sign-In** → Updates last login timestamp
3. **Google Sign-In/Sign-Up** → Creates/updates document with Google profile
4. **Guest Mode** → No database storage (local only)

---

## 🚀 Required Setup Steps

### Step 1: Create Firestore Database

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **qibla_compass_offline**
3. Click **Firestore Database** in left sidebar
4. Click **Create database** button
5. Choose **Production mode** (we'll add security rules next)
6. Select your database location (closest region)
7. Click **Enable**

### Step 2: Set Security Rules

1. In Firestore Database, click **Rules** tab
2. Copy this code and paste it:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

3. Click **Publish**

**These rules ensure:**

- ✅ Only authenticated users can access the database
- ✅ Users can only read/write their own data
- ✅ No one can access other users' data

### Step 3: Test User Storage

1. **Sign up a new user** (email or Google)
2. Go to Firebase Console → **Firestore Database**
3. You should see:
   ```
   users/
     └── {some-uid}/
         ├── email: "user@example.com"
         ├── name: "User Name"
         ├── authProvider: "email"
         ├── createdAt: (timestamp)
         ├── lastLoginAt: (timestamp)
         └── ...
   ```

---

## 📊 What Data Gets Stored

### For Email Users:

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

### For Google Users:

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

---

## 🔍 Verify It's Working

### Check Console Logs:

**During Sign-Up:**

```
📝 Attempting sign up with email: user@example.com
🔥 Creating Firebase Auth user...
📝 Creating user document in Firestore...
✅ User document created: abc123xyz
✅ Sign Up Successful!
```

**During Sign-In:**

```
📝 Attempting sign in with email: user@example.com
🔥 Signing in with email...
📝 Updating last login time...
✅ Last login updated for: abc123xyz
✅ Sign In Successful!
```

**During Google Sign-In:**

```
🔷 Attempting Google sign in...
📝 Creating/updating user document in Firestore...
✅ Google user updated: google123
✅ User document saved!
✅ Google Sign In Successful!
```

### Check Firebase Console:

1. Open [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Click **Firestore Database**
4. Expand **users** collection
5. Click on a user document to see all stored data

---

## 🔐 Security & Privacy

✅ **Passwords are NEVER stored in Firestore** (handled securely by Firebase Auth)
✅ **Each user can only access their own data** (enforced by Security Rules)
✅ **Guest users leave no permanent record** (stored locally only)
✅ **All data is encrypted at rest** (by Firebase)

---

## 📂 Files Modified/Created

### New Files:

- ✅ `lib/models/user_model.dart` - User data structure
- ✅ `firestore.rules` - Security rules template
- ✅ `FIRESTORE_USER_STORAGE.md` - Detailed documentation
- ✅ `FIRESTORE_SETUP_QUICKSTART.md` - This file

### Modified Files:

- ✅ `lib/services/auth/auth_service.dart` - Added Firestore integration

---

## ❓ Troubleshooting

### Issue: "Permission denied" error

**Cause:** Security rules not set up
**Solution:** Follow Step 2 above to add security rules

### Issue: No data appears in Firestore

**Cause:** Database not created or network issue
**Solution:**

1. Check Firebase Console - is Firestore enabled?
2. Check app logs for error messages
3. Verify internet connection

### Issue: Console shows "Error creating user document"

**Cause:** Usually Firestore not initialized or rules blocking write
**Solution:**

1. Ensure Firestore is enabled in Firebase Console
2. Check security rules allow user creation
3. Check app has internet connection

---

## 🎨 Future Enhancements

This user storage system enables future features:

- 📱 **User Preferences** - Store settings, notification preferences
- 📍 **Saved Locations** - Store favorite prayer locations
- 📊 **Prayer Statistics** - Track prayer history
- 🕌 **Bookmarked Mosques** - Save favorite mosques
- 📖 **Quran Progress** - Track reading progress
- 🔔 **Custom Notifications** - Per-user notification settings

---

## ✅ Checklist

Before continuing, ensure:

- [ ] Firestore Database created in Firebase Console
- [ ] Security rules published
- [ ] Tested email sign-up
- [ ] Tested email sign-in
- [ ] Tested Google sign-in (after SHA-1 setup)
- [ ] Verified user documents appear in Firestore Console
- [ ] Console logs show "✅ User document created"

---

## 🔗 Related Documentation

- `FIRESTORE_USER_STORAGE.md` - Complete technical documentation
- `ANDROID_GOOGLE_SIGNIN_FIX.md` - Fix Google Sign-In error 10
- `AUTH_SETUP_SUMMARY.md` - Authentication system overview
- `firestore.rules` - Security rules template

---

**Last Updated:** 2026-01-27
**Status:** ✅ Ready to use after Firestore setup
**Priority:** HIGH - Required for user authentication system
