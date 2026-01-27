# 💳 In-App Subscription Integration Guide

## Overview

Complete subscription system for removing ads with **auto-renewable subscriptions** through Google Play Billing.

### Pricing Structure

#### 🇵🇰 Pakistan

- **Monthly**: Rs. 50/month
- **Yearly**: Rs. 300/year (Save Rs. 300)

#### 🌍 International

- **Monthly**: $1.00/month
- **Yearly**: $6.00/year (Save $6)

---

## ✅ What's Implemented

### 1. **Subscription Models** (`lib/models/subscription_model.dart`)

- `SubscriptionProduct` - Product details from Play Store
- `SubscriptionStatus` - User's subscription state
- `SubscriptionIds` - Product ID constants

### 2. **Subscription Service** (`lib/services/subscription_service.dart`)

- Google Play Billing integration
- Purchase flow management
- Subscription status tracking
- Auto-renewal handling
- Restore purchases
- Firestore sync

### 3. **Subscription UI** (`lib/views/subscription/subscription_screen.dart`)

- Beautiful premium screen
- Multiple plan cards
- Benefits showcase
- Purchase flow

### 4. **Features**

- ✅ Auto-renewable subscriptions
- ✅ Location-based pricing (Pakistan vs International)
- ✅ Firestore integration for subscription tracking
- ✅ Local caching
- ✅ Restore purchases
- ✅ Ad removal when premium
- ✅ Google Play payment methods (cards, GPay, etc.)

---

## 🚀 Setup Steps

### Step 1: Google Play Console Setup

#### A. Create Subscription Products

