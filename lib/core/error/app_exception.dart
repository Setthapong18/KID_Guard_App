// ==================== App Exception ====================
// Centralized Exception classes สำหรับ KID Guard
//
// เหตุผลที่ต้องมี:
// - FirebaseAuthException มี code ที่เป็น string (เช่น 'user-not-found')
//   ยากต่อการแสดงผลเป็นข้อความไทย/อังกฤษ
// - AppException แปลง Firebase error codes → ข้อความที่เข้าใจได้
// - ทุก layer ใช้ AppException เดียวกัน → error handling สม่ำเสมอ
//
// วิธีใช้:
// ```dart
// try {
//   await authService.signIn(email, password);
// } on AppException catch (e) {
//   showError(e.message); // ข้อความภาษาไทยเข้าใจได้เลย
// } on FirebaseAuthException catch (e) {
//   throw AppException.fromFirebaseAuth(e);
// }
// ```
import 'package:firebase_auth/firebase_auth.dart';

/// App-level exception ที่ใช้ทั่วทั้งระบบ
class AppException implements Exception {
  /// ข้อความ error ที่แสดงให้ผู้ใช้เห็น
  final String message;

  /// Error code สำหรับ debugging (เช่น 'user-not-found')
  final String? code;

  /// Original exception (optional) สำหรับ logging
  final Object? originalException;

  const AppException({
    required this.message,
    this.code,
    this.originalException,
  });

  /// สร้าง AppException จาก FirebaseAuthException
  /// แปลง Firebase error codes → ข้อความที่เข้าใจได้
  factory AppException.fromFirebaseAuth(FirebaseAuthException e) {
    final message = _authErrorMessage(e.code);
    return AppException(
      message: message,
      code: e.code,
      originalException: e,
    );
  }

  /// สร้าง AppException จาก FirebaseException ทั่วไป (Firestore, Storage)
  factory AppException.fromFirebase(dynamic e) {
    return AppException(
      message: 'เกิดข้อผิดพลาดจากระบบ Firebase: ${e.message ?? e.toString()}',
      code: e.code?.toString(),
      originalException: e,
    );
  }

  /// Network error
  factory AppException.network() => const AppException(
        message: 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต กรุณาตรวจสอบเน็ตแล้วลองใหม่',
        code: 'network-error',
      );

  /// Unknown error
  factory AppException.unknown([Object? e]) => AppException(
        message: 'เกิดข้อผิดพลาดที่ไม่ทราบสาเหตุ กรุณาลองใหม่',
        code: 'unknown',
        originalException: e,
      );

  @override
  String toString() => 'AppException(code: $code, message: $message)';

  // ==================== Firebase Auth Error Messages ====================
  /// แปลง Firebase Auth error codes → ข้อความภาษาไทย
  static String _authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'ไม่พบบัญชีผู้ใช้นี้ กรุณาตรวจสอบ Email';
      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้อง กรุณาลองใหม่';
      case 'invalid-credential':
        return 'Email หรือรหัสผ่านไม่ถูกต้อง';
      case 'email-already-in-use':
        return 'Email นี้มีบัญชีอยู่แล้ว กรุณาใช้ Email อื่น';
      case 'weak-password':
        return 'รหัสผ่านอ่อนเกินไป ควรมีอย่างน้อย 6 ตัวอักษร';
      case 'invalid-email':
        return 'รูปแบบ Email ไม่ถูกต้อง';
      case 'user-disabled':
        return 'บัญชีนี้ถูกระงับการใช้งาน กรุณาติดต่อผู้ดูแล';
      case 'too-many-requests':
        return 'ลองผิดหลายครั้งเกินไป กรุณารอสักครู่แล้วลองใหม่';
      case 'network-request-failed':
        return 'ไม่มีการเชื่อมต่ออินเทอร์เน็ต กรุณาตรวจสอบเน็ต';
      case 'requires-recent-login':
        return 'กรุณาออกจากระบบแล้วล็อกอินใหม่ก่อนทำรายการนี้';
      case 'operation-not-allowed':
        return 'ไม่อนุญาตให้ทำรายการนี้ในขณะนี้';
      default:
        return 'เกิดข้อผิดพลาด: $code กรุณาลองใหม่';
    }
  }
}
