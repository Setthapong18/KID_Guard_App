// ==================== Contact Model ====================
/// โมเดลข้อมูลรายชื่อผู้ติดต่อจากเครื่องเด็ก
///
/// เก็บข้อมูล contact ที่ sync มาจากเครื่องเด็ก
/// ให้ผู้ปกครองสามารถดูรายชื่อผู้ติดต่อของลูกได้
///
/// โครงสร้าง Firestore: /users/{parentUid}/children/{childId}/contacts/{contactId}
/// - contactId: ใช้ ID จากระบบ contact ของเครื่อง
///
/// ใช้ร่วมกับ ContactService ที่จัดการ sync
class ContactModel {
  final String id; // ID ของ contact จากระบบ (ใช้เป็น document ID)
  final String displayName; // ชื่อที่แสดงของผู้ติดต่อ
  final List<String> phones; // รายการเบอร์โทรศัพท์ (contact 1 คนมีหลายเบอร์ได้)
  final String?
  avatar; // รูปโปรไฟล์ (Base64 หรือ URL) - ตอนนี้ยัง null เพราะรูปหนัก

  ContactModel({
    required this.id,
    required this.displayName,
    required this.phones,
    this.avatar,
  });

  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'displayName': displayName,
      'phones': phones,
      'avatar': avatar,
    };
  }

  /// สร้าง ContactModel จาก Firestore document data
  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      id: map['id'] ?? '',
      displayName: map['displayName'] ?? '',
      phones: List<String>.from(map['phones'] ?? []),
      avatar: map['avatar'],
    );
  }
}
