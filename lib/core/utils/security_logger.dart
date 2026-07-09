// ==================== Security Logger ====================
// ตัวช่วยบันทึก log ด้านความปลอดภัย
//
// Wrapper ของ SecurityService ที่ให้เรียกใช้ง่ายผ่าน static methods
// ส่ง log ไปยัง native (Kotlin) ผ่าน MethodChannel
//
// ระดับ log (LogLevel):
// - debug: ข้อมูล debug (สำหรับ dev)
// - info: ข้อมูลทั่วไป (เปิดหน้า, กดปุ่ม)
// - warn: เตือน (ยังไม่ error แต่ควรระวัง)
// - error: เกิดข้อผิดพลาด
// - security: เหตุการณ์ด้านความปลอดภัย (root detected, login)
//
// วิธีใช้:
// ```dart
// await SecurityLogger.info('User opened settings');
// await SecurityLogger.security('Root detected', data: {'isRooted': true});
// await SecurityLogger.logAuth('login', true, userId: 'abc123');
// ```
import '../../data/services/security_service.dart';

class SecurityLogger {
  static final SecurityService _service = SecurityService();

  /// บันทึก log ระดับ debug (สำหรับ dev ใช้ debug)
  static Future<void> debug(
    String message, {
    Map<String, dynamic>? data,
  }) async {
    await _service.logEvent(LogLevel.debug, message, data: data);
  }

  /// บันทึก log ระดับ info (ข้อมูลทั่วไป)
  static Future<void> info(String message, {Map<String, dynamic>? data}) async {
    await _service.logEvent(LogLevel.info, message, data: data);
  }

  /// บันทึก log ระดับ warn (เตือน)
  static Future<void> warn(String message, {Map<String, dynamic>? data}) async {
    await _service.logEvent(LogLevel.warn, message, data: data);
  }

  /// บันทึก log ระดับ error (ข้อผิดพลาด)
  static Future<void> error(
    String message, {
    Map<String, dynamic>? data,
  }) async {
    await _service.logEvent(LogLevel.error, message, data: data);
  }

  /// บันทึก log เหตุการณ์ด้านความปลอดภัย
  /// เช่น root detected, tampered app
  static Future<void> security(
    String event, {
    Map<String, dynamic>? data,
  }) async {
    await _service.logEvent(LogLevel.security, 'Security: $event', data: data);
  }

  /// บันทึกการเปิดหน้าจอ (ใช้ track navigation)
  static Future<void> logScreen(String screenName) async {
    await info(
      'Screen: $screenName',
      data: {'timestamp': DateTime.now().toIso8601String()},
    );
  }

  /// บันทึกการกระทำของผู้ใช้ (กดปุ่ม, toggle switch ฯลฯ)
  static Future<void> logAction(
    String action, {
    String? target,
    Map<String, dynamic>? extra,
  }) async {
    await info(
      'Action: $action',
      data: {
        'target': ?target,
        'timestamp': DateTime.now().toIso8601String(),
        ...?extra,
      },
    );
  }

  /// บันทึกเหตุการณ์ authentication (login, register, logout)
  static Future<void> logAuth(
    String event,
    bool success, {
    String? userId,
  }) async {
    await _service.logAuth(event, success, userId: userId);
  }

  /// บันทึก exception พร้อม stack trace (เอาแค่ 5 บรรทัดแรก)
  static Future<void> logException(
    String context,
    dynamic error, {
    StackTrace? stackTrace,
  }) async {
    await _service.logEvent(
      LogLevel.error,
      'Exception in $context',
      data: {
        'error': error.toString(),
        if (stackTrace != null)
          'stackTrace': stackTrace.toString().split('\n').take(5).join('\n'),
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  /// ดึง log ทั้งหมด
  static Future<List<LogEntry>> getLogs() async {
    return _service.getLogs();
  }

  /// Export log เป็นไฟล์
  static Future<String?> exportLogs() async {
    return _service.exportLogs();
  }

  /// ลบ log ทั้งหมด
  static Future<bool> clearLogs() async {
    return _service.clearLogs();
  }
}
