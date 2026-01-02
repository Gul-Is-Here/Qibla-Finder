# Onboarding Prayer Times Data Loading

## Overview

This document explains how prayer times and Qibla data are loaded and cached during the onboarding flow.

## Implementation Summary

### Location Permission Screen Enhancement

**File**: `lib/views/onboarding/location_permission_screen.dart`

When the user grants location permission, the app now:

1. **Shows Loading Dialog**

   - Non-dismissible dialog with loading spinner
   - Shows "Loading Prayer Times..." message
   - Explains what's happening to the user

2. **Initializes Prayer Times Controller**

   - Checks if `PrayerTimesController` is already registered
   - Gets existing instance or creates new one
   - Ensures controller is available for data loading

3. **Fetches Prayer Times & Qibla Data**

   - Calls `prayerController.fetchPrayerTimes()`
   - Gets user's current location
   - Fetches prayer times from API
   - **Automatically caches data to local database**
   - Calculates Qibla direction

4. **Handles Success/Error States**

   - **Success**: Shows success snackbar, navigates to main screen
   - **Error**: Shows warning snackbar, allows user to continue (can retry later from app)
   - Closes loading dialog in both cases

5. **Completes Onboarding**
   - Marks onboarding as completed in GetStorage
   - Navigates to main screen

## Caching Mechanism

### Automatic Caching

The `PrayerTimesController` automatically handles caching:

1. **First Load** (after location permission):

   - Fetches from API
   - Saves to local SQLite database
   - Updates UI with fresh data

2. **Subsequent Launches**:
   - Checks database for cached data first
   - Loads from cache immediately (instant load)
   - Syncs with API in background if online
   - Falls back to cache if offline

### Database Storage

- Prayer times stored with:
  - Date
  - Latitude/Longitude coordinates
  - Location name
  - All prayer times (Fajr, Dhuhr, Asr, Maghrib, Isha, Sunrise)

## User Experience Flow

```
1. Splash Screen
   ↓
2. Notification Permission Screen
   ↓
3. Location Permission Screen
   ↓
4. [User grants location]
   ↓
5. Loading Dialog appears
   ├─ "Loading Prayer Times..."
   └─ Purple spinner animation
   ↓
6. Prayer times fetched & cached
   ↓
7. Success message
   ↓
8. Navigate to Main Screen
   ↓
9. Prayer times already loaded! ✨
```

## Benefits

1. **Faster Subsequent Launches**

   - Data loaded from cache instantly
   - No waiting on API calls
   - Works offline

2. **Better First-Time Experience**

   - User sees loading progress
   - Clear feedback on what's happening
   - Data preloaded before main screen

3. **Reduced API Calls**

   - Cache-first strategy
   - Background sync when online
   - Saves bandwidth and API quota

4. **Offline Support**
   - Prayer times available without internet
   - Falls back to cached data
   - Only needs internet for updates

## Error Handling

### Location Permission Denied

- Shows error snackbar
- Still completes onboarding
- User can enable location later from settings

### API Fetch Failed

- Shows warning message
- Allows user to continue
- User can retry from main app (pull to refresh)

### No Internet Connection

- First-time users: Shows error, can retry later
- Returning users: Loads from cache seamlessly

## Technical Details

### Key Components

- **PrayerTimesController**: Manages prayer times state and API calls
- **LocationService**: Handles location permissions and coordinates
- **Database**: SQLite storage for cached prayer times
- **GetStorage**: Simple key-value storage for onboarding state

### Modified Files

1. `lib/views/onboarding/location_permission_screen.dart`
   - Added prayer controller integration
   - Added loading dialog
   - Enhanced error handling

### Dependencies

```yaml
get: State management
get_storage: Persistent storage
sqflite: Local database
geolocator: Location services
```

## Testing Checklist

- [ ] Grant location permission → Prayer times load
- [ ] Deny location permission → Still navigate to app
- [ ] No internet on first launch → Error handled gracefully
- [ ] No internet on subsequent launch → Loads from cache
- [ ] Loading dialog appears and dismisses properly
- [ ] Success/error messages show correctly
- [ ] Prayer times available on main screen after onboarding

## Future Improvements

- [ ] Add offline indicator in loading dialog
- [ ] Show cached data timestamp
- [ ] Add manual refresh option in error state
- [ ] Preload monthly prayer times data
- [ ] Add loading progress percentage
