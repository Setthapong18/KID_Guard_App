// ==================== Secure Storage Service ====================
// จัดการข้อมูลสำคัญโดยใช้ Android Keystore / iOS Keychain
// ผ่าน flutter_secure_storage
//
// หลักการแบ่ง:
// ✅ Secure Storage (ไฟล์นี้):
//    - activeParentPin    → PIN ผู้ปกครองที่ตั้งไว้
//    - activeParentUid    → Firebase UID ของผู้ปกครอง
//    - activeChildId      → Document ID ของลูก
//    - current_child_id   → ใช้ใน background worker
//    - current_parent_uid → ใช้ใน background worker
//
// 🟢 SharedPreferences (ยังใช้ได้):
//    - notif_*           → notification on/off flags
//    - isChildModeActive → session flag (non-sensitive)
//    - app_locale        → ภาษา
//    - hasSeenOnboarding → onboarding flag
//
// วิธีใช้:
// ```dart
// // เขียน PIN
// await SecureStorageService.saveParentPin('1234');
//
// // อ่าน PIN
// final pin = await SecureStorageService.getParentPin();
//
// // ลบทั้งหมดตอน logout
// await SecureStorageService.clearSession();
// ```
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageService {
  SecureStorageService._(); // static-only class

  // ==================== Instance ====================
  // encryptedSharedPreferences: true → ใช้ AES encryption บน Android
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // ==================== Keys ====================
  static const String _keyParentPin = 'secure_activeParentPin';
  static const String _keyParentUid = 'secure_activeParentUid';
  static const String _keyChildId = 'secure_activeChildId';
  static const String _keyCurrentChildId = 'secure_current_child_id';
  static const String _keyCurrentParentUid = 'secure_current_parent_uid';

  // ==================== PIN ====================
  /// บันทึก PIN ผู้ปกครองใน Keystore (เข้ารหัสอัตโนมัติ)
  static Future<void> saveParentPin(String pin) async {
    await _storage.write(key: _keyParentPin, value: pin);
  }

  /// อ่าน PIN ผู้ปกครอง (null = ยังไม่เคยตั้ง)
  static Future<String?> getParentPin() async {
    return _storage.read(key: _keyParentPin);
  }

  /// ลบ PIN (เช่น ตอน reset)
  static Future<void> deleteParentPin() async {
    await _storage.delete(key: _keyParentPin);
  }

  // ==================== Parent UID ====================
  /// บันทึก Firebase UID ของผู้ปกครอง
  static Future<void> saveParentUid(String uid) async {
    await _storage.write(key: _keyParentUid, value: uid);
  }

  /// อ่าน Firebase UID ของผู้ปกครอง
  static Future<String?> getParentUid() async {
    return _storage.read(key: _keyParentUid);
  }

  // ==================== Child ID ====================
  /// บันทึก child document ID ที่กำลัง active
  static Future<void> saveActiveChildId(String childId) async {
    await _storage.write(key: _keyChildId, value: childId);
  }

  /// อ่าน child document ID ที่ active
  static Future<String?> getActiveChildId() async {
    return _storage.read(key: _keyChildId);
  }

  // ==================== Background Worker Session ====================
  /// บันทึก IDs สำหรับ background worker (Workmanager)
  static Future<void> saveBackgroundSession({
    required String childId,
    required String parentUid,
  }) async {
    await Future.wait([
      _storage.write(key: _keyCurrentChildId, value: childId),
      _storage.write(key: _keyCurrentParentUid, value: parentUid),
    ]);
  }

  /// อ่าน childId สำหรับ background worker
  static Future<String?> getBackgroundChildId() async {
    return _storage.read(key: _keyCurrentChildId);
  }

  /// อ่าน parentUid สำหรับ background worker
  static Future<String?> getBackgroundParentUid() async {
    return _storage.read(key: _keyCurrentParentUid);
  }

  // ==================== Session Management ====================
  /// ลบข้อมูล session ทั้งหมดตอน logout / deactivate child mode
  /// เรียกพร้อมกับ SharedPreferences.clear() เพื่อล้างทุกอย่าง
  static Future<void> clearSession() async {
    await Future.wait([
      _storage.delete(key: _keyParentPin),
      _storage.delete(key: _keyParentUid),
      _storage.delete(key: _keyChildId),
      _storage.delete(key: _keyCurrentChildId),
      _storage.delete(key: _keyCurrentParentUid),
    ]);
  }

  /// ล้าง Secure Storage ทั้งหมด (ใช้เฉพาะตอน debug/reset)
  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }
}
