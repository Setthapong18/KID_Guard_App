// ==================== Child Mode Service ====================
// บริการจัดการ Foreground Notification สำหรับ Child Mode
//
// เมื่อเปิด child mode จะแสดง persistent notification ที่ status bar
// เพื่อบอกว่า KidGuard กำลังทำงานและแสดงเวลาใช้งาน
//
// ทำงานผ่าน MethodChannel สื่อสารกับ Native Kotlin
// Native จะสร้าง Foreground Service ที่ทำให้แอพไม่ถูก kill โดยระบบ
//
// Notification แสดง:
// - ชื่อเด็ก
// - เวลาใช้หน้าจอปัจจุบัน
// - เวลาจำกัดรายวัน
//
// ฟีเจอร์ Anti-tamper:
// - setAllowShutdown(false): ถ้าเด็กปัดปิดแอพ จะเปิดขึ้นมาใหม่อัตโนมัติ
// - setAllowShutdown(true): ปิดแอพได้ (เรียกตอนพิมพ์ PIN ถูก)
//
// ฟังก์ชัน:
// - start() → เริ่ม foreground service + notification
// - stop() → หยุดและซ่อน notification
// - update() → อัปเดตเวลาบน notification
// - isRunning() → เช็คว่า service ทำงานอยู่หรือไม่
// - setAllowShutdown() → เปิด/ปิดการป้องกัน
// - getLaunchAction() → เช็คว่า user กดปุ่มหยุดบน notification หรือไม่
import 'package:flutter/services.dart';

class ChildModeService {
  static const _channel = MethodChannel('com.kidguard/childmode');

  /// เริ่ม foreground service พร้อมแสดง notification
  /// [childName] - ชื่อเด็ก (แสดงบน notification)
  /// [screenTime] - เวลาใช้งานปัจจุบัน (วินาที)
  /// [dailyLimit] - เวลาจำกัดรายวัน (วินาที)
  static Future<bool> start({
    required String childName,
    required int screenTime,
    required int dailyLimit,
  }) async {
    try {
      final result = await _channel.invokeMethod('startService', {
        'childName': childName,
        'screenTime': screenTime,
        'dailyLimit': dailyLimit,
      });
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// หยุด foreground service และซ่อน notification
  static Future<bool> stop() async {
    try {
      final result = await _channel.invokeMethod('stopService');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// อัปเดตเวลาบน notification
  /// เรียกทุกๆ วินาทีเพื่ออัปเดตตัวเลขเวลาบน notification
  static Future<bool> update({
    required String childName,
    required int screenTime,
    required int dailyLimit,
  }) async {
    try {
      final result = await _channel.invokeMethod('updateService', {
        'childName': childName,
        'screenTime': screenTime,
        'dailyLimit': dailyLimit,
      });
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// เช็คว่า foreground service ทำงานอยู่หรือไม่
  static Future<bool> isRunning() async {
    try {
      final result = await _channel.invokeMethod('isServiceRunning');
      return result == true;
    } catch (e) {
      return false;
    }
  }

  /// ตั้งค่า allow shutdown (ป้องกันเด็กปัดปิดแอพ)
  /// - allow = false: ปัดปิดแอพ → เปิดขึ้นมาใหม่อัตโนมัติ (ป้องกันเด็ก)
  /// - allow = true: ปัดปิดแอพได้ (เรียกตอน parent พิมพ์ PIN ถูก)
  static Future<bool> setAllowShutdown(bool allow) async {
    try {
      await _channel.invokeMethod('setAllowShutdown', {'allow': allow});
      return true;
    } catch (e) {
      return false;
    }
  }

  /// เช็คว่า user กดปุ่มหยุดบน notification หรือไม่
  /// คืน "com.kidguard.ACTION_STOP_CHILD_MODE" ถ้ากดปุ่มหยุด
  /// ใช้ตรวจสอบตอนเปิดแอพกลับมาว่าต้อง show PIN dialog หรือไม่
  static Future<String?> getLaunchAction() async {
    try {
      final result = await _channel.invokeMethod('getLaunchAction');
      return result as String?;
    } catch (e) {
      return null;
    }
  }
}
