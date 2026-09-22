import 'package:flutter/services.dart';

import '../storage/hive_storage_service.dart';

/// Audio and Haptic feedback controller respecting player preferences.
class AudioHapticService {
  static final AudioHapticService _instance = AudioHapticService._internal();
  factory AudioHapticService() => _instance;
  AudioHapticService._internal();

  bool _hapticsEnabled = true;
  bool _soundEnabled = true;

  static bool get soundEnabled => _instance._soundEnabled;
  static set soundEnabled(bool value) => _instance._soundEnabled = value;

  static bool get hapticsEnabled => _instance._hapticsEnabled;
  static set hapticsEnabled(bool value) => _instance._hapticsEnabled = value;

  void init() {
    final settings = HiveStorageService().getSettings();
    _hapticsEnabled = settings['haptics'] as bool? ?? true;
    _soundEnabled = settings['soundFx'] as bool? ?? true;
  }

  void updateSettings({bool? haptics, bool? sound}) {
    if (haptics != null) _hapticsEnabled = haptics;
    if (sound != null) _soundEnabled = sound;
  }

  /// Light tick while dragging across adjacent letter cells
  void playDragTick() {
    if (_hapticsEnabled) {
      HapticFeedback.selectionClick();
    }
  }

  /// Medium pulse when a correct word is discovered
  void playWordFound() {
    if (_hapticsEnabled) {
      HapticFeedback.mediumImpact();
    }
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.click);
    }
  }

  /// Quick double vibration on invalid selection
  void playInvalidWord() {
    if (_hapticsEnabled) {
      HapticFeedback.lightImpact();
    }
  }

  /// Grand celebratory haptic on level victory
  void playLevelComplete() {
    if (_hapticsEnabled) {
      HapticFeedback.heavyImpact();
    }
    if (_soundEnabled) {
      SystemSound.play(SystemSoundType.alert);
    }
  }
}
