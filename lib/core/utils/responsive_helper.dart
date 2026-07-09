// ==================== Responsive Helper ====================
// เครื่องมือปรับขนาด UI ตามขนาดหน้าจอ
//
// แก้ปัญหา UI ดูใหญ่/เล็กเกินไปบนอุปกรณ์ต่างรุ่น
// ใช้ระบบ scale factor โดยอ้างอิงจากหน้าจอมาตรฐาน 393×852 (โทรศัพท์ Android ~6 นิ้ว)
//
// วิธีใช้:
// ```dart
// final r = ResponsiveHelper.of(context);
// Text('Hello', style: TextStyle(fontSize: r.sp(16)));
// SizedBox(width: r.wp(20));
// SizedBox(height: r.hp(100));
// ```
//
// ค่า scale จะถูก clamp ไว้ที่ 0.85-1.3
// เพื่อไม่ให้ UI บิดเบี้ยวบนจอที่เล็กหรือใหญ่มากๆ
import 'package:flutter/material.dart';

class ResponsiveHelper {
  final double screenWidth; // ความกว้างหน้าจอจริง (logical pixels)
  final double screenHeight; // ความสูงหน้าจอจริง (logical pixels)

  // ขนาดหน้าจอที่ใช้ออกแบบ (โทรศัพท์ Android ~6 นิ้ว)
  static const double _designWidth = 393;
  static const double _designHeight = 852;

  // Scale factors - clamp ไว้ไม่ให้เล็ก/ใหญ่เกินไป
  late final double _widthScale;
  late final double _heightScale;

  ResponsiveHelper._({required this.screenWidth, required this.screenHeight}) {
    _widthScale = (screenWidth / _designWidth).clamp(0.85, 1.3);
    _heightScale = (screenHeight / _designHeight).clamp(0.85, 1.3);
  }

  /// สร้าง instance จาก BuildContext (ดึงขนาดจอจาก MediaQuery)
  factory ResponsiveHelper.of(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return ResponsiveHelper._(
      screenWidth: size.width,
      screenHeight: size.height,
    );
  }

  /// ปรับขนาดตัวอักษร (Font Size) - scale ตามความกว้างจอ
  double sp(double size) => size * _widthScale;

  /// ปรับค่าแนวนอน (padding, width, margin) - scale ตามความกว้างจอ
  double wp(double size) => size * _widthScale;

  /// ปรับค่าแนวตั้ง (height, vertical spacing) - scale ตามความสูงจอ
  double hp(double size) => size * _heightScale;

  /// ปรับขนาด icon - scale ตามความกว้างจอ
  double iconSize(double size) => size * _widthScale;

  /// ปรับ border radius - scale ตามความกว้างจอ
  double radius(double size) => size * _widthScale;

  /// จำนวนคอลัมน์ Grid ตามความกว้างหน้าจอ
  /// >=900px → 4 คอลัมน์ (แท็บเล็ตแนวนอน)
  /// >=600px → 3 คอลัมน์ (แท็บเล็ต)
  /// <600px → 2 คอลัมน์ (โทรศัพท์)
  int get gridCrossAxisCount {
    if (screenWidth >= 900) return 4;
    if (screenWidth >= 600) return 3;
    return 2;
  }

  /// Padding ด้านข้างของหน้าจอ (ปรับตามขนาดจอ)
  double get horizontalPadding {
    if (screenWidth >= 600) return 32;
    if (screenWidth >= 360) return 20;
    return 16;
  }

  /// Aspect ratio ของ Quick Actions grid items
  double get quickActionAspectRatio {
    if (screenWidth >= 600) return 1.8;
    return 1.5;
  }
}
