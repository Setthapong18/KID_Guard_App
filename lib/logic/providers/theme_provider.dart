// ==================== Theme Provider ====================
// จัดการ Dark Mode / Light Mode ของแอพ
//
// แก้ไข:
// - Cache SharedPreferences instance (ไม่ getInstance() ทุกครั้ง)
// - notifyListeners() ก่อน แล้วค่อย save async (UI response ทันที)
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _key = 'app_theme_mode';

  ThemeMode _themeMode = ThemeMode.light;
  SharedPreferences? _prefs; // cache — ไม่ getInstance() ทุกครั้ง

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs!.getString(_key) ?? 'light';
    _themeMode = saved == 'dark' ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  void setDarkMode(bool isDark) {
    if (_themeMode == (isDark ? ThemeMode.dark : ThemeMode.light)) return;
    // อัปเดต state และ notify ทันที — UI response instant
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
    // save async ทีหลัง — ไม่ block UI
    _saveToPrefs(isDark);
  }

  void toggleTheme() => setDarkMode(!isDarkMode);

  Future<void> _saveToPrefs(bool isDark) async {
    _prefs ??= await SharedPreferences.getInstance();
    await _prefs!.setString(_key, isDark ? 'dark' : 'light');
  }
}
