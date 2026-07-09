// ==================== Blocklist Storage ====================
// จัดเก็บรายการแอพที่ถูกบล็อกแบบ Local (ไฟล์ JSON)
//
// เก็บ blocklist เป็นไฟล์ JSON ในเครื่อง เพื่อให้ Native (Kotlin/Swift)
// อ่านได้โดยไม่ต้องเรียก Firebase
//
// ทำไมต้องเก็บ local?
// - Native service (AccessibilityService) ทำงาน background ตลอด
// - ไม่สามารถเรียก Firebase ได้ตรงๆ จาก native
// - จึงให้ Flutter sync blocklist จาก Firebase → ไฟล์ JSON
// - Native อ่านจากไฟล์ JSON แทน
//
// ตำแหน่งไฟล์: {app_files_dir}/blocked_apps.json
// รูปแบบ: JSON array ของ package names เช่น ["com.facebook.katana", "com.tiktok"]
//
// ใช้ร่วมกับ:
// - BackgroundWorker: sync blocklist จาก Firestore → ไฟล์ JSON (ทำงาน periodic)
// - BackgroundService: อ่าน blocklist จากไฟล์ (ผ่าน Dart)
// - Native AccessibilityService: อ่านไฟล์โดยตรง (Kotlin)
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class BlocklistStorage {
  static const String _fileName = 'blocked_apps.json';
  static const platform = MethodChannel('com.kidguard/native');

  /// ดึง path ของ files directory
  /// ต้องตรงกับ path ที่ Kotlin ใช้ (applicationContext.filesDir)
  /// เพื่อให้ทั้ง Flutter และ Native อ่าน/เขียนไฟล์เดียวกัน
  ///
  /// ลำดับการหา path:
  /// 1. ถาม native ผ่าน MethodChannel (ตรงที่สุด — ตรงกับ Kotlin filesDir)
  /// 2. Fallback ใช้ getApplicationSupportDirectory() (ปลอดภัยสำหรับทุกเครื่อง)
  Future<String> get _localPath async {
    try {
      if (Platform.isAndroid) {
        // ถาม native ก่อน → ได้ path ที่ตรงกับ Kotlin applicationContext.filesDir
        final String? path = await platform.invokeMethod<String>('getFilesDir');
        if (path != null && path.isNotEmpty) return path;
      }

      // Fallback: ใช้ path_provider ซึ่งปลอดภัยและไม่ hardcode
      // getApplicationSupportDirectory() คืน path ที่ถูกต้องสำหรับแต่ละ platform
      final directory = Platform.isAndroid
          ? await getApplicationSupportDirectory()
          : await getApplicationDocumentsDirectory();

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      return directory.path;
    } catch (e) {
      // ถ้าทุก fallback ล้มเหลว ให้ throw แทนการใช้ hardcoded path
      // เพื่อให้ error ชัดเจน ไม่ใช่ silent fail ที่ผิดเครื่อง
      throw StateError(
        'BlocklistStorage: ไม่สามารถหา application files directory ได้: $e',
      );
    }
  }

  /// ดึง File object ของ blocked_apps.json
  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/$_fileName');
  }

  /// บันทึก blocklist ลงไฟล์ JSON
  /// [blockedApps] - รายการ package name ที่ถูกบล็อก
  /// ใช้ flush: true เพื่อให้แน่ใจว่าข้อมูลเขียนลง disk จริง
  Future<void> saveBlocklist(List<String> blockedApps) async {
    final file = await _localFile;
    // สร้าง directory ถ้ายังไม่มี
    final dir = file.parent;
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    // Native ต้องการ JSON array ของ strings
    final String jsonString = jsonEncode(blockedApps);
    await file.writeAsString(jsonString, flush: true);
  }

  /// อ่าน blocklist จากไฟล์ JSON
  /// คืน list ว่างถ้าไฟล์ยังไม่มีหรืออ่านไม่ได้
  Future<List<String>> readBlocklist() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) return [];
      final String contents = await file.readAsString();
      final List<dynamic> jsonList = jsonDecode(contents);
      return jsonList.cast<String>();
    } catch (e) {
      return [];
    }
  }
}
