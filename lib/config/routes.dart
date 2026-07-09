// ==================== Route Guard ====================
// ระบบป้องกันการเข้าถึงหน้าที่ต้องการ Authentication
//
// ปัญหาเดิม:
// - ไม่มี Route Guard เลย → user สามารถ navigate ไปหน้า parentDashboard
//   ได้โดยตรง โดยไม่ต้อง login
//
// วิธีแก้:
// - ใช้ MaterialApp.onGenerateRoute แทน routes map สำหรับ protected routes
// - ทุก route ที่ต้องการ auth จะถูกตรวจสอบก่อน redirect ไปหน้า login
//
// Protected Routes (ต้อง login):
//   - parentDashboard, parentSettings, parentContacts,
//     parentAppControl, parentAccountProfile, settingsNotifications,
//     settingsLanguage, settingsHelpCenter, settingsFeedback, settingsAbout
//
// Public Routes (ไม่ต้อง login):
//   - selectUser, onboarding, login,
//     childHome, childPin, childActivation, childProfileSetup,
//     childSelection, childFriendlyLock
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../presentation/auth/login_screen.dart';
import '../presentation/shared/parent_shell.dart';
import '../presentation/child/child_home_screen.dart';
import '../presentation/child/child_mode_activation_screen.dart';
import '../presentation/onboarding/select_user_screen.dart';
import '../presentation/onboarding/onboarding_screen.dart';
import '../presentation/child/child_pin_screen.dart';
import '../presentation/parent/parent_settings_screen.dart';
import '../presentation/child/child_profile_setup_screen.dart';
import '../presentation/child/child_selection_screen.dart';
import '../presentation/parent/contacts/parent_contacts_screen.dart';
import '../presentation/parent/apps/parent_app_control_screen.dart';
import '../presentation/parent/account_profile_screen.dart';
// หน้าตั้งค่าย่อย
import '../presentation/parent/settings/notifications_settings_screen.dart';
import '../presentation/parent/settings/language_settings_screen.dart';
import '../presentation/parent/settings/help_center_screen.dart';
import '../presentation/parent/settings/feedback_screen.dart';
import '../presentation/parent/settings/about_screen.dart';
import '../presentation/child/friendly_lock_screen.dart';

class AppRoutes {
  // ==================== เส้นทาง Onboarding ====================
  static const String selectUser = '/select_user';
  static const String onboarding = '/onboarding';
  static const String login = '/login';

  // ==================== เส้นทาง Parent ====================
  static const String parentDashboard = '/parent/dashboard';
  static const String parentSettings = '/parent/settings';
  static const String parentContacts = '/parent/contacts';
  static const String parentAppControl = '/parent/app_control';
  static const String parentAccountProfile = '/parent/account-profile';

  // ==================== เส้นทาง Child ====================
  static const String childHome = '/child/home';
  static const String childActivation = '/child/activation';
  static const String childPin = '/child/pin';
  static const String childProfileSetup = '/child/profile_setup';
  static const String childSelection = '/child/selection';
  static const String childFriendlyLock = '/child/friendly-lock';

  // ==================== เส้นทาง Settings ย่อย ====================
  static const String settingsNotifications = '/settings/notifications';
  static const String settingsLanguage = '/settings/language';
  static const String settingsHelpCenter = '/settings/help-center';
  static const String settingsFeedback = '/settings/feedback';
  static const String settingsAbout = '/settings/about';

  // ==================== Protected Routes Set ====================
  // routes เหล่านี้ต้องการ Authentication — ถ้าไม่ได้ login จะถูก redirect ไปหน้า login
  static const Set<String> _protectedRoutes = {
    parentDashboard,
    parentSettings,
    parentContacts,
    parentAppControl,
    parentAccountProfile,
    settingsNotifications,
    settingsLanguage,
    settingsHelpCenter,
    settingsFeedback,
    settingsAbout,
  };

  /// ตรวจสอบว่า route นี้ต้องการ Authentication หรือไม่
  static bool isProtected(String routeName) =>
      _protectedRoutes.contains(routeName);

  /// สร้าง Map ของ routes ทั้งหมด
  /// ใช้ใน MaterialApp(routes: AppRoutes.getRoutes())
  static Map<String, WidgetBuilder> getRoutes() {
    return {
      // Onboarding (Public)
      selectUser: (context) => const SelectUserScreen(),
      login: (context) => const LoginScreen(),
      onboarding: (context) => const OnboardingScreen(),
      // Parent (Protected — ตรวจสอบโดย RouteGuard ใน onGenerateRoute)
      parentDashboard: (context) => const ParentShell(),
      parentSettings: (context) => const ParentSettingsScreen(),
      parentContacts: (context) => const ParentContactsScreen(),
      parentAppControl: (context) => const ParentAppControlScreen(),
      parentAccountProfile: (context) => const AccountProfileScreen(),
      // Child (Public — ระบบ PIN ดูแลความปลอดภัยเอง)
      childHome: (context) => const ChildHomeScreen(),
      childActivation: (context) => const ChildModeActivationScreen(),
      childPin: (context) => const ChildPinScreen(),
      childProfileSetup: (context) => const ChildProfileSetupScreen(),
      childSelection: (context) => const ChildSelectionScreen(),
      childFriendlyLock: (context) => const FriendlyLockScreen(),
      // Settings ย่อย (Protected)
      settingsNotifications: (context) => const NotificationsSettingsScreen(),
      settingsLanguage: (context) => const LanguageSettingsScreen(),
      settingsHelpCenter: (context) => const HelpCenterScreen(),
      settingsFeedback: (context) => const FeedbackScreen(),
      settingsAbout: (context) => const AboutScreen(),
    };
  }

  /// Route Guard: ตรวจสอบ auth ก่อน navigate ไปหน้าที่ protected
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final routeName = settings.name ?? '';
    final allRoutes = getRoutes();

    // ตรวจสอบว่า route มีอยู่จริงไหม
    final builder = allRoutes[routeName];
    if (builder == null) {
      return _buildRoute((_) => const SelectUserScreen(), settings);
    }

    // ตรวจสอบ Auth Guard สำหรับ protected routes
    if (isProtected(routeName)) {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null || currentUser.isAnonymous) {
        // ❌ ไม่ได้ login → redirect ไป /login แทน
        return _buildRoute(
          (_) => const LoginScreen(),
          const RouteSettings(name: login),
        );
      }
    }

    // ✅ ผ่าน guard → navigate ด้วย smooth transition
    return _buildRoute(builder, settings);
  }

  // ==================== Smooth Page Transition ====================
  // Slide + Fade animation แทน MaterialPageRoute ธรรมดา
  static PageRouteBuilder<dynamic> _buildRoute(
    WidgetBuilder builder,
    RouteSettings settings,
  ) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) =>
          builder(context),
      transitionDuration: const Duration(milliseconds: 280),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide in from right + fade
        final slideIn = Tween<Offset>(
          begin: const Offset(0.06, 0),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        ));
        final fadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(
            parent: animation,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );
        // Slide out slightly to left on pop
        final slideOut = Tween<Offset>(
          begin: Offset.zero,
          end: const Offset(-0.03, 0),
        ).animate(CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
        ));
        return SlideTransition(
          position: slideOut,
          child: SlideTransition(
            position: slideIn,
            child: FadeTransition(opacity: fadeIn, child: child),
          ),
        );
      },
    );
  }
}
