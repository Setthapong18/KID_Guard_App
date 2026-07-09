// ==================== Background Worker ====================
// งาน Background สำหรับ sync blocklist (ทำงานแม้แอพปิด)
//
// ใช้ WorkManager plugin ที่ทำงานเป็น periodic task
// ดึง blocklist จาก Firestore → บันทึกเป็นไฟล์ JSON ในเครื่อง
//
// Tasks:
// - syncBlocklist: ดึง blocklist จาก Firestore ทุก 15 นาที
// - daily_report_notification: ส่ง notification สรุปรายวัน
import 'package:workmanager/workmanager.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/local/blocklist_storage.dart';
import '../data/services/secure_storage_service.dart';
import '../data/services/daily_report_service.dart';

@pragma('vm:entry-point') // จำเป็น! บอก Dart compiler ว่าเรียกจาก native
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    // ─── Daily Report Notification ────────────────────────────────────
    if (task == DailyReportService.taskName) {
      final isTest = inputData?['isTest'] as bool? ?? false;
      return DailyReportService.runDailyReport(isTest: isTest);
    }

    // ─── Sync Blocklist (default task) ────────────────────────────────
    try {
      // ต้อง initialize Firebase ใหม่เพราะอยู่ใน isolate ใหม่
      await Firebase.initializeApp();

      // อ่าน childId, parentUid จาก SecureStorageService (Android Keystore)
      // เป็นข้อมูล sensitive — ไม่ใช้ SharedPreferences แล้ว
      final childId = await SecureStorageService.getBackgroundChildId();
      final parentUid = await SecureStorageService.getBackgroundParentUid();

      if (childId != null && parentUid != null) {
        // ดึงรายการแอพที่ถูกบล็อกจาก Firestore
        final snapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(parentUid)
            .collection('children')
            .doc(childId)
            .collection('apps')
            .where('isLocked', isEqualTo: true)
            .get();

        // แปลงเป็น list ของ package names
        final blockedApps = snapshot.docs
            .map((doc) => doc['packageName'] as String)
            .toList();

        // บันทึกลงไฟล์ JSON เพื่อให้ Native AccessibilityService อ่าน
        await BlocklistStorage().saveBlocklist(blockedApps);
      }

      return Future.value(true); // task สำเร็จ
    } catch (e) {
      return Future.value(false); // task ล้มเหลว
    }
  });
}
