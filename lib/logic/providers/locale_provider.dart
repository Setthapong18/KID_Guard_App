// ==================== Locale Provider ====================
// จัดการภาษาของแอพ (ไทย/อังกฤษ)
//
// เก็บค่าภาษาปัจจุบันและ persist ไว้ใน SharedPreferences
// เมื่อเปลี่ยนภาษา จะ notify ให้ MaterialApp rebuild UI ทั้งหมด
//
// ค่าเริ่มต้น: ภาษาไทย ('th')
// ภาษาที่รองรับ: 'th' (ไทย), 'en' (อังกฤษ)
//
// วิธีใช้:
// - อ่านภาษาปัจจุบัน: context.read<LocaleProvider>().locale
// - เปลี่ยนภาษา: context.read<LocaleProvider>().setLocale('en')
//
// ใช้ร่วมกับ:
// - MaterialApp → locale: localeProvider.locale
// - AppLocalizations → ดึงข้อความตามภาษา
// - LanguageSettingsScreen → หน้าเปลี่ยนภาษา
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleProvider extends ChangeNotifier {
  static const String _key = 'app_language'; // key ใน SharedPreferences

  Locale _locale = const Locale('th'); // ค่าเริ่มต้น: ภาษาไทย

  /// ดึง Locale ปัจจุบัน
  Locale get locale => _locale;

  /// โหลดภาษาจาก SharedPreferences ตอนสร้าง instance
  LocaleProvider() {
    _loadFromPrefs();
  }

  /// โหลดค่าภาษาจาก SharedPreferences
  /// ถ้าไม่มีค่าเก็บไว้จะใช้ 'th' (ภาษาไทย)
  Future<void> _loadFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLang = prefs.getString(_key) ?? 'th';
    _locale = Locale(savedLang);
    notifyListeners();
  }

  /// เปลี่ยนภาษาและบันทึกค่าลง SharedPreferences
  /// [languageCode] - รหัสภาษา: 'th' หรือ 'en'
  Future<void> setLocale(String languageCode) async {
    _locale = Locale(languageCode);
    notifyListeners(); // บอก MaterialApp ให้ rebuild

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, languageCode);
  }

  /// ดึงรหัสภาษาปัจจุบัน (เช่น 'th' หรือ 'en')
  String get languageCode => _locale.languageCode;
}
