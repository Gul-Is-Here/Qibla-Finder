# Spiritual Goal Onboarding Screen

## Overview

Created a beautiful first onboarding screen that asks users about their spiritual goal before showing notification and location permission screens.

## Features Implemented

### 1. **Screen Design**

- **Greeting**: "السلام عليكم" (As-salamu alaykum) in Arabic calligraphy
- **Welcome Text**: "Welcome to Muslim Pro"
- **App Logo**: Mosque icon in a gradient circle with shadow
- **Question**: "What is your spiritual goal?"

### 2. **Goal Options**

Two beautifully designed goal cards:

#### Pray Consistently

- Icon: Mosque
- Subtitle: "Never miss a prayer"
- Gradient: Purple (matches app theme)

#### Read Quran

- Icon: Book
- Subtitle: "Daily Quran reading"
- Gradient: Gold

### 3. **Interactive Elements**

- **Selection Animation**: Cards animate when selected with:
  - Border color change
  - Shadow enhancement
  - Checkmark appears
  - Icon gets gradient background
- **Button State**: "Bismillah, Let's Start" button is:
  - Disabled (greyed out) when no goal selected
  - Enabled with shadow when goal selected
  - Contains Arabic "بِسْمِ اللهِ" and "Let's Start"
  - Has arrow icon

### 4. **Setup Message**

Info box with text: "Setup your app and stay on track"

### 5. **Navigation Flow**

```
Splash Screen
  ↓
Spiritual Goal Screen (NEW - First)
  ↓
Notification Permission Screen
  ↓
Location Permission Screen
  ↓
Main App
```

## Technical Details

### Files Created/Modified

1. **Created**: `lib/views/onboarding/spiritual_goal_screen.dart`
   - Complete onboarding screen with animations
   - Saves selected goal to GetStorage
   - Beautiful UI matching app theme

2. **Modified**: `lib/routes/app_pages.dart`
   - Added `SPIRITUAL_GOAL` route
   - Added route definition for new screen

3. **Modified**: `lib/views/splash_screen.dart`
   - Changed initial navigation from `NOTIFICATION_PERMISSION` to `SPIRITUAL_GOAL`

### Color Scheme

- Primary Purple: `#8F66FF`
- Light Purple: `#AB80FF`
- Gold Accent: `#D4AF37`

### Animations

- Fade-in animation for entire screen
- Scale animation for goal cards on selection
- Smooth transitions for button states
- Animated opacity for disabled/enabled button

### Data Storage

Saves to GetStorage:

- `spiritual_goal`: User's selected goal ID ('pray_consistently' or 'read_quran')
- `onboarding_completed_step_1`: Boolean flag for completion

## Design Philosophy

- **Clean & Minimal**: Focused on one question at a time
- **Islamic Touch**: Arabic greetings and Bismillah on button
- **Professional**: Smooth animations and gradients
- **User-Friendly**: Clear visual feedback on selections
- **Motivational**: Helps users set their spiritual intentions

## Future Enhancements

Could add more goal options:

- Learn Arabic
- Memorize Quran
- Study Hadith
- Perform Hajj/Umrah
- Increase Charity

## Testing

Test the flow:

1. Clear app data to see onboarding
2. Launch app → should see Spiritual Goal screen first
3. Try selecting different goals
4. Verify button enables after selection
5. Confirm navigation to Notification Permission screen
