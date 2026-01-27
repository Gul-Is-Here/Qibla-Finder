# ✅ Subscription System - Quick Setup Checklist

## 📋 Pre-Launch Checklist

Use this checklist to ensure everything is set up correctly before launching subscriptions.

---

## ✅ Step 1: Google Play Console (Required)

### Create Subscription Products

- [ ] Logged into [Google Play Console](https://play.google.com/console)
- [ ] Selected app: **Qibla Compass Offline**
- [ ] Navigated to: **Monetize** → **Products** → **Subscriptions**

#### Pakistan Monthly (`pk_premium_monthly`)

- [ ] Created subscription
- [ ] Product ID: `pk_premium_monthly`
- [ ] Name: Premium Monthly (Pakistan)
- [ ] Billing period: 1 Month
- [ ] Price: Rs. 50.00 (PKR)
- [ ] Auto-renewing: YES
- [ ] Base plan created
- [ ] Status: **ACTIVE** ✅

#### Pakistan Yearly (`pk_premium_yearly`)

- [ ] Created subscription
- [ ] Product ID: `pk_premium_yearly`
- [ ] Name: Premium Yearly (Pakistan)
- [ ] Billing period: 1 Year
- [ ] Price: Rs. 300.00 (PKR)
- [ ] Auto-renewing: YES
- [ ] Base plan created
- [ ] Status: **ACTIVE** ✅

#### International Monthly (`intl_premium_monthly`)

- [ ] Created subscription
- [ ] Product ID: `intl_premium_monthly`
- [ ] Name: Premium Monthly
- [ ] Billing period: 1 Month
- [ ] Price: $1.00 (USD)
- [ ] Auto-renewing: YES
- [ ] Base plan created
- [ ] Status: **ACTIVE** ✅

#### International Yearly (`intl_premium_yearly`)

- [ ] Created subscription
- [ ] Product ID: `intl_premium_yearly`
- [ ] Name: Premium Yearly
- [ ] Billing period: 1 Year
- [ ] Price: $6.00 (USD)
- [ ] Auto-renewing: YES
- [ ] Base plan created
- [ ] Status: **ACTIVE** ✅

### License Testing Setup

- [ ] Added test Gmail account(s)
- [ ] License response: **Licensed**
- [ ] Verified test account can see products

---

## ✅ Step 2: App Integration (Required)

### Add "Go Premium" Button

- [ ] Opened `lib/views/settings_views/settings_screen.dart`
- [ ] Added premium button with gold gradient
- [ ] Button navigates to `Routes.SUBSCRIPTION`
- [ ] Tested button click

### Update Ad Logic

- [ ] Located main ad service file
- [ ] Added subscription service import
- [ ] Added `shouldShowAds` check before showing ads
- [ ] Updated interstitial ad logic
- [ ] Updated banner ad logic
- [ ] Updated any other ad types

### Verify Imports

- [ ] All files import `subscription_service.dart` correctly
- [ ] No compilation errors
- [ ] Run `flutter pub get` successful

---

## ✅ Step 3: Testing (Critical)

### Test Account Purchase

- [ ] Installed app on test device
- [ ] Signed in with test account
- [ ] Navigated to subscription screen
- [ ] Saw all 2 subscription plans
- [ ] Clicked "Subscribe Now" on monthly plan
- [ ] Google Play payment sheet appeared
- [ ] Completed test purchase
- [ ] Purchase succeeded without real charge

### Verify Premium Activation

- [ ] Ads disappeared immediately after purchase
- [ ] Restarted app - ads still hidden
- [ ] Premium badge/status visible
- [ ] Subscription screen shows active subscription

### Test Firestore Update

- [ ] Opened [Firebase Console](https://console.firebase.google.com/)
- [ ] Navigated to Firestore Database
- [ ] Found user document: `users/{test_uid}`
- [ ] Verified fields:
  ```
  isPremium: true
  subscription: {
    isPremium: true,
    productId: "pk_premium_monthly" (or other)
    purchaseDate: (timestamp)
    expiryDate: (timestamp)
    isAutoRenewing: true
  }
  ```

### Test Restore Purchases

- [ ] Clicked "Restore Purchases" button
- [ ] Previous purchase restored successfully
- [ ] Premium status maintained

### Test on Multiple Devices

- [ ] Tested on Android device
- [ ] Tested on emulator
- [ ] Tested with different Google accounts
- [ ] Subscription syncs across devices

---

## ✅ Step 4: Firestore Configuration (Required)

### Security Rules

- [ ] Opened [Firebase Console](https://console.firebase.google.com/)
- [ ] Went to Firestore Database → Rules
- [ ] Updated rules to allow subscription updates:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

- [ ] Published rules
- [ ] Tested subscription purchase after rules update

---

## ✅ Step 5: User Experience (Important)

### UI/UX Verification

- [ ] Subscription screen loads quickly
- [ ] Plans display correctly
- [ ] Prices show in correct currency
- [ ] Benefits list is clear
- [ ] Purchase buttons work
- [ ] Loading states show properly
- [ ] Error messages are user-friendly
- [ ] Success message shows after purchase

### Ad Removal Verification

- [ ] No banner ads shown to premium users
- [ ] No interstitial ads shown to premium users
- [ ] All ad locations respect premium status
- [ ] Premium badge/indicator visible
- [ ] "Remove Ads" prompts hidden for premium users

---

## ✅ Step 6: App Store Preparation (Before Release)

### App Bundle/APK

- [ ] Built release APK: `flutter build apk --release`
- [ ] Or built App Bundle: `flutter build appbundle --release`
- [ ] File size is reasonable
- [ ] Tested release build on device

### Play Console Upload

- [ ] Uploaded APK/AAB to Play Console
- [ ] Created new release in **Internal testing** track
- [ ] Added release notes mentioning premium features
- [ ] Reviewed app permissions
- [ ] Verified all subscriptions are ACTIVE

### Privacy & Legal

- [ ] Updated Privacy Policy to mention:
  - In-app purchases
  - Subscription auto-renewal
  - Cancellation policy
  - Data usage for subscriptions
- [ ] Added Terms of Service link
- [ ] Added cancellation instructions in app
- [ ] Added contact email for subscription support

### Store Listing

- [ ] Updated app description to mention premium features
- [ ] Added "Remove Ads" to feature list
- [ ] Created promotional screenshots showing premium benefits
- [ ] Set up promotional graphics (optional)

---

## ✅ Step 7: Internal Testing (Recommended)

### Internal Track Testing

- [ ] Released to Internal testing track
- [ ] Added internal testers (not test accounts)
- [ ] Internal testers downloaded app
- [ ] Internal testers made real purchases (small amounts)
- [ ] Verified real payments work correctly
- [ ] Monitored for any issues
- [ ] Collected feedback

### Closed Testing (Optional)

- [ ] Created closed testing track
- [ ] Added beta testers (100-1000 users)
- [ ] Monitored conversion rates
- [ ] Fixed any reported issues
- [ ] Verified subscriptions work at scale

---

## ✅ Step 8: Production Release

### Pre-Release Verification

- [ ] All checklist items above completed ✅
- [ ] No critical bugs found
- [ ] Subscription flow tested end-to-end
- [ ] Revenue tracking works in Play Console
- [ ] Customer support email set up
- [ ] Refund policy decided

### Production Rollout

- [ ] Created Production release
- [ ] Started with 10% rollout
- [ ] Monitored for issues (24 hours)
- [ ] Increased to 50% rollout
- [ ] Monitored for issues (24 hours)
- [ ] Released to 100%

### Post-Release Monitoring

- [ ] Checked Play Console for crash reports
- [ ] Monitored subscription metrics:
  - New subscribers
  - Active subscriptions
  - Churn rate
  - Revenue
- [ ] Responded to user reviews
- [ ] Monitored Firebase errors
- [ ] Checked Firestore for any issues

---

## ✅ Step 9: Marketing & Optimization (Optional)

### In-App Promotion

- [ ] Added banner promoting premium in free version
- [ ] Added "Upgrade" prompts after ads
- [ ] Created onboarding highlighting premium benefits
- [ ] Added limited-time offers (optional)

### External Marketing

- [ ] Announced premium features on social media
- [ ] Updated app website with premium info
- [ ] Created promotional videos
- [ ] Engaged with user community

### A/B Testing (Advanced)

- [ ] Tested different pricing
- [ ] Tested different trial periods
- [ ] Tested different promotional messages
- [ ] Optimized conversion rates

---

## 🎯 Success Metrics

### Key Performance Indicators

After 1 Week:

- [ ] Subscription conversion rate: \_\_\_\_%
- [ ] Number of premium users: **\_**
- [ ] Revenue generated: Rs. **\_** / $ **\_**

After 1 Month:

- [ ] Conversion rate: \_\_\_\_%
- [ ] Active subscriptions: **\_**
- [ ] Monthly recurring revenue: Rs. **\_** / $ **\_**
- [ ] Churn rate: \_\_\_\_%

### Targets (Industry Benchmarks)

- ✅ Conversion rate: 2-5% is good
- ✅ Churn rate: <5% monthly is excellent
- ✅ LTV (Lifetime Value): >$10 per paying user

---

## 🐛 Troubleshooting Quick Reference

### Common Issues

**❌ "Product not found"**

- ✅ Wait 24 hours after creating product
- ✅ Verify product ID matches exactly
- ✅ Ensure product is ACTIVE in Play Console

**❌ "Billing unavailable"**

- ✅ Update Google Play Store app
- ✅ Check internet connection
- ✅ Verify device has Google services

**❌ Ads still showing after purchase**

- ✅ Check `shouldShowAds` logic
- ✅ Verify Firestore updated correctly
- ✅ Restart app to reload subscription status

**❌ Purchase not completing**

- ✅ Check test account is added to License testing
- ✅ Verify device has payment method
- ✅ Check Firebase logs for errors

---

## 📞 Support Resources

### Documentation

- ✅ `SUBSCRIPTION_SETUP_GUIDE.md` - Complete setup
- ✅ `SUBSCRIPTION_QUICK_INTEGRATION.md` - Code integration
- ✅ `SUBSCRIPTION_IMPLEMENTATION_SUMMARY.md` - Overview

### External Links

- [Google Play Billing Docs](https://developer.android.com/google/play/billing)
- [In-App Purchase Plugin](https://pub.dev/packages/in_app_purchase)
- [Firebase Console](https://console.firebase.google.com)
- [Play Console](https://play.google.com/console)

---

## ✅ Final Checklist Summary

Ready to launch when ALL are checked:

- [ ] 4 subscriptions created & ACTIVE in Play Console
- [ ] Test account successfully purchased subscription
- [ ] Ads disappear for premium users
- [ ] Firestore updates correctly
- [ ] "Go Premium" button added to Settings
- [ ] Privacy policy updated
- [ ] App tested on multiple devices
- [ ] Internal testing completed
- [ ] No critical bugs found
- [ ] Production release uploaded

---

## 🎉 Launch Ready!

When all items are checked, your subscription system is ready to generate revenue!

**Estimated Time to Complete All Steps:** 2-4 hours

**Expected Results:**

- 📈 2-5% conversion rate (industry standard)
- 💰 Rs. 25,000-85,000/month for 10K users
- ⭐ Improved user satisfaction (ad-free experience)
- 🚀 Scalable revenue stream

---

**Good luck with your launch!** 🚀💰

---

**Created:** 2026-01-27
**Project:** Qibla Compass Offline
