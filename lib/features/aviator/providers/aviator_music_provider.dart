import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider to manage music on/off state
final aviatorMusicProvider = StateNotifierProvider<AviatorMusicNotifier, bool>(
  (ref) => AviatorMusicNotifier(),
);

class AviatorMusicNotifier extends StateNotifier<bool> {
  AviatorMusicNotifier() : super(true); // Default to ON

  void toggle() {
    state = !state;
  }

  void setMusic(bool value) {
    state = value;
  }
}

// Provider to manage start sound on/off state
final aviatorStartSoundProvider =
    StateNotifierProvider<AviatorStartSoundNotifier, bool>(
      (ref) => AviatorStartSoundNotifier(),
    );

class AviatorStartSoundNotifier extends StateNotifier<bool> {
  AviatorStartSoundNotifier() : super(true); // Default to ON

  void toggle() {
    state = !state;
  }

  void setStartSound(bool value) {
    state = value;
  }
}
