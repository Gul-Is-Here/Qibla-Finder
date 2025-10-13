# 🎨 Prayer Card Redesign

## New Prayer Card Layout

### Visual Design
```
┌─────────────────────────────────────────────────────┐
│  📍 Islamabad, Pakistan                             │
│                                                     │
│  Asr                               14:30           │
│  (Large Prayer Name)         (Prayer Time Box)     │
│                                                     │
│                                                     │
│  ⏰ 2h 15m left                                    │
│  (Time Remaining Badge)                            │
└─────────────────────────────────────────────────────┘
```

### Detailed Layout Structure

#### Top Section: Location
- **Icon**: 📍 Location pin (16px, white with 85% opacity)
- **Text**: User's current location
  - Font: Poppins, 13px, medium weight
  - Color: White 85% opacity
  - Overflow: Ellipsis (truncates if too long)

#### Middle Section: Prayer Name + Time
**Left Side - Prayer Name:**
- **Font**: Poppins, 32px, extra bold (800 weight)
- **Color**: White
- **Layout**: Takes available space (Expanded)
- **Example**: "Asr", "Fajr", "Maghrib"

**Right Side - Prayer Time:**
- **Container**: 
  - Background: White 20% opacity
  - Border: White 30% opacity, 1.5px
  - Padding: 16px horizontal, 10px vertical
  - Border radius: 14px
- **Time Text**:
  - Font: Roboto Mono, 24px, extra bold (800 weight)
  - Color: White
  - Format: "14:30", "05:45", "18:30"

#### Bottom Section: Time Remaining
- **Container**:
  - Background: White 15% opacity
  - Padding: 14px horizontal, 10px vertical
  - Border radius: 12px
  - Inline with content (mainAxisSize: min)

- **Content** (Row):
  - ⏰ Clock icon (18px, white 90% opacity)
  - **Time**: Roboto Mono, 20px, bold
    - Examples: "2h 15m", "45m", "Now"
  - **"left"**: Poppins, 14px, medium
    - Color: White 85% opacity

### Color Scheme
- **Background**: Gradient from `#00897B` to `#00695C` (teal)
- **Highlight blob**: White 10% opacity (top right)
- **All text**: White with varying opacity
- **Card height**: 200px (increased from 180px)
- **Border radius**: 22px

### Layout Hierarchy
```
Column (main container)
├── Row (Location)
│   ├── Icon (location pin)
│   └── Text (location name)
├── SizedBox (16px spacing)
├── Row (Prayer name + time)
│   ├── Expanded (Prayer name)
│   │   └── Text (large prayer name)
│   ├── SizedBox (12px spacing)
│   └── Container (Prayer time box)
│       └── Text (time in HH:MM)
├── Spacer (pushes bottom section down)
└── Container (Time left badge)
    └── Row
        ├── Icon (clock)
        ├── Text (time remaining)
        └── Text ("left")
```

### Animations
1. **Location**: AnimatedSwitcher with 300ms fade
2. **Prayer Name**: AnimatedSwitcher with 300ms transition
3. **Prayer Time**: AnimatedSwitcher with 300ms transition
4. **Time Left**: AnimatedSwitcher with FadeTransition
5. **Entire Card**: Pulse animation (scale 1.0 → 1.03) via ScaleTransition

### Responsive Behavior
- **Location**: Truncates with ellipsis if too long
- **Prayer Name**: Takes available space (Expanded)
- **Prayer Time**: Fixed width based on content
- **Time Left**: Fixed width based on content

### Data Source
```dart
// Location
controller.locationName.value
// Fallback: "Loading location..."

// Prayer Name
controller.nextPrayer.value
// Fallback: "Next Prayer"

// Prayer Time
controller.prayerTimes.value!.getAllPrayerTimes()[nextPrayerName]
// Format: "HH:MM"

// Time Remaining
controller.timeUntilNextPrayer.value
// Format: "2h 15m", "45m", or "Calculating..."
```

### Comparison: Before vs After

#### Before (Old Design)
```
┌─────────────────────────────────┐
│  UPCOMING                       │  ← Chip
│                                 │
│  Asr Prayer                     │  ← Name only
│                                 │
│  ⏰ Time left                   │  ← Label
│  2h 15m                         │  ← Time
│                                 │
│                  🕌             │  ← Badge icon
└─────────────────────────────────┘
```

