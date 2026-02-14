import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:void_surge/core/providers/preferences_provider.dart';

final tutorialCompletedProvider =
    NotifierProvider<TutorialCompletedNotifier, bool>(
  TutorialCompletedNotifier.new,
);

class TutorialCompletedNotifier extends Notifier<bool> {
  static const _key = 'tutorial_completed';

  @override
  bool build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return prefs.getBool(_key) ?? false;
  }

  void markCompleted() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_key, true);
    state = true;
  }

  void reset() {
    final prefs = ref.read(sharedPreferencesProvider);
    prefs.setBool(_key, false);
    state = false;
  }
}
