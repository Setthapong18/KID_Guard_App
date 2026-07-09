// ==================== Native Settings Sync ====================
// บริการ Sync ข้อมูลระหว่าง Flutter กับ Native (Accessibility Service)
//
// ปัญหา: Android Accessibility Service ทำงาน background ตลอด
// แต่ไม่สามารถเข้าถึง Flutter/Dart ได้โดยตรง
//
// วิธีแก้: ใช้ไฟล์ JSON เป็นตัวกลาง
// - Flutter เขียนข้อมูลลงไฟล์ kid_guard_settings.json
// - Native Accessibility Service อ่านจากไฟล์เดียวกัน
//
// ไฟล์ที่ใช้:
// 1. kid_guard_settings.json → Flutter เขียน, Native อ่าน
//    - เก็บ: childId, parentId, isChildModeActive, screenTime, dailyTimeLimit,
//      sleepSchedule, quietTimes, timeLimitDisabledUntil
//
// 2. screen_time_data.json → Native เขียน, Flutter อ่าน
//    - เก็บ: screenTime, limitUsedTime ที่ native คำนวณ
//
// Flow หลัก:
// 1. Parent เปลี่ยนค่าใน Firebase (เช่น เปลี่ยน time limit)
// 2. Flutter ดึงค่าจาก Firebase → เขียนลงไฟล์ JSON
// 3. Native Accessibility Service อ่านไฟล์ JSON → ใช้ค่าจัดการ
// 4. Native อัปเดต screenTime → เขียนลง screen_time_data.json
// 5. Flutter อ่าน screen_time_data.json → sync กลับไป Firebase
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NativeSettingsSync {
  // Singleton pattern - ใช้ instance เดียวทั้งแอพ
  static final NativeSettingsSync _instance = NativeSettingsSync._internal();
  factory NativeSettingsSync() => _instance;
  NativeSettingsSync._internal();

  /// ดึง directory ที่ native service ใช้อ่านไฟล์
  /// ต้องตรงกับ path ที่ Kotlin Accessibility Service ใช้
  Future<Directory> _getNativeDataDirectory() async {
    Directory? directory;
    if (Platform.isAndroid) {
      // ใช้ getApplicationSupportDirectory() ซึ่งตรงกับ filesDir ใน Kotlin
      directory = await getApplicationSupportDirectory();
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    if (!await directory.exists()) {
      await directory.create(recursive: true);
    }
    return directory;
  }

  /// บันทึกค่าตั้งทั้งหมดลงไฟล์ JSON เพื่อให้ Native อ่าน
  /// เรียกทุกครั้งที่มีการเปลี่ยนแปลงค่าตั้ง (time limit, schedule, ฯลฯ)
  Future<void> syncSettingsToNative({
    required String childId,
    required String parentId,
    required bool isChildModeActive,
    required int screenTime,
    required int limitUsedTime,
    required int dailyTimeLimit,
    DateTime? timeLimitDisabledUntil,
    bool sleepScheduleEnabled = false,
    int bedtimeHour = 20,
    int bedtimeMinute = 0,
    int wakeHour = 7,
    int wakeMinute = 0,
    List<Map<String, dynamic>> quietTimes = const [],
  }) async {
    try {
      final directory = await _getNativeDataDirectory();
      final file = File('${directory.path}/kid_guard_settings.json');

      final settings = {
        'childId': childId,
        'parentId': parentId,
        'isChildModeActive': isChildModeActive,
        'screenTime': screenTime,
        'limitUsedTime': limitUsedTime,
        'dailyTimeLimit': dailyTimeLimit,
        'timeLimitDisabledUntil':
            timeLimitDisabledUntil?.millisecondsSinceEpoch ?? 0,
        'sleepScheduleEnabled': sleepScheduleEnabled,
        'bedtimeHour': bedtimeHour,
        'bedtimeMinute': bedtimeMinute,
        'wakeHour': wakeHour,
        'wakeMinute': wakeMinute,
        'quietTimes': quietTimes,
        'lastUpdate': DateTime.now().millisecondsSinceEpoch,
      };

      await file.writeAsString(jsonEncode(settings));
    } catch (e) {
      // Error syncing settings to native - fail silently
    }
  }

  /// อ่าน screen time ที่ native คำนวณ
  /// Native Accessibility Service เขียนไฟล์ screen_time_data.json
  Future<Map<String, dynamic>?> readScreenTimeFromNative() async {
    try {
      final directory = await _getNativeDataDirectory();
      final file = File('${directory.path}/screen_time_data.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        return jsonDecode(content) as Map<String, dynamic>;
      }
    } catch (e) {
      // Error reading screen time from native
    }
    return null;
  }

  /// Sync screen time จาก native → Firebase
  /// เพื่อให้ parent เห็นเวลาใช้งานล่าสุดจากฝั่ง native
  Future<void> syncScreenTimeToFirebase(String parentId, String childId) async {
    try {
      final data = await readScreenTimeFromNative();
      if (data == null) return;

      final screenTime = data['screenTime'] as int? ?? 0;
      final limitUsedTime = data['limitUsedTime'] as int? ?? 0;

      await FirebaseFirestore.instance
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .update({
            'screenTime': screenTime,
            'limitUsedTime': limitUsedTime,
            'lastActive': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      // Error syncing screen time to Firebase
    }
  }

  /// ดึงค่าการตั้งค่าทั้งหมดจาก Firebase → sync ลงไฟล์ JSON
  /// เรียกตอนเปิด child mode เพื่อให้ native มีข้อมูลล่าสุด
  Future<void> loadFromFirebaseAndSync(String parentId, String childId) async {
    try {
      final childDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(parentId)
          .collection('children')
          .doc(childId)
          .get();

      if (!childDoc.exists) return;

      final data = childDoc.data()!;

      // ดึงค่า sleep schedule
      bool sleepEnabled = false;
      int bedtimeHour = 20;
      int bedtimeMinute = 0;
      int wakeHour = 7;
      int wakeMinute = 0;

      if (data['sleepSchedule'] != null) {
        final sleep = data['sleepSchedule'] as Map<String, dynamic>;
        sleepEnabled = sleep['enabled'] ?? false;
        bedtimeHour = sleep['bedtimeHour'] ?? 20;
        bedtimeMinute = sleep['bedtimeMinute'] ?? 0;
        wakeHour = sleep['wakeHour'] ?? 7;
        wakeMinute = sleep['wakeMinute'] ?? 0;
      }

      // ดึงค่า quiet times
      List<Map<String, dynamic>> quietTimes = [];
      if (data['quietTimes'] != null) {
        quietTimes = List<Map<String, dynamic>>.from(
          (data['quietTimes'] as List).map(
            (item) => Map<String, dynamic>.from(item),
          ),
        );
      }

      // ดึงค่า time limit disabled until
      DateTime? timeLimitDisabledUntil;
      if (data['timeLimitDisabledUntil'] != null) {
        timeLimitDisabledUntil = (data['timeLimitDisabledUntil'] as Timestamp)
            .toDate();
      }

      // เขียนทั้งหมดลงไฟล์ JSON
      await syncSettingsToNative(
        childId: childId,
        parentId: parentId,
        isChildModeActive: data['isChildModeActive'] ?? false,
        screenTime: data['screenTime'] ?? 0,
        limitUsedTime: data['limitUsedTime'] ?? data['screenTime'] ?? 0,
        dailyTimeLimit: data['dailyTimeLimit'] ?? 0,
        timeLimitDisabledUntil: timeLimitDisabledUntil,
        sleepScheduleEnabled: sleepEnabled,
        bedtimeHour: bedtimeHour,
        bedtimeMinute: bedtimeMinute,
        wakeHour: wakeHour,
        wakeMinute: wakeMinute,
        quietTimes: quietTimes,
      );
    } catch (e) {
      // Error loading settings from Firebase
    }
  }

  /// เปิด child mode → sync ค่าทั้งหมดจาก Firebase แล้วตั้ง flag
  Future<void> enableChildMode(String parentId, String childId) async {
    // ดึงค่าทุกอย่างจาก Firebase มาเขียนลงไฟล์ก่อน
    await loadFromFirebaseAndSync(parentId, childId);

    // อัปเดต flag isChildModeActive = true
    final directory = await _getNativeDataDirectory();
    final file = File('${directory.path}/kid_guard_settings.json');

    if (await file.exists()) {
      final content = await file.readAsString();
      final settings = jsonDecode(content) as Map<String, dynamic>;
      settings['isChildModeActive'] = true;
      await file.writeAsString(jsonEncode(settings));
    }
  }

  /// ปิด child mode → ตั้ง flag เป็น false
  Future<void> disableChildMode() async {
    try {
      final directory = await _getNativeDataDirectory();
      final file = File('${directory.path}/kid_guard_settings.json');

      if (await file.exists()) {
        final content = await file.readAsString();
        final settings = jsonDecode(content) as Map<String, dynamic>;
        settings['isChildModeActive'] = false;
        await file.writeAsString(jsonEncode(settings));
      }
    } catch (e) {
      // Error disabling child mode
    }
  }
}
