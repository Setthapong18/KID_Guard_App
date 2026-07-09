// ==================== Local Notification Service ====================
// บริการแจ้งเตือนบนอุปกรณ์ (Local Push Notification)
//
// แสดง notification บน status bar ของเครื่อง (ไม่ต้องใช้ server)
// ใช้ flutter_local_notifications plugin
//
// ระบบ Channel (Android):
// Android แยก notification เป็น channel ให้ user จัดการเปิด/ปิดในตั้งค่าได้
// - kidguard_app_blocked: แจ้งเมื่อเด็กเปิดแอพที่ถูกบล็อก
// - kidguard_time_limit: แจ้งเรื่อง time limit
// - kidguard_location: แจ้งเรื่องตำแหน่ง
// - kidguard_daily_report: รายงานสรุปรายวัน
// - kidguard_system: แจ้งเตือนระบบทั่วไป
//
// ระบบกรอง:
// เช็คจาก SharedPreferences ว่าแต่ละ category เปิดอยู่หรือไม่
// (แยกจาก Firestore settings → ใช้ local เพื่อเร็วกว่า)
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalNotificationService {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  /// เริ่มต้น notification plugin
  /// เรียกใน main() ก่อน runApp()
  /// ใช้ @drawable/ic_stat_name เป็น small icon บน notification bar
  static Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@drawable/ic_stat_name');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // สามารถจัดการ notification click ได้ที่นี่ (ตอนนี้ยังไม่ใช้)
      },
    );
  }

  /// แสดง local notification พร้อมระบบกรองตาม category
  ///
  /// [id] - ID ของ notification (ถ้าซ้ำจะ replace อันเก่า)
  /// [title] - หัวข้อ
  /// [body] - เนื้อหา
  /// [payload] - ข้อมูลเพิ่มเติม (ส่งไปตอน click)
  /// [category] - หมวดหมู่: 'app_blocked', 'time_limit', 'location', 'daily_report', 'system'
  ///
  /// ขั้นตอน:
  /// 1. เช็คว่า category นี้เปิดใช้งานใน SharedPreferences หรือไม่
  /// 2. เลือก Android channel ตาม category
  /// 3. แสดง notification
  static Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    String category = 'system',
  }) async {
    // เช็คการตั้งค่าเสียงและสั่น
    final prefs = await SharedPreferences.getInstance();
    final soundEnabled = prefs.getBool('notif_sound') ?? true;
    final vibrationEnabled = prefs.getBool('notif_vibration') ?? true;

    // เช็คว่า category นี้เปิดใช้งานหรือไม่
    bool isEnabled = true;
    switch (category) {
      case 'app_blocked':
        isEnabled = prefs.getBool('notif_app_blocked') ?? true;
      case 'time_limit':
        isEnabled = prefs.getBool('notif_time_limit') ?? true;
      case 'location':
        isEnabled = prefs.getBool('notif_location') ?? true;
      case 'daily_report':
        isEnabled = prefs.getBool('notif_daily_reports') ?? false;
      default:
        isEnabled = true; // system notification ปิดไม่ได้
    }

    if (!isEnabled) return;

    // เลือก notification channel ตาม category
    final channelInfo = _getChannelForCategory(category);

    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelInfo['id']!,
          channelInfo['name']!,
          channelDescription: channelInfo['description'],
          importance: Importance.max,
          priority: Priority.high,
          playSound: soundEnabled,
          enableVibration: vibrationEnabled,
          color: const Color(0xFF6B9080), // สี Sage Green ของแอพ
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        );

    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  /// คืนค่า channel info ตาม category
  /// Android ใช้ channel เพื่อให้ user จัดการ notification แต่ละประเภทแยกกัน
  static Map<String, String> _getChannelForCategory(String category) {
    switch (category) {
      case 'app_blocked':
        return {
          'id': 'kidguard_app_blocked',
          'name': 'App Blocked Alerts',
          'description': 'Alerts when a child tries to open a blocked app',
        };
      case 'time_limit':
        return {
          'id': 'kidguard_time_limit',
          'name': 'Time Limit Alerts',
          'description': 'Alerts about screen time limits',
        };
      case 'location':
        return {
          'id': 'kidguard_location',
          'name': 'Location Alerts',
          'description': 'Alerts about child location changes',
        };
      case 'daily_report':
        return {
          'id': 'kidguard_daily_report',
          'name': 'Daily Reports',
          'description': 'Daily usage summary reports',
        };
      default:
        return {
          'id': 'kidguard_system',
          'name': 'Kid Guard System',
          'description': 'System and account notifications',
        };
    }
  }
}
