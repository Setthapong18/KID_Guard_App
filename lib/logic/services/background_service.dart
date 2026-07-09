// ==================== Background Service ====================
// เครื่องยนต์หลักของการ Monitor (หัวใจของแอพ!)
//
// ทำงานตอนเปิด Child Mode → วน loop ทุก 1 วินาทีเพื่อเช็ค:
// 1. แอพที่เปิดอยู่ → ถูกบล็อกหรือไม่?
// 2. เวลาหน้าจอ → เกิน time limit หรือยัง?
// 3. ตาราง → อยู่ในเวลานอน/เวลาพักหรือไม่?
// 4. Instant Pause → parent สั่ง pause ชั่วคราวหรือไม่?
//
// Flow หลัก (ทุก 1 วินาที):
// 1. _checkForegroundApp() → เช็ค schedule, time limit, blocked apps
// 2. _updateScreenTime() → นับเวลาใช้งาน + อัปเดต Firestore (ทุก 10 วินาที)
//
// ระบบ Realtime Listener (Snapshot):
// - _listenToBlocklist() → ฟัง blocklist จาก Firestore (เปลี่ยนแปลงทันที)
// - _listenToChildSettings() → ฟังค่า time limit, schedule, lock, unlock
//
// เหตุผลที่ล็อกเครื่อง (lockReason):
// - 'blocked_app': เด็กเปิดแอพที่ถูกบล็อก
// - 'time_limit': หมดเวลาใช้งาน
// - 'sleep': อยู่ในเวลานอน
// - 'quiet': อยู่ในเวลาพัก
// - 'pause': parent สั่ง pause ชั่วคราว
//
// ข้อควรระวัง (สำคัญ!):
// - _currentLimitUsedTime โหลดจาก Firestore แค่ครั้งแรก
//   หลังจากนั้นนับเอง (local counter) เพื่อป้องกัน Firestore ล่าช้า
// - screenTime (สถิติรวม) ใช้ FieldValue.increment → ไม่มีทาง diverge
// - limitUsedTime (เทียบ limit) ใช้ค่า absolute → ป้องกัน race condition
// - _isInRestrictedTime ใช้กับ schedule (sleep/quiet/pause) เท่านั้น
//   ห้ามใช้กับ time_limit! (เคย bug: ทำให้ unlock-lock loop)
import 'dart:async';
import 'package:usage_stats/usage_stats.dart' hide NetworkType;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/local/blocklist_storage.dart';
import 'package:workmanager/workmanager.dart';
import 'package:device_apps/device_apps.dart';
import '../../data/services/secure_storage_service.dart';

class BackgroundService {
  Timer? _monitorTimer; // Timer ที่ทำงานทุก 1 วินาที
  bool _isMonitoring = false; // กำลัง monitor อยู่หรือไม่
  String? _currentChildId; // ID ของเด็กที่กำลัง monitor
  String? _currentParentId; // ID ของ parent (เพื่อ reference Firestore)
  int _sessionSeconds =
      0; // จำนวนวินาที session นี้ (ใช้นับทุก 10 วินาทีก่อน sync)
  bool _initialLimitLoaded =
      false; // โหลด limitUsedTime จาก Firestore แล้วหรือยัง

  // ==================== Blocklist ====================
  Set<String> _blockedPackages = {}; // รายการ package name ที่ถูกบล็อก
  StreamSubscription? _blocklistSubscription; // Subscription สำหรับ cancel

  // ==================== App Usage Tracking ====================
  final Map<String, int> _appUsageSession =
      {}; // Package → วินาทีที่ใช้ (buffer ก่อน sync)
  final Map<String, String> _appNames = {}; // Cache: Package → ชื่อแอพ

