# 🧪 Quick Test Guide for Notification Improvements

## How to Test the New Features

### 1️⃣ Test Beautiful Notification Design

#### Step 1: Enable Notifications
```bash
# Run the app
flutter run
```

1. Navigate to **Settings** → **Notification Settings**
2. Enable **Master Notifications** toggle
3. Enable notifications for at least one prayer (e.g., Fajr)

#### Step 2: Schedule a Test Notification
You can test immediately by modifying the schedule time to be 1-2 minutes from now:

**Option A: Use Debug Test Notification**
In your app, you could add a test button temporarily, or:

**Option B: Wait for Next Prayer**
- Check the "Next Prayer" card on home screen
- Wait for that prayer time
- Notification will appear automatically

#### Step 3: Verify Notification Appearance
When notification appears, check:
- ✅ Prayer-specific emoji (🌅 for Fajr, ☀️ for Dhuhr, etc.)
- ✅ Beautiful message: "Begin your day with peace. Time for Fajr prayer at 05:30"
- ✅ Time is formatted correctly (HH:MM)
- ✅ Location name appears (if available)
- ✅ Two buttons: "🔇 Stop Azan" and "✓ Prayed"

#### Step 4: Test Actions
- **Tap Notification Body**: Should navigate to Prayer Times screen
- **Tap "Stop Azan"**: Should stop the Azan audio
- **Tap "Prayed"**: Should dismiss notification

---

### 2️⃣ Test Fixed Time Calculation

#### Test Immediate Loading
1. Open the app
2. Navigate to **Prayer Times** screen
3. **Verify**: Next Prayer card shows immediately (NOT blank)
4. **Verify**: Time remaining shows (e.g., "2h 15m")

#### Test Real-Time Updates
1. Stay on Prayer Times screen
2. Wait for 1 minute
3. **Verify**: Time countdown updates (e.g., "2h 15m" → "2h 14m")

#### Test Status Messages
1. If prayer times are loading: Should show "Calculating..."
2. If next prayer is loading: Should show "Loading..."
3. When prayer time arrives: Should show "Now"

#### Test AM/PM Format
1. Check that times with AM/PM are parsed correctly
2. Example: "05:30 AM" should show Fajr in early morning
3. Example: "12:45 PM" should show Dhuhr at noon

#### Test Prayer Transition
1. Wait until a prayer time passes (or change device time)
2. **Verify**: Next prayer automatically updates to the following one
3. **Verify**: Time calculation updates correctly
4. **Verify**: No "Loading..." or blank states

---

### 3️⃣ Quick Visual Test

#### Expected Next Prayer Card Appearance
```
┌─────────────────────────────────────┐
│         🕌 NEXT PRAYER              │
│                                     │
│            Asr Prayer               │
│             14:30                   │
│                                     │
│         in 2h 15m                   │
│                                     │
│      Islamabad, Pakistan            │
└─────────────────────────────────────┘
```

#### Expected Notification Appearance
```
┌─────────────────────────────────────┐
│ 🌤️ Asr Prayer Time                 │
├─────────────────────────────────────┤
│ Afternoon prayer time.              │
│ Asr at 14:30                        │
│                                     │
│ 📍 Islamabad                        │
├─────────────────────────────────────┤
│  [🔇 Stop Azan]  [✓ Prayed]        │
└─────────────────────────────────────┘
```

---

### 4️⃣ Edge Case Testing

#### Test at Midnight (00:00)
- Next prayer should show "Fajr" (next day)
- Time should calculate correctly across day boundary

#### Test Between Isha and Midnight
- Next prayer should be "Fajr"
- Time calculation should show hours until next day's Fajr

#### Test Offline Mode
- Turn off internet
- **Verify**: Cached prayer times still calculate correctly
- **Verify**: Time countdown continues working

#### Test After All Prayers Pass
- After Isha prayer time passes
- **Verify**: Next prayer shows "Fajr" (tomorrow)
- **Verify**: Time calculation works for next day

