// ==================== Overlay Service ====================
// บริการแสดง Overlay (หน้าต่างซ้อนทับ) บนแอพอื่น
//
// ใช้แสดงหน้าจอบล็อกทับบนแอพที่ถูกบล็อก
// เมื่อเด็กเปิดแอพที่ parent บล็อกไว้ จะแสดง overlay ทับแทน
//
// ทำงานผ่าน MethodChannel สื่อสารกับ Native (Kotlin)
// เพราะ Android Overlay ต้องสร้างจาก native code (WindowManager)
//
// สิทธิ์ที่ต้องการ: SYSTEM_ALERT_WINDOW (Display over other apps)
//
// ฟังก์ชัน:
// - showBlockOverlay() → แสดง overlay ทับแอพที่ถูกบล็อก
// - hideOverlay() → ซ่อน overlay
// - checkPermission() → เช็คว่ามีสิทธิ์ overlay หรือไม่
// - requestPermission() → ขอสิทธิ์ overlay (เปิดหน้าตั้งค่า Android)
import 'package:flutter/services.dart';

class OverlayService {
  static const MethodChannel _channel = MethodChannel(
    'com.example.kid_guard/overlay',
  );

  /// แสดง overlay ทับแอพที่ถูกบล็อก
  /// [packageName] - package name ของแอพที่จะแสดง overlay ทับ
  Future<void> showBlockOverlay(String packageName) async {
    try {
      await _channel.invokeMethod('showOverlay', {'packageName': packageName});
    } catch (e) {
      // Error showing overlay - fail silently
    }
  }

  /// ซ่อน overlay
  Future<void> hideOverlay() async {
    try {
      await _channel.invokeMethod('hideOverlay');
    } catch (e) {
      // Error hiding overlay - fail silently
    }
  }

  /// เช็คว่ามีสิทธิ์ SYSTEM_ALERT_WINDOW หรือไม่
  Future<bool> checkPermission() async {
    try {
      final bool result = await _channel.invokeMethod('checkPermission');
      return result;
    } catch (e) {
      return false;
    }
  }

  /// ขอสิทธิ์ SYSTEM_ALERT_WINDOW (เปิดหน้าตั้งค่า Android ให้ user เปิดเอง)
  Future<void> requestPermission() async {
    try {
      await _channel.invokeMethod('requestPermission');
    } catch (e) {
      // Error requesting overlay permission - fail silently
    }
  }
}
