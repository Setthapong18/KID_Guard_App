// ==================== Device Service ====================
// บริการจัดการอุปกรณ์ของเด็ก (โทรศัพท์/แท็บเล็ต)
//
// จัดการการลงทะเบียน, สถานะออนไลน์, และ sync request ของอุปกรณ์
// รองรับเด็ก 1 คนมีหลายอุปกรณ์ (Multi-device support)
//
// โครงสร้าง Firestore: /users/{parentUid}/children/{childId}/devices/{deviceId}
//
// ฟังก์ชันหลัก:
// - getDeviceId() → ดึง unique ID ของอุปกรณ์นี้
// - getDeviceName() → ดึงชื่อรุ่นอุปกรณ์
// - registerDevice() → ลงทะเบียนอุปกรณ์นี้กับโปรไฟล์เด็ก
// - updateDeviceStatus() → อัปเดตสถานะออนไลน์
// - streamDevices() → ดึงรายการอุปกรณ์ทั้งหมด (realtime)
// - requestDeviceSync() → parent สั่ง sync อุปกรณ์เฉพาะ
// - requestAllDevicesSync() → parent สั่ง sync ทุกอุปกรณ์
// - streamSyncRequest() → เด็ก listen ว่า parent สั่ง sync หรือยัง
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/device_model.dart';

class DeviceService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  // Cache device ID และ name เพื่อไม่ต้องเรียก native ทุกครั้ง
  String? _cachedDeviceId;
  String? _cachedDeviceName;

  /// ดึง unique ID ของอุปกรณ์
  /// - Android: ใช้ androidInfo.id (unique ต่อ device + app signing key)
  /// - iOS: ใช้ identifierForVendor
  /// - อื่นๆ: return 'unknown_platform'
  /// ค่าจะถูก cache ไว้ เรียกครั้งเดียวพอ
  Future<String> getDeviceId() async {
    if (_cachedDeviceId != null) return _cachedDeviceId!;

    final prefs = await SharedPreferences.getInstance();
    String? storedId = prefs.getString('kidguard_custom_device_id');

    if (storedId == null) {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        storedId = '${androidInfo.id}_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        storedId = '${iosInfo.identifierForVendor}_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        storedId = 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }
      await prefs.setString('kidguard_custom_device_id', storedId);
    }

    _cachedDeviceId = storedId;
    return storedId;
  }

  /// ดึงชื่อรุ่นอุปกรณ์ (เช่น "Samsung Galaxy A54")
  /// ค่าจะถูก cache ไว้ เรียกครั้งเดียวพอ
  Future<String> getDeviceName() async {
    if (_cachedDeviceName != null) return _cachedDeviceName!;

    if (Platform.isAndroid) {
      final androidInfo = await _deviceInfo.androidInfo;
      _cachedDeviceName = '${androidInfo.brand} ${androidInfo.model}';
    } else if (Platform.isIOS) {
      final iosInfo = await _deviceInfo.iosInfo;
      _cachedDeviceName = iosInfo.utsname.machine;
    } else {
      _cachedDeviceName = 'Unknown Device';
    }

    return _cachedDeviceName!;
  }

  /// ลงทะเบียนอุปกรณ์นี้กับโปรไฟล์เด็ก
  /// เรียกตอนเปิด child mode ครั้งแรก
  /// ใช้ merge: true เพื่อไม่ overwrite ข้อมูลเดิม (เช่น syncRequested)
  Future<void> registerDevice(String parentUid, String childId) async {
    final deviceId = await getDeviceId();
    final deviceName = await getDeviceName();

    await _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .collection('devices')
        .doc(deviceId)
        .set({
          'deviceName': deviceName,
          'lastActive': FieldValue.serverTimestamp(),
          'isOnline': true,
          'syncRequested': false,
        }, SetOptions(merge: true));
  }

  /// อัปเดตสถานะออนไลน์ของอุปกรณ์
  /// เรียกตอนเปิด/ปิด child mode
  Future<void> updateDeviceStatus(
    String parentUid,
    String childId,
    bool isOnline,
  ) async {
    final deviceId = await getDeviceId();

    await _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .collection('devices')
        .doc(deviceId)
        .set({
          'lastActive': FieldValue.serverTimestamp(),
          'isOnline': isOnline,
        }, SetOptions(merge: true));
  }

  /// Stream รายการอุปกรณ์ทั้งหมดของเด็ก (realtime)
  /// ใช้ในหน้า parent เพื่อดูว่าเด็กมีอุปกรณ์อะไรบ้าง, ออนไลน์ตัวไหน
  Stream<List<DeviceModel>> streamDevices(String parentUid, String childId) {
    return _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .collection('devices')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return DeviceModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  /// parent สั่ง sync อุปกรณ์เฉพาะตัว
  /// ตั้ง syncRequested = true → อุปกรณ์เด็กจะ listen แล้ว sync blocklist ใหม่
  Future<void> requestDeviceSync(
    String parentUid,
    String childId,
    String deviceId,
  ) async {
    await _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .collection('devices')
        .doc(deviceId)
        .set({'syncRequested': true}, SetOptions(merge: true));
  }

  /// parent สั่ง sync ทุกอุปกรณ์ของเด็ก
  /// ใช้ batch write เพื่อ update ทุกอุปกรณ์ในครั้งเดียว
  Future<void> requestAllDevicesSync(String parentUid, String childId) async {
    final devicesSnapshot = await _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .collection('devices')
        .get();

    final batch = _firestore.batch();
    for (final doc in devicesSnapshot.docs) {
      batch.update(doc.reference, {'syncRequested': true});
    }
    await batch.commit();
  }

  /// เคลียร์ sync request หลังจากอุปกรณ์เด็ก sync เสร็จแล้ว
  Future<void> clearSyncRequest(String parentUid, String childId) async {
    final deviceId = await getDeviceId();

    await _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .collection('devices')
        .doc(deviceId)
        .set({'syncRequested': false}, SetOptions(merge: true));
  }

  /// Stream sync request สำหรับอุปกรณ์นี้ (realtime)
  /// เด็ก listen เพื่อรู้ว่า parent สั่ง sync หรือยัง
  /// ถ้า syncRequested = true → sync blocklist แล้วเคลียร์ request
  Stream<bool> streamSyncRequest(String parentUid, String childId) async* {
    final deviceId = await getDeviceId();

    yield* _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .collection('devices')
        .doc(deviceId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists) {
            return snapshot.data()?['syncRequested'] ?? false;
          }
          return false;
        });
  }
}
