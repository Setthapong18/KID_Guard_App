// ==================== Child Repository Implementation ====================
// Implementation ของ ChildRepository ที่ใช้ Firestore โดยตรง
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/error/app_exception.dart';
import '../../models/child_model.dart';
import '../child_repository.dart';

class ChildRepositoryImpl implements ChildRepository {
  final FirebaseFirestore _firestore;

  const ChildRepositoryImpl(this._firestore);

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

  // ==================== Lock / Unlock ====================
  @override
  Future<bool> lockDevice({
    required String parentUid,
    required String childId,
    required String reason,
  }) async {
    try {
      await _childRef(parentUid, childId).update({
        'isLocked': true,
        'lockReason': reason,
        'lockedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  @override
  Future<bool> unlockDevice({
    required String parentUid,
    required String childId,
  }) async {
    try {
      await _childRef(parentUid, childId).update({
        'isLocked': false,
        'lockReason': null,
        'lockedAt': null,
      });
      return true;
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  // ==================== Child Data ====================
  @override
  Future<ChildModel?> getChild({
    required String parentUid,
    required String childId,
  }) async {
    try {
      final snap = await _childRef(parentUid, childId).get();
      if (!snap.exists || snap.data() == null) return null;
      return ChildModel.fromMap(snap.data()!, snap.id);
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  @override
  Future<bool> updateChild({
    required String parentUid,
    required String childId,
    String? name,
    int? age,
    String? avatar,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (name != null) updates['name'] = name;
      if (age != null) updates['age'] = age;
      if (avatar != null) updates['avatar'] = avatar;

      if (updates.isEmpty) return true;

      await _childRef(parentUid, childId).update(updates);
      return true;
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  // ==================== Screen Time ====================
  @override
  Future<void> updateScreenTime({
    required String parentUid,
    required String childId,
    required int additionalMinutes,
  }) async {
    try {
      await _childRef(parentUid, childId).update({
        'screenTimeToday': FieldValue.increment(additionalMinutes),
        'lastScreenTimeUpdate': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw AppException.fromFirebase(e);
    }
  }

  // ==================== Real-time Stream ====================
  @override
  Stream<ChildModel?> watchChild({
    required String parentUid,
    required String childId,
  }) {
    return _childRef(parentUid, childId).snapshots().map((snap) {
      if (!snap.exists || snap.data() == null) return null;
      return ChildModel.fromMap(snap.data()!, snap.id);
    });
  }
}
