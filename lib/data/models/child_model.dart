// ==================== Child Model ====================
// โมเดลข้อมูลเด็ก (ลูก)
//
// เก็บข้อมูลลูกแต่ละคนภายใต้ผู้ปกครอง
// เป็นโมเดลหลักที่ใช้ทั่วทั้งแอพ ทั้งฝั่ง parent และ child
//
// โครงสร้าง Firestore: /users/{parentUid}/children/{childId}
//
// การจัดการเวลาหน้าจอ:
// - screenTime: เวลาใช้หน้าจอรวมวันนี้ (สำหรับสถิติ) - ไม่ reset เมื่อ parent ปลดล็อก
// - limitUsedTime: เวลาที่ใช้ไปเทียบกับ limit - reset ได้เมื่อ parent ปลดล็อก
// - dailyTimeLimit: จำกัดเวลาใช้ต่อวัน (วินาที), 0 = ไม่จำกัด
//
// สถานะล็อก:
// - isLocked: true = เครื่องถูกล็อก (แสดง lock screen)
// - lockReason: เหตุผลที่ล็อก (blocked_app, time_limit, sleep, quiet, screen_timeout)
// - unlockRequested: parent สั่ง unlock ระยะไกล (child device จะ listen แล้ว unlock)
// - timeLimitDisabledUntil: ปิด time limit ชั่วครามจนถึงเวลานี้
import 'package:cloud_firestore/cloud_firestore.dart';

class ChildModel {
  final String id; // document ID ใน children subcollection
  final String parentId; // UID ของผู้ปกครอง (เพื่อ reference กลับ)
  final String name; // ชื่อเด็ก
  final int age; // อายุ
  final String? avatar; // ชื่อไฟล์ avatar (เช่น 'bear', 'cat')
  final int
  screenTime; // เวลาใช้หน้าจอรวมวันนี้ (วินาที) - สำหรับสถิติ ไม่ reset
  final int
  limitUsedTime; // เวลาที่ใช้ไปเทียบกับ limit (วินาที) - reset ได้โดย parent
  final bool isLocked; // สถานะล็อกเครื่อง
  final bool isOnline; // เด็กออนไลน์อยู่หรือไม่
  final DateTime? lastActive; // เวลาที่ active ล่าสุด
  final DateTime?
  sessionStartTime; // เวลาที่เปิด child mode (ใช้คำนวณ screen time)
  final int dailyTimeLimit; // จำกัดเวลาต่อวัน (วินาที), 0 = ไม่จำกัด
  final bool isChildModeActive; // child mode เปิดอยู่หรือไม่
  final bool unlockRequested; // parent สั่ง unlock ระยะไกล
  final DateTime? timeLimitDisabledUntil; // ปิด time limit ชั่วคราวจนถึงเวลานี้
  final String
  lockReason; // เหตุผลที่ล็อก: blocked_app, time_limit, sleep, quiet, screen_timeout
  final int points; // แต้มสะสมสำหรับระบบรางวัล
  final String? linkedDeviceId; // ID ของอุปกรณ์ที่ผูกกับบัญชีนี้ (1 บัญชีต่อ 1 เครื่อง)

  ChildModel({
    required this.id,
    required this.parentId,
    required this.name,
    required this.age,
    this.avatar,
    this.screenTime = 0,
    this.limitUsedTime = 0,
    this.isLocked = false,
    this.isOnline = false,
    this.lastActive,
    this.sessionStartTime,
    this.dailyTimeLimit = 0,
    this.isChildModeActive = false,
    this.unlockRequested = false,
    this.timeLimitDisabledUntil,
    this.lockReason = '',
    this.points = 0,
    this.linkedDeviceId,
  });

