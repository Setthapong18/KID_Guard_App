// ==================== Notification Model ====================
// โมเดลข้อมูลการแจ้งเตือนในแอพ
//
// เก็บ notification ที่แสดงในหน้า parent home
// เช่น "ลูกพยายามเปิดแอพที่ถูกบล็อก", "ถึงเวลานอนแล้ว"
//
// โครงสร้าง Firestore: /users/{parentUid}/notifications/{notificationId}
//
// ประเภท (type):
// - 'system': แจ้งเตือนจากระบบ (เช่น อัปเดต, ยินดีต้อนรับ)
// - 'child_activity': กิจกรรมของเด็ก (เช่น เปิดแอพ)
// - 'alert': แจ้งเตือนเร่งด่วน (เช่น เด็กพยายามเปิดแอพที่บล็อก)
//
// หมวดหมู่ (category) - ใช้สำหรับกรอง on/off ในตั้งค่า:
// - 'app_blocked': แจ้งเมื่อเด็กเปิดแอพที่ถูกบล็อก
// - 'time_limit': แจ้งเมื่อใกล้หมดเวลา/หมดเวลา
// - 'location': แจ้งเตือนตำแหน่ง
// - 'daily_report': รายงานสรุปรายวัน
// - 'system': แจ้งเตือนระบบ (ปิดไม่ได้)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationModel {
  final String id; // document ID ใน notifications subcollection
  final String title; // หัวข้อแจ้งเตือน
  final String message; // เนื้อหาแจ้งเตือน
  final DateTime timestamp; // เวลาที่สร้าง notification
  final String type; // ประเภท: 'system', 'child_activity', 'alert'
  final String
  category; // หมวดหมู่: 'app_blocked', 'time_limit', 'location', 'daily_report', 'system'
  final bool isRead; // อ่านแล้วหรือยัง
  final String?
  iconName; // ชื่อ icon (เช่น 'warning_rounded') - ใช้ map เป็น IconData
  final int?
  colorValue; // ค่าสีแบบ int (เช่น 0xFFFF0000 = แดง) - ถ้า null ใช้สีตาม type

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.type,
    this.category = 'system',
    this.isRead = false,
    this.iconName,
    this.colorValue,
  });

  /// สร้าง NotificationModel จาก Firestore document data
  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      timestamp: map['timestamp'] != null
          ? (map['timestamp'] as Timestamp).toDate()
          : DateTime.now(),
      type: map['type'] ?? 'system',
      category: map['category'] ?? 'system',
      isRead: map['isRead'] ?? false,
      iconName: map['iconName'],
      colorValue: map['colorValue'],
    );
  }

  /// แปลงเป็น Map สำหรับบันทึกลง Firestore
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'type': type,
      'category': category,
      'isRead': isRead,
      'iconName': iconName,
      'colorValue': colorValue,
    };
  }

  /// แปลงชื่อ icon (String) เป็น IconData ที่ Flutter ใช้ได้
  /// ถ้าไม่รู้จักชื่อ icon จะ fallback เป็น notifications_rounded
  IconData get icon {
    switch (iconName) {
      case 'person_add_rounded':
        return Icons.person_add_rounded;
      case 'settings_rounded':
        return Icons.settings_rounded;
      case 'warning_rounded':
        return Icons.warning_rounded;
      case 'check_circle_rounded':
        return Icons.check_circle_rounded;
      case 'edit_rounded':
        return Icons.edit_rounded;
      case 'vpn_key_rounded':
        return Icons.vpn_key_rounded;
      case 'schedule_rounded':
        return Icons.schedule_rounded;
      case 'location_on_rounded':
        return Icons.location_on_rounded;
      case 'block_rounded':
        return Icons.block_rounded;
      case 'shield_rounded':
        return Icons.shield_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  /// ดึงสีตาม type ของ notification
  /// ถ้ามี colorValue ที่กำหนดมาจะใช้ค่านั้น
  /// ถ้าไม่มีจะเลือกสีตาม type: alert=แดง, warning=ส้ม, success=เขียว, อื่นๆ=น้ำเงิน
  Color get color {
    if (colorValue != null) {
      return Color(colorValue!);
    }
    switch (type) {
      case 'alert':
        return Colors.red;
      case 'warning':
        return Colors.orange;
      case 'success':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }
}
