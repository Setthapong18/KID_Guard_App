// ==================== Auth Repository Implementation ====================
// Implementation ของ AuthRepository ที่ใช้ AuthService จริง
//
// เหตุผลที่มี layer นี้:
// - แยก "สิ่งที่ทำ" (interface) ออกจาก "วิธีทำ" (implementation)
// - ถ้าเปลี่ยนจาก Firebase เป็น backend อื่น แค่สร้าง impl ใหม่
// - Unit Test ใช้ MockAuthRepository แทน impl จริงได้ทันที
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/error/app_exception.dart';
import '../../models/child_model.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';
import '../auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;

  const AuthRepositoryImpl(this._authService);

  // ==================== Auth State ====================
  @override
  Stream<String?> get authStateChanges =>
      _authService.authStateChanges.map((user) => user?.uid);

  // ==================== Sign In / Register ====================
  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      return await _authService.signIn(email, password);
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebaseAuth(e);
    }
  }

  @override
  Future<UserModel?> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      return await _authService.register(email, password, name);
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebaseAuth(e);
    }
  }

  @override
  Future<UserModel?> signInWithGoogle() async {
    try {
      return await _authService.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebaseAuth(e);
    } catch (e) {
      throw AppException(
        message: 'Google Sign-In ล้มเหลว: $e',
        code: 'google-sign-in-failed',
      );
    }
  }

  @override
  Future<void> signOut() => _authService.signOut();

  // ==================== User Data ====================
  @override
  Future<UserModel?> getUserData(String uid) => _authService.getUserData(uid);

  @override
  Future<void> updateDisplayName(String uid, String newName) =>
      _authService.updateDisplayName(uid, newName);

  @override
  Future<void> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _authService.updatePassword(currentPassword, newPassword);
    } on FirebaseAuthException catch (e) {
      throw AppException.fromFirebaseAuth(e);
    }
  }

  // ==================== Child Management ====================
  @override
  Future<ChildModel?> registerChild(
    String parentUid,
    String name,
    int age,
    String avatar,
  ) => _authService.registerChild(parentUid, name, age, avatar);

  @override
  Future<List<ChildModel>> getChildren(String parentUid) =>
      _authService.getChildren(parentUid);

  @override
  Future<void> deleteChild(String parentUid, String childId) =>
      _authService.deleteChild(parentUid, childId);

  @override
  Future<void> updateChildStatus(
    String parentUid,
    String childId,
    bool isOnline,
  ) => _authService.updateChildStatus(parentUid, childId, isOnline);

  // ==================== PIN ====================
  @override
  Future<String?> generatePin(String uid) => _authService.generatePin(uid);

  @override
  Future<UserModel?> verifyPin(String pin) => _authService.verifyPin(pin);

  @override
  Future<String?> getParentUidFromPin(String pin) =>
      _authService.getParentUidFromPin(pin);
}
