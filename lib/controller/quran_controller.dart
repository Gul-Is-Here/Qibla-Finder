import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../model/quran_model.dart';
import '../services/quran_service.dart';

// Simple audio handler for background playback
class _QuranAudioHandler extends BaseAudioHandler {
  final AudioPlayer _player;

  _QuranAudioHandler(this._player) {
    // Sync player state with audio service
    _player.playerStateStream.listen((state) {
      playbackState.add(
        playbackState.value.copyWith(
          playing: state.playing,
          controls: [
            MediaControl.skipToPrevious,
            state.playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
        ),
      );
    });
  }

  // Update current media item
  void updateMedia(String surahName, int ayahNumber, int totalAyahs) {
    mediaItem.add(
      MediaItem(
        id: '$surahName-$ayahNumber',
        album: surahName,
        title: 'Ayah $ayahNumber of $totalAyahs',
        artist: 'Quran Recitation',
        artUri: Uri.parse('https://via.placeholder.com/200x200.png?text=Quran'),
      ),
    );
  }

  @override
  Future<void> play() => _player.play();

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }
}

class QuranController extends GetxController {
  final QuranService _quranService = QuranService();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final ScrollController scrollController = ScrollController();
  AudioHandler? _audioHandler;

  // Observable state
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var surahs = <Surah>[].obs;
  var currentQuranData = Rxn<QuranData>();
  var currentAyahIndex = 0.obs;
  var isPlaying = false.obs;
  var audioProgress = 0.0.obs;
  var currentDuration = Duration.zero.obs;
  var totalDuration = Duration.zero.obs;
  var selectedReciter = 'ar.alafasy'.obs;
  var selectedTranslation = 'en.sahih'.obs;
  var showTranslation = true.obs;
  var autoScroll = true.obs;
  var isDownloadingAudio = false.obs;
  var downloadProgress = 0.0.obs;

  // Reciters and translations
  final reciters = <Map<String, String>>[].obs;
  final translations = <Map<String, String>>[].obs;

  // Cache directory
  Directory? _cacheDir;

  // Item keys for scrolling
  final Map<int, GlobalKey> ayahKeys = {};

  @override
  void onInit() {
    super.onInit();
    _initializeAudioService();
    _initializeAudioListeners();
    _initializeCacheDirectory();
    loadSurahs();
    reciters.value = _quranService.getReciters();
    translations.value = _quranService.getTranslations();
  }

  @override
  void onClose() {
    _audioPlayer.dispose();
    scrollController.dispose();
    _audioHandler?.stop();
    super.onClose();
  }

  /// Initialize audio service for background playback
  Future<void> _initializeAudioService() async {
    try {
      _audioHandler = await AudioService.init(
        builder: () => _QuranAudioHandler(_audioPlayer),
        config: AudioServiceConfig(
          androidNotificationChannelId: 'com.qibla.compass.quran',
          androidNotificationChannelName: 'Quran Audio',
          androidNotificationOngoing: true,
          androidStopForegroundOnPause: false,
        ),
      );

      // Listen to audio handler button presses
      _audioHandler?.playbackState.listen((state) {
        // Handle skip next/previous from notification
        if (state.processingState == AudioProcessingState.ready) {
          // You can add custom logic here if needed
        }
      });

      // Configure audio session for Quran playback
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      print('Error initializing audio service: $e');
      // Continue without background service if it fails
    }
  }

  /// Initialize audio player listeners
  void _initializeAudioListeners() {
    // Listen to player state
    _audioPlayer.playerStateStream.listen((state) {
      isPlaying.value = state.playing;

      // Auto-play next ayah when current finishes
      if (state.processingState == ProcessingState.completed) {
        playNextAyah();
      }
    });

    // Listen to position
    _audioPlayer.positionStream.listen((position) {
      currentDuration.value = position;
      if (totalDuration.value.inMilliseconds > 0) {
        audioProgress.value =
            position.inMilliseconds / totalDuration.value.inMilliseconds;
      }
    });

    // Listen to duration
    _audioPlayer.durationStream.listen((duration) {
      if (duration != null) {
        totalDuration.value = duration;
      }
    });
  }

