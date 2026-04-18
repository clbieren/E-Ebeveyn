import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final aiCreditProvider = StateNotifierProvider<AiCreditNotifier, int>((ref) {
  return AiCreditNotifier();
});

class AiCreditNotifier extends StateNotifier<int> {
  static const int _maxCredits = 3;
  static const String _creditKey = 'ai_coach_credits';
  static const String _lastDateKey = 'ai_coach_last_date';

  AiCreditNotifier() : super(0) {
    _init();
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final lastDateStr = prefs.getString(_lastDateKey);
    final todayStr = _getTodayStr();

    if (lastDateStr != todayStr) {
      // New day, reset credits
      await resetCredits();
    } else {
      // Same day, load existing credits
      final storedCredits = prefs.getInt(_creditKey) ?? _maxCredits;
      state = storedCredits;
    }
  }

  String _getTodayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  Future<void> resetCredits() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_creditKey, _maxCredits);
    await prefs.setString(_lastDateKey, _getTodayStr());
    state = _maxCredits;
  }

  Future<bool> useCredit() async {
    if (state <= 0) return false;
    final prefs = await SharedPreferences.getInstance();
    final newCredits = state - 1;
    await prefs.setInt(_creditKey, newCredits);
    state = newCredits;
    return true;
  }

  Future<void> earnCredit() async {
    final prefs = await SharedPreferences.getInstance();
    final newCredits = state + 1;
    await prefs.setInt(_creditKey, newCredits);
    state = newCredits;
  }
}
