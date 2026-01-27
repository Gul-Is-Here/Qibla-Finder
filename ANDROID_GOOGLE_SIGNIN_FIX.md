# 🔴 URGENT: Fix Android Google Sign-In Error 10

## Problem

```
❌ Google Sign Up Failed: PlatformException(sign_in_failed,
com.google.android.gms.common.api.ApiException: 10: , null, null)
```

**Error Code 10** = "Developer Error" - SHA-1 fingerprint not configured in Firebase

---

## ✅ Solution (Follow in Order)

### Step 1: Get Your SHA-1 Fingerprints

Open terminal in your project root and run:

```bash
# For DEBUG builds (testing)
cd android
./gradlew signingReport
```

Look for the **SHA-1** fingerprints in the output:

```
Variant: debug
Config: debug
Store: /Users/.../.android/debug.keystore
Alias: AndroidDebugKey
MD5: XX:XX:XX...
SHA1: AA:BB:CC:DD:EE:FF:11:22:33:44:55:66:77:88:99:00:AA:BB:CC:DD  ⬅️ COPY THIS
SHA-256: ...
```

**Copy BOTH debug and release SHA-1 certificates!**

For release, you'll find it under the "release" variant section.

---

### Step 2: Add SHA-1 to Firebase Console

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **qibla_compass_offline**
3. Click the **⚙️ Settings** icon → **Project settings**
4. Scroll down to **Your apps** section
5. Find your Android app: `com.qibla_compass_offline.app`
6. Click **Add fingerprint** button
7. **Paste the DEBUG SHA-1** from Step 1
8. Click **Add fingerprint** again
9. **Paste the RELEASE SHA-1** from Step 1
10. Click **Save**

---

### Step 3: Download NEW google-services.json

**CRITICAL:** After adding SHA-1 certificates, you MUST download a new config file!

1. Still in Firebase Console → Project Settings
2. Scroll to **Your apps** → Android app
3. Click **google-services.json** download button
4. **Save it to**: `android/app/google-services.json`
   - ⚠️ **NOT** in `android/` root
   - ✅ Must be in `android/app/` directory

---

### Step 4: Enable Google Sign-In in Firebase

1. In Firebase Console, go to **Authentication** (left sidebar)
2. Click **Sign-in method** tab
3. Find **Google** in the providers list
4. Click the **pencil/edit** icon
5. Toggle **Enable** switch to ON
6. Set **Project support email** (your email)
7. Click **Save**

---

### Step 5: Verify OAuth 2.0 Client

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select your project (same as Firebase)
3. Go to **APIs & Services** → **Credentials**
4. You should see:
   - ✅ **Android client** (auto-created by Firebase)
   - ✅ **Web client (auto created by Google Service)** - This is what your app uses!

   Don't delete these!

---

### Step 6: Clean and Rebuild

```bash
# Clean Flutter
flutter clean
flutter pub get

# Clean Android
cd android
./gradlew clean
cd ..

# Rebuild
flutter build apk --debug
```

---

### Step 7: Test Again

```bash
flutter run
```

Try Google Sign-In again. Check the console for:

- ✅ `✅ Google Sign Up Successful!`
- ❌ Any error messages

---

## 🔍 Common Issues

### Issue 1: Still Error 10 After Adding SHA-1

**Solution:**

- Wait 5-10 minutes for Firebase to propagate changes
- Download NEW google-services.json (Step 3)
- Run `flutter clean` again

### Issue 2: Multiple SHA-1 Fingerprints

**Solution:** Add ALL of them to Firebase:

- Debug SHA-1 (from `~/.android/debug.keystore`)
- Release SHA-1 (from `android/upload-keystore.jks`)
- Any other keystores you use

### Issue 3: Package Name Mismatch

**Solution:** Verify these match:

- `android/app/build.gradle.kts`: `applicationId = "com.qibla_compass_offline.app"`
- Firebase Console: Package name
- `google-services.json`: `package_name` field

### Issue 4: google-services.json Not Found

**Error:** `:app:processDebugGoogleServices FAILED`
**Solution:**

- Ensure file is at: `android/app/google-services.json` (NOT `android/google-services.json`)

---

## 📱 Quick Verification Checklist

Before testing again, verify:

- [ ] SHA-1 (debug) added to Firebase
- [ ] SHA-1 (release) added to Firebase
- [ ] NEW google-services.json downloaded
- [ ] File placed at: `android/app/google-services.json`
- [ ] Google Sign-In enabled in Firebase Auth
- [ ] Package name matches: `com.qibla_compass_offline.app`
- [ ] Ran `flutter clean`
- [ ] Rebuilt app

---

## 🎯 Expected Output After Fix

When testing Google Sign-In, console should show:

```
🔷 Attempting Google sign in...
✅ Google Sign In Successful!
```

No error code 10!

---

## 📞 Still Not Working?

If you still get error 10:

1. **Share your SHA-1 output** (run `cd android && ./gradlew signingReport`)
2. **Verify Firebase settings**:
   - Check if Android app exists in Firebase Console
   - Verify package name matches
   - Confirm SHA-1 fingerprints are saved
3. **Check google-services.json location**: Must be `android/app/` not `android/`

---

## 🔗 Helpful Resources

- [Firebase Android Setup](https://firebase.google.com/docs/android/setup)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [SHA-1 Certificate Fingerprint](https://developers.google.com/android/guides/client-auth)

---

**Last Updated:** 2026-01-27
**Project:** Qibla Compass Offline
**Package:** com.qibla_compass_offline.app