1. Go to [Google Play Console](https://play.google.com/console)
2. Select your app: **Qibla Compass Offline**
3. Navigate to: **Monetize** → **Products** → **Subscriptions**
4. Click **Create subscription**

#### B. Create Pakistan Monthly Subscription

1. **Product ID**: `pk_premium_monthly`
2. **Name**: Premium Monthly (Pakistan)
3. **Description**: Remove all ads and enjoy premium features
4. **Billing period**: 1 Month
5. **Price**:
   - Currency: PKR (Pakistani Rupee)
   - Price: Rs. 50.00
6. **Free trial**: Optional (e.g., 3 days)
7. **Grace period**: 3 days (recommended)
8. **Auto-renewing**: Yes ✅
9. Click **Save** → **Activate**

#### C. Create Pakistan Yearly Subscription

1. **Product ID**: `pk_premium_yearly`
2. **Name**: Premium Yearly (Pakistan)
3. **Description**: Remove all ads and enjoy premium features - Best Value!
4. **Billing period**: 1 Year
5. **Price**:
   - Currency: PKR (Pakistani Rupee)
   - Price: Rs. 300.00
6. **Free trial**: Optional (e.g., 7 days)
7. **Grace period**: 3 days (recommended)
8. **Auto-renewing**: Yes ✅
9. Click **Save** → **Activate**

#### D. Create International Monthly Subscription

1. **Product ID**: `intl_premium_monthly`
2. **Name**: Premium Monthly
3. **Description**: Remove all ads and enjoy premium features
4. **Billing period**: 1 Month
5. **Price**:
   - Currency: USD (US Dollar)
   - Price: $1.00
6. **Add more countries** (optional): EUR, GBP, etc.
7. **Auto-renewing**: Yes ✅
8. Click **Save** → **Activate**

#### E. Create International Yearly Subscription

1. **Product ID**: `intl_premium_yearly`
2. **Name**: Premium Yearly
3. **Description**: Remove all ads and enjoy premium features - Best Value!
4. **Billing period**: 1 Year
5. **Price**:
   - Currency: USD (US Dollar)
   - Price: $6.00
6. **Add more countries** (optional)
7. **Auto-renewing**: Yes ✅
8. Click **Save** → **Activate**

### Step 2: Configure Base Plans (Important!)

For each subscription:

1. Click on the subscription
2. Go to **Base plans** tab
3. Create a base plan:
   - **Base plan ID**: `base-plan` (or auto-generated)
   - **Billing period**: Match the subscription (monthly/yearly)
   - **Price**: Set the price
   - **Auto-renewing**: Yes
4. **Activate** the base plan

### Step 3: App Configuration

Your app is already configured! The code includes:

- ✅ Product IDs defined in `subscription_model.dart`
- ✅ Subscription service initialized
- ✅ UI screens ready
- ✅ Routes configured

### Step 4: Testing Subscriptions

#### A. Add License Testers

1. In Play Console, go to **Setup** → **License testing**
2. Add test accounts (Gmail addresses)
3. Choose response: **Licensed** (for successful purchases)

#### B. Test Purchase Flow

1. Build and install app on test device
2. Sign in with a test account
3. Navigate to Subscription screen
4. Try purchasing a subscription
5. Complete the test payment (won't be charged)

**Test Account Benefits:**

- No real charges
- Instant subscription activation
- Shorter subscription periods for testing:
  - Monthly → 5 minutes
  - Yearly → 30 minutes

### Step 5: Production Release

1. **Upload APK/AAB** to Play Console
2. Ensure all subscriptions are **ACTIVE**
3. Test on internal/closed testing track first
4. Move to production when ready
5. Users can now purchase with real money!

---

## 💻 Code Integration

### Navigate to Subscription Screen

```dart
// From any screen
Get.toNamed(Routes.SUBSCRIPTION);
```

### Check Premium Status

```dart
final subscriptionService = Get.find<SubscriptionService>();

if (subscriptionService.isPremium) {
  // User has active subscription
  // Don't show ads
} else {
  // Show ads
}
```

### Add Subscription Button to Settings

In `settings_screen.dart`:

```dart
ListTile(
  leading: const Icon(Icons.workspace_premium, color: Color(0xFFD4AF37)),
  title: const Text('Go Premium'),
  subtitle: const Text('Remove all ads'),
  trailing: const Icon(Icons.chevron_right),
  onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
)
```

---

## 🎨 Customization

### Change Pricing

Edit product prices in Google Play Console (not in code).

### Change Product IDs

If you need different IDs:

1. Update `SubscriptionIds` class in `subscription_model.dart`
2. Create matching products in Play Console
3. Test thoroughly

### Change UI

Edit `subscription_screen.dart` to customize:

- Colors
- Layout
- Benefits list
- Card design

---

## 📱 User Flow

1. User opens app (sees ads)
2. Navigates to Settings → "Go Premium"
3. Sees subscription plans
4. Chooses Monthly or Yearly
5. Clicks "Subscribe Now"
6. Google Play payment sheet appears
7. User pays with card/GPay/carrier billing
8. Subscription activates immediately
9. Ads removed automatically
10. Auto-renews every month/year

---

## 🔄 Subscription Management

### Auto-Renewal

- Subscriptions auto-renew by default
- Google handles billing automatically
- User can cancel anytime in Play Store

### User Cancellation

Users can cancel via:

1. Google Play Store app
2. **Subscriptions** section
3. Select your app
4. Click **Cancel subscription**

### Grace Period

- 3-day grace period configured
- If payment fails, user keeps access for 3 days
- Google retries payment automatically

### Restore Purchases

- Button in subscription screen
- Restores previous purchases across devices
- Syncs with Firestore

---

## 🛡️ Security & Verification

### Server-Side Verification (Recommended for Production)

Currently, the app validates subscriptions client-side. For production:

1. **Set up Cloud Functions** to verify purchases with Google
2. **Verify receipts** on your server
3. **Update Firestore** only after verification

Example Cloud Function:

```javascript
// Firebase Cloud Function
exports.verifySubscription = functions.https.onCall(async (data, context) => {
  const { purchaseToken, subscriptionId } = data;

  // Verify with Google Play API
  const subscription = await googlePlayAPI.verifySubscription(
    subscriptionId,
    purchaseToken,
  );

  if (subscription.paymentState === 1) {
    // Active
    // Update user's Firestore document
    await admin
      .firestore()
      .collection("users")
      .doc(context.auth.uid)
      .update({
        "subscription.isPremium": true,
        "subscription.expiryDate": new Date(subscription.expiryTimeMillis),
      });

    return { success: true };
  }

  return { success: false };
});
```

---

## 📊 Analytics & Monitoring

### Track Subscription Events

```dart
// In subscription_service.dart, add analytics

Future<void> _handleSuccessfulPurchase(PurchaseDetails purchase) async {
  // ... existing code ...

  // Track event
  FirebaseAnalytics.instance.logEvent(
    name: 'subscription_purchased',
    parameters: {
      'product_id': purchase.productID,
      'price': product.price,
      'currency': product.currencyCode,
    },
  );
}
```

### Monitor in Play Console

1. **Monetize** → **Subscriptions**
2. View subscription statistics:
   - Active subscriptions
   - Churn rate
   - Revenue
   - New subscribers
   - Cancellations

---

## 🐛 Troubleshooting

### Issue: "Product not found"

**Solution:**

- Ensure products are ACTIVE in Play Console
- Wait 24 hours after creating products
- Check product IDs match exactly
- Test on internal testing track first

### Issue: "Billing service unavailable"

**Solution:**

- Check device has Play Store installed
- Update Play Store to latest version
- Check internet connection
- Try on different device

### Issue: Purchase not updating

**Solution:**

- Check Firestore rules allow user updates
- Verify Firebase is initialized
- Check console logs for errors
- Try restore purchases

### Issue: Test purchases taking real money

**Solution:**

- Ensure test account is added to License testing
- Sign out and sign in with test account
- Clear Play Store cache
- Verify in License testing section

---

## 📝 Important Notes

### ⚠️ Before Production:

1. ✅ Test all subscription flows thoroughly
2. ✅ Verify prices are correct
3. ✅ Test on multiple devices/accounts
4. ✅ Implement server-side verification
5. ✅ Add proper error handling
6. ✅ Test cancellation and restore
7. ✅ Update privacy policy (mention subscriptions)
8. ✅ Add terms of service

### Payment Methods Supported:

- Credit/Debit cards (Visa, MasterCard, etc.)
- Google Pay
- Carrier billing (for some carriers)
- Gift cards
- PayPal (in some regions)

### Refunds:

- Users can request refunds within Play Store
- Google handles refund policy (usually 48 hours)
- You can also issue refunds from Play Console

---

## 🎯 Next Steps

1. **Create subscription products in Play Console** (follow Step 1)
2. **Test with test account** (follow Step 4)
3. **Add "Go Premium" button to Settings screen**
4. **Modify ad logic** to check `shouldShowAds`:

```dart
// In your ad service
if (!subscriptionService.shouldShowAds) {
  print('🚫 Premium user - skipping ads');
  return;
}
// Show ads
```

5. **Test end-to-end flow**
6. **Upload to Play Console for testing**
7. **Production release!**

---

## 📞 Support

For issues:

- **Google Play Billing**: [Developer Documentation](https://developer.android.com/google/play/billing)
- **In-App Purchase Plugin**: [pub.dev/packages/in_app_purchase](https://pub.dev/packages/in_app_purchase)

---

**Last Updated:** 2026-01-27
**Project:** Qibla Compass Offline
**Package:** com.qibla_compass_offline.app