  // ==================== Time Limit ====================
  int _dailyTimeLimit = 0; // จำกัดเวลารายวัน (วินาที), 0 = ไม่จำกัด
  int _currentLimitUsedTime =
      0; // เวลาที่ใช้ไปเทียบ limit (Local counter, นับเอง!)
  DateTime?
  _timeLimitDisabledUntil; // Parent ปิด time limit ชั่วคราวจนถึงเวลานี้
  StreamSubscription?
  _childSubscription; // Subscription สำหรับ listen child settings

  String?
  _lastBlockedPackage; // Package ล่าสุดที่ detect ว่าถูกบล็อก (ป้องกัน notify ซ้ำ)

  // ==================== Sleep Schedule ====================
  bool _sleepScheduleEnabled = false;
  int _bedtimeHour = 20; // ชั่วโมงเข้านอน (default 20:00)
  int _bedtimeMinute = 0;
  int _wakeHour = 7; // ชั่วโมงตื่น (default 07:00)
  int _wakeMinute = 0;

  // ==================== Quiet Times ====================
  List<Map<String, dynamic>> _quietTimes = []; // รายการเวลาพัก (หลายช่วง)

  // ==================== State Flags ====================
  bool _isInRestrictedTime =
      false; // อยู่ในช่วง schedule/pause (ใช้กับ sleep/quiet/pause เท่านั้น!)

  // ==================== Instant Pause / Lock ====================
  bool _isDeviceLocked = false; // เครื่องถูกล็อกอยู่หรือไม่
  DateTime? _pauseUntil; // Pause จนถึงเวลานี้ (null = ไม่ได้ pause)

  // ==================== Callbacks ====================
  /// เรียกเมื่อ detect แอพที่ถูกบล็อก หรือ Schedule เริ่ม
  final Function(String) onBlockedAppDetected;

  /// เรียกเมื่อหมดเวลาใช้งาน (time limit reached)
  final Function() onTimeLimitReached;

  /// เรียกเมื่อเด็กปิดแอพที่ถูกบล็อก หรือ parent unlock
  final Function() onAppAllowed;

  BackgroundService({
    required this.onBlockedAppDetected,
    required this.onTimeLimitReached,
    required this.onAppAllowed,
  });

