// ==================== Rewards Repository Interface ====================
// Interface กำหนดสัญญา (contract) ของ Rewards & Points operations
//
// Layer:
//   RewardsProvider → [RewardsRepository] → RewardsRepositoryImpl → Firestore
import '../models/reward_model.dart';

/// Abstract interface สำหรับ Rewards & Points operations
abstract class RewardsRepository {
  // ==================== Points ====================
  /// เพิ่มแต้มให้เด็ก (atomic: update points + add history พร้อมกัน)
  Future<bool> addPoints({
    required String parentUid,
    required String childId,
    required int amount,
    required String reason,
    required DateTime date,
  });

  /// หักแต้มเมื่อแลกรางวัล (atomic: update points + add history พร้อมกัน)
  Future<bool> redeemReward({
    required String parentUid,
    required String childId,
    required int cost,
    required String rewardName,
  });

  // ==================== History ====================
  /// ดึงประวัติแต้ม
  Future<List<Map<String, dynamic>>> getPointHistory({
    required String parentUid,
    required String childId,
  });

  // ==================== Custom Rewards ====================
  /// ดึงรายการรางวัล Custom ทั้งหมดของ Parent
  Future<List<RewardModel>> getCustomRewards(String parentUid);

  /// เพิ่มรางวัล Custom ใหม่
  Future<bool> addCustomReward({
    required String parentUid,
    required String name,
    required String emoji,
    required int cost,
  });

  /// แก้ไขรางวัล Custom
  Future<bool> updateCustomReward({
    required String parentUid,
    required String rewardId,
    required String name,
    required String emoji,
    required int cost,
  });

  /// ลบรางวัล Custom
  Future<bool> deleteCustomReward({
    required String parentUid,
    required String rewardId,
  });
}
