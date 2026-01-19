# Google Play Data Safety Form - Quick Guide

## Qibla Compass Offline App

**Date:** January 16, 2026  
**Version Code:** 17 (next submission)

---

## ✅ QUICK CHECKLIST

### Step 1: Data Collection and Security

- [x] Does your app collect data? → **YES**
- [x] Encrypted in transit? → **YES**
- [x] Account creation? → **NO - My app does not allow users to create an account**
- [x] External login? → **NO**
- [x] Data deletion? → **No, but user data is automatically deleted within 90 days**

### Step 2: Data Types to Declare

#### ✅ LOCATION DATA

- **Precise Location** → YES
  - Purpose: App functionality (Qibla & Prayer times)
  - Shared: YES (with Prayer Times API)
  - Required: YES
  - Encrypted: YES

#### ✅ DEVICE IDs

- **Device or Other IDs** → YES
  - Types: Advertising ID, Android ID
  - Purpose: Advertising or marketing, Analytics
  - Shared: YES (with Google AdMob, InMobi)
  - Required: YES
  - Encrypted: YES

#### ✅ APP ACTIVITY

- **App interactions** → YES
  - Purpose: Analytics, Advertising
  - Shared: YES (with ad networks)
  - Required: YES
  - Encrypted: YES

#### ✅ APP INFO AND PERFORMANCE

- **Crash logs** → YES
  - Purpose: Analytics (bug fixes)
  - Shared: NO
  - Required: YES
- **Diagnostics** → YES
  - Purpose: Analytics (performance)
  - Shared: NO
  - Required: YES

---

## ❌ DATA TYPES NOT COLLECTED

- ❌ Personal info (name, email, phone, etc.)
- ❌ Financial info
- ❌ Health and fitness
- ❌ Messages
- ❌ Photos and videos
- ❌ Audio files
- ❌ Files and docs
- ❌ Calendar
- ❌ Contacts
- ❌ Web browsing history
- ❌ Approximate location

---

## 🔒 DATA SECURITY SUMMARY

| Security Measure          | Status                         |
| ------------------------- | ------------------------------ |
| Encrypted in transit      | ✅ YES (HTTPS)                 |
| Encrypted at rest         | ✅ YES (GetStorage)            |
| User can request deletion | ⚠️ Auto-deleted within 90 days |
| Privacy Policy            | ⚠️ REQUIRED (see below)        |

---

## 📄 PRIVACY POLICY REQUIREMENTS

**Status:** ⚠️ **REQUIRED BEFORE SUBMISSION**

You MUST create and host a privacy policy that includes:

1. **What data is collected:**

   - Precise GPS location
   - Device IDs (Advertising ID)
   - App usage data
   - Crash logs and diagnostics

2. **Why it's collected:**

   - Qibla direction calculation
   - Prayer times accuracy
   - Ad serving and personalization
   - App improvement and bug fixes

3. **Who it's shared with:**

   - Prayer Times API (alquran.cloud)
   - Google AdMob
   - InMobi

4. **User rights:**

   - How to reset Advertising ID
   - How to uninstall app
   - Contact information

5. **Data retention:**
   - Location: Not stored permanently
   - Cache: Auto-deleted after 30-90 days
   - Device IDs: Managed by ad networks

### Where to Host Privacy Policy:

- [ ] GitHub Pages (recommended, free)
- [ ] Your website
- [ ] Google Sites (free)
- [ ] Any public web hosting

**Privacy Policy URL must be added to Play Console before submission!**

---

## 🚀 SUBMISSION STEPS

1. **Update Data Safety Form** (use CSV file as reference)

   - Go to Play Console → App content → Data safety
   - Answer all questions exactly as shown in CSV
   - Save changes

2. **Create Privacy Policy**

   - Use template provided
   - Host at public URL
   - Test that URL is accessible

3. **Add Privacy Policy to Play Console**

   - App content → Privacy Policy
   - Enter your privacy policy URL
   - Save

4. **Update App Version**

   - Change version code to 17 in pubspec.yaml
   - Update version name if needed

5. **Build and Submit**
   ```bash
   flutter build appbundle --release
   ```
   - Upload to Play Console
   - Submit for review

---

## 🎯 COMMON MISTAKES TO AVOID

1. ❌ Saying "No data collected" when using ads
2. ❌ Not declaring Device IDs (Advertising ID)
3. ❌ Not declaring precise location
4. ❌ Privacy policy not matching Data Safety form
5. ❌ Forgetting to mention third-party SDKs (AdMob, InMobi)
6. ❌ Not declaring data sharing with ad networks

---

## 📞 THIRD-PARTY SERVICES USED

Your app uses these SDKs/Services that collect data:

1. **Google Mobile Ads (AdMob)**

   - Collects: Device IDs, App activity
   - Privacy: https://policies.google.com/privacy

2. **InMobi Ads**

   - Collects: Device IDs, App activity
   - Privacy: https://www.inmobi.com/privacy-policy/

3. **Prayer Times API (alquran.cloud)**

   - Collects: Location (for prayer times)
   - Privacy: Check their website

4. **Awesome Notifications**

   - Local only, no data sent externally

5. **GetStorage**
   - Local storage only

---

## 🔄 AFTER APPROVAL

Once approved:

- Monitor for any policy violations
- Keep privacy policy up to date
- If adding new SDKs, update Data Safety form
- Annual review of data practices

---

## 📧 NEED HELP?

If Google rejects again:

1. Read rejection reason carefully
2. Compare with this guide
3. Update specific fields mentioned
4. Appeal if you believe it's incorrect

---

## 📋 FILES IN THIS REPOSITORY

- `google_play_data_safety_form.csv` - Complete form answers
- `DATA_SAFETY_GUIDE.md` - This guide
- `PRIVACY_POLICY.md` - Template (create separately)

---

**Next Action:** Create privacy policy and host it online before resubmitting!
