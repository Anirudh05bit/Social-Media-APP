import 'package:shared_preferences/shared_preferences.dart';

class FocusModeService {
  static const _enabledKey = "focus_enabled";
  static const _endTimeKey = "focus_end_time_ms";

  Future<void> enableForMinutes(int minutes) async {
    final prefs = await SharedPreferences.getInstance();
    final end = DateTime.now().add(Duration(minutes: minutes)).millisecondsSinceEpoch;
    await prefs.setBool(_enabledKey, true);
    await prefs.setInt(_endTimeKey, end);
  }

  Future<void> disable() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_enabledKey, false);
    await prefs.remove(_endTimeKey);
  }

  Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_enabledKey) ?? false;
    if (!enabled) return false;

    final end = prefs.getInt(_endTimeKey);
    if (end == null) return true; // manual focus mode with no end time

    final now = DateTime.now().millisecondsSinceEpoch;
    if (now >= end) {
      await disable(); // auto-expire
      return false;
    }
    return true;
  }

  Future<DateTime?> getEndTime() async {
    final prefs = await SharedPreferences.getInstance();
    final end = prefs.getInt(_endTimeKey);
    if (end == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(end);
  }
}