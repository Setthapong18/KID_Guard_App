import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kidguard/l10n/app_localizations.dart' show AppLocalizations;
import 'package:provider/provider.dart';
import 'config/app_theme.dart';

import 'config/routes.dart';
import 'logic/providers/auth_provider.dart';
import 'logic/providers/rewards_provider.dart';
import 'logic/providers/schedule_provider.dart';
import 'logic/providers/time_limit_provider.dart';
import 'logic/providers/onboarding_provider.dart';

import 'logic/providers/locale_provider.dart';
import 'logic/providers/theme_provider.dart';
import 'data/services/security_service.dart';
import 'data/services/crashlytics_service.dart';
import 'core/utils/security_logger.dart';
import 'dart:io';

import 'package:workmanager/workmanager.dart';
import 'logic/background_worker.dart';
import 'data/services/local_notification_service.dart';
import 'data/services/daily_report_service.dart';
import 'core/di/injection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ==================== จุดเริ่มต้นแอพ ====================
/// ฟังก์ชัน main() - จุดเริ่มต้นของแอพ
/// 1. Initialize Firebase + Crashlytics
/// 2. Initialize WorkManager สำหรับ background tasks
/// 3. รัน MyApp widget
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // ==================== Firebase Crashlytics ====================
  // ดักจับ crash ทุกประเภทอัตโนมัติ:
  // - Flutter framework errors (widget build errors)
  // - Dart async errors
  // - Platform channel errors
  // ปิดอัตโนมัติใน debug mode เพื่อไม่รบกวน dev workflow
  await CrashlyticsService.initialize();

  // ==================== Firestore Offline Persistence ====================
  // เปิดใช้งาน Local Cache ของ Firestore
  // - แอปยังดึงข้อมูลเก่าจาก Cache ได้เมื่อเน็ตหลุด
  // - เมื่อเน็ตกลับมา Firestore จะ Sync ข้อมูลที่เขียนขณะ Offline อัตโนมัติ
  // - CACHE_SIZE_UNLIMITED = ไม่จำกัดขนาด cache (เหมาะกับแอปที่มีข้อมูลหลายลูก)
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
  );

  // Initialize Dependency Injection
  await initDependencies();

  // Initialize Local Notifications
  await LocalNotificationService.initialize();

  // ตั้งค่า WorkManager สำหรับงาน background (sync, tracking)
  Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

  // ─── ลงทะเบียน Daily Report Task ──────────────────────────────────

  // คำนวณ delay จนถึง 20:00 น. (2 ทุ่ม) ของคืนนี้ (สำหรับใช้งานจริง)
  final now = DateTime.now();
  final targetToday = DateTime(now.year, now.month, now.day, 20, 0);
  final targetFiring = now.isBefore(targetToday)
      ? targetToday
      : targetToday.add(const Duration(days: 1));
  final initialDelay = targetFiring.difference(now);

  await Workmanager().registerPeriodicTask(
    'daily_report_task',
    DailyReportService.taskName,
    frequency: const Duration(hours: 24),
    initialDelay: initialDelay,
    existingWorkPolicy: ExistingWorkPolicy.replace,
    constraints: Constraints(
      networkType: NetworkType.connected, // ต้องมี internet ดึงข้อมูล Firestore
    ),
  );

  runApp(const MyApp());
}

