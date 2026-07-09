// ==================== Crashlytics Service ====================
// Service สำหรับรายงาน Crash และ Error ไปยัง Firebase Crashlytics
//
// หน้าที่:
// - รายงาน Crash อัตโนมัติ (Flutter uncaught exceptions)
// - รายงาน non-fatal errors (AppException ต่างๆ)
// - แนบ metadata: userId, childId, screen, custom keys
// - ปิด Crashlytics ใน debug mode (ประหยัด quota + ไม่รบกวน dev)
//
// วิธีใช้:
// ```dart
// // รายงาน non-fatal error
// CrashlyticsService.recordError(e, stack, reason: 'addPoints failed');
//
// // ตั้ง user context
// CrashlyticsService.setUserId(uid);
//
// // บันทึก breadcrumb
// CrashlyticsService.log('User tapped Add Points button');
// ```
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

/// Wrapper รอบ FirebaseCrashlytics เพื่อ centralize การตั้งค่า
class CrashlyticsService {
  CrashlyticsService._(); // Prevent instantiation — ใช้ static methods เท่านั้น

  static FirebaseCrashlytics get _crashlytics => FirebaseCrashlytics.instance;

  // ==================== Initialize ====================
  /// เปิดใช้งาน Crashlytics และ Flutter Error Handler
  /// เรียกครั้งเดียวใน main() หลัง Firebase.initializeApp()
  static Future<void> initialize() async {
    // ปิด Crashlytics ใน debug mode → ป้องกัน noise ใน dashboard
    // เปิดใช้งานเฉพาะ release build เท่านั้น
    await _crashlytics.setCrashlyticsCollectionEnabled(!kDebugMode);

    // ดัก Flutter framework errors (เช่น widget build errors)
    FlutterError.onError = (FlutterErrorDetails details) {
      if (kDebugMode) {
        // ใน debug mode พิมพ์ลง console ตามปกติ
        FlutterError.dumpErrorToConsole(details);
      } else {
        // ใน release mode ส่งไป Crashlytics
        _crashlytics.recordFlutterFatalError(details);
      }
    };

    // ดัก Dart errors ที่ไม่ได้อยู่ใน Flutter framework
    // เช่น async errors ใน Isolates, Platform Channel errors
    PlatformDispatcher.instance.onError = (error, stack) {
      if (!kDebugMode) {
        _crashlytics.recordError(error, stack, fatal: true);
      }
      return true; // true = error ถูก handled แล้ว
    };
  }

  // ==================== User Context ====================
  /// ตั้ง userId เพื่อให้ crash report ระบุตัวตนผู้ใช้ได้
  /// เรียกหลัง login สำเร็จ
  static Future<void> setUserId(String uid) async {
    if (kDebugMode) return;
    await _crashlytics.setUserIdentifier(uid);
  }

  /// ล้าง userId เมื่อ logout
  static Future<void> clearUserId() async {
    if (kDebugMode) return;
    await _crashlytics.setUserIdentifier('');
  }

  // ==================== Custom Keys (Metadata) ====================
  /// แนบ metadata เพิ่มเติมใน crash report
  /// ช่วย debug ว่า crash เกิดตอน child ไหน/หน้าจอไหน
  static Future<void> setChildContext({
    required String parentUid,
    required String childId,
    required String childName,
  }) async {
    if (kDebugMode) return;
    await Future.wait([
      _crashlytics.setCustomKey('parent_uid', parentUid),
      _crashlytics.setCustomKey('child_id', childId),
      _crashlytics.setCustomKey('child_name', childName),
    ]);
  }

  /// บันทึกชื่อหน้าจอปัจจุบัน (breadcrumb สำหรับ debug)
  static Future<void> setCurrentScreen(String screenName) async {
    if (kDebugMode) return;
    await _crashlytics.setCustomKey('current_screen', screenName);
  }

  // ==================== Error Recording ====================
  /// รายงาน non-fatal error (แอปไม่ crash แต่มี error เกิดขึ้น)
  /// ใช้สำหรับ errors ที่ catch ได้แล้ว แต่อยากติดตามใน dashboard
  ///
  /// ตัวอย่าง:
  /// ```dart
  /// try {
  ///   await rewardsRepo.addPoints(...);
  /// } catch (e, stack) {
  ///   CrashlyticsService.recordError(e, stack, reason: 'addPoints failed');
  /// }
  /// ```
  static Future<void> recordError(
    Object error,
    StackTrace? stack, {
    String? reason,
    bool fatal = false,
    Map<String, String>? context,
  }) async {
    if (kDebugMode) {
      // ใน debug mode แค่พิมพ์ลง console
      debugPrint('[Crashlytics] ${fatal ? "FATAL" : "Error"}: $error');
      if (reason != null) debugPrint('[Crashlytics] Reason: $reason');
      return;
    }

    // แนบ context เพิ่มเติมถ้ามี
    if (context != null) {
      for (final entry in context.entries) {
        await _crashlytics.setCustomKey(entry.key, entry.value);
      }
    }

    await _crashlytics.recordError(
      error,
      stack,
      reason: reason,
      fatal: fatal,
    );
  }

  // ==================== Breadcrumb Logging ====================
  /// บันทึก log เพื่อ trace user journey ก่อน crash
  /// ใช้เหมือน "breadcrumb" → เมื่อ crash เกิดขึ้น จะเห็น logs ก่อนหน้า
  ///
  /// ตัวอย่าง:
  /// ```dart
  /// CrashlyticsService.log('User navigated to RewardsScreen');
  /// CrashlyticsService.log('Tapped Add Points: amount=50, reason=homework');
  /// ```
  static void log(String message) {
    if (kDebugMode) {
      debugPrint('[Crashlytics Log] $message');
      return;
    }
    _crashlytics.log(message);
  }
}
