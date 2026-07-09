// ==================== Contact Service ====================
// บริการจัดการรายชื่อผู้ติดต่อ (Contacts) จากเครื่องเด็ก
//
// ดึงรายชื่อผู้ติดต่อจากเครื่องเด็ก แล้ว sync ขึ้น Firestore
// เพื่อให้ผู้ปกครองดูได้ว่าเด็กมีผู้ติดต่อใครบ้าง
//
// โครงสร้าง Firestore: /users/{parentUid}/children/{childId}/contacts/{contactId}
//
// ฟังก์ชันหลัก:
// - requestPermission() → ขอสิทธิ์เข้าถึงรายชื่อผู้ติดต่อ
// - fetchContacts() → ดึงรายชื่อจากเครื่อง
// - syncContacts() → sync ขึ้น Firestore
// - streamContacts() → Stream รายชื่อจาก Firestore (realtime)
//
// ข้อจำกัด:
// - Firestore batch มีลิมิต 500 operations
// - ตอนนี้รองรับ < 400 contacts ต่อ batch (เหลือ buffer)
// - Avatar ปิดไว้ (null) เพราะรูปหนักเกินไป
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/contact_model.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// ขอ permission เข้าถึงรายชื่อผู้ติดต่อ (read-only)
  Future<bool> requestPermission() async {
    return FlutterContacts.requestPermission(readonly: true);
  }

  /// ดึงรายชื่อผู้ติดต่อจากเครื่อง
  /// ต้องได้ permission ก่อน ถ้าไม่ได้จะ return list ว่าง
  /// withProperties: true → ดึงเบอร์โทร, อีเมล ฯลฯ ด้วย
  Future<List<ContactModel>> fetchContacts() async {
    if (await Permission.contacts.request().isGranted) {
      final contacts = await FlutterContacts.getContacts(withProperties: true);
      return contacts.map((c) {
        return ContactModel(
          id: c.id,
          displayName: c.displayName,
          phones: c.phones.map((p) => p.number).toList(),
        );
      }).toList();
    }
    return [];
  }

  /// Sync รายชื่อผู้ติดต่อขึ้น Firestore
  /// ใช้ batch write เพื่อประสิทธิภาพ (ลดจำนวน network call)
  ///
  /// หมายเหตุ:
  /// - ใช้ set() ซึ่งจะ overwrite ข้อมูลเดิม
  /// - ระบบ sync จริงควรทำ diffing (เปรียบเทียบก่อน update)
  /// - Batch มีลิมิต 500 ops → commit เมื่อถึง 400 เพื่อเหลือ buffer
  Future<void> syncContacts(String parentUid, String childId) async {
    try {
      final contacts = await fetchContacts();
      final batch = _firestore.batch();
      final collectionRef = _firestore
          .collection('users')
          .doc(parentUid)
          .collection('children')
          .doc(childId)
          .collection('contacts');

      int count = 0;
      for (final contact in contacts) {
        final docRef = collectionRef.doc(contact.id);
        batch.set(docRef, contact.toMap());
        count++;
        if (count >= 400) {
          // Batch ลิมิต 500 → commit ที่ 400 เพื่อเหลือ buffer
          await batch.commit();
          count = 0;
        }
      }
      await batch.commit();
    } catch (e) {
      // Error syncing contacts - fail silently
    }
  }

  /// Stream รายชื่อผู้ติดต่อจาก Firestore (realtime)
  /// ใช้ในหน้า parent เพื่อดูรายชื่อผู้ติดต่อของเด็ก
  Stream<List<ContactModel>> streamContacts(String parentUid, String childId) {
    return _firestore
        .collection('users')
        .doc(parentUid)
        .collection('children')
        .doc(childId)
        .collection('contacts')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ContactModel.fromMap(doc.data()))
              .toList();
        });
  }
}
