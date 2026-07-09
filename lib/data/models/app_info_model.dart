// ==================== App Info Model ====================
/// โมเดลข้อมูลแอพที่ติดตั้งในเครื่องเด็ก
///
/// เก็บข้อมูลแอพแต่ละตัวที่ติดตั้งในเครื่องเด็ก
/// ผู้ปกครองสามารถล็อก/ปลดล็อกแอพแต่ละตัวได้
///
/// โครงสร้าง Firestore:
/// /users/{parentUid}/children/{childId}/devices/{deviceId}/apps/{packageName}
///
/// หมายเหตุ:
/// - iconBase64: เก็บ icon ของแอพเป็น base64 string
///   เพื่อให้ฝั่ง parent แสดงผลได้โดยไม่ต้องติดตั้งแอพ
/// - isSystemApp: แอพระบบ (เช่น Settings, Clock) ซึ่งไม่ควรบล็อก
class AppInfoModel {
  final String packageName; // Package name ของแอพ (เช่น "com.facebook.katana")
  final String name; // ชื่อแอพที่แสดงผล (เช่น "Facebook")
  final bool isSystemApp; // เป็นแอพระบบหรือไม่ (true = ไม่ควรบล็อก)
  final bool isLocked; // ถูกบล็อกโดยผู้ปกครองหรือไม่
  final String? iconBase64; // Icon ของแอพเป็น base64 (ใช้แสดงฝั่ง parent)

  AppInfoModel({
    required this.packageName,
    required this.name,
    required this.isSystemApp,
    this.isLocked = false,
    this.iconBase64,
  });

  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  Map<String, dynamic> toMap() {
    return {
      'packageName': packageName,
      'name': name,
      'isSystemApp': isSystemApp,
      'isLocked': isLocked,
      'iconBase64': iconBase64,
    };
  }

  /// สร้าง AppInfoModel จาก Firestore document data
  factory AppInfoModel.fromMap(Map<String, dynamic> map) {
    return AppInfoModel(
      packageName: map['packageName'] ?? '',
      name: map['name'] ?? '',
      isSystemApp: map['isSystemApp'] ?? false,
      isLocked: map['isLocked'] ?? false,
      iconBase64: map['iconBase64'],
    );
  }

  /// สร้างสำเนาใหม่พร้อมเปลี่ยนค่าบางส่วน
  /// ใช้ตอน toggle lock status
  AppInfoModel copyWith({
    String? packageName,
    String? name,
    bool? isSystemApp,
    bool? isLocked,
    String? iconBase64,
  }) {
    return AppInfoModel(
      packageName: packageName ?? this.packageName,
      name: name ?? this.name,
      isSystemApp: isSystemApp ?? this.isSystemApp,
      isLocked: isLocked ?? this.isLocked,
      iconBase64: iconBase64 ?? this.iconBase64,
    );
  }
}
