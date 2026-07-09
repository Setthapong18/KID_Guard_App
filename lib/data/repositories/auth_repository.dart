// ==================== Auth Repository Interface ====================
// Interface กำหนดสัญญา (contract) ของ Auth operations
//
// Clean Architecture Benefit:
// - Provider/ViewModel ขึ้นกับ Interface ไม่ใช่ Implementation
// - ทำให้ swap implementation ได้ง่าย (เช่น เปลี่ยนจาก Firebase → Mock ใน tests)
// - ง่ายต่อการเขียน Unit Test โดยใช้ Mock ของ Interface นี้
//
// Layer:
//   Presentation → [AuthRepository] → AuthRepositoryImpl → AuthService → Firebase
import '../models/user_model.dart';
import '../models/child_model.dart';

/// Abstract interface สำหรับ Auth & User operations
abstract class AuthRepository {
  // ==================== Authentication ====================
  /// Stream สถานะ login (listen ตลอด)
  Stream<String?> get authStateChanges; // คืน uid หรือ null

  /// ล็อกอินด้วย email + password
  Future<UserModel?> signIn(String email, String password);

  /// ลงทะเบียนด้วย email + password
  Future<UserModel?> register(String email, String password, String name);

  /// ล็อกอินด้วย Google
  Future<UserModel?> signInWithGoogle();

  /// ออกจากระบบ
  Future<void> signOut();

  // ==================== User Data ====================
  /// ดึงข้อมูล user จาก Firestore
  Future<UserModel?> getUserData(String uid);

  /// อัปเดตชื่อที่แสดง
  Future<void> updateDisplayName(String uid, String newName);

  /// เปลี่ยนรหัสผ่าน (ต้อง re-authenticate)
  Future<void> updatePassword(String currentPassword, String newPassword);

  // ==================== Child Management ====================
  /// ลงทะเบียนลูกใหม่
  Future<ChildModel?> registerChild(
    String parentUid,
    String name,
    int age,
    String avatar,
  );

  /// ดึงรายชื่อลูกทั้งหมด
  Future<List<ChildModel>> getChildren(String parentUid);

  /// ลบลูก
  Future<void> deleteChild(String parentUid, String childId);

  /// อัปเดตสถานะออนไลน์
  Future<void> updateChildStatus(
    String parentUid,
    String childId,
    bool isOnline,
  );

  // ==================== PIN ====================
  /// สร้าง PIN สำหรับผู้ปกครอง
  Future<String?> generatePin(String uid);

  /// ตรวจสอบ PIN (ใช้ตอน child login)
  Future<UserModel?> verifyPin(String pin);

  /// ดึง parentUid จาก PIN
  Future<String?> getParentUidFromPin(String pin);
}
