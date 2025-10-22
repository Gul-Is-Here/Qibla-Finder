# Manual Qibla Direction Feature

## Overview

Added support for manual Qibla direction adjustment when GPS location is not available. The app now works in two modes:

### 1. **Automatic Mode (Location Available)**

- Uses GPS coordinates to calculate accurate Qibla direction
- Shows "Location Ready - Accurate Qibla" status
- Green location icon indicator

### 2. **Manual Mode (No Location)**

- Uses mobile compass heading with manually set Qibla angle
- Shows manual adjustment controls
- Orange location icon indicator
- User can fine-tune the Qibla direction

## Features Implemented

### QiblaController Changes

1. **New Observables:**

   - `manualQiblaAngle`: Stores the manual Qibla angle (0-360°)
   - `useManualQibla`: Flag indicating if manual mode is active

2. **New Methods:**

   - `setManualQiblaAngle(double angle)`: Sets the manual Qibla angle
   - `adjustManualQiblaAngle(double delta)`: Adjusts angle by delta value
   - Manual angle is persisted in local storage

3. **Enhanced Calculation:**
   - `_calculateQiblaDirection()` now falls back to manual angle when location is unavailable
   - Manual angle is loaded from storage on app start

### Compass Screen Changes

1. **Status Indicator:**

   - Shows different icon colors (green/orange) based on location status
   - Displays appropriate status message

2. **Manual Controls (shown when no location):**

   - **-10°** button: Decrease angle by 10 degrees
   - **-1°** button: Decrease angle by 1 degree
   - **Center Display**: Shows current manual angle
   - **+1°** button: Increase angle by 1 degree
   - **+10°** button: Increase angle by 10 degrees

3. **User Guidance:**
   - Info icon with helper text
   - Instructions to rotate device and adjust as needed

## How It Works

### Location Available Flow:

```
GPS Location → Calculate Qibla from Kaaba coords → Display accurate direction
```

### No Location Flow:

```
Manual Angle (stored) → Use compass heading → User adjusts angle → Direction displayed
```

## User Instructions

### When Location is Not Available:

1. The compass will still show direction based on your phone's compass
2. Use the adjustment buttons to set the correct Qibla angle for your location
3. You can look up your city's Qibla direction online and set it manually
4. The angle is saved and will be used next time you open the app

### Finding Your Qibla Angle:

- Search online for "Qibla direction from [Your City]"
- Use another Qibla app with location to get the angle
- Ask your local mosque for the Qibla direction in degrees

## Technical Details

- Manual angle stored in GetStorage as `'manualQiblaAngle'`
- Default value: 0° (North)
- Angle normalized to 0-360° range
- Compass widget works identically in both modes
- Smooth transition between manual and automatic modes

## Benefits

1. **Works Offline**: Compass functions without GPS
2. **Privacy**: Users can use the app without granting location permission
3. **Battery Saving**: No GPS usage in manual mode
4. **Flexibility**: Useful in areas with poor GPS signal
5. **Indoor Use**: Works inside buildings where GPS is weak

## Future Enhancements (Optional)

- Add preset angles for major cities
- Slider control for smoother adjustment
- Visual alignment helper (when compass aligns with Qibla)
- Save multiple locations with their Qibla angles
- Auto-detect city from IP and suggest angle
