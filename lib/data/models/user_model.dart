// ==================== User Model ====================
/// โมเดลข้อมูลผู้ใช้ (ผู้ปกครอง)
///
/// เก็บข้อมูลหลักของผู้ปกครองที่ลงทะเบียนในระบบ
/// ใช้ร่วมกับ AuthService และ AuthProvider
///
/// โครงสร้าง Firestore: /users/{uid}
/// - email: อีเมลที่ใช้ลงทะเบียน
/// - displayName: ชื่อที่แสดง (ตั้งตอนลงทะเบียน)
/// - role: บทบาท (ตอนนี้มีแค่ 'parent')
/// - childIds: รายการ ID ลูกที่อยู่ภายใต้ผู้ปกครองนี้
/// - pin: PIN 6 หลักสำหรับให้เด็กใช้ล็อกอินเข้า child mode
class UserModel {
  final String uid; // Firebase Auth UID - ใช้เป็น document ID ใน Firestore
  final String email; // อีเมลที่ใช้ลงทะเบียน
  final String? displayName; // ชื่อที่แสดงผล (อาจ null ถ้ายังไม่ตั้ง)
  final String role; // บทบาทผู้ใช้ - ตอนนี้มีแค่ 'parent'
  final List<String> childIds; // รายการ ID ลูกทั้งหมด
  final String? pin; // PIN 6 หลัก - ใช้ให้เด็กล็อกอินแทน email/password

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.role = 'parent',
    this.childIds = const [],
    this.pin,
  });

  /// สร้าง UserModel จาก Firestore document data
  /// [map] - ข้อมูลจาก Firestore (doc.data())
  /// [uid] - document ID ของ users collection
  factory UserModel.fromMap(Map<String, dynamic> map, String uid) {
    return UserModel(
      uid: uid,
      email: map['email'] ?? '',
      displayName: map['displayName'],
      role: map['role'] ?? 'parent',
      childIds: List<String>.from(map['childIds'] ?? []),
      pin: map['pin'],
    );
  }

  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  /// หมายเหตุ: ไม่รวม uid เพราะ uid คือ document ID อยู่แล้ว
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'childIds': childIds,
      'pin': pin,
    };
  }
}
