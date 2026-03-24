import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';

import '../constants/app_sounds.dart';

class SoundManager {
  // static final AudioPlayer _audioPlayer = AudioPlayer();
  static final AudioPlayer _backgroundPlayer = AudioPlayer();
  static final AudioPlayer _soundEffectsPlayer =
      AudioPlayer(); // Separate player for sound effects

  // static Future<void> play(String source) async {
  //   await _audioPlayer.play(AssetSource(source));
  // }

  static Future<void> playBackground(String source) async {
    try {
      // Set audio context to allow mixing with other audio
      await _backgroundPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.music,
            usageType: AndroidUsageType.media,
            audioFocus: AndroidAudioFocus.gain,
          ),
        ),
      );
      await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);
      await _backgroundPlayer.play(AssetSource(source));
      log('✅ Playing background music: $source');
    } catch (e) {
      log('❌ Error playing background music: $e');
    }
  }

  static Future<void> stopBackground() async {
    if (_backgroundPlayer.state == PlayerState.playing ||
        _backgroundPlayer.state == PlayerState.paused) {
      await _backgroundPlayer.stop();
      log('🛑 Stopped background music');
    }
  }

  static Future<void> pauseBackground() async {
    if (_backgroundPlayer.state == PlayerState.playing) {
      await _backgroundPlayer.pause();
      log('⏸️ Paused background music');
    }
  }

  static Future<void> resumeBackground() async {
    if (_backgroundPlayer.state == PlayerState.paused) {
      await _backgroundPlayer.resume();
      log('▶️ Resumed background music');
    }
  }

  //! AVIATOR
  // Optional: predefined app sounds
  static Future<void> aviatorMusic() =>
      playBackground(AppSounds.aviatorBgMusic);
  static Future<void> stopAviatorMusic() => stopBackground();

  // Play start sound (plays once, not looping) - uses separate player
  static Future<void> aviatorStartSound() async {
    try {
      // Set audio context to allow mixing with background music
      await _soundEffectsPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
        ),
      );
      await _soundEffectsPlayer.play(AssetSource(AppSounds.aviatorStartSound));
      log('✅ Playing start sound');
    } catch (e) {
      log('❌ Error playing start sound: $e');
    }
  }

  // Play flew away sound (plays once when plane crashes) - uses separate player
  static Future<void> aviatorFlewAwaySound() async {
    try {
      // Set audio context to allow mixing with background music
      await _soundEffectsPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
        ),
      );
      await _soundEffectsPlayer.play(
        AssetSource(AppSounds.aviatorFlewAwaySound),
      );
      log('✅ Playing flew away sound');
    } catch (e) {
      log('❌ Error playing flew away sound: $e');
    }
  }

  //! CRASH

  static Future<void> crashMusic() => playBackground(AppSounds.crashBgMusic);
  static Future<void> stopCrashMusic() => stopBackground();

  // Play start sound (plays once, not looping) - uses separate player
  static Future<void> crashStartSound() async {
    try {
      // Set audio context to allow mixing with background music
      await _soundEffectsPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
        ),
      );
      await _soundEffectsPlayer.play(AssetSource(AppSounds.crashStartSound));
      log('✅ Playing start sound');
    } catch (e) {
      log('❌ Error playing start sound: $e');
    }
  }

  static Future<void> crashEndSound() async {
    try {
      // Set audio context to allow mixing with background music
      await _soundEffectsPlayer.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            category: AVAudioSessionCategory.playback,
            options: {AVAudioSessionOptions.mixWithOthers},
          ),
          android: AudioContextAndroid(
            isSpeakerphoneOn: false,
            stayAwake: false,
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.game,
            audioFocus: AndroidAudioFocus.gainTransient,
          ),
        ),
      );
      await _soundEffectsPlayer.play(AssetSource(AppSounds.crashEndSound));
      log('✅ Playing end sound');
    } catch (e) {
      log('❌ Error playing end sound: $e');
    }
  }
}
