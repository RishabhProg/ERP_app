import 'package:shared_preferences/shared_preferences.dart';

class BackgroundStorage {
  static const _key = "selected_background";

  static Future<void> saveIndex(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, index);
  }

  static Future<int> loadIndex() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 0;
  }
}