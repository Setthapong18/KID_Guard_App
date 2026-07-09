// ==================== Rewards Provider ====================
/// จัดการ logic ของระบบ Rewards: เพิ่มคะแนน, แลกรางวัล, ดึงประวัติ, จัดการรางวัล custom
library;

import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/models/reward_model.dart';

class RewardsProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  int _currentPoints = 0;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<dynamic>> _events = {};
  bool _isLoading = false;
  String? _errorMessage;
  List<RewardModel> _customRewards = [];

  // Getters
  int get currentPoints => _currentPoints;
  DateTime get focusedDay => _focusedDay;
  DateTime? get selectedDay => _selectedDay;
  Map<DateTime, List<dynamic>> get events => _events;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<RewardModel> get customRewards => List.unmodifiable(_customRewards);

  /// เริ่มต้นค่า points จากข้อมูล child
  void initializePoints(int points) {
    _currentPoints = points;
    _selectedDay = _focusedDay;
    notifyListeners();
  }

  /// เลือกวันใน calendar
  void selectDay(DateTime selected, DateTime focused) {
    _selectedDay = selected;
    _focusedDay = focused;
    notifyListeners();
  }

  /// ดึง events สำหรับวันที่ระบุ
  List<dynamic> getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  /// ดึงประวัติ points จาก Firestore
  Future<void> fetchHistory(String userId, String childId) async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('children')
        .doc(childId)
        .collection('point_history')
        .orderBy('date', descending: true)
        .limit(100)
        .get();

    final Map<DateTime, List<dynamic>> newEvents = {};
    for (final doc in snapshot.docs) {
      final data = doc.data();
      final date = (data['date'] as Timestamp).toDate();
      final dayKey = DateTime(date.year, date.month, date.day);
      newEvents[dayKey] = [
        ...(newEvents[dayKey] ?? []),
        {...data, 'id': doc.id},
      ];
    }

    _events = newEvents;
    notifyListeners();
  }

  /// เพิ่ม points ให้เด็ก
  /// ใช้ WriteBatch เพื่อให้ทั้ง update points และ add history เป็น atomic
  /// (สำเร็จทั้งคู่หรือล้มเหลวทั้งคู่ — ป้องกัน data inconsistency)
  Future<bool> addPoints({
    required String userId,
    required String childId,
    required int amount,
    required String reason,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPoints = _currentPoints + amount;
      final entryDate = _selectedDay ?? DateTime.now();

      final childRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId);

      final historyRef = childRef.collection('point_history').doc();

      // ✅ Atomic batch: ถ้า operation ใดล้มเหลว ทั้งคู่จะ rollback
      final batch = _firestore.batch();
      batch.update(childRef, {'points': newPoints});
      batch.set(historyRef, {
        'amount': amount,
        'reason': reason,
        'type': 'earn',
        'date': Timestamp.fromDate(entryDate),
      });
      await batch.commit();

      _currentPoints = newPoints;
      _isLoading = false;
      notifyListeners();

      await fetchHistory(userId, childId);
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// แลกรางวัล (หัก points)
  /// ใช้ WriteBatch เพื่อให้ทั้ง update points และ add history เป็น atomic
  Future<bool> redeemReward({
    required String userId,
    required String childId,
    required int cost,
    required String rewardName,
  }) async {
    if (_currentPoints < cost) return false;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newPoints = _currentPoints - cost;

      final childRef = _firestore
          .collection('users')
          .doc(userId)
          .collection('children')
          .doc(childId);

      final historyRef = childRef.collection('point_history').doc();

      // ✅ Atomic batch: หัก points และบันทึก history พร้อมกัน
      final batch = _firestore.batch();
      batch.update(childRef, {'points': newPoints});
      batch.set(historyRef, {
        'amount': cost,
        'reason': rewardName,
        'type': 'redeem',
        'date': Timestamp.now(),
      });
      await batch.commit();

      _currentPoints = newPoints;
      _isLoading = false;
      notifyListeners();

      await fetchHistory(userId, childId);
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  // ==================== Custom Rewards CRUD ====================

  /// ดึงรางวัล custom ทั้งหมดของ user
  Future<void> fetchCustomRewards(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('custom_rewards')
          .orderBy('createdAt', descending: false)
          .get();

      _customRewards = snapshot.docs
          .map((doc) => RewardModel.fromMap(doc.data(), doc.id))
          .toList();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  /// เพิ่มรางวัล custom ใหม่
  Future<bool> addCustomReward({
    required String userId,
    required String name,
    required String emoji,
    required int cost,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reward = RewardModel(
        id: '',
        name: name,
        emoji: emoji,
        cost: cost,
        createdAt: DateTime.now(),
      );

      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('custom_rewards')
          .add(reward.toMap());

      _customRewards.add(
        RewardModel(
          id: docRef.id,
          name: name,
          emoji: emoji,
          cost: cost,
          createdAt: reward.createdAt,
        ),
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// แก้ไขรางวัล custom
  Future<bool> updateCustomReward({
    required String userId,
    required String rewardId,
    required String name,
    required String emoji,
    required int cost,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('custom_rewards')
          .doc(rewardId)
          .update({'name': name, 'emoji': emoji, 'cost': cost});

      final index = _customRewards.indexWhere((r) => r.id == rewardId);
      if (index != -1) {
        _customRewards[index] = _customRewards[index].copyWith(
          name: name,
          emoji: emoji,
          cost: cost,
        );
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// ลบรางวัล custom
  Future<bool> deleteCustomReward({
    required String userId,
    required String rewardId,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('custom_rewards')
          .doc(rewardId)
          .delete();

      _customRewards.removeWhere((r) => r.id == rewardId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
