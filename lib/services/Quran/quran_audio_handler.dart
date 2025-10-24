import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

/// Background audio handler for Quran playback
/// Manages audio playback in background with notification controls
class QuranAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer _player = AudioPlayer();

  // Current playback info
  String currentSurahName = '';
  int currentAyahNumber = 0;
  int totalAyahs = 0;

  QuranAudioHandler() {
    _init();
  }

  Future<void> _init() async {
    // Listen to audio player state changes
    _player.playerStateStream.listen((state) {
      // Update playback state for notification
      final playing = state.playing;
      final processingState = state.processingState;

      playbackState.add(
        playbackState.value.copyWith(
          playing: playing,
          controls: [
            MediaControl.skipToPrevious,
            playing ? MediaControl.pause : MediaControl.play,
            MediaControl.skipToNext,
            MediaControl.stop,
          ],
          processingState:
              {
                ProcessingState.idle: AudioProcessingState.idle,
                ProcessingState.loading: AudioProcessingState.loading,
                ProcessingState.buffering: AudioProcessingState.buffering,
                ProcessingState.ready: AudioProcessingState.ready,
                ProcessingState.completed: AudioProcessingState.completed,
              }[processingState] ??
              AudioProcessingState.idle,
        ),
      );
    });

    // Listen to position updates
    _player.positionStream.listen((position) {
      playbackState.add(playbackState.value.copyWith(updatePosition: position));
    });

    // Listen to duration
    _player.durationStream.listen((duration) {
      if (duration != null) {
        mediaItem.add(mediaItem.value?.copyWith(duration: duration));
      }
    });
  }

  /// Update media item with current ayah info
  void updateCurrentMediaItem({
    required String surahName,
    required int ayahNumber,
    required int totalAyahs,
    String? artUri,
  }) {
    currentSurahName = surahName;
    currentAyahNumber = ayahNumber;
    this.totalAyahs = totalAyahs;

    mediaItem.add(
      MediaItem(
        id: '$surahName-$ayahNumber',
        album: surahName,
        title: 'Ayah $ayahNumber of $totalAyahs',
        artist: 'Quran Recitation',
        duration: _player.duration,
        artUri: artUri != null ? Uri.parse(artUri) : null,
        playable: true,
      ),
    );
  }

  /// Set audio source from file path
  Future<void> setAudioSource(String filePath) async {
    try {
      await _player.setFilePath(filePath);
    } catch (e) {
      print('Error setting audio source: $e');
    }
  }

  /// Set audio source from URL
  Future<void> setAudioUrl(String url) async {
    try {
      await _player.setUrl(url);
    } catch (e) {
      print('Error setting audio URL: $e');
    }
  }

  @override
  Future<void> play() async {
    await _player.play();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
  }

  @override
  Future<void> stop() async {
    await _player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  @override
  Future<void> skipToNext() async {
    // This will be handled by the controller
    // Just update state to indicate skip request
    playbackState.add(
      playbackState.value.copyWith(processingState: AudioProcessingState.ready),
    );
  }

  @override
  Future<void> skipToPrevious() async {
    // This will be handled by the controller
    // Just update state to indicate skip request
    playbackState.add(
      playbackState.value.copyWith(processingState: AudioProcessingState.ready),
    );
  }

  // Get current position
  Duration get position => _player.position;

  // Get duration
  Duration? get duration => _player.duration;

  // Get player state stream
  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  // Dispose
  Future<void> dispose() async {
    await _player.dispose();
  }
}
