// ==================== Rewards Repository Implementation ====================
// Implementation ของ RewardsRepository ที่ใช้ Firestore โดยตรง
//
// เหตุผลที่แยก Firestore logic ออกจาก Provider:
// - Provider ควรจัดการเฉพาะ UI State (loading, error, data)
// - Firestore logic อยู่ที่นี่ → Provider เรียกผ่าน Repository
// - ทำให้ test Provider ได้ง่าย (mock Repository แทน mock Firestore)
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/error/app_exception.dart';
import '../../models/reward_model.dart';
import '../rewards_repository.dart';

class RewardsRepositoryImpl implements RewardsRepository {
  final FirebaseFirestore _firestore;

  const RewardsRepositoryImpl(this._firestore);

  // ==================== Helper ====================
  DocumentReference<Map<String, dynamic>> _childRef(
    String parentUid,
    String childId,
  ) =>
      _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childId);

  // ==================== Points ====================
  @override
  Future<bool> addPoints({
    required String parentUid,
    required String childId,
    required int amount,
    required String reason,
    required DateTime date,
  }) async {
    try {
      final childRef = _childRef(parentUid, childId);
      // อ่าน points ปัจจุบันจาก Firestore ก่อน (source of truth)
      final snap = await childRef.get();
      final currentPoints = (snap.data()?['points'] as int?) ?? 0;
      final newPoints = currentPoints + amount;

      final batch = _firestore.batch();
      batch.update(childRef, {'points': newPoints});
      batch.set(
        childRef.collection('point_history').doc(),
        {
          'amount': amount,
          'reason': reason,
          'type': 'earn',
          'date': Timestamp.fromDate(date),
        },
      );
      await batch.commit();
      return true;
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  @override
  Future<bool> redeemReward({
    required String parentUid,
    required String childId,
    required int cost,
    required String rewardName,
  }) async {
    try {
      final childRef = _childRef(parentUid, childId);
      final snap = await childRef.get();
      final currentPoints = (snap.data()?['points'] as int?) ?? 0;

      if (currentPoints < cost) return false;
      final newPoints = currentPoints - cost;

      final batch = _firestore.batch();
      batch.update(childRef, {'points': newPoints});
      batch.set(
        childRef.collection('point_history').doc(),
        {
          'amount': cost,
          'reason': rewardName,
          'type': 'redeem',
          'date': Timestamp.now(),
        },
      );
      await batch.commit();
      return true;
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  // ==================== History ====================
  @override
  Future<List<Map<String, dynamic>>> getPointHistory({
    required String parentUid,
    required String childId,
  }) async {
    try {
      final snap = await _childRef(parentUid, childId)
          .collection('point_history')
          .orderBy('date', descending: true)
          .limit(100)
          .get();

      return snap.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList();
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  // ==================== Custom Rewards ====================
  @override
  Future<List<RewardModel>> getCustomRewards(String parentUid) async {
    try {
      final snap = await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('custom_rewards')
          .orderBy('createdAt', descending: false)
          .get();

      return snap.docs
          .map((doc) => RewardModel.fromMap(doc.data(), doc.id))
          .toList();
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  @override
  Future<bool> addCustomReward({
    required String parentUid,
    required String name,
    required String emoji,
    required int cost,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('custom_rewards')
          .add({
            'name': name,
            'emoji': emoji,
            'cost': cost,
            'createdAt': Timestamp.now(),
          });
      return true;
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  @override
  Future<bool> updateCustomReward({
    required String parentUid,
    required String rewardId,
    required String name,
    required String emoji,
    required int cost,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('custom_rewards')
          .doc(rewardId)
          .update({'name': name, 'emoji': emoji, 'cost': cost});
      return true;
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  @override
  Future<bool> deleteCustomReward({
    required String parentUid,
    required String rewardId,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('custom_rewards')
          .doc(rewardId)
          .delete();
      return true;
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }
}
