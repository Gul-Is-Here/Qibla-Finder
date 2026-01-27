# 🚀 Quick Start: Integrate Subscriptions with Ads

## Overview

This guide shows how to hide ads for premium (subscribed) users.

---

## Step 1: Add "Go Premium" Button to Settings

Edit `lib/views/settings_views/settings_screen.dart`:

```dart
// Add this import at top
import '../../routes/app_pages.dart';

// Add this ListTile in your settings list (after About section):
Container(
  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    gradient: const LinearGradient(
      colors: [Color(0xFFD4AF37), Color(0xFFB8960F)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ),
    borderRadius: BorderRadius.circular(12),
  ),
  child: ListTile(
    leading: const Icon(
      Icons.workspace_premium,
      color: Colors.white,
      size: 32,
    ),
    title: Text(
      'Go Premium',
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    ),
    subtitle: Text(
      'Remove all ads - Special offer!',
      style: GoogleFonts.poppins(
        color: Colors.white70,
        fontSize: 13,
      ),
    ),
    trailing: const Icon(
      Icons.arrow_forward_ios,
      color: Colors.white,
      size: 18,
    ),
    onTap: () => Get.toNamed(Routes.SUBSCRIPTION),
  ),
),
```

---

## Step 2: Update Ad Service to Check Premium Status

### Option A: Update Global Ad Service

Edit `lib/services/ads/ad_service.dart` (or your main ad service):

```dart
import '../subscription_service.dart';

class AdService {
  final SubscriptionService _subscriptionService = Get.find<SubscriptionService>();

  // Add this method to check if ads should be shown
  bool get shouldShowAds {
    return !_subscriptionService.isPremium;
  }

  // Update your ad loading methods
  Future<void> loadInterstitialAd() async {
    if (!shouldShowAds) {
      print('🚫 Premium user - skipping interstitial ad');
      return;
    }

    // ... existing ad loading code ...
  }

  Future<void> showBannerAd() async {
    if (!shouldShowAds) {
      print('🚫 Premium user - skipping banner ad');
      return;
    }

    // ... existing ad showing code ...
  }
}
```

### Option B: Check in Individual Screens

In any screen that shows ads:

```dart
import '../../services/subscription_service.dart';

class YourScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final subscriptionService = Get.find<SubscriptionService>();

    return Scaffold(
      body: Column(
        children: [
          // Your content

          // Only show banner if not premium
          Obx(() {
            if (subscriptionService.shouldShowAds) {
              return BannerAdWidget();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
```

---

## Step 3: Update Banner Ad Widget

Edit your banner ad widget to check premium status:

```dart
class BannerAdWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final subscriptionService = Get.find<SubscriptionService>();

    return Obx(() {
      // Don't show if premium
      if (subscriptionService.isPremium) {
        return const SizedBox.shrink();
      }

      // Show your ad widget
      return Container(
        height: 50,
        child: // Your ad widget
      );
    });
  }
}
```

---

## Step 4: Update Main Navigation

If you show ads in `main_navigation_screen.dart`:

```dart
import '../services/subscription_service.dart';

class MainNavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final subscriptionService = Get.find<SubscriptionService>();

    return Scaffold(
      body: Column(
        children: [
          Expanded(child: // Your main content),

          // Bottom banner - only for non-premium users
          Obx(() {
            if (subscriptionService.shouldShowAds) {
              return BottomBannerAd();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
```

---

## Step 5: Test the Integration

### A. Test Without Subscription

1. Run the app
2. You should see ads normally
3. Navigate to Settings → "Go Premium"
4. See subscription screen

### B. Test With Subscription

1. Purchase a subscription (use test account)
2. Ads should disappear immediately
3. Restart app - ads should still be hidden
4. Check Firestore - `isPremium` should be true

### C. Verify Firestore Update

After purchase, check Firestore Console:

```
users/
  └── {uid}/
      ├── isPremium: true
      └── subscription: {
          isPremium: true,
          productId: "pk_premium_monthly",
          purchaseDate: "2026-01-27...",
          expiryDate: "2026-02-27...",
          isAutoRenewing: true
      }
```

---

## Step 6: Add Subscription Info to Profile

Show subscription status in user profile/settings:

```dart
// In settings or profile screen
Obx(() {
  final status = subscriptionService.subscriptionStatus.value;

  if (status.isPremium && status.isActive) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD4AF37)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.verified,
            color: Color(0xFFD4AF37),
            size: 32,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Premium Member',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Ad-free until ${DateFormat.yMMMd().format(status.expiryDate!)}',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  return const SizedBox.shrink();
}),
```

---

## Complete Example: Ad-Aware Screen

Here's a complete example of a screen that respects premium status:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/subscription_service.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final subscriptionService = Get.find<SubscriptionService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Example'),
        actions: [
          // Show premium badge if subscribed
          Obx(() {
            if (subscriptionService.isPremium) {
              return IconButton(
                icon: const Icon(Icons.workspace_premium, color: Color(0xFFD4AF37)),
                onPressed: () => Get.toNamed(Routes.SUBSCRIPTION),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
      body: Column(
        children: [
          // Top banner (only for non-premium)
          Obx(() {
            if (subscriptionService.shouldShowAds) {
              return Container(
                height: 50,
                color: Colors.grey[300],
                child: const Center(child: Text('Ad Banner Here')),
              );
            }
            return const SizedBox.shrink();
          }),

          // Main content
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Your Content'),

                  // Show upgrade button only for non-premium
                  Obx(() {
                    if (!subscriptionService.isPremium) {
                      return Padding(
                        padding: const EdgeInsets.all(16),
                        child: ElevatedButton.icon(
                          onPressed: () => Get.toNamed(Routes.SUBSCRIPTION),
                          icon: const Icon(Icons.workspace_premium),
                          label: const Text('Remove Ads'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD4AF37),
                          ),
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                ],
              ),
            ),
          ),

          // Bottom banner (only for non-premium)
          Obx(() {
            if (subscriptionService.shouldShowAds) {
              return Container(
                height: 50,
                color: Colors.grey[300],
                child: const Center(child: Text('Ad Banner Here')),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }
}
```

---

## Testing Checklist

Before releasing:

- [ ] "Go Premium" button visible in Settings
- [ ] Subscription screen opens correctly
- [ ] Can see subscription plans
- [ ] Test account can complete purchase
- [ ] Ads disappear after purchase
- [ ] Premium status persists after app restart
- [ ] Firestore updates correctly
- [ ] Can restore purchases
- [ ] Subscription status shows in profile
- [ ] All ad locations check premium status

---

## Important Notes

### Ad Service Integration

Make sure to update **ALL** places where ads are shown:

- Interstitial ads
- Banner ads (top & bottom)
- Rewarded ads (if applicable)
- Native ads (if applicable)

### GetX Reactive Updates

Use `Obx(() { ... })` wrapper to automatically update UI when subscription status changes.

### Performance

The `isPremium` check is very fast (just reading a boolean). Don't worry about performance impact.

---

## Need Help?

See the main guide: `SUBSCRIPTION_SETUP_GUIDE.md`

---

**Quick Start Complete!** 🎉

Now users can remove ads by subscribing to your premium plan!