---

### 5️⃣ Performance Testing

#### Check Memory Usage
```bash
# Run with performance overlay
flutter run --profile
```
- Open Prayer Times screen
- Check that animations run at 60 FPS
- Verify no memory leaks (use DevTools)

#### Check Notification Delivery
```bash
# Check device logs
adb logcat | grep "Scheduled notification"
```
Look for:
- `✓ Scheduled Fajr notification for...`
- `✓ Scheduled Dhuhr notification for...`
- etc.

---

### 6️⃣ Debug Console Output

#### Expected Console Messages

When scheduling notifications:
```
✓ Scheduled Fajr notification for 2025-10-13 05:30:00.000 (ID: 13100)
✓ Scheduled Dhuhr notification for 2025-10-13 12:45:00.000 (ID: 13101)
✓ Scheduled Asr notification for 2025-10-13 14:30:00.000 (ID: 13102)
✓ Scheduled Maghrib notification for 2025-10-13 18:30:00.000 (ID: 13103)
✓ Scheduled Isha notification for 2025-10-13 20:00:00.000 (ID: 13104)
```

When prayer time is skipped (already passed):
```
Skipping Fajr - time has passed (2025-10-13 05:30:00.000)
```

When notification is displayed:
```
Notification displayed: 13102
```

---

### 7️⃣ Manual Time Testing (Advanced)

To test without waiting for actual prayer times:

#### Method 1: Change Device Time
1. Go to device Settings → Date & Time
2. Disable "Automatic date & time"
3. Set time to 1 minute before a prayer
4. Return to app
5. Wait for notification

#### Method 2: Modify Code Temporarily
In `notification_service.dart`, change:
```dart
// Original
schedule: NotificationCalendar.fromDate(date: prayerTime),

// Test (schedules 1 minute from now)
schedule: NotificationCalendar.fromDate(
  date: DateTime.now().add(Duration(minutes: 1))
),
```

---

## ✅ Success Criteria

### Notification Design ✓
- [ ] Emoji shows correctly for each prayer
- [ ] Message is custom and meaningful
- [ ] Time is formatted as HH:MM
- [ ] Location name appears
- [ ] Buttons have emojis and clear labels
- [ ] Notification can be tapped to open app
- [ ] Actions work (Stop Azan, Prayed)

### Time Calculation ✓
- [ ] Shows immediately on screen open
- [ ] Updates every minute
- [ ] Shows status messages (Calculating, Loading, Now)
- [ ] Handles AM/PM format
- [ ] Auto-updates when prayer passes
- [ ] Works across day boundaries
- [ ] Works offline with cached data

### User Experience ✓
- [ ] No blank screens or loading delays
- [ ] Clear feedback at all times
- [ ] Smooth animations (60 FPS)
- [ ] No errors in console
- [ ] Notifications arrive on time
- [ ] Audio plays and stops correctly

---

## 🐛 If Something Doesn't Work

### Notification Not Showing
1. Check notification permissions: Settings → Apps → Your App → Notifications
2. Check battery optimization: Settings → Battery → Battery Optimization
3. Check console for scheduling messages

### Time Not Calculating
1. Check prayer times are loaded: See if list shows times
2. Check console for parsing errors
3. Verify date/time format in API response

### Audio Not Playing
1. Check that `assets/audio/azan.mp3` exists
2. Verify asset is listed in `pubspec.yaml`
3. Check device volume is not muted

---

## 📱 Device-Specific Notes

### Android
- Notifications should show in notification tray
- Azan should play even if phone is locked
- Full-screen intent may require permission (some Android versions)

### iOS
- Notifications require explicit permission
- Audio may not play if phone is in silent mode
- Test with ringer on

---

**Ready to Test?** Start with Step 1️⃣ and work through each section!

For detailed information, see: `NOTIFICATION_IMPROVEMENTS.md`
