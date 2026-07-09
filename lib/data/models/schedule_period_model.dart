// ==================== Schedule Period Model ====================
/// โมเดลสำหรับช่วงเวลาตาราง (เวลานอน / เวลาพัก)
///
/// ใช้สำหรับตั้งค่าช่วงเวลาที่เด็กไม่สามารถใช้งานเครื่องได้
/// มี 2 ประเภท:
/// - sleep: เวลานอน (มีได้ 1 ช่วง) - ล็อกเครื่องเมื่อถึงเวลานอน
/// - quietTime: เวลาเงียบ (มีได้หลายช่วง) - ล็อกเครื่องในช่วงเวลาที่กำหนด
///
/// โครงสร้าง Firestore:
/// - เวลานอน: /users/{parentUid}/children/{childId} → sleepSchedule field
/// - เวลาเงียบ: /users/{parentUid}/children/{childId}/quietTimes/{id}
///
/// ใช้ร่วมกับ ScheduleProvider และ BackgroundService
/// BackgroundService จะเช็คเวลาปัจจุบันกับ schedule ทุก 3 วินาที
library;

/// ประเภทของตารางเวลา
/// - sleep: เวลานอน (เช่น 21:00 - 06:00)
/// - quietTime: เวลาเงียบ/เวลาทำการบ้าน (เช่น 18:00 - 19:00)
enum ScheduleType { sleep, quietTime }

class SchedulePeriod {
  final String name; // ชื่อช่วงเวลา (เช่น "เวลานอน", "ทำการบ้าน")
  final ScheduleType type; // ประเภท: sleep หรือ quietTime
  final int startHour; // ชั่วโมงเริ่มต้น (0-23)
  final int startMinute; // นาทีเริ่มต้น (0-59)
  final int endHour; // ชั่วโมงสิ้นสุด (0-23)
  final int endMinute; // นาทีสิ้นสุด (0-59)
  final bool enabled; // เปิดใช้งานหรือไม่

  SchedulePeriod({
    required this.name,
    required this.type,
    required this.startHour,
    required this.startMinute,
    required this.endHour,
    required this.endMinute,
    required this.enabled,
  });

  /// สร้างสำเนาใหม่พร้อมเปลี่ยนค่าบางส่วน
  /// ใช้ตอนแก้ไขเวลาหรือเปิด/ปิด schedule
  SchedulePeriod copyWith({
    String? name,
    ScheduleType? type,
    int? startHour,
    int? startMinute,
    int? endHour,
    int? endMinute,
    bool? enabled,
  }) {
    return SchedulePeriod(
      name: name ?? this.name,
      type: type ?? this.type,
      startHour: startHour ?? this.startHour,
      startMinute: startMinute ?? this.startMinute,
      endHour: endHour ?? this.endHour,
      endMinute: endMinute ?? this.endMinute,
      enabled: enabled ?? this.enabled,
    );
  }

  /// แปลงเวลาเริ่มต้นเป็น String "HH:MM" (เช่น "21:00")
  String formatStart() {
    return '${startHour.toString().padLeft(2, '0')}:${startMinute.toString().padLeft(2, '0')}';
  }

  /// แปลงเวลาสิ้นสุดเป็น String "HH:MM" (เช่น "06:00")
  String formatEnd() {
    return '${endHour.toString().padLeft(2, '0')}:${endMinute.toString().padLeft(2, '0')}';
  }

  /// แปลงเป็น Map สำหรับบันทึก quiet time ลง Firestore
  /// หมายเหตุ: ไม่รวม type เพราะเก็บแยก collection กัน
  /// (sleep อยู่ใน child doc ตรงๆ, quietTime อยู่ใน subcollection)
  Map<String, dynamic> toQuietTimeMap() {
    return {
      'name': name,
      'startHour': startHour,
      'startMinute': startMinute,
      'endHour': endHour,
      'endMinute': endMinute,
      'enabled': enabled,
    };
  }
}
