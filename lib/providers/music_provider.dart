import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:panda_study_buddy/core/constants/app_constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Music state
class MusicState {
  final bool isPlaying;
  final bool isMusicEnabled;
  final bool isLoading;

  const MusicState({
    this.isPlaying = false,
    this.isMusicEnabled = true,
    this.isLoading = true,
  });

  MusicState copyWith({
    bool? isPlaying,
    bool? isMusicEnabled,
    bool? isLoading,
  }) {
    return MusicState(
      isPlaying: isPlaying ?? this.isPlaying,
      isMusicEnabled: isMusicEnabled ?? this.isMusicEnabled,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Music provider notifier
class MusicNotifier extends StateNotifier<MusicState> {
  final AudioPlayer _audioPlayer;
  SharedPreferences? _prefs;

  MusicNotifier()
      : _audioPlayer = AudioPlayer(),
        super(const MusicState()) {
    _initialize();
  }

  /// Initialize audio player and load preferences
  Future<void> _initialize() async {
    try {
      // Load preferences
      _prefs = await SharedPreferences.getInstance();
      final isMusicEnabled = _prefs?.getBool(AppConstants.musicEnabledKey) ?? true;

      // Configure audio player
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.setVolume(AppConstants.defaultMusicVolume);
      await _audioPlayer.setSource(AssetSource('sounds/focus_music.mp3'));

      // Update state
      state = state.copyWith(
        isMusicEnabled: isMusicEnabled,
        isLoading: false,
      );
    } catch (e) {
      // If there's an error (e.g., file not found), disable music
      state = state.copyWith(
        isMusicEnabled: false,
        isLoading: false,
      );
      print('Error initializing music player: $e');
    }
  }

  /// Play music if enabled
  Future<void> play() async {
    if (!state.isMusicEnabled || state.isLoading) {
      return;
    }

    try {
      await _audioPlayer.resume();
      state = state.copyWith(isPlaying: true);
    } catch (e) {
      print('Error playing music: $e');
    }
  }

  /// Pause music
  Future<void> pause() async {
    if (!state.isPlaying) {
      return;
    }

    try {
      await _audioPlayer.pause();
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      print('Error pausing music: $e');
    }
  }

  /// Stop music
  Future<void> stop() async {
    if (!state.isPlaying) {
      return;
    }

    try {
      await _audioPlayer.stop();
      state = state.copyWith(isPlaying: false);
    } catch (e) {
      print('Error stopping music: $e');
    }
  }

  /// Resume music
  Future<void> resume() async {
    await play();
  }

  /// Toggle music enabled state
  Future<void> toggleMusicEnabled() async {
    final newValue = !state.isMusicEnabled;

    // Save to preferences
    await _prefs?.setBool(AppConstants.musicEnabledKey, newValue);

    // Update state
    state = state.copyWith(isMusicEnabled: newValue);

    // Stop music if disabled
    if (!newValue && state.isPlaying) {
      await stop();
    }
    else {
      await resume();
    }
  }

  /// Set music enabled state
  Future<void> setMusicEnabled(bool enabled) async {
    if (state.isMusicEnabled == enabled) {
      return;
    }

    // Save to preferences
    await _prefs?.setBool(AppConstants.musicEnabledKey, enabled);

    // Update state
    state = state.copyWith(isMusicEnabled: enabled);

    // Stop music if disabled
    if (!enabled && state.isPlaying) {
      await stop();
    }
  }

  /// Set volume
  Future<void> setVolume(double volume) async {
    try {
      await _audioPlayer.setVolume(volume);
    } catch (e) {
      print('Error setting volume: $e');
    }
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}

/// Music provider
final musicProvider = StateNotifierProvider<MusicNotifier, MusicState>((ref) {
  return MusicNotifier();
});