  /// สร้าง ChildModel จาก Firestore document data
  /// [map] - ข้อมูลจาก Firestore
  /// [id] - document ID ของ children subcollection
  ///
  /// หมายเหตุ: limitUsedTime fallback ไปใช้ screenTime
  /// สำหรับข้อมูลเก่าที่ยังไม่มี field limitUsedTime
  factory ChildModel.fromMap(Map<String, dynamic> map, String id) {
    return ChildModel(
      id: id,
      parentId: map['parentId'] ?? '',
      name: map['name'] ?? '',
      age: map['age'] ?? 0,
      avatar: map['avatar'],
      screenTime: map['screenTime'] ?? 0,
      limitUsedTime:
          map['limitUsedTime'] ??
          map['screenTime'] ??
          0, // Fallback สำหรับข้อมูลเก่า
      isLocked: map['isLocked'] ?? false,
      isOnline: map['isOnline'] ?? false,
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
      sessionStartTime: map['sessionStartTime'] != null
          ? (map['sessionStartTime'] as Timestamp).toDate()
          : null,
      dailyTimeLimit: map['dailyTimeLimit'] ?? 0,
      isChildModeActive: map['isChildModeActive'] ?? false,
      unlockRequested: map['unlockRequested'] ?? false,
      timeLimitDisabledUntil: map['timeLimitDisabledUntil'] != null
          ? (map['timeLimitDisabledUntil'] as Timestamp).toDate()
          : null,
      lockReason: map['lockReason'] ?? '',
      points: map['points'] ?? 0,
      linkedDeviceId: map['linkedDeviceId'],
    );
  }

  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  /// DateTime จะถูกเก็บเป็น Timestamp อัตโนมัติโดย Firestore
  Map<String, dynamic> toMap() {
    return {
      'parentId': parentId,
      'name': name,
      'age': age,
      'avatar': avatar,
      'screenTime': screenTime,
      'limitUsedTime': limitUsedTime,
      'isLocked': isLocked,
      'isOnline': isOnline,
      'lastActive': lastActive,
      'sessionStartTime': sessionStartTime,
      'dailyTimeLimit': dailyTimeLimit,
      'isChildModeActive': isChildModeActive,
      'unlockRequested': unlockRequested,
      'timeLimitDisabledUntil': timeLimitDisabledUntil,
      'lockReason': lockReason,
      'points': points,
      'linkedDeviceId': linkedDeviceId,
    };
  }

  /// สร้าง copy ของ ChildModel พร้อม override field ที่ต้องการ
  /// ทำให้อัปเดตข้อมูลเด็กได้แบบ Immutable (เหมือน RewardModel.copyWith)
  ///
  /// ตัวอย่าง:
  /// ```dart
  /// final updated = child.copyWith(isLocked: true, lockReason: 'sleep');
  /// ```
  ChildModel copyWith({
    String? id,
    String? parentId,
    String? name,
    int? age,
    String? avatar,
    int? screenTime,
    int? limitUsedTime,
    bool? isLocked,
    bool? isOnline,
    DateTime? lastActive,
    DateTime? sessionStartTime,
    int? dailyTimeLimit,
    bool? isChildModeActive,
    bool? unlockRequested,
    DateTime? timeLimitDisabledUntil,
    String? lockReason,
    int? points,
    String? linkedDeviceId,
  }) {
    return ChildModel(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      age: age ?? this.age,
      avatar: avatar ?? this.avatar,
      screenTime: screenTime ?? this.screenTime,
      limitUsedTime: limitUsedTime ?? this.limitUsedTime,
      isLocked: isLocked ?? this.isLocked,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      sessionStartTime: sessionStartTime ?? this.sessionStartTime,
      dailyTimeLimit: dailyTimeLimit ?? this.dailyTimeLimit,
      isChildModeActive: isChildModeActive ?? this.isChildModeActive,
      unlockRequested: unlockRequested ?? this.unlockRequested,
      timeLimitDisabledUntil:
          timeLimitDisabledUntil ?? this.timeLimitDisabledUntil,
      lockReason: lockReason ?? this.lockReason,
      points: points ?? this.points,
      linkedDeviceId: linkedDeviceId ?? this.linkedDeviceId,
    );
  }
}

