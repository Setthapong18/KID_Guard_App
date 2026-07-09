// ==================== Device Model ====================
// โมเดลข้อมูลอุปกรณ์ (โทรศัพท์/แท็บเล็ตของเด็ก)
//
// ระบบรองรับเด็ก 1 คนมีหลายอุปกรณ์ได้
// แต่ละอุปกรณ์จะ track สถานะออนไลน์และ sync request แยกกัน
//
// โครงสร้าง Firestore: /users/{parentUid}/children/{childId}/devices/{deviceId}
// - deviceId: ใช้ Android ID หรือ iOS identifierForVendor เป็น document ID
// - syncRequested: parent สั่งให้อุปกรณ์ sync ข้อมูลใหม่ (เด็ก listen แล้ว sync)
import 'package:cloud_firestore/cloud_firestore.dart';

class DeviceModel {
  final String deviceId; // ID เฉพาะของอุปกรณ์ (Android ID / iOS vendor ID)
  final String deviceName; // ชื่ออุปกรณ์ (เช่น "Samsung Galaxy A54")
  final DateTime? lastActive; // เวลาที่อุปกรณ์ active ล่าสุด
  final bool isOnline; // อุปกรณ์ออนไลน์อยู่หรือไม่
  final bool syncRequested; // parent ขอให้ sync ข้อมูล (blocklist, apps)

  DeviceModel({
    required this.deviceId,
    required this.deviceName,
    this.lastActive,
    this.isOnline = false,
    this.syncRequested = false,
  });

  /// สร้าง DeviceModel จาก Firestore document data
  factory DeviceModel.fromMap(Map<String, dynamic> map, String id) {
    return DeviceModel(
      deviceId: id,
      deviceName: map['deviceName'] ?? 'Unknown Device',
      lastActive: map['lastActive'] != null
          ? (map['lastActive'] as Timestamp).toDate()
          : null,
      isOnline: map['isOnline'] ?? false,
      syncRequested: map['syncRequested'] ?? false,
    );
  }

  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  /// lastActive แปลงเป็น Timestamp ก่อนบันทึก
  Map<String, dynamic> toMap() {
    return {
      'deviceName': deviceName,
      'lastActive': lastActive != null ? Timestamp.fromDate(lastActive!) : null,
      'isOnline': isOnline,
      'syncRequested': syncRequested,
    };
  }
}