  /// เริ่ม Monitor - ทำงานทุก 1 วินาที
  ///
  /// ขั้นตอน:
  /// 1. บันทึก IDs ลง SharedPreferences (สำหรับ WorkManager)
  /// 2. ลงทะเบียน WorkManager periodic task (sync blocklist ทุก 15 นาที)
  /// 3. เช็คสิทธิ์ UsageStats (จำเป็นสำหรับดูแอพที่เปิดอยู่)
  /// 4. เริ่ม listen blocklist + child settings จาก Firestore
  /// 5. ตั้ง online status + session start time
  /// 6. เริ่ม Timer ทุก 1 วินาที → _checkForegroundApp() + _updateScreenTime()
  Future<void> startMonitoring(String childId, String parentId) async {
    // ถ้า monitor เด็กคนเดิมอยู่แล้ว → ข้าม
    if (_isMonitoring &&
        _currentChildId == childId &&
        _currentParentId == parentId) {
      return;
    }

    // ถ้า monitor เด็กคนอื่นอยู่ → หยุดก่อนแล้วเริ่มใหม่
    if (_isMonitoring) {
      await stopMonitoring();
    }

    _currentChildId = childId;
    _currentParentId = parentId;

    // บันทึก IDs สำหรับ WorkManager (background isolate ใช้)
    // ใช้ SecureStorageService แทน SharedPreferences เพราะข้อมูลนี้เป็น sensitive data
    await SecureStorageService.saveBackgroundSession(
      childId: childId,
      parentUid: parentId,
    );

    // ลงทะเบียน Periodic Task → sync blocklist ทุก 15 นาที
    Workmanager().registerPeriodicTask(
      'sync_blocklist',
      'syncBlocklistTask',
      frequency: const Duration(minutes: 15),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.replace,
    );

    // เช็คสิทธิ์ UsageStats (Android) - จำเป็นเพื่อรู้ว่าแอพไหนเปิดอยู่
    final bool? isPermissionGranted = await UsageStats.checkUsagePermission();
    if (isPermissionGranted != true) {
      await UsageStats.grantUsagePermission();
      return;
    }

    _isMonitoring = true;

    // เริ่ม listen ข้อมูลจาก Firestore (realtime)
    _listenToBlocklist(); // รายการแอพที่ถูกบล็อก
    _listenToChildSettings(); // ค่า time limit, schedule, lock, unlock

    // ตั้งสถานะ online + บันทึกเวลาเริ่ม session
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentParentId)
          .collection('children')
          .doc(_currentChildId)
          .update({
            'isOnline': true,
            'sessionStartTime': FieldValue.serverTimestamp(),
            'lastActive': FieldValue.serverTimestamp(),
          });
    } catch (e) {
      // Error setting online status
    }

    // เริ่ม Timer ทุก 1 วินาที
    _monitorTimer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      await _checkForegroundApp(); // เช็คแอพ foreground
      _updateScreenTime(); // นับเวลาใช้งาน
    });
  }

  /// หยุด Monitor
  /// เรียกตอนปิด child mode หรือออกจากแอพ
  Future<void> stopMonitoring() async {
    // ตั้งสถานะ offline ก่อนหยุด
    if (_currentChildId != null && _currentParentId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_currentParentId)
            .collection('children')
            .doc(_currentChildId)
            .update({
              'isOnline': false,
              'sessionStartTime': null,
              'lastActive': FieldValue.serverTimestamp(),
            });
      } catch (e) {
        // Error setting offline status
      }
    }

    // เคลียร์ทุกอย่าง
    _monitorTimer?.cancel();
    _blocklistSubscription?.cancel();
    _childSubscription?.cancel();
    _isMonitoring = false;
    _sessionSeconds = 0;
    _initialLimitLoaded = false;
    _blockedPackages.clear();
    _lastBlockedPackage = null;
    _isInRestrictedTime = false;
  }

  /// Listen blocklist จาก Firestore (realtime)
  /// เมื่อ parent บล็อก/ปลดล็อกแอพ จะอัปเดตทันที
  /// พร้อมบันทึกลงไฟล์ JSON สำหรับ Native Service
  void _listenToBlocklist() {
    if (_currentChildId == null || _currentParentId == null) return;

    _blocklistSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentParentId)
        .collection('children')
        .doc(_currentChildId)
        .collection('apps')
        .where('isLocked', isEqualTo: true)
        .snapshots()
        .listen(
          (snapshot) {
            _blockedPackages = snapshot.docs
                .map((doc) => doc['packageName'] as String)
                .toSet();
            // บันทึกลงไฟล์ JSON สำหรับ Native Accessibility Service ใช้
            BlocklistStorage().saveBlocklist(_blockedPackages.toList());
          },
          onError: (e) {
            // Error listening to blocklist
          },
        );
  }

  /// Listen ค่าตั้งของเด็กจาก Firestore (realtime)
  /// รวม: time limit, sleep schedule, quiet times, lock/unlock, pause
  ///
  /// สิ่งที่ listen:
  /// - dailyTimeLimit: จำกัดเวลาต่อวัน
  /// - limitUsedTime: เวลาที่ใช้ไปแล้ว (โหลดแค่ครั้งแรก!)
  /// - timeLimitDisabledUntil: parent ปิด time limit ชั่วคราว
  /// - sleepSchedule: เวลานอน
  /// - quietTimes: เวลาพัก
  /// - isLocked: สถานะล็อก
  /// - pauseUntil: Pause ชั่วคราวจนถึงเวลานี้
  /// - unlockRequested: parent สั่ง unlock ระยะไกล
  void _listenToChildSettings() {
    if (_currentChildId == null || _currentParentId == null) return;

    _childSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(_currentParentId)
        .collection('children')
        .doc(_currentChildId)
        .snapshots()
        .listen(
          (snapshot) {
            if (snapshot.exists) {
              final data = snapshot.data();
              if (data != null) {
                // ---------- Time Limit ----------
                final newDailyLimit = data['dailyTimeLimit'] ?? 0;
                // ตรวจจับ parent เคลียร์ time limit (เปลี่ยนจากมีค่า → 0)
                if (_initialLimitLoaded &&
                    newDailyLimit == 0 &&
                    _dailyTimeLimit > 0) {
                  _currentLimitUsedTime = 0;
                }
                _dailyTimeLimit = newDailyLimit;

                // สำคัญ! โหลด limitUsedTime จาก Firestore แค่ครั้งแรก
                // หลังจากนั้น local counter เป็น "ผู้นำ" (SOLE authority)
                // เพื่อป้องกัน Firestore ล่าช้าทำให้นับผิด
                if (!_initialLimitLoaded) {
                  _currentLimitUsedTime =
                      data['limitUsedTime'] ?? data['screenTime'] ?? 0;
                  _initialLimitLoaded = true;
                }

                // ---------- Time Limit Disabled Until (parent unlock ชั่วคราว) ----------
                if (data['timeLimitDisabledUntil'] != null) {
                  _timeLimitDisabledUntil =
                      (data['timeLimitDisabledUntil'] as Timestamp).toDate();
                } else {
                  _timeLimitDisabledUntil = null;
                }

                // ---------- Sleep Schedule ----------
                if (data['sleepSchedule'] != null) {
                  final sleep = data['sleepSchedule'] as Map<String, dynamic>;
                  _sleepScheduleEnabled = sleep['enabled'] ?? false;
                  _bedtimeHour = sleep['bedtimeHour'] ?? 20;
                  _bedtimeMinute = sleep['bedtimeMinute'] ?? 0;
                  _wakeHour = sleep['wakeHour'] ?? 7;
                  _wakeMinute = sleep['wakeMinute'] ?? 0;
                }

                // ---------- Quiet Times ----------
                if (data['quietTimes'] != null) {
                  _quietTimes = List<Map<String, dynamic>>.from(
                    (data['quietTimes'] as List).map(
                      (item) => Map<String, dynamic>.from(item),
                    ),
                  );
                } else {
                  _quietTimes = [];
                }

                // ---------- Global Lock & Pause ----------
                _isDeviceLocked = data['isLocked'] ?? false;
                if (data['pauseUntil'] != null) {
                  _pauseUntil = DateTime.parse(data['pauseUntil']);
                } else {
                  _pauseUntil = null;
                }

                // เช็ค auto-unlock (pause หมดเวลา)
                if (_pauseUntil != null &&
                    DateTime.now().isAfter(_pauseUntil!)) {
                  _unlockDevice();
                }

                // ---------- Handle Parent Unlock Request ----------
                final unlockRequested = data['unlockRequested'] ?? false;
                if (unlockRequested && !_isDeviceLocked) {
                  // Parent สั่ง unlock สำเร็จ → ซ่อน overlay
                  onAppAllowed();
                  _isInRestrictedTime = false;

                  // เคลียร์ flag ใน Firestore
                  FirebaseFirestore.instance
                      .collection('users')
                      .doc(_currentParentId)
                      .collection('children')
                      .doc(_currentChildId)
                      .update({'unlockRequested': false});
                }
              }
            }
          },
          onError: (e) {
            // Error listening to child settings
          },
        );
  }

  /// อัปเดตสถานะ isLocked ใน Firestore
  /// เพื่อให้ parent เห็นว่าเครื่องถูกล็อก + แสดงปุ่ม unlock
  Future<void> _setLockedInFirestore(bool isLocked, String reason) async {
    if (_currentChildId == null || _currentParentId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentParentId)
          .collection('children')
          .doc(_currentChildId)
          .update({
            'isLocked': isLocked,
            'lockReason': reason,
            'lockedAt': isLocked ? FieldValue.serverTimestamp() : null,
          });
    } catch (e) {
      // Error updating isLocked in Firestore
    }
  }

  /// เช็คว่าตอนนี้อยู่ในเวลานอนหรือไม่
  /// รองรับ overnight (เช่น 21:00 - 06:00 ข้ามวัน)
  bool _isInSleepTime() {
    if (!_sleepScheduleEnabled) return false;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;
    final bedtimeMinutes = _bedtimeHour * 60 + _bedtimeMinute;
    final wakeMinutes = _wakeHour * 60 + _wakeMinute;

    // กรณีข้ามวัน (เช่น 21:00 - 06:00)
    if (bedtimeMinutes > wakeMinutes) {
      return currentMinutes >= bedtimeMinutes || currentMinutes < wakeMinutes;
    } else {
      // กรณีวันเดียวกัน (เช่น 13:00 - 15:00)
      return currentMinutes >= bedtimeMinutes && currentMinutes < wakeMinutes;
    }
  }

  /// เช็คว่าตอนนี้อยู่ในเวลาพัก (quiet time) หรือไม่
  /// เช็คทุก quiet time ที่เปิดใช้งาน
  bool _isInQuietTime() {
    if (_quietTimes.isEmpty) return false;

    final now = DateTime.now();
    final currentMinutes = now.hour * 60 + now.minute;

    for (final period in _quietTimes) {
      final enabled = period['enabled'] ?? false;
      if (!enabled) continue;

      final startMinutes =
          (period['startHour'] ?? 0) * 60 + (period['startMinute'] ?? 0);
      final endMinutes =
          (period['endHour'] ?? 0) * 60 + (period['endMinute'] ?? 0);

      if (startMinutes <= endMinutes) {
        // ช่วงเวลาปกติ (ไม่ข้ามวัน)
        if (currentMinutes >= startMinutes && currentMinutes < endMinutes) {
          return true;
        }
      } else {
        // ช่วงเวลาข้ามวัน (กรณีหายาก)
        if (currentMinutes >= startMinutes || currentMinutes < endMinutes) {
          return true;
        }
      }
    }
    return false;
  }

  /// ดึงเหตุผลที่ lock เป็นข้อความภาษาไทย
  String _getRestrictionReason() {
    if (_isInSleepTime()) {
      return 'เวลานอน 🌙';
    }
    if (_isInQuietTime()) {
      return 'เวลาพักผ่อน 🔕';
    }
    if (_dailyTimeLimit > 0 && _currentLimitUsedTime >= _dailyTimeLimit) {
      return 'หมดเวลาใช้งาน ⏰';
    }
    return '';
  }

  /// เช็คแอพ Foreground (ทำงานทุก 1 วินาที)
  ///
  /// ลำดับการเช็ค:
  /// 1. Schedule restrictions (sleep/quiet) + Instant Pause
  /// 2. Time limit
  /// 3. Blocked apps
  ///
  /// เมื่อ detect ว่าต้องล็อก จะ:
  /// - ตั้ง isLocked ใน Firestore (parent เห็น)
  /// - เรียก callback → แสดง lock screen
  Future<void> _checkForegroundApp() async {
    try {
      // ==================== 1. เช็ค Schedule Restrictions ====================
      final inSleep = _isInSleepTime();
      final inQuiet = _isInQuietTime();
      final isRestricted = inSleep || inQuiet;

      // เช็ค Instant Pause (parent สั่ง pause ชั่วคราว)
      final isActivePause =
          _isDeviceLocked &&
          _pauseUntil != null &&
          DateTime.now().isBefore(_pauseUntil!);

      if (isRestricted || isActivePause) {
        if (!_isInRestrictedTime) {
          // เพิ่งเข้าช่วง restricted → ล็อกเครื่อง
          _isInRestrictedTime = true;

          String reason;
          String message;
          if (isRestricted) {
            reason = inSleep ? 'sleep' : 'quiet';
            message = _getRestrictionReason();
          } else {
            reason = 'pause';
            message = 'อุปกรณ์ถูกระงับชั่วคราว 🔒';
          }
          _setLockedInFirestore(true, reason);
          onBlockedAppDetected(message);
        }
        return; // ไม่ต้องเช็คอย่างอื่น - เครื่องต้องถูกล็อก
      } else {
        if (_isInRestrictedTime) {
          // เพิ่งออกจากช่วง restricted → ปลดล็อก
          _isInRestrictedTime = false;
          if (_pauseUntil != null) {
            _unlockDevice(); // Pause หมดเวลา → unlock
          } else {
            _setLockedInFirestore(false, ''); // Schedule จบ → unlock
            onAppAllowed();
          }
        }
      }

      // ==================== 2. เช็ค Time Limit ====================
      final isTimeLimitDisabled =
          _timeLimitDisabledUntil != null &&
          DateTime.now().isBefore(_timeLimitDisabledUntil!);

      if (!isTimeLimitDisabled &&
          !_isDeviceLocked &&
          _dailyTimeLimit > 0 &&
          _currentLimitUsedTime >= _dailyTimeLimit) {
        // หมดเวลา! ล็อกเครื่อง
        // หมายเหตุสำคัญ: ตั้ง _isDeviceLocked ทันทีเพื่อป้องกัน trigger ซ้ำ
        // ห้ามตั้ง _isInRestrictedTime! (จะทำให้ schedule-exit logic unlock ผิดจังหวะ)
        _isDeviceLocked = true;
        _setLockedInFirestore(true, 'time_limit');
        onTimeLimitReached();
        return;
      }

      // ==================== 3. เช็ค Blocked Apps ====================
      final DateTime endDate = DateTime.now();
      final DateTime startDate = endDate.subtract(const Duration(seconds: 2));

      // ดึงข้อมูล Usage Stats (แอพที่ใช้ล่าสุด)
      final List<UsageInfo> usageStats = await UsageStats.queryUsageStats(
        startDate,
        endDate,
      );

      // เรียงจากใหม่ที่สุด → แอพแรกคือแอพ foreground ปัจจุบัน
      usageStats.sort(
        (a, b) =>
            int.parse(b.lastTimeUsed!).compareTo(int.parse(a.lastTimeUsed!)),
      );

      if (usageStats.isNotEmpty) {
        final String currentPackage = usageStats.first.packageName!;

        // Track การใช้แอพ (เก็บเป็น buffer แล้ว sync ทุก 10 วินาที)
        _appUsageSession[currentPackage] =
            (_appUsageSession[currentPackage] ?? 0) + 1;

        // Cache ชื่อแอพ (ดึงจาก DeviceApps ครั้งแรกแล้ว cache)
        if (!_appNames.containsKey(currentPackage)) {
          _appNames[currentPackage] = currentPackage; // Fallback
          DeviceApps.getApp(currentPackage)
              .then((app) {
                if (app != null) {
                  _appNames[currentPackage] = app.appName;
                }
              })
              .catchError((_) {});
        }

        // เช็คว่าแอพ foreground ถูกบล็อกหรือไม่
        if (_isBlocked(currentPackage)) {
          if (_lastBlockedPackage != currentPackage) {
            onBlockedAppDetected(currentPackage);
            _lastBlockedPackage = currentPackage;
          }
        } else {
          if (_lastBlockedPackage != null) {
            // เด็กออกจากแอพที่ถูกบล็อกแล้ว → ซ่อน overlay
            onAppAllowed();
            _lastBlockedPackage = null;
          }
        }
      }
    } catch (e) {
      // Error checking usage stats
    }
  }

  /// อัปเดตเวลาหน้าจอ (ทำงานทุก 1 วินาที)
  ///
  /// - ไม่นับเวลาตอนอยู่ใน restricted period หรือ device locked
  /// - อัปเดต Firestore ทุก 10 วินาที (ลด write cost)
  /// - screenTime ใช้ increment (สำหรับสถิติ, ไม่ reset)
  /// - limitUsedTime ใช้ค่า absolute (ป้องกัน diverge)
  /// - บันทึก daily_stats สำหรับกราฟรายวัน
  Future<void> _updateScreenTime() async {
    // ไม่นับเวลาตอนล็อกหรืออยู่ใน schedule
    if (_isInRestrictedTime || _isDeviceLocked) return;

    if (_currentChildId == null || _currentParentId == null) return;

    _sessionSeconds++;
    _currentLimitUsedTime++;

    // อัปเดต Firestore ทุก 10 วินาที (ลด write cost)
    if (_sessionSeconds % 10 == 0) {
      try {
        final docRef = FirebaseFirestore.instance
            .collection('users')
            .doc(_currentParentId)
            .collection('children')
            .doc(_currentChildId);

        // 1. อัปเดตข้อมูล realtime (parent เห็นทันที)
        await docRef.update({
          'screenTime': FieldValue.increment(
            10,
          ), // สถิติรวม (increment ไม่มีปัญหา)
          'limitUsedTime':
              _currentLimitUsedTime, // ค่า absolute (ป้องกัน race condition)
          'lastActive': FieldValue.serverTimestamp(),
        });

        // 2. อัปเดตสถิติรายวัน (สำหรับกราฟ + ranking แอพ)
        final dateStr = DateTime.now().toIso8601String().split(
          'T',
        )[0]; // YYYY-MM-DD

        // สร้าง Map ข้อมูลแอพที่ใช้ (เก็บแยกตามแอพ)
        final Map<String, dynamic> appUpdates = {};
        _appUsageSession.forEach((pkg, seconds) {
          if (seconds > 0) {
            // แปลง package name ให้ปลอดภัย (Firestore ไม่รับ . ใน key)
            final safeKey = pkg.replaceAll('.', '_');
            final appName = _appNames[pkg] ?? pkg;
            appUpdates['apps.$safeKey.duration'] = FieldValue.increment(
              seconds,
            );
            appUpdates['apps.$safeKey.name'] = appName;
            appUpdates['apps.$safeKey.packageName'] = pkg;
          }
        });

        appUpdates['screenTime'] = FieldValue.increment(10);
        appUpdates['timestamp'] = FieldValue.serverTimestamp();

        // ใช้ set + merge เพื่อสร้าง document ถ้ายังไม่มี
        await docRef
            .collection('daily_stats')
            .doc(dateStr)
            .set(appUpdates, SetOptions(merge: true));

        // เคลียร์ buffer
        _appUsageSession.clear();
      } catch (e) {
        // Error updating screen time
      }
    }
  }

  /// เช็คว่า package นี้ถูกบล็อกหรือไม่
  bool _isBlocked(String packageName) {
    return _blockedPackages.contains(packageName);
  }

  /// ดึงสถานะ schedule ปัจจุบัน (สำหรับ debug/UI)
  Map<String, dynamic> getScheduleStatus() {
    return {
      'sleepEnabled': _sleepScheduleEnabled,
      'bedtime': '$_bedtimeHour:$_bedtimeMinute',
      'wakeTime': '$_wakeHour:$_wakeMinute',
      'isInSleepTime': _isInSleepTime(),
      'quietTimesCount': _quietTimes.length,
      'isInQuietTime': _isInQuietTime(),
      'isRestricted': _isInRestrictedTime,
      'restrictionReason': _getRestrictionReason(),
    };
  }

  /// ปลดล็อกเครื่อง + เคลียร์ค่า pause ทั้ง Firestore และ local
  Future<void> _unlockDevice() async {
    if (_currentChildId == null || _currentParentId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentParentId)
          .collection('children')
          .doc(_currentChildId)
          .update({'isLocked': false, 'pauseUntil': null, 'lockReason': ''});
      // Reset local flags ทันที
      _isDeviceLocked = false;
      _pauseUntil = null;
      _isInRestrictedTime = false;
      onAppAllowed();
    } catch (e) {
      // Error unlocking device
    }
  }
}