  /// Initialize cache directory for audio files
  Future<void> _initializeCacheDirectory() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      _cacheDir = Directory('${dir.path}/quran_audio');
      if (!await _cacheDir!.exists()) {
        await _cacheDir!.create(recursive: true);
      }
    } catch (e) {
      print('Error initializing cache directory: $e');
    }
  }

  /// Get cached audio file path
  String _getCachedAudioPath(int surahNumber, int ayahNumber, String reciter) {
    return '${_cacheDir!.path}/${reciter}_${surahNumber}_$ayahNumber.mp3';
  }

  /// Check if audio is cached
  Future<bool> _isAudioCached(
    int surahNumber,
    int ayahNumber,
    String reciter,
  ) async {
    if (_cacheDir == null) return false;
    final file = File(_getCachedAudioPath(surahNumber, ayahNumber, reciter));
    return await file.exists();
  }

  /// Download and cache audio file
  Future<String> _downloadAndCacheAudio(
    String audioUrl,
    int surahNumber,
    int ayahNumber,
    String reciter,
  ) async {
    try {
      isDownloadingAudio.value = true;
      downloadProgress.value = 0.0;

      final response = await http.get(Uri.parse(audioUrl));

      if (response.statusCode == 200) {
        final filePath = _getCachedAudioPath(surahNumber, ayahNumber, reciter);
        final file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);

        downloadProgress.value = 1.0;
        isDownloadingAudio.value = false;

        return filePath;
      } else {
        throw Exception('Failed to download audio: ${response.statusCode}');
      }
    } catch (e) {
      isDownloadingAudio.value = false;
      downloadProgress.value = 0.0;
      print('Error downloading audio: $e');
      rethrow;
    }
  }

  /// Load all surahs
  Future<void> loadSurahs() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      surahs.value = await _quranService.getAllSurahs();
    } catch (e) {
      errorMessage.value = 'Error loading surahs: $e';
      Get.snackbar(
        'Error',
        'Failed to load surahs',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Load a specific surah with translation
  Future<void> loadSurah(int surahNumber) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      stopAudio(); // Stop any playing audio

      currentQuranData.value = await _quranService.getSurahWithTranslation(
        surahNumber,
        translationEdition: selectedTranslation.value,
      );

      currentAyahIndex.value = 0;
      audioProgress.value = 0.0;
      currentDuration.value = Duration.zero;
      totalDuration.value = Duration.zero;

      // Pre-download all audio files in background
      _preDownloadSurahAudio(surahNumber);
    } catch (e) {
      errorMessage.value = 'Error loading surah: $e';
      Get.snackbar(
        'Error',
        'Failed to load surah',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Pre-download all ayahs audio in background
  Future<void> _preDownloadSurahAudio(int surahNumber) async {
    try {
      if (currentQuranData.value == null) return;

      final quranData = currentQuranData.value!;

      // Show downloading indicator
      Get.snackbar(
        'Downloading Audio',
        'Preparing audio files for offline playback...',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      int downloadedCount = 0;
      final totalAyahs = quranData.ayahs.length;

      for (int i = 0; i < quranData.ayahs.length; i++) {
        final ayah = quranData.ayahs[i];

        // Skip if already cached
        final isCached = await _isAudioCached(
          surahNumber,
          ayah.numberInSurah,
          selectedReciter.value,
        );

        if (!isCached) {
          try {
            final audioUrl = _quranService.getAyahAudio(
              surahNumber,
              ayah.numberInSurah,
              reciter: selectedReciter.value,
            );

            await _downloadAndCacheAudio(
              audioUrl,
              surahNumber,
              ayah.numberInSurah,
              selectedReciter.value,
            );

            downloadedCount++;
            downloadProgress.value = downloadedCount / totalAyahs;
          } catch (e) {
            print('Error downloading ayah $i: $e');
            // Continue with next ayah even if one fails
          }
        }
      }

      // Show completion message
      Get.snackbar(
        'Download Complete',
        'All audio files are ready for offline playback',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

      downloadProgress.value = 0.0;
    } catch (e) {
      print('Error pre-downloading surah audio: $e');
    }
  }

  /// Play a specific ayah
  Future<void> playAyah(int ayahIndex) async {
    try {
      if (currentQuranData.value == null) return;

      final quranData = currentQuranData.value!;
      if (ayahIndex < 0 || ayahIndex >= quranData.ayahs.length) return;

      currentAyahIndex.value = ayahIndex;
      final ayah = quranData.ayahs[ayahIndex];

      // Check if audio is cached
      final isCached = await _isAudioCached(
        quranData.surah.number,
        ayah.numberInSurah,
        selectedReciter.value,
      );

      String audioPath;
      if (isCached) {
        // Use cached file
        audioPath = _getCachedAudioPath(
          quranData.surah.number,
          ayah.numberInSurah,
          selectedReciter.value,
        );
      } else {
        // Download and cache audio
        final audioUrl = _quranService.getAyahAudio(
          quranData.surah.number,
          ayah.numberInSurah,
          reciter: selectedReciter.value,
        );

        audioPath = await _downloadAndCacheAudio(
          audioUrl,
          quranData.surah.number,
          ayah.numberInSurah,
          selectedReciter.value,
        );
      }

      // Play from local file
      await _audioPlayer.setFilePath(audioPath);

      // Update notification with current ayah info
      if (_audioHandler != null && _audioHandler is _QuranAudioHandler) {
        (_audioHandler as _QuranAudioHandler).updateMedia(
          '${quranData.surah.englishName} (${quranData.surah.name})',
          ayah.numberInSurah,
          quranData.surah.numberOfAyahs,
        );
      }

      await _audioPlayer.play();

      // Auto-scroll to current ayah if enabled
      if (autoScroll.value) {
        scrollToCurrentAyah();
      }
    } catch (e) {
      isDownloadingAudio.value = false;
      Get.snackbar(
        'Error',
        'Failed to play audio: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Scroll to current playing ayah
  void scrollToCurrentAyah() {
    try {
      if (scrollController.hasClients && currentQuranData.value != null) {
        final index = currentAyahIndex.value;

        // Estimate item height and position
        // Each ayah tile is approximately 150-300px depending on content
        // Add header height (approximately 200px) and padding
        final estimatedItemHeight = 200.0;
        final headerHeight = 200.0;
        final targetPosition = (index * estimatedItemHeight) + headerHeight;

        // Scroll with animation
        scrollController.animateTo(
          targetPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    } catch (e) {
      print('Error scrolling to ayah: $e');
    }
  }

  /// Play next ayah
  Future<void> playNextAyah() async {
    if (currentQuranData.value == null) return;

    final nextIndex = currentAyahIndex.value + 1;
    if (nextIndex < currentQuranData.value!.ayahs.length) {
      await playAyah(nextIndex);
    } else {
      // Reached end of surah
      stopAudio();
      Get.snackbar(
        'Surah Complete',
        'You have reached the end of the surah',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  /// Play previous ayah
  Future<void> playPreviousAyah() async {
    if (currentQuranData.value == null) return;

    final prevIndex = currentAyahIndex.value - 1;
    if (prevIndex >= 0) {
      await playAyah(prevIndex);
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (isPlaying.value) {
      await pauseAudio();
    } else {
      if (currentDuration.value == Duration.zero) {
        await playAyah(currentAyahIndex.value);
      } else {
        await resumeAudio();
      }
    }
  }

  /// Pause audio
  Future<void> pauseAudio() async {
    await _audioPlayer.pause();
  }

  /// Resume audio
  Future<void> resumeAudio() async {
    await _audioPlayer.play();
  }

  /// Stop audio
  Future<void> stopAudio() async {
    await _audioPlayer.stop();
    isPlaying.value = false;
    audioProgress.value = 0.0;
    currentDuration.value = Duration.zero;
  }

  /// Change reciter
  Future<void> changeReciter(String reciterId) async {
    selectedReciter.value = reciterId;

    // If currently playing, restart with new reciter
    if (isPlaying.value) {
      final currentIndex = currentAyahIndex.value;
      await stopAudio();
      await playAyah(currentIndex);
    }
  }

  /// Change translation
  Future<void> changeTranslation(String translationId) async {
    selectedTranslation.value = translationId;

    // Reload current surah with new translation
    if (currentQuranData.value != null) {
      await loadSurah(currentQuranData.value!.surah.number);
    }
  }

  /// Seek to position
  Future<void> seekTo(double progress) async {
    final position = Duration(
      milliseconds: (progress * totalDuration.value.inMilliseconds).toInt(),
    );
    await _audioPlayer.seek(position);
  }

  /// Format duration to string
  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  /// Get Juz number for display
  String getJuzText(int juz) {
    return 'Juz $juz';
  }

  /// Get revelation type icon
  String getRevelationIcon(String type) {
    return type.toLowerCase() == 'meccan' ? '🕋' : '🕌';
  }

  /// Toggle translation visibility
  void toggleTranslation() {
    showTranslation.value = !showTranslation.value;
  }

  /// Toggle auto-scroll feature
  void toggleAutoScroll() {
    autoScroll.value = !autoScroll.value;
  }
}