#### After (New Design)
```
┌─────────────────────────────────┐
│  📍 Islamabad                   │  ← Location
│                                 │
│  Asr           14:30           │  ← Name + Time
│                                 │
│                                 │
│  ⏰ 2h 15m left                │  ← Time left
└─────────────────────────────────┘
```

### Key Improvements
1. ✅ **Location Added**: Shows user's current city/location
2. ✅ **Prayer Time Visible**: Time displayed prominently next to name
3. ✅ **Better Layout**: Name and time on same line
4. ✅ **Cleaner Design**: Removed "UPCOMING" chip and badge
5. ✅ **More Information**: All essential data in compact form
6. ✅ **Better Hierarchy**: Clear visual flow from top to bottom

### User Experience Flow
```
User Opens Screen
    ↓
Sees Location: "📍 Islamabad"
    ↓
Sees Next Prayer: "Asr" with time "14:30"
    ↓
Sees Time Remaining: "⏰ 2h 15m left"
    ↓
Understands: Asr prayer is at 14:30, 2h 15m from now, in Islamabad
```

### Mobile Preview (iPhone/Android)
```
╔═══════════════════════════════════════════╗
║  Prayer Times                              ║
╠═══════════════════════════════════════════╣
║                                           ║
║  ╭─────────────────────────────────────╮ ║
║  │ 📍 Islamabad, Pakistan              │ ║
║  │                                     │ ║
║  │ Asr                          14:30 │ ║
║  │                                     │ ║
║  │                                     │ ║
║  │ ⏰ 2h 15m left                     │ ║
║  ╰─────────────────────────────────────╯ ║
║                                           ║
║  < Friday, 13 Oct 2025 >                 ║
║                                           ║
║  ┌─────────────────────────────────────┐ ║
║  │ 🌅 Fajr          05:30             │ ║
║  └─────────────────────────────────────┘ ║
║  ┌─────────────────────────────────────┐ ║
║  │ ☀️ Dhuhr         12:45             │ ║
║  └─────────────────────────────────────┘ ║
║  ┌─────────────────────────────────────┐ ║
║  │ 🌤 Asr           14:30  [NEXT]     │ ║
║  └─────────────────────────────────────┘ ║
╚═══════════════════════════════════════════╝
```

### Technical Specifications

#### Container Dimensions
- **Height**: 200px
- **Width**: Screen width - 32px (16px margin each side)
- **Border Radius**: 22px
- **Padding**: 20px all sides

#### Typography Scale
- **Location**: 13px
- **Prayer Name**: 32px (largest)
- **Prayer Time**: 24px
- **Time Left Number**: 20px
- **Time Left Label**: 14px

#### Spacing Scale
- **Location to Name**: 16px
- **Name to Time Left**: Auto (Spacer)
- **Elements within Time Badge**: 6-8px

#### Color Palette
```dart
Primary Gradient: #00897B → #00695C
Text: #FFFFFF
Location Icon: #FFFFFF @ 85%
Location Text: #FFFFFF @ 85%
Prayer Name: #FFFFFF @ 100%
Prayer Time Box BG: #FFFFFF @ 20%
Prayer Time Box Border: #FFFFFF @ 30%
Prayer Time Text: #FFFFFF @ 100%
Time Left Badge BG: #FFFFFF @ 15%
Time Left Icon: #FFFFFF @ 90%
Time Left Text: #FFFFFF @ 100%
Time Left Label: #FFFFFF @ 85%
```

### Accessibility
- ✅ High contrast white on dark teal
- ✅ Clear hierarchy with size differences
- ✅ Icons accompany text for better understanding
- ✅ Large touch targets (entire card is interactive)
- ✅ Clear visual separation between sections

### Performance
- ✅ Lightweight AnimatedSwitcher for smooth updates
- ✅ No heavy animations (just fade transitions)
- ✅ Efficient layout (Column with Row children)
- ✅ Conditional rendering (prayer time only shows when available)

---

**Status**: ✅ Implemented and ready to test
**File**: `lib/view/prayer_times_screen.dart`
**Method**: `_nextPrayerCard()`
**Test**: Run `flutter run` to see the new design
