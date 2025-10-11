# 📋 Quick Reference - App Structure

## 🎯 Feature Navigation

### Prayer Notifications → Prayer Screen
**How it works:**
1. User receives prayer notification
2. User taps notification
3. App navigates to Prayer Times screen
4. Shows current day's prayer times

**Code Location:**
- `lib/services/notification_service.dart` - Line ~96
- Method: `onActionReceivedMethod()`

### Banner Ads Display
**Location:** Below prayer list in Prayer Times screen

**Code:**
- `lib/view/prayer_times_screen.dart` - `_buildBannerAd()` method
- Controlled by: `AdService.areAdsDisabled` flag

## 🗂️ File Structure Quick Reference

```
📦 qibla_compass_offline
├── 📱 lib/
│   ├── 🎯 main.dart                    # App entry point
│   │
│   ├── 📁 controller/                  # Business Logic
│   │   ├── prayer_times_controller.dart     # Prayer times & scheduling
│   │   ├── qibla_controller.dart            # Compass logic
│   │   └── notification_settings_controller.dart
│   │
│   ├── 📁 services/                    # Backend Services
│   │   ├── notification_service.dart        # ⭐ Notifications + Navigation
│   │   ├── ad_service.dart                  # ⭐ AdMob integration
│   │   ├── prayer_times_service.dart        # API calls
│   │   ├── prayer_times_database.dart       # SQLite offline storage
│   │   ├── location_service.dart            # GPS
│   │   └── connectivity_service.dart        # Network status
│   │
│   ├── 📁 view/                        # UI Screens
│   │   ├── prayer_times_screen.dart         # ⭐ Main prayer UI + Banner Ad
│   │   ├── notification_settings_screen.dart
│   │   ├── optimized_home_screen.dart       # Qibla compass
│   │   └── main_navigation_screen.dart      # Bottom navigation
│   │
│   ├── 📁 model/                       # Data Models
│   │   └── prayer_times_model.dart
│   │
│   ├── 📁 routes/                      # Navigation
│   │   └── app_pages.dart                   # Route definitions
│   │
│   ├── 📁 bindings/                    # Dependency Injection
│   │   └── qibla_binding.dart
│   │
│   ├── 📁 constants/                   # App Constants
│   ├── 📁 utils/                       # Utility Functions
│   └── 📁 widget/                      # Reusable Widgets
│
├── 📁 android/                         # Android Configuration
│   └── app/
│       ├── build.gradle                     # Dependencies
│       └── src/main/
│           ├── AndroidManifest.xml          # Permissions
│           └── res/raw/
│               └── azan.mp3                 # Azan audio file
│
├── 📁 ios/                             # iOS Configuration
│   └── Runner/
│       └── Info.plist                       # iOS permissions
│
├── 📁 assets/                          # App Assets
│   ├── icons/                               # App icons
│   ├── images/                              # Images
│   └── audio/
│       └── azan.mp3                         # Azan audio
│
└── 📄 pubspec.yaml                     # Dependencies

```

## 🔑 Key Components

### 1. Notification System
**File**: `services/notification_service.dart`

**Key Methods:**
- `initialize()` - Setup notification channels
- `scheduleAzanNotification()` - Schedule single prayer
- `onActionReceivedMethod()` - ⭐ Handle notification taps
- `_playAzan()` - Play Azan audio
- `_stopAzan()` - Stop Azan audio

**Navigation Code:**
```dart
if (receivedAction.buttonKeyPressed.isEmpty) {
  // User tapped notification (not a button)
  Get.toNamed(Routes.PRAYER_TIMES);
}
```

### 2. Banner Ads
**File**: `view/prayer_times_screen.dart`

**Implementation:**
```dart
Widget _buildBannerAd() {
  final adService = Get.find<AdService>();
  return Obx(() {
    if (AdService.areAdsDisabled || !adService.isBannerAdLoaded.value) {
      return const SizedBox.shrink();
    }
    return Container(
      // Ad widget with styling
      child: AdWidget(ad: adService.bannerAd!),
    );
  });
}
```

**Usage in UI:**
```dart
Column(
  children: [
    _prayerTiles(controller),
    SizedBox(height: 16),
    _buildBannerAd(),  // ⭐ Banner ad here
    SizedBox(height: 28),
  ],
)
```

### 3. Prayer Times Controller
**File**: `controller/prayer_times_controller.dart`

**Key Features:**
- ✅ Offline-first (DB fallback)
- ✅ Monthly caching
- ✅ Auto location name
- ✅ Notification scheduling
- ✅ Next prayer countdown

**Main Methods:**
- `fetchPrayerTimes()` - Get prayer times for date
- `fetchAndCacheMonthlyPrayerTimes()` - Cache 2 months
- `enableNotifications()` - Turn on notifications
- `changeDate()` - Navigate dates
- `refreshPrayerTimes()` - Manual refresh

