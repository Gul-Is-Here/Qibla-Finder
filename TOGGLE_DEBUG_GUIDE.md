# Toggle Button Debugging Guide

## Problem: Toggle buttons not activating in notification settings

### Symptoms

- User clicks toggle switch
- Switch doesn't visually change state
- Settings don't persist

### Debugging Steps Added

I've added debug print statements to the Pre-Prayer Reminders toggle to trace the issue:

```dart
onChanged: (value) async {
  print('🔔 Pre-Prayer toggle changed to: $value');
  print('🔔 Before write, storage value: ${enhancedService.prePrayerEnabled}');
  await enhancedService.setPrePrayerEnabled(value);
  print('🔔 After write, storage value: ${enhancedService.prePrayerEnabled}');
  setState(() {});
  print('🔔 After setState, storage value: ${enhancedService.prePrayerEnabled}');
},
```

### How to Test

1. **Run the app in debug mode:**

   ```bash
   flutter run
   ```

2. **Navigate to Settings → Prayer Notifications**

3. **Toggle the "Pre-Prayer Reminders" switch**

4. **Check the console output** for the debug prints

### Expected Console Output

If working correctly, you should see:

```
🔔 Pre-Prayer toggle changed to: true
🔔 Before write, storage value: false
🔔 After write, storage value: true
🔔 After setState, storage value: true
```

### Possible Issues & Solutions

#### Issue 1: Storage value doesn't change after write

**Console shows:**

```
🔔 After write, storage value: false  // ❌ Still false!
```

**Solution:** GetStorage write might be failing. Check:

- GetStorage is initialized in main.dart ✅ (already verified)
- Storage permissions on device
- Storage quota

**Fix:**

```dart
await GetStorage().write('pre_prayer_enabled', value);
print('Direct write result: ${GetStorage().read('pre_prayer_enabled')}');
```

#### Issue 2: setState not triggering rebuild

**Console shows all values correct, but UI doesn't update**

**Solution:** The widget might not be in the widget tree, or there's a parent widget preventing rebuild.

**Fix:** Wrap the entire widget in a StatefulBuilder:

```dart
StatefulBuilder(
  builder: (context, setState) {
    return EnhancedNotificationSettingsWidget();
  }
)
```

#### Issue 3: Value changes but reverts immediately

**Console shows value flipping back**

**Solution:** Another part of the code is overwriting the value.

**Fix:** Search for other places setting the same storage key.

#### Issue 4: GetStorage not persisting

**Value changes during session but lost on app restart**

**Solution:** GetStorage might not be flushing to disk.

**Fix:**

```dart
await enhancedService.setPrePrayerEnabled(value);
await GetStorage().save(); // Force flush to disk
setState(() {});
```

### Additional Debugging

Add similar prints to ALL toggle callbacks to see if it's a global issue or specific to certain toggles:

```dart
onChanged: (value) async {
  print('🔔 [FEATURE_NAME] toggle changed to: $value');
  print('🔔 [FEATURE_NAME] Before: ${enhancedService.GETTER}');
  await enhancedService.SETTER(value);
  print('🔔 [FEATURE_NAME] After: ${enhancedService.GETTER}');
  setState(() {});
  print('🔔 [FEATURE_NAME] Final: ${enhancedService.GETTER}');
},
```

### Testing the Dedicated Screen

The dedicated notification settings screen (`/notification-settings`) uses a different approach with StatefulBuilder and GetStorage directly:

```dart
StatefulBuilder(
  builder: (context, setState) {
    bool isEnabled = _storage.read(storageKey) ?? false;

    return Switch(
      value: isEnabled,
      onChanged: (value) async {
        await onChanged(value); // Writes to storage
        setState(() {}); // Rebuilds to read new value
      },
    );
  },
)
```

Test BOTH screens to see if the issue is in the widget or the service.

### Quick Fix to Try

If the issue persists, try this immediate fix - read directly from GetStorage instead of using the service getter:

```dart
Widget _buildSettingCard({
  required String storageKey, // Add this parameter
  // ... other params
}) {
  return StatefulBuilder(
    builder: (context, setState) {
      final storage = GetStorage();
      bool value = storage.read(storageKey) ?? false;

      return SwitchListTile(
        value: value,
        onChanged: (newValue) async {
          await storage.write(storageKey, newValue);
          setState(() {}); // Rebuilds with new value
        },
      );
    },
  );
}
```

### Verification Steps

After applying fixes:

1. ✅ Toggle switch - should animate immediately
2. ✅ Close settings and reopen - should show saved state
3. ✅ Kill and restart app - should persist
4. ✅ Toggle multiple switches - all should work
5. ✅ Check console for any errors

### Remove Debug Prints

Once issue is resolved, remove all debug print statements to clean up the code.

## Contact

If issue persists after trying all solutions, provide:

1. Console output from debug prints
2. Flutter doctor output
3. Device/emulator details
4. Steps to reproduce
