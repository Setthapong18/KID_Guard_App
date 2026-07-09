// ==================== AppException Tests ====================
// ทดสอบ Error handling ที่ถูกต้อง
//
// ครอบคลุม:
// - factory fromFirebaseAuth: แปลง Firebase error codes → ข้อความไทย
// - factory fromFirebase: สำหรับ Firestore errors
// - factory network(), unknown()
// - toString() representation
//
// วิธีรัน:
//   flutter test test/core/error/app_exception_test.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kidguard/core/error/app_exception.dart';

/// Helper — สร้าง FirebaseAuthException จริง× ไม่ต้องใช้ Mock
/// (FirebaseAuthException มี constructor รับ code และ message อยู่แล้ว)
FirebaseAuthException makeAuthException(String code) =>
    FirebaseAuthException(code: code, message: 'Test error for $code');

void main() {
  group('AppException', () {
    // ==================== Constructor ====================
    group('constructor', () {
      test('creates exception with required message', () {
        const exception = AppException(message: 'Test error');
        expect(exception.message, 'Test error');
        expect(exception.code, isNull);
        expect(exception.originalException, isNull);
      });

      test('creates exception with all optional fields', () {
        final original = Exception('original');
        final exception = AppException(
          message: 'Test error',
          code: 'test-code',
          originalException: original,
        );
        expect(exception.message, 'Test error');
        expect(exception.code, 'test-code');
        expect(exception.originalException, same(original));
      });
    });

    // ==================== fromFirebaseAuth ====================
    group('fromFirebaseAuth()', () {
      test('maps user-not-found to Thai message', () {
        final appEx = AppException.fromFirebaseAuth(
          makeAuthException('user-not-found'),
        );
        expect(appEx.code, 'user-not-found');
        expect(appEx.message, contains('ไม่พบบัญชีผู้ใช้'));
      });

      test('maps wrong-password to Thai message', () {
        final appEx = AppException.fromFirebaseAuth(
          makeAuthException('wrong-password'),
        );
        expect(appEx.code, 'wrong-password');
        expect(appEx.message, contains('รหัสผ่านไม่ถูกต้อง'));
      });

      test('maps invalid-credential to Thai message', () {
        final appEx = AppException.fromFirebaseAuth(
          makeAuthException('invalid-credential'),
        );
        expect(appEx.code, 'invalid-credential');
        expect(appEx.message, contains('Email หรือรหัสผ่าน'));
      });

      test('maps email-already-in-use to Thai message', () {
        final appEx = AppException.fromFirebaseAuth(
          makeAuthException('email-already-in-use'),
        );
        expect(appEx.code, 'email-already-in-use');
        expect(appEx.message, contains('มีบัญชีอยู่แล้ว'));
      });

      test('maps weak-password to Thai message', () {
        final appEx = AppException.fromFirebaseAuth(
          makeAuthException('weak-password'),
        );
        expect(appEx.code, 'weak-password');
        expect(appEx.message, contains('รหัสผ่านอ่อนเกินไป'));
      });

      test('maps too-many-requests to Thai message', () {
        final appEx = AppException.fromFirebaseAuth(
          makeAuthException('too-many-requests'),
        );
        expect(appEx.code, 'too-many-requests');
        expect(appEx.message, contains('ลองผิดหลายครั้ง'));
      });

      test('maps network-request-failed to Thai message', () {
        final appEx = AppException.fromFirebaseAuth(
          makeAuthException('network-request-failed'),
        );
        expect(appEx.message, contains('อินเทอร์เน็ต'));
      });

      test('maps unknown code to fallback message with code', () {
        final appEx = AppException.fromFirebaseAuth(
          makeAuthException('some-unknown-code'),
        );
        expect(appEx.code, 'some-unknown-code');
        expect(appEx.message, contains('some-unknown-code'));
      });

      test('preserves originalException reference', () {
        final firebaseEx = makeAuthException('user-not-found');
        final appEx = AppException.fromFirebaseAuth(firebaseEx);
        expect(appEx.originalException, same(firebaseEx));
      });
    });

    // ==================== Factory Shortcuts ====================
    group('network()', () {
      test('creates network error with correct code', () {
        final ex = AppException.network();
        expect(ex.code, 'network-error');
        expect(ex.message, contains('อินเทอร์เน็ต'));
      });
    });

    group('unknown()', () {
      test('creates unknown error with default message', () {
        final ex = AppException.unknown();
        expect(ex.code, 'unknown');
        expect(ex.message, contains('ไม่ทราบสาเหตุ'));
      });

      test('preserves original exception', () {
        final original = Exception('test');
        final ex = AppException.unknown(original);
        expect(ex.originalException, same(original));
      });
    });

    // ==================== toString ====================
    group('toString()', () {
      test('includes code and message', () {
        final ex = AppException(message: 'Test message', code: 'test-code');
        final str = ex.toString();

        expect(str, contains('test-code'));
        expect(str, contains('Test message'));
      });
    });

    // ==================== implements Exception ====================
    test('is an Exception', () {
      const ex = AppException(message: 'test');
      expect(ex, isA<Exception>());
    });
  });
}
