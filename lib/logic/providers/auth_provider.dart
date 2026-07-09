import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import '../../core/utils/security_logger.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/crashlytics_service.dart';
import '../../data/models/user_model.dart';
import '../../data/models/child_model.dart';
import '../../data/services/notification_service.dart';
import '../../data/models/notification_model.dart';
import '../../data/services/device_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _userModel;
  bool _isLoading = false;
  String? _errorMessage;
  bool _needsEmailVerification = false;

  UserModel? get userModel => _userModel;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get needsEmailVerification => _needsEmailVerification;

  // Initialize auth state
  List<ChildModel> _children = [];
  ChildModel? _currentChild;
  StreamSubscription<User?>? _authStateSubscription;
  StreamSubscription<DocumentSnapshot>? _currentChildSubscription;

  bool _isChildMode = false;

  // ==================== PIN Rate Limiting ====================
  /// ป้องกันการเดา PIN (brute-force)
  /// ลองผิดได้ 5 ครั้ง → ล็อก 15 นาที
  static const int _maxPinAttempts = 5;
  static const Duration _lockoutDuration = Duration(minutes: 15);

  // ==================== Session Expiry ====================
  /// Child session หมดอายุหลัง 24 ชม. ป้องกัน session ค้าง
  static const Duration _sessionDuration = Duration(hours: 24);
  int _pinAttempts = 0;
  DateTime? _pinLockoutUntil;

  /// จำนวนครั้งที่ลองผิด (สำหรับ UI แสดง)
  int get pinAttempts => _pinAttempts;

  /// เวลาที่จะหมดล็อก (null = ไม่ได้ล็อก)
  DateTime? get pinLockoutUntil => _pinLockoutUntil;

  /// ตรวจว่าถูกล็อกอยู่หรือไม่
  bool get isPinLockedOut =>
      _pinLockoutUntil != null && DateTime.now().isBefore(_pinLockoutUntil!);

  /// จำนวนนาทีที่เหลือก่อนปลดล็อก
  int get pinLockoutMinutesRemaining {
    if (_pinLockoutUntil == null) return 0;
    final remaining = _pinLockoutUntil!.difference(DateTime.now()).inMinutes;
    return remaining > 0 ? remaining + 1 : 0; // +1 เพื่อไม่แสดง 0 นาที
  }

  List<ChildModel> get children => _children;
  ChildModel? get currentChild => _currentChild;
  bool get isChildMode => _isChildMode;

  Future<void> init() async {
    // Cancel existing subscription if init is called again
    await _authStateSubscription?.cancel();

    _authStateSubscription = _authService.authStateChanges.listen((
      user,
    ) async {
      // ข้าม listener ตอนอยู่ใน child mode (anonymous auth)
      if (_isChildMode) return;

      if (user != null && !user.isAnonymous) {
        _userModel = await _authService.getUserData(user.uid);
        if (_userModel != null) {
          await fetchChildren();
          // แจ้ง Crashlytics ว่า user คนไหน login อยู่
          // ช่วยระบุ user ใน crash reports ได้ทันที
          await CrashlyticsService.setUserId(user.uid);
        }
      } else if (user == null) {
        _userModel = null;
        _children = [];
        // ล้าง user context ใน Crashlytics เมื่อ logout
        await CrashlyticsService.clearUserId();
      }
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _authStateSubscription?.cancel();
    _currentChildSubscription?.cancel();
    super.dispose();
  }

  Future<void> fetchChildren() async {
    if (_userModel != null) {
      _children = await _authService.getChildren(_userModel!.uid);
      notifyListeners();
    }
  }

  Future<bool> registerChild(String name, int age, String avatar) async {
    if (_userModel == null) return false;
    try {
      _isLoading = true;
      notifyListeners();
      final child = await _authService.registerChild(
        _userModel!.uid,
        name,
        age,
        avatar,
      );
      if (child != null) {
        _children.add(child);
        _currentChild = child;
        return true;
      }
      return false;
    } catch (e) {
      // Error registering child
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _needsEmailVerification = false;
      notifyListeners();
      _userModel = await _authService.signIn(email, password);

      // ==================== Email Verification Check ====================
      // ถ้าอีเมลยังไม่ verified → บล็อกไม่ให้เข้าใช้
      final firebaseUser = FirebaseAuth.instance.currentUser;
      if (firebaseUser != null && !firebaseUser.emailVerified) {
        _needsEmailVerification = true;
        _userModel = null;
        _errorMessage = 'กรุณายืนยันอีเมลก่อนเข้าใช้งาน (เช็ค Inbox หรือ Spam)';
        await FirebaseAuth.instance.signOut();
        return false;
      }

      if (_userModel != null) {
        await fetchChildren();
      }
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String email, String password, String name) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      _needsEmailVerification = false;
      notifyListeners();
      _userModel = await _authService.register(email, password, name);

      // ==================== Force Email Verification ====================
      // สมัครเสร็จ → sign out ทันที → ต้อง verify email ก่อนใช้
      _needsEmailVerification = true;
      _userModel = null;
      await FirebaseAuth.instance.signOut();
      _errorMessage =
          'สมัครสำเร็จ! กรุณาเช็คอีเมลเพื่อยืนยันตัวตนก่อนเข้าสู่ระบบ';
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapAuthError(e.code);
      return false;
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== Resend Verification Email ====================
  /// ส่ง verification email ซ้ำ (ต้อง sign in ชั่วคราวเพื่อส่ง)
  Future<bool> resendVerificationEmail(String email, String password) async {
    try {
      _isLoading = true;
      notifyListeners();
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && !user.emailVerified) {
        await user.sendEmailVerification();
        await FirebaseAuth.instance.signOut();
        _errorMessage = 'ส่งอีเมลยืนยันอีกครั้งแล้ว กรุณาเช็ค Inbox หรือ Spam';
        return true;
      }
      await FirebaseAuth.instance.signOut();
      return false;
    } catch (_) {
      _errorMessage = 'ไม่สามารถส่งอีเมลยืนยันได้ กรุณาลองใหม่';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signInWithGoogle() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();
      _userModel = await _authService.signInWithGoogle();
      if (_userModel != null) {
        await fetchChildren();
      }
      return _userModel != null;
    } catch (e) {
      _errorMessage = 'เข้าสู่ระบบด้วย Google ไม่สำเร็จ กรุณาลองใหม่';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    _userModel = null;
    notifyListeners();
  }

  Future<String?> generatePin() async {
    if (_userModel == null) return null;
    try {
      _isLoading = true;
      notifyListeners();
      final pin = await _authService.generatePin(_userModel!.uid);
      if (pin != null) {
        // Update local user model with new PIN
        _userModel = UserModel(
          uid: _userModel!.uid,
          email: _userModel!.email,
          displayName: _userModel!.displayName,
          role: _userModel!.role,
          childIds: _userModel!.childIds,
          pin: pin,
        );

        // Notify user about PIN change
        await NotificationService().addNotification(
          _userModel!.uid,
          NotificationModel(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            title: 'PIN Updated',
            message: 'Your connection PIN has been regenerated.',
            timestamp: DateTime.now(),
            type: 'system',
            iconName: 'vpn_key_rounded',
            colorValue: Colors.orange.toARGB32(),
          ),
        );
      }
      return pin;
    } catch (e) {
      // Error generating PIN
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> selectChild(ChildModel child) async {
    if (_userModel == null) return false;

    try {
      final deviceId = await DeviceService().getDeviceId();
      final childDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_userModel!.uid)
          .collection('children')
          .doc(child.id)
          .get();
          
      if (childDoc.exists) {
        final data = childDoc.data()!;
        final linkedDevice = data['linkedDeviceId'] as String?;
        if (linkedDevice != null && linkedDevice.isNotEmpty && linkedDevice != deviceId) {
          _errorMessage = 'บัญชีเด็กนี้ถูกเข้าใช้งานในเครื่องอื่นแล้ว\n(1 บัญชีต่อ 1 เครื่อง)';
          notifyListeners();
          return false;
        }

        if (linkedDevice != deviceId) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userModel!.uid)
              .collection('children')
              .doc(child.id)
              .update({'linkedDeviceId': deviceId});
        }
      }
    } catch (e) {
      _errorMessage = 'เกิดข้อผิดพลาดในการตรวจสอบข้อมูลอุปกรณ์';
      notifyListeners();
      return false;
    }

    _errorMessage = null;
    _currentChild = child;
    notifyListeners();

    // Cancel previous subscription if exists
    await _currentChildSubscription?.cancel();

    // Subscribe to realtime updates for this child
    if (_userModel != null) {
      _currentChildSubscription = FirebaseFirestore.instance
          .collection('users')
          .doc(_userModel!.uid)
          .collection('children')
          .doc(child.id)
          .snapshots()
          .listen((snapshot) async {
            if (snapshot.exists && snapshot.data() != null) {
              final newChildData = ChildModel.fromMap(snapshot.data()!, snapshot.id);
              final currentDeviceId = await DeviceService().getDeviceId();

              // Auto logout if the linked device changed to another device
              if (newChildData.linkedDeviceId != null &&
                  newChildData.linkedDeviceId!.isNotEmpty &&
                  newChildData.linkedDeviceId != currentDeviceId &&
                  _isChildMode) {
                // Another device took over
                _errorMessage = 'บัญชีเด็กนี้ถูกเข้าใช้งานในเครื่องอื่นแล้ว\nระบบจะทำการออกจากระบบ...';
                await logoutChild(clearDeviceLink: false);
                return;
              }
              
              _currentChild = newChildData;
              notifyListeners();
            }
          });

      await _authService.updateChildStatus(_userModel!.uid, child.id, true);
    }
    return true;
  }

  Future<void> logoutChild({bool clearDeviceLink = true}) async {
    // Cancel realtime subscription
    await _currentChildSubscription?.cancel();
    _currentChildSubscription = null;

    if (_userModel != null && _currentChild != null) {
      try {
        await _authService.updateChildStatus(
          _userModel!.uid,
          _currentChild!.id,
          false,
        );
        // เลิกเชื่อมต่ออุปกรณ์เมื่อเด็กออกจากระบบเอง
        if (clearDeviceLink) {
          await FirebaseFirestore.instance
              .collection('users')
              .doc(_userModel!.uid)
              .collection('children')
              .doc(_currentChild!.id)
              .update({'linkedDeviceId': FieldValue.delete()});
        }
      } catch (_) {}
    }

    // ลบ child session และ anonymous account
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      try {
        await FirebaseFirestore.instance
            .collection('child_sessions')
            .doc(currentUser.uid)
            .delete();
        await currentUser.delete();
      } catch (_) {
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
      }
    }

    _currentChild = null;
    _userModel = null;
    _children = [];
    _isChildMode = false;
    notifyListeners();
  }

  Future<bool> childLogin(String pin) async {
    // ==================== Rate Limiting Check ====================
    // ตรวจสอบว่าถูกล็อกจากการลองผิดหลายครั้งหรือไม่
    if (isPinLockedOut) {
      _errorMessage =
          'ลองผิดหลายครั้ง กรุณารอ $pinLockoutMinutesRemaining นาที';
      notifyListeners();
      return false;
    }

    try {
      _isLoading = true;
      _isChildMode = true;
      _errorMessage = null;
      notifyListeners();

      // 1. Sign in anonymously (ให้มี Firebase Auth session)
      await FirebaseAuth.instance.signInAnonymously();

      // 2. ดึง parentUid จาก PIN (อ่าน pins/{pin} ไม่ต้อง auth)
      final parentUid = await _authService.getParentUidFromPin(pin);
      if (parentUid == null) {
        // ==================== PIN ผิด — นับ attempt ====================
        _pinAttempts++;
        await SecurityLogger.logAuth(
          'child_pin_failed',
          false,
          userId: 'attempt_$_pinAttempts',
        );

        if (_pinAttempts >= _maxPinAttempts) {
          _pinLockoutUntil = DateTime.now().add(_lockoutDuration);
          _errorMessage =
              'ลองผิดครบ $_maxPinAttempts ครั้ง ล็อก ${_lockoutDuration.inMinutes} นาที';
          _pinAttempts = 0;
          await SecurityLogger.security(
            'PIN brute-force lockout triggered',
            data: {'lockoutUntil': _pinLockoutUntil!.toIso8601String()},
          );
        } else {
          final remaining = _maxPinAttempts - _pinAttempts;
          _errorMessage = 'PIN ไม่ถูกต้อง (เหลืออีก $remaining ครั้ง)';
        }

        _isChildMode = false;
        try {
          await FirebaseAuth.instance.signOut();
        } catch (_) {}
        return false;
      }

      // ==================== PIN ถูก — reset attempts ====================
      _pinAttempts = 0;
      _pinLockoutUntil = null;

      // 3. สร้าง child session mapping
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        _isChildMode = false;
        return false;
      }
      await FirebaseFirestore.instance
          .collection('child_sessions')
          .doc(currentUser.uid)
          .delete()
          .catchError((_) {}); // Doc may not exist yet — that's fine

      await FirebaseFirestore.instance
          .collection('child_sessions')
          .doc(currentUser.uid)
          .set({
            'parentUid': parentUid,
            'createdAt': FieldValue.serverTimestamp(),
            'expiresAt': Timestamp.fromDate(
              DateTime.now().add(_sessionDuration),
            ),
          });

      // 4. ตอนนี้ rules อนุญาตแล้ว — ดึงข้อมูล parent
      _userModel = await _authService.getUserData(parentUid);
      if (_userModel != null) {
        await fetchChildren();
      }

      return _userModel != null;
    } catch (e) {
      _isChildMode = false;
      try {
        await FirebaseAuth.instance.signOut();
      } catch (_) {}
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ==================== Offline Session Restore ====================
  /// ลอง restore child session จากข้อมูลในเครื่อง (Secure Storage + Firestore cache)
  /// ใช้ก่อน childLogin() เสมอ — ไม่ต้องต่อเน็ต
  /// คืนค่า true ถ้า restore สำเร็จและมีข้อมูลเด็กใน memory แล้ว
  Future<bool> restoreChildSessionOffline({
    required String parentUid,
    required String childId,
  }) async {
    try {
      _isLoading = true;
      _isChildMode = true;
      notifyListeners();

      // ดึงข้อมูล parent จาก Firestore cache (ไม่ต้องเน็ต ถ้า cache ยังอยู่)
      _userModel = await _authService.getUserData(parentUid);
      if (_userModel == null) {
        _isChildMode = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // ดึง children จาก cache
      await fetchChildren();
      if (_children.isEmpty) {
        _isChildMode = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      // หาเด็กที่ตรงกับ childId ที่บันทึกไว้
      final matchedChildren = _children.where((c) => c.id == childId).toList();
      if (matchedChildren.isEmpty) {
        // childId ไม่มีอยู่จริง (ถูกลบไปแล้ว) — session ไม่ valid
        _isChildMode = false;
        _isLoading = false;
        notifyListeners();
        return false;
      }

      _currentChild = matchedChildren.first;
      _errorMessage = null;
      notifyListeners();
      return true;
    } catch (_) {
      // ถ้า error ก็แค่บอกว่า restore ไม่ได้ — ไม่ต้อง clearSession
      _isChildMode = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteChild(String childId) async {
    if (_userModel == null) return false;
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.deleteChild(_userModel!.uid, childId);
      _children.removeWhere((child) => child.id == childId);
      return true;
    } catch (e) {
      // Error deleting child
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDisplayName(String newName) async {
    if (_userModel == null) return false;
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.updateDisplayName(_userModel!.uid, newName);
      // Update local user model
      _userModel = UserModel(
        uid: _userModel!.uid,
        email: _userModel!.email,
        displayName: newName,
        role: _userModel!.role,
        childIds: _userModel!.childIds,
        pin: _userModel!.pin,
      );
      return true;
    } catch (e) {
      // Error updating display name
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updatePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_userModel == null) return false;
    try {
      _isLoading = true;
      notifyListeners();
      await _authService.updatePassword(currentPassword, newPassword);
      return true;
    } catch (e) {
      // Error updating password
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// แปลง Firebase error code เป็นข้อความภาษาไทยที่เข้าใจง่าย
  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'ไม่พบบัญชีที่ใช้อีเมลนี้';
      case 'wrong-password':
        return 'รหัสผ่านไม่ถูกต้อง';
      case 'invalid-email':
        return 'รูปแบบอีเมลไม่ถูกต้อง';
      case 'user-disabled':
        return 'บัญชีนี้ถูกระงับการใช้งาน';
      case 'email-already-in-use':
        return 'อีเมลนี้ถูกใช้งานแล้ว';
      case 'weak-password':
        return 'รหัสผ่านไม่แข็งแรงพอ กรุณาตั้งรหัสที่ซับซ้อนกว่านี้';
      case 'too-many-requests':
        return 'ลองผิดหลายครั้งเกินไป กรุณารอสักครู่แล้วลองใหม่';
      case 'invalid-credential':
        return 'อีเมลหรือรหัสผ่านไม่ถูกต้อง';
      case 'network-request-failed':
        return 'ไม่สามารถเชื่อมต่ออินเทอร์เน็ตได้';
      default:
        return 'เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง';
    }
  }
}
