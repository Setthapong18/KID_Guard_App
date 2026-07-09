// ==================== App Theme ====================
// ธีมหลักของแอพ KidGuard
//
// กำหนดสี, font, ขนาด, และ style ของ UI components ทั้งหมด
// ใช้ Material 3 design system
//
// ระบบสี:
// - Primary: Sage Green (#6B9080) - สีเขียวอ่อนที่ดูนุ่มนวลและเป็นมืออาชีพ
// - Secondary: Mint (#A4C3B2) - สีเขียวมิ้นท์เสริม
// - Tertiary: Light Mint (#CCE3DE) - สีมิ้นท์อ่อนสำหรับ background
// - Surface: White - พื้นหลังการ์ด
// - Scaffold Background: #F6FBF4 - พื้นหลังหน้าจอ (เขียวอ่อนมาก)
//
// ฟอนต์: Itim-Regular (ฟอนต์ไทยที่อ่านง่าย)
//
// ทั้ง lightTheme และ darkTheme กำหนดไว้แล้ว
// แต่ตอนนี้ใช้แค่ lightTheme (ดูที่ main.dart)
import 'package:flutter/material.dart';

class AppTheme {
  // ฟอนต์หลักของแอพ - ใช้ Itim-Regular (ต้องเพิ่มในไฟล์ pubspec.yaml ด้วย)
  static const String _fontFamily = 'Itim-Regular';

  // ==================== Light Theme ====================
  /// ธีมสว่าง - ใช้เป็นค่าเริ่มต้น
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,

    // ระบบสีหลัก
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF6B9080), // Sage Green - สีหลักของแอพ
      primary: const Color(0xFF6B9080), // Sage Green - ปุ่ม, link, active items
      secondary: const Color(0xFFA4C3B2), // Mint - สีเสริม
      tertiary: const Color(0xFFCCE3DE), // Light Mint - background อ่อน
      surface: Colors.white, // พื้นหลังการ์ด
    ),

    // พื้นหลังหน้าจอ
    scaffoldBackgroundColor: const Color(0xFFF6FBF4),

    // ใช้ Typography มาตรฐาน ป้องกัน TextStyle interpolation crash
    typography: Typography.material2021(platform: TargetPlatform.iOS),

    // สีตัวอักษร
    textTheme: Typography.material2021(platform: TargetPlatform.iOS).black
        .apply(
          fontFamily: _fontFamily,
          bodyColor: const Color(0xFF1E293B),
          displayColor: const Color(0xFF0F172A),
        ),

    // App Bar - โปร่งใส ไม่มีเงา
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1E293B)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1E293B),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: _fontFamily,
      ),
    ),

    // Card - ไม่มีเงา มีขอบเทาอ่อน มุมโค้ง 20px
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      color: Colors.white,
      margin: EdgeInsets.zero,
    ),

    // Input Field - พื้นหลังขาว ขอบโค้ง 16px
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6B9080), width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
    ),

    // Elevated Button - สีเขียว ตัวอักษรขาว ไม่มีเงา
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6B9080),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // Outlined Button - ขอบเขียว ตัวอักษรเขียว
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: const BorderSide(color: Color(0xFF6B9080)),
        foregroundColor: const Color(0xFF6B9080),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );

  // ==================== Dark Theme ====================
  /// ธีมมืด - เตรียมไว้แต่ยังไม่ได้ใช้
  /// สามารถเปิดใช้ได้โดยเปลี่ยน theme ใน main.dart
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: _fontFamily,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF84A98C),
      brightness: Brightness.dark,
      surface: const Color(0xFF1E293B),
    ),
    scaffoldBackgroundColor: const Color(0xFF0F172A),

    typography: Typography.material2021(platform: TargetPlatform.iOS),

    // ใช้ base เดียวกันเป๊ะๆ ป้องกัน crash
    textTheme: Typography.material2021(platform: TargetPlatform.iOS).black
        .apply(
          fontFamily: _fontFamily,
          bodyColor: const Color(0xFFE2E8F0),
          displayColor: const Color(0xFFF8FAFC),
        ),

    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE2E8F0)),
      // ต้องใส่ titleTextStyle ให้โครงสร้างเหมือน lightTheme เป๊ะๆ
      titleTextStyle: TextStyle(
        color: Color(0xFFF8FAFC),
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: _fontFamily,
      ),
    ),

    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      color: const Color(0xFF1E293B),
      margin: EdgeInsets.zero, // เพิ่ม margin: zero เหมือน lightTheme
    ),

    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1E293B),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF84A98C), width: 2),
      ),
      // ต้องใส่ errorBorder เหมือน lightTheme
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Colors.red),
      ),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF84A98C),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        // ต้องใส่ textStyle แบบเดียวกับ lightTheme เป๊ะๆ
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),

    // ต้องใส่ outlinedButtonTheme ด้วย เพราะ lightTheme มี
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        side: const BorderSide(color: Color(0xFF84A98C)),
        foregroundColor: const Color(0xFF84A98C),
        // ต้องใส่ textStyle แบบเดียวกับ lightTheme เป๊ะๆ
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
  );
}