// ==================== Widget หลัก ====================
/// MyApp - Widget หลักที่ครอบทั้งแอพ
/// - ตรวจสอบความปลอดภัยของเครื่องเมื่อเริ่มแอพ
/// - ตั้งค่า Providers (Auth, Locale)
/// - ตั้งค่า routes และ themes
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SecurityService _securityService = SecurityService();
  SecurityStatus? _securityStatus; // ผลการตรวจสอบความปลอดภัย

  // ==================== Security Enforcement ====================
  // Flag บอกว่าเครื่องมีความเสี่ยง → บล็อก features บางอย่าง
  // ignore: unused_field
  static bool _isSecurityRestricted = false;

  @override
  void initState() {
    super.initState();
    _performSecurityCheck(); // ตรวจสอบความปลอดภัยทันทีเมื่อเปิดแอพ
  }

  // ==================== ตรวจสอบความปลอดภัย ====================
  /// ตรวจสอบว่าเครื่องมีความเสี่ยงหรือไม่
  /// - Root detection
  /// - Emulator detection
  /// - Debugger detection
  Future<void> _performSecurityCheck() async {
    try {
      final status = await _securityService.performSecurityCheck();
      setState(() {
        _securityStatus = status;
      });

      // บันทึก log ถ้าพบปัญหาความปลอดภัย
      if (status.hasSecurityIssue) {
        await SecurityLogger.security(
          'Security risk detected on startup',
          data: {
            'isRooted': status.isRooted,
            'isEmulator': status.isEmulator,
            'isDebugged': status.isDebugged,
            'riskLevel': status.riskLevel,
          },
        );

        // ==================== Enforcement Logic ====================
        // kDebugMode → ข้าม enforcement (dev ใช้ emulator ได้)
        if (kDebugMode) {
          debugPrint('[Security] Risk detected but skipped (debug mode)');
          return;
        }

        // ตั้ง flag restricted ถ้า risk ≥ 30
        if (status.riskLevel >= 30) {
          _isSecurityRestricted = true;
        }

        // Show dialog
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final navContext = _navigatorKey.currentContext;
          if (navContext != null) {
            _showSecurityWarningDialog(navContext);
          }
        });
      }
    } catch (e) {
      // Security check error handled silently
    }
  }

  // ==================== สร้าง UI ====================
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      // ==================== Providers ====================
      // AuthProvider - จัดการ login, user data, children data
      // LocaleProvider - จัดการภาษา (ไทย/อังกฤษ)
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),
        ChangeNotifierProvider(create: (_) => RewardsProvider()),
        ChangeNotifierProvider(create: (_) => ScheduleProvider()),
        ChangeNotifierProvider(create: (_) => TimeLimitProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()..init()),

        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: Consumer2<LocaleProvider, ThemeProvider>(
        builder: (context, localeProvider, themeProvider, child) {
          return MaterialApp(
            title: 'Kid Guard',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            // theme transition animation — smooth 200ms
            // แก้ไข TextStyle interpolation error ด้วยการใช้ ThemeData.light() เป็น base ให้ darkTheme แล้ว
            themeAnimationDuration: const Duration(milliseconds: 200),
            themeAnimationCurve: Curves.easeInOut,
            locale: localeProvider.locale,
            supportedLocales: const [Locale('th'), Locale('en')],
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            navigatorKey: _navigatorKey,
            initialRoute: AppRoutes.selectUser,
            // Route Guard: ตรวจสอบ auth ก่อน navigate ทุกครั้ง
            // ถ้าไม่ได้ login และพยายามเข้าหน้า protected → redirect ไป /login
            onGenerateRoute: AppRoutes.onGenerateRoute,
            // routes ยังคงไว้เพื่อรองรับ pushNamed ทั่วไปที่ไม่ต้องการ guard
            routes: AppRoutes.getRoutes(),
            debugShowCheckedModeBanner: false,
            builder: (context, child) {
              return child ?? const SizedBox.shrink();
            },
          );
        },
      ),
    );
  }

  // ==================== Dialog เตือนความปลอดภัย ====================

  bool _dialogShown = false;

  void _showSecurityWarningDialog(BuildContext context) {
    if (_dialogShown) return;
    _dialogShown = true;

    final isHighRisk = _securityStatus!.riskLevel >= 70;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        // Risk ≥ 70 → ไม่ให้กดย้อนกลับ (ต้องออกจากแอพ)
        canPop: !isHighRisk,
        child: AlertDialog(
          title: Row(
            children: [
              Icon(
                isHighRisk
                    ? Icons.gpp_bad_rounded
                    : Icons.warning_amber_rounded,
                color: isHighRisk ? Colors.red : Colors.orange[700],
                size: 28,
              ),
              const SizedBox(width: 8),
              Text(isHighRisk ? 'Security Blocked' : 'Security Warning'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                isHighRisk
                    ? 'Critical security issues detected. This app cannot run on this device:'
                    : 'Security issues detected on this device:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              ..._securityStatus!.details
                  .take(3)
                  .map(
                    (detail) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 16,
                            color: Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              detail,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              const SizedBox(height: 12),
              Text(
                'Risk Level: ${_securityStatus!.riskLevel}%',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: _securityStatus!.riskLevel > 50
                      ? Colors.red
                      : Colors.orange,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                isHighRisk
                    ? 'For security reasons, this app will now close.'
                    : 'Some features are restricted for security.',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            if (isHighRisk)
              // Risk ≥ 70 → ปิดแอพเลย
              TextButton(
                onPressed: () => exit(0),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Exit App'),
              )
            else
              // Risk 30-69 → อนุญาตใช้ต่อแต่ restricted
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('I Understand'),
              ),
          ],
        ),
      ),
    );
  }
}
