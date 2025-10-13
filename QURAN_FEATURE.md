# Quran Feature Documentation

## Overview
Complete Quran reading feature with audio playback, translation support, and real-time ayah tracking.

## Features Implemented

### 1. **Quran Data Models** (`lib/model/quran_model.dart`)
- **Surah**: Represents a chapter with metadata (number, name, translation, ayah count, revelation type)
- **Ayah**: Represents a verse with Arabic text, translation, Juz, page, and audio support
- **QuranData**: Combines surah metadata with its ayahs

### 2. **API Integration** (`lib/services/quran_service.dart`)
- **Data Source**: AlQuran Cloud API (https://api.alquran.cloud/v1)
- **Audio Source**: Islamic Network CDN (https://cdn.islamic.network/quran/audio)
- **Endpoints**:
  - `getAllSurahs()`: Fetch all 114 surahs
  - `getSurah(number)`: Get specific surah with Arabic text
  - `getSurahWithTranslation(number, edition)`: Get surah with translation merged
  - `getAyahAudio(surah, ayah, reciter)`: Generate audio URL for specific ayah

### 3. **Audio System** (`lib/controller/quran_controller.dart`)
- **Just Audio Integration**: Professional audio playback with stream listeners
- **Features**:
  - Play/pause/stop controls
  - Auto-advance to next ayah on completion
  - Previous/next ayah navigation
  - Progress tracking and seeking
  - Real-time position and duration updates
  - 8 reciter options (Alafasy, Abdul Basit, etc.)
  - 6 translation editions (Sahih International, Pickthall, Yusuf Ali, etc.)

### 4. **User Interface**

#### **Quran List Screen** (`lib/view/quran_list_screen.dart`)
- Grid/card layout of all 114 surahs
- Each card displays:
  - Surah number (circular badge)
  - English and Arabic names
  - English translation of the name
  - Number of ayahs
  - Revelation type indicator (Meccan 🕋 / Medinan 🕌)
- Search functionality (placeholder for future enhancement)
- Loading and error states with retry

#### **Quran Reader Screen** (`lib/view/quran_reader_screen.dart`)
- **Header**: Surah name in Arabic and English with Bismillah
- **Ayah Display**:
  - Large, clear Arabic text (Amiri Quran font)
  - Optional English translation (toggle-able)
  - Ayah number badge
  - Play button for each ayah
  - Metadata tags (Juz, Page)
- **Highlighting**: Current playing ayah has green border and background
- **Audio Player Controls**:
  - Progress bar with seeking
  - Time display (current / total)
  - Previous/Next ayah buttons
  - Large play/pause button
  - Current ayah indicator
- **Settings**:
  - Show/hide translation toggle
  - Auto-scroll toggle (for future enhancement)
  - Reciter selection dialog
  - Translation edition selection dialog

## Technical Implementation

### State Management
- **GetX** for reactive state management
- Observable variables for real-time UI updates
- Automatic dependency injection

### Audio Playback
```dart
// Stream listeners for real-time updates
_audioPlayer.playerStateStream.listen((state) {
  isPlaying.value = state.playing;
  if (state.processingState == ProcessingState.completed) {
    playNextAyah(); // Auto-advance
  }
});

_audioPlayer.positionStream.listen((position) {
  currentDuration.value = position;
  audioProgress.value = position / totalDuration;
});
```

### API Data Merging
The service merges Arabic text with translations:
```dart
// Fetch Arabic and translation separately
final arabicResponse = await http.get('/surah/$number');
final translationResponse = await http.get('/surah/$number/$edition');

// Merge ayah by ayah
for (int i = 0; i < arabicAyahs.length; i++) {
  ayahData['translation'] = translationAyahs[i]['text'];
  ayahs.add(Ayah.fromJson(ayahData));
}
```

## Reciters Available
1. **ar.alafasy** - Mishary Rashid Alafasy (default)
2. **ar.abdulbasitmurattal** - Abdul Basit (Murattal)
3. **ar.hudhaify** - Ali Al-Hudhaify
4. **ar.minshawi** - Mohamed Siddiq Al-Minshawi
5. **ar.muhammadayyoub** - Muhammad Ayyub
6. **ar.husary** - Mahmoud Khalil Al-Husary
7. **ar.abdurrahmaansudais** - Abdurrahman As-Sudais
8. **ar.shaatree** - Abu Bakr Ash-Shaatree

## Translation Editions
1. **en.sahih** - Sahih International (default)
2. **en.pickthall** - Pickthall
3. **en.yusufali** - Yusuf Ali
4. **en.shakir** - Shakir
5. **en.asad** - Muhammad Asad
6. **ur.jalandhry** - Jalandhry (Urdu)

## Navigation
- Added to bottom navigation bar (4th tab: "Quran")
- Routes defined in `lib/routes/app_pages.dart`:
  - `/quran-list`: Surah selection screen
  - `/quran-reader`: Ayah reading with audio

## Future Enhancements
1. **Auto-scroll**: Automatically scroll to highlighted ayah during playback
2. **Bookmarks**: Save favorite surahs and ayahs
3. **Last Read**: Remember last reading position
4. **Offline Mode**: Cache surahs and audio for offline reading
5. **Search**: Search within Quran text
6. **Tafsir**: Add Quranic commentary
7. **Word-by-word**: Display word-by-word translation
8. **Tajweed**: Highlight Tajweed rules
9. **Night Mode**: Dark theme for reading at night
10. **Audio Settings**: Playback speed, auto-repeat

## Dependencies
```yaml
dependencies:
  just_audio: ^0.9.38  # Professional audio playback
  google_fonts: ^6.2.1  # Amiri Quran font
  http: ^1.2.0  # API calls
  get: ^4.6.6  # State management
```

## Usage

### Initialize Controller
```dart
// In main.dart
Get.put(QuranController());
```

### Navigate to Quran
```dart
// From anywhere in the app
Get.toNamed(Routes.QURAN_LIST);
```

### Play Specific Ayah
```dart
final controller = Get.find<QuranController>();
await controller.loadSurah(1); // Load Surah Al-Fatiha
await controller.playAyah(0); // Play first ayah
```

### Change Reciter
```dart
controller.changeReciter('ar.hudhaify');
```

### Change Translation
```dart
controller.changeTranslation('en.yusufali');
```

## Color Scheme
- **Primary**: #00332F (Dark green)
- **Accent**: #8BC34A (Light green)
- **Background**: #F5F5F5 (Light gray)
- **Cards**: White with shadows
- **Highlights**: Green border and background

## Performance Considerations
- Lazy loading of surahs (load only when needed)
- Audio streaming (no need to download full file)
- Efficient state updates with GetX observables
- Smooth animations (300ms duration)

## Error Handling
- Network error recovery with retry option
- User-friendly error messages via snackbars
- Fallback states for missing data
- Audio playback error handling

## Testing
1. Test with different network conditions
2. Test all reciters and translations
3. Test audio controls (play, pause, seek, next, previous)
4. Test ayah highlighting during playback
5. Test settings changes (reciter, translation)
6. Test navigation between screens

## Credits
- **API**: AlQuran Cloud (https://alquran.cloud)
- **Audio**: Islamic Network (https://islamic.network)
- **Font**: Google Fonts - Amiri Quran
- **Audio Library**: Just Audio