## 🎨 UI Components

### Prayer Times Screen Layout
```
┌─────────────────────────────────┐
│  📍 Location  🔔 📅 PRO         │ ← Header
├─────────────────────────────────┤
│  🌐 Offline Banner (conditional)│
│  ┌───────────────────────────┐ │
│  │ ⏰ UPCOMING               │ │
│  │ Fajr                      │ │ ← Next Prayer Card
│  │ Time left: 2h 30m         │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │ ← | Hijri & Gregorian | → │ │ ← Date Navigator
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │ 🌙 Fajr        05:30 AM ✓ │ │
│  │ ☀️ Sunrise     06:45 AM   │ │
│  │ ☀️ Dhuhr       12:30 PM   │ │ ← Prayer List
│  │ 🌤️ Asr         03:45 PM   │ │
│  │ 🌆 Maghrib     06:15 PM   │ │
│  │ 🌙 Isha        07:30 PM   │ │
│  └───────────────────────────┘ │
│  ┌───────────────────────────┐ │
│  │     [Banner Ad]           │ │ ← ⭐ Banner Ad
│  └───────────────────────────┘ │
└─────────────────────────────────┘
```

## 🔄 Data Flow Diagram

```
┌─────────────┐
│ App Launch  │
└──────┬──────┘
       │
       ▼
┌──────────────────┐     ┌─────────────────┐
│ Check Internet   │────►│ Online: API     │
│ Connection       │     │ Offline: DB     │
└──────┬───────────┘     └────────┬────────┘
       │                          │
       └──────────┬───────────────┘
                  │
                  ▼
         ┌────────────────┐
         │ Display Times  │
         └────────┬───────┘
                  │
                  ▼
         ┌────────────────────┐
         │ Schedule           │
         │ Notifications      │
         └────────┬───────────┘
                  │
      ┌───────────┴──────────┐
      │                      │
      ▼                      ▼
┌─────────────┐      ┌──────────────┐
│ Prayer Time │      │ User Taps    │
│ Reached     │      │ Notification │
└──────┬──────┘      └──────┬───────┘
       │                    │
       ▼                    ▼
┌─────────────┐      ┌──────────────┐
│ Show        │      │ Navigate to  │
│ Notification│      │ Prayer Screen│ ⭐
│ Play Azan   │      └──────────────┘
└─────────────┘
```

## ⚙️ Configuration Flags

### Ad Control
**File**: `services/ad_service.dart`

```dart
// Set to true for Play Store submission
// Set to false for production with ads
static const bool _disableAdsForStore = false;
```

### Notification Channels
**File**: `services/notification_service.dart`

```dart
// Prayer channel (with sound)
NotificationChannel(
  channelKey: 'prayer_channel',
  soundSource: 'resource://raw/azan',
  playSound: true,
)

// Silent channel (no sound)
NotificationChannel(
  channelKey: 'silent_channel',
  playSound: false,
)
```

## 🚀 Quick Commands

```bash
# Run app
flutter run

# Build APK
flutter build apk --release

# Check for errors
flutter analyze

# Clean and rebuild
flutter clean && flutter pub get && flutter run

# Check app size
flutter build apk --analyze-size
```

## 📊 Performance Tips

### Optimizations Applied
✅ Lazy loading of ads
✅ Cached prayer times (DB)
✅ Selective widget rebuilds (Obx)
✅ Const constructors
✅ Efficient list rendering
✅ Resource cleanup in onClose()

### Memory Management
✅ Singleton services
✅ Disposed controllers
✅ Audio player cleanup
✅ Ad disposal
✅ GetStorage for lightweight data

## 🐛 Common Issues

| Issue | Solution |
|-------|----------|
| Notification not navigating | ✅ Fixed in notification_service.dart |
| Banner ad not showing | Check `_disableAdsForStore` flag |
| RenderFlex overflow | ✅ Fixed with FittedBox |
| Location permission denied | Check AndroidManifest.xml |
| Azan not playing | Ensure azan.mp3 in res/raw/ |

## 📱 Testing Checklist

- [ ] Tap notification → Opens Prayer Times screen ⭐
- [ ] Banner ad displays below prayer list ⭐
- [ ] Offline mode works
- [ ] Date navigation works
- [ ] Notifications scheduled
- [ ] Azan plays on notification
- [ ] Location detected
- [ ] Pull-to-refresh works

---

**Quick Links:**
- Full Guide: `APP_OPTIMIZATION_GUIDE.md`
- Notification Docs: `NOTIFICATION_SYSTEM_DOCS.md`
- Setup Guide: `ANDROID_SETUP.md`
