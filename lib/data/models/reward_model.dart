// ==================== Reward Model ====================
// โมเดลข้อมูลรางวัล
//
// ระบบรางวัลช่วยให้ผู้ปกครองสร้างแรงจูงใจให้เด็ก
// ผู้ปกครองตั้งรางวัลพร้อมกำหนดแต้มที่ต้องใช้แลก
// เด็กสะสมแต้มจากการใช้งานที่ดี แล้วนำมาแลกรางวัล
//
// โครงสร้าง Firestore: /users/{parentUid}/children/{childId}/rewards/{rewardId}
//
// ใช้ร่วมกับ RewardsProvider ที่จัดการ CRUD
import 'package:cloud_firestore/cloud_firestore.dart';

class RewardModel {
  final String id; // document ID ใน rewards subcollection
  final String name; // ชื่อรางวัล (เช่น "เล่นเกม 30 นาที")
  final String emoji; // อิโมจิแทนรางวัล (เช่น "🎮", "🍦")
  final int cost; // จำนวนแต้มที่ต้องใช้แลก
  final DateTime createdAt; // วันที่สร้างรางวัล

  RewardModel({
    required this.id,
    required this.name,
    required this.emoji,
    required this.cost,
    required this.createdAt,
  });

  /// สร้าง RewardModel จาก Firestore document data
  factory RewardModel.fromMap(Map<String, dynamic> map, String id) {
    return RewardModel(
      id: id,
      name: map['name'] ?? '',
      emoji: map['emoji'] ?? '⭐',
      cost: map['cost'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
    );
  }

  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'emoji': emoji,
      'cost': cost,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  /// สร้างสำเนาใหม่พร้อมเปลี่ยนค่าบางส่วน
  /// ใช้ตอนแก้ไขรางวัล โดยไม่ต้องสร้าง object ใหม่ทั้งหมด
  RewardModel copyWith({String? name, String? emoji, int? cost}) {
    return RewardModel(
      id: id,
      name: name ?? this.name,
      emoji: emoji ?? this.emoji,
      cost: cost ?? this.cost,
      createdAt: createdAt,
    );
  }
}
