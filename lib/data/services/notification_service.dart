// ==================== Notification Service ====================
// บริการจัดการ Notification ใน Firestore
//
// จัดการการสร้าง, อ่าน, ลบ notification ในระบบ
// Notification จะแสดงในหน้า parent home (กดไอคอนกระดิ่ง)
//
// โครงสร้าง Firestore: /users/{parentUid}/notifications/{notificationId}
//
// ฟังก์ชันหลัก:
// - getNotifications() → Stream notification (realtime, จำกัด 50 รายการ)
// - addNotification() → สร้าง notification ใหม่ (มี dedup + category filter)
// - deleteNotification() → ลบ notification
// - markAllAsRead() → อ่านทั้งหมด
// - markAsRead() → อ่านรายการเดียว
//
// ระบบป้องกันซ้ำ (Dedup):
// เช็คกับ notification ล่าสุด ถ้าซ้ำภายใน 2 นาที จะไม่สร้างใหม่
//
// ระบบกรอง (Category Filter):
// เช็คจาก notificationSettings ใน user doc ว่าเปิดหมวดนั้นหรือไม่
//
// ทำความสะอาดอัตโนมัติ:
// ลบ notification ที่เก่ากว่า 30 วัน
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../models/child_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Stream notification ของผู้ปกครอง (realtime)
  /// เรียงจากใหม่ไปเก่า จำกัด 50 รายการ
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('timestamp', descending: true)
        .limit(50) // จำกัดจำนวนเพื่อไม่ให้โหลดหนัก
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList();
        });
  }

  /// สร้าง notification ใหม่พร้อมระบบ dedup และ category filter
  ///
  /// ขั้นตอนการทำงาน:
  /// 1. เช็คว่า category นี้เปิดในตั้งค่าหรือไม่
  /// 2. เช็ค dedup กับ notification ล่าสุด (ซ้ำภายใน 2 นาที = ไม่สร้าง)
  /// 3. บันทึกลง Firestore
  /// 4. ลบ notification เก่า (> 30 วัน)
  Future<void> addNotification(
    String userId,
    NotificationModel notification,
  ) async {
    try {
      // ขั้นตอน 1: เช็คว่า category นี้เปิดใช้งานในตั้งค่าหรือไม่
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final data = userDoc.data();
        if (data != null && data.containsKey('notificationSettings')) {
          final settings = data['notificationSettings'] as Map<String, dynamic>;

          bool isEnabled = true;
          final category = notification.category;

          // แต่ละ category สามารถเปิด/ปิดได้แยกกัน
          switch (category) {
            case 'app_blocked':
              isEnabled = settings['appBlocked'] ?? true;
            case 'time_limit':
              isEnabled = settings['timeLimit'] ?? true;
            case 'location':
              isEnabled = settings['location'] ?? true;
            case 'daily_report':
              isEnabled = settings['dailyReports'] ?? false;
            default:
              isEnabled = true; // system notification ปิดไม่ได้
          }

          if (!isEnabled) {
            if (kDebugMode) {
              debugPrint(
                'Notification suppressed: category=$category is disabled.',
              );
            }
            return;
          }
        }
      }

      // ขั้นตอน 2: เช็ค dedup - ไม่สร้างซ้ำถ้าเนื้อหาเหมือนกันภายใน 2 นาที
      // เช็คแค่ notification ล่าสุด 1 รายการ เพื่อหลีกเลี่ยง composite index
      final lastNotifSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (lastNotifSnapshot.docs.isNotEmpty) {
        final lastNotif = lastNotifSnapshot.docs.first.data();
        final lastTimestamp = (lastNotif['timestamp'] as Timestamp).toDate();

        // ถ้าเนื้อหาซ้ำกันภายใน 2 นาที ถือว่าเป็น duplicate
        if (lastNotif['title'] == notification.title &&
            lastNotif['message'] == notification.message &&
            DateTime.now().difference(lastTimestamp).inMinutes < 2) {
          if (kDebugMode) {
            debugPrint('Notification suppressed: Duplicate of most recent.');
          }
          return;
        }
      }

      // ขั้นตอน 3: บันทึกลง Firestore
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add(notification.toMap());

      if (kDebugMode) {
        debugPrint('Notification added successfully: ${notification.title}');
      }

      // ขั้นตอน 4: ลบ notification เก่า (เก็บไว้ไม่เกิน 30 วัน)
      _cleanupOldNotifications(userId);
    } catch (e) {
      if (kDebugMode) debugPrint('Error adding notification: $e');
    }
  }

  /// ลบ notification รายการเดียว
  Future<void> deleteNotification(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  /// อ่าน notification ทั้งหมด (mark all as read)
  /// ใช้ batch write เพื่อ update หลายรายการในครั้งเดียว
  Future<void> markAllAsRead(String userId) async {
    final batch = _firestore.batch();
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (final doc in snapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  /// อ่าน notification รายการเดียว
  Future<void> markAsRead(String userId, String notificationId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  /// ลบ notification ที่เก่ากว่า 30 วัน
  /// เรียกอัตโนมัติหลังจากสร้าง notification ใหม่
  Future<void> _cleanupOldNotifications(String userId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      final oldDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('timestamp', isLessThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      if (oldDocs.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in oldDocs.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
        if (kDebugMode) {
          debugPrint('Cleaned up ${oldDocs.docs.length} old notifications.');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error cleaning up notifications: $e');
    }
  }

  /// สร้าง notification ตัวอย่างตอนเริ่มใช้งาน (สำหรับ demo)
  /// ตอนนี้ปิดไว้ เพื่อให้ notification มาจากการใช้งานจริงเท่านั้น
  Future<void> seedInitialNotifications(
    String userId,
    List<ChildModel> children, {
    bool force = false,
  }) async {
    // ปิดการ seed notification เพื่อให้แสดงเฉพาะ notification จริงเท่านั้น
  }

  /// ลบ notification ที่ซ้ำกัน (เนื้อหาเหมือนกัน)
  /// ใช้ title + message เป็น key ในการเช็คซ้ำ
  /// เก็บรายการแรกไว้ ลบรายการที่ซ้ำทั้งหมด
  Future<void> removeDuplicateNotifications(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('timestamp', descending: true)
          .get();

      final seen = <String>{}; // เก็บ key ที่เจอแล้ว
      final batch = _firestore.batch();
      int deleteCount = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        // สร้าง key จาก title + message เพื่อเช็คซ้ำ
        final key = '${data['title']}|${data['message']}';
        if (seen.contains(key)) {
          // ซ้ำ → ลบ
          batch.delete(doc.reference);
          deleteCount++;
        } else {
          // ยังไม่เจอ → เก็บไว้
          seen.add(key);
        }
      }

      if (deleteCount > 0) {
        await batch.commit();
        if (kDebugMode) {
          debugPrint('Removed $deleteCount duplicate notifications.');
        }
      }
    } catch (e) {
      if (kDebugMode) debugPrint('Error removing duplicates: $e');
    }
  }
}
