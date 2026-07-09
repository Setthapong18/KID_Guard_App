// ==================== Child Repository Interface ====================
// Interface กำหนดสัญญา (contract) สำหรับ Child data operations
// ที่ไม่เกี่ยวกับ Auth โดยตรง (เช่น lock, screen time, settings)
//
// Layer:
//   Provider → [ChildRepository] → ChildRepositoryImpl → Firestore
import '../models/child_model.dart';

/// Abstract interface สำหรับ Child data operations
abstract class ChildRepository {
  // ==================== Lock / Unlock ====================
  /// ล็อกหน้าจอเด็ก
  Future<bool> lockDevice({
    required String parentUid,
    required String childId,
    required String reason,
  });

  /// ปลดล็อกหน้าจอเด็ก
  Future<bool> unlockDevice({
    required String parentUid,
    required String childId,
  });

  // ==================== Child Data ====================
  /// ดึงข้อมูลเด็กคนเดียว
  Future<ChildModel?> getChild({
    required String parentUid,
    required String childId,
  });

  /// อัปเดตข้อมูลเด็ก (ชื่อ, อายุ, avatar)
  Future<bool> updateChild({
    required String parentUid,
    required String childId,
    String? name,
    int? age,
    String? avatar,
  });

  // ==================== Screen Time ====================
  /// อัปเดตเวลาใช้หน้าจอวันนี้
  Future<void> updateScreenTime({
    required String parentUid,
    required String childId,
    required int additionalMinutes,
  });

  /// Stream ข้อมูลเด็ก (real-time)
  Stream<ChildModel?> watchChild({
    required String parentUid,
    required String childId,
  });
}
