// ==================== Daily Report Service ====================
// บริการสรุปการใช้งานรายวันของเด็ก
//
// Flow:
// 1. WorkManager trigger ทุกวัน เวลา 20:00
// 2. ดึงข้อมูล children ทั้งหมดของ parent จาก Firestore
// 3. ดึง daily_stats ของวันนี้ของแต่ละเด็ก
// 4. ส่ง local notification สรุปยอด screen time
//
// หมายเหตุ:
// - ทำงานใน isolate แยก (WorkManager) ดังนั้นต้อง init Firebase ใหม่
// - SharedPreferences & SecureStorage ใช้ได้ แต่ Provider ใช้ไม่ได้
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/secure_storage_service.dart';

class DailyReportService {
  static const String taskName = 'daily_report_notification';

  // ─── แสดง notification สรุปรายวัน ──────────────────────────────────
  /// ดึงข้อมูลและส่ง notification — เรียกจาก WorkManager callback
  static Future<bool> runDailyReport({bool isTest = false}) async {
    try {
      // ตรวจสอบว่าผู้ปกครองเปิดการแจ้งเตือน daily reports หรือไม่
      final prefs = await SharedPreferences.getInstance();
      final enabled = prefs.getBool('notif_daily_reports') ?? false;
      if (!enabled && !isTest) return true; // ไม่ได้เปิด → ข้ามไปเลย

      // ต้อง init Firebase ใหม่ (WorkManager ทำงานใน isolate แยก)
      await Firebase.initializeApp();

      // อ่าน parentUid จาก SecureStorage
      final parentUid = await SecureStorageService.getBackgroundParentUid();
      if (parentUid == null) return true; // ยังไม่ได้ล็อกอิน

      // ดึงรายชื่อเด็กทั้งหมด
      final childrenSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .get();

      if (childrenSnapshot.docs.isEmpty) return true;

      // วันนี้
      final now = DateTime.now();
      final todayStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

      // เตรียม notification plugin
      final plugin = FlutterLocalNotificationsPlugin();
      const androidInit = AndroidInitializationSettings(
        '@drawable/ic_stat_name',
      );
      await plugin.initialize(
        const InitializationSettings(android: androidInit),
      );

      final soundEnabled = prefs.getBool('notif_sound') ?? true;
      final vibrationEnabled = prefs.getBool('notif_vibration') ?? true;

      // วน loop ทุกเด็ก
      int notifId = 9000; // base ID สำหรับ daily report
      for (final childDoc in childrenSnapshot.docs) {
        final childData = childDoc.data();
        final childName = childData['name'] as String? ?? 'ลูก';
        final childId = childDoc.id;

        // ดึง daily_stats ของวันนี้
        final statsDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(parentUid)
            .collection('children')
            .doc(childId)
            .collection('daily_stats')
            .doc(todayStr)
            .get();

        if (!statsDoc.exists) continue;

        final statsData = statsDoc.data()!;
        final screenTimeSec = statsData['screenTime'] as int? ?? 0;

        if (screenTimeSec < 60 && !isTest)
          continue; // ใช้งานน้อยมาก ไม่ต้องแจ้ง (ถ้าเทส แจ้งตลอด)

        // แปลงเวลาเป็น ชม./นาที
        final hours = screenTimeSec ~/ 3600;
        final minutes = (screenTimeSec % 3600) ~/ 60;

        final timeStr = hours > 0
            ? '$hours ชม. $minutes นาที'
            : '$minutes นาที';

        // หาแอพที่ใช้เยอะสุดวันนี้
        String topAppName = '';
        if (statsData.containsKey('apps') && statsData['apps'] is Map) {
          final appsMap = Map<String, dynamic>.from(statsData['apps'] as Map);
          String topKey = '';
          int topSec = 0;
          appsMap.forEach((key, val) {
            if (val is Map) {
              final sec = val['screenTime'] as int? ?? 0;
              if (sec > topSec) {
                topSec = sec;
                topKey = val['appName'] as String? ?? key;
              }
            }
          });
          topAppName = topKey;
        }

        // สร้างข้อความแจ้งเตือน
        final title = '📊 รายงานประจำวัน – $childName';
        final body = topAppName.isNotEmpty
            ? '$childName ใช้งานวันนี้ $timeStr (แอพยอดนิยม: $topAppName)'
            : '$childName ใช้งานหน้าจอวันนี้ $timeStr';

        // ส่ง notification
        final androidDetails = AndroidNotificationDetails(
          'kidguard_daily_report',
          'Daily Reports',
          channelDescription: 'Daily usage summary reports',
          importance: Importance.high,
          priority: Priority.high,
          playSound: soundEnabled,
          enableVibration: vibrationEnabled,
          color: const Color(0xFF6B9080),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(body),
        );

        await plugin.show(
          notifId++,
          title,
          body,
          NotificationDetails(android: androidDetails),
          payload: 'daily_report:$childId',
        );
      }

      return true;
    } catch (e) {
      return false;
    }
  }
}
