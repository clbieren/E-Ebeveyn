import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kTutorialShownKey = 'home_tutorial_shown';

class TutorialNotifier extends StateNotifier<bool> {
  TutorialNotifier() : super(false);

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isShown = prefs.getBool(_kTutorialShownKey) ?? false;
    state = isShown;
  }

  Future<void> markAsShown() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kTutorialShownKey, true);
    state = true;
  }
}

final tutorialProvider = StateNotifierProvider<TutorialNotifier, bool>((ref) {
  final notifier = TutorialNotifier();
  notifier.init();
  return notifier;
});
