import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:void_surge/core/providers/preferences_provider.dart';

class GameSettings {
  final bool bgmEnabled;
  final bool sfxEnabled;
  final bool hapticEnabled;

  const GameSettings({
    this.bgmEnabled = true,
    this.sfxEnabled = true,
    this.hapticEnabled = true,
  });

  GameSettings copyWith({
    bool? bgmEnabled,
    bool? sfxEnabled,
    bool? hapticEnabled,
  }) {
    return GameSettings(
      bgmEnabled: bgmEnabled ?? this.bgmEnabled,
      sfxEnabled: sfxEnabled ?? this.sfxEnabled,
      hapticEnabled: hapticEnabled ?? this.hapticEnabled,
    );
  }
}

final settingsProvider = NotifierProvider<SettingsNotifier, GameSettings>(
  SettingsNotifier.new,
);

class SettingsNotifier extends Notifier<GameSettings> {
  static const _bgmKey = 'settings_bgm';
  static const _sfxKey = 'settings_sfx';
  static const _hapticKey = 'settings_haptic';

  @override
  GameSettings build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return GameSettings(
      bgmEnabled: prefs.getBool(_bgmKey) ?? true,
      sfxEnabled: prefs.getBool(_sfxKey) ?? true,
      hapticEnabled: prefs.getBool(_hapticKey) ?? true,
    );
  }

  void toggleBgm() {
    final prefs = ref.read(sharedPreferencesProvider);
    final newValue = !state.bgmEnabled;
    prefs.setBool(_bgmKey, newValue);
    state = state.copyWith(bgmEnabled: newValue);
  }

  void toggleSfx() {
    final prefs = ref.read(sharedPreferencesProvider);
    final newValue = !state.sfxEnabled;
    prefs.setBool(_sfxKey, newValue);
    state = state.copyWith(sfxEnabled: newValue);
  }

  void toggleHaptic() {
    final prefs = ref.read(sharedPreferencesProvider);
    final newValue = !state.hapticEnabled;
    prefs.setBool(_hapticKey, newValue);
    state = state.copyWith(hapticEnabled: newValue);
  }
}
