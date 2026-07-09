// ==================== Location Service ====================
// บริการติดตามตำแหน่งเด็ก (GPS Tracking)
//
// ใช้ Geolocator plugin ติดตามตำแหน่งเด็กแบบ realtime
// อัปเดตทุกครั้งที่เครื่องเคลื่อนที่ > 50 เมตร (ประหยัดแบตเตอรี่)
//
// โครงสร้าง Firestore:
// /users/{parentUid}/children/{childId} → currentLocation field
//   - latitude: ละติจูด
//   - longitude: ลองจิจูด
//   - timestamp: เวลาที่อัปเดต
//   - speed: ความเร็ว (m/s)
//   - accuracy: ความแม่นยำ (เมตร)
//
// ฟังก์ชันหลัก:
// - startTracking() → เริ่ม track (เรียกตอนเปิด child mode)
// - stopTracking() → หยุด track (เรียกตอนปิด child mode)
// - getCurrentLocation() → ดึงตำแหน่งปัจจุบัน (ครั้งเดียว)
//
// สิทธิ์ที่ต้องการ:
// - Android: ACCESS_FINE_LOCATION
// - iOS: NSLocationWhenInUseUsageDescription
import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<Position>?
  _positionStreamSubscription; // subscription สำหรับ cancel

  /// เริ่มติดตามตำแหน่งแบบ realtime
  /// อัปเดตเมื่อเคลื่อนที่ > 50 เมตร (distanceFilter)
  ///
  /// ขั้นตอน:
  /// 1. เช็คว่า GPS เปิดอยู่หรือไม่
  /// 2. เช็คสิทธิ์ location (ขอถ้ายังไม่ได้)
  /// 3. เริ่ม listen position stream → อัปเดต Firestore
  Future<void> startTracking(String parentUid, String childId) async {
    bool serviceEnabled;
    LocationPermission permission;

    // 1. เช็คว่า GPS service เปิดอยู่หรือไม่
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // GPS ปิด → ไม่สามารถ track ได้
      return;
    }

    // 2. เช็คสิทธิ์ location
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // ยังไม่ได้สิทธิ์ → ขอ
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // ผู้ใช้ปฏิเสธ → ไม่สามารถ track ได้
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // ผู้ใช้ปฏิเสธถาวร → ต้องไปเปิดในตั้งค่าเอง
      return;
    }

    // 3. เริ่ม track - อัปเดตทุก 50 เมตร เพื่อประหยัดแบตเตอรี่
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 50, // อัปเดตเมื่อเคลื่อนที่ 50 เมตร
    );

    _positionStreamSubscription =
        Geolocator.getPositionStream(locationSettings: locationSettings).listen(
          (position) {
            _uploadLocation(parentUid, childId, position);
          },
        );
  }

  /// หยุดติดตามตำแหน่ง
  /// เรียกตอนปิด child mode หรือปิดแอพ
  void stopTracking() {
    _positionStreamSubscription?.cancel();
    _positionStreamSubscription = null;
  }

  /// อัปเดตตำแหน่งปัจจุบันลง Firestore
  /// เก็บไว้ใน currentLocation field ของ child document
  Future<void> _uploadLocation(
    String parentUid,
    String childId,
    Position position,
  ) async {
    try {
      await _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .update({
            'currentLocation': {
              'latitude': position.latitude,
              'longitude': position.longitude,
              'timestamp': FieldValue.serverTimestamp(),
              'speed': position.speed,
              'accuracy': position.accuracy,
            },
          });
    } catch (e) {
      // Error uploading location - fail silently
    }
  }

  /// ดึงตำแหน่งปัจจุบันครั้งเดียว (ไม่ต้อง stream)
  /// ใช้เมื่อต้องการดึงตำแหน่งตอนนี้โดยไม่ต้อง track ต่อเนื่อง
  Future<Position?> getCurrentLocation() async {
    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      return null;
    }
  }
}
