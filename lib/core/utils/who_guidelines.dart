// ==================== WHO Guidelines ====================
// คำแนะนำเวลาหน้าจอตามมาตรฐาน WHO (องค์การอนามัยโลก)
//
// ใช้แสดงคำแนะนำเวลาหน้าจอที่เหมาะสมตามอายุของเด็ก
// แสดงในหน้า Time Limit เพื่อช่วยผู้ปกครองตัดสินใจ
//
// ข้อมูลอ้างอิง: WHO Guidelines on Physical Activity, Sedentary Behaviour
// and Sleep for Children Under 5 Years of Age (2019)
//
// แบ่งตามช่วงอายุ:
// - 0-1 ปี: ไม่ควรมีเวลาหน้าจอเลย
// - 1-2 ปี: ไม่เกิน 1 ชั่วโมง (ยิ่งน้อยยิ่งดี)
// - 3-4 ปี: ไม่เกิน 1 ชั่วโมง
// - 5-12 ปี: ไม่เกิน 2 ชั่วโมง
// - 13+ ปี: ควบคุมอย่างเหมาะสม
import 'package:flutter/material.dart';

/// โมเดลคำแนะนำเวลาหน้าจอจาก WHO
class WHORecommendation {
  final String ageGroup; // กลุ่มอายุ (เช่น "5-12 ปี")
  final String recommendation; // คำแนะนำสั้นๆ (เช่น "ไม่เกิน 2 ชั่วโมง")
  final String details; // คำอธิบายเพิ่มเติม
  final int maxMinutes; // เวลาสูงสุดที่แนะนำ (นาที), 0 = ไม่ควรใช้เลย
  final bool showWarning; // แสดงเตือนพิเศษหรือไม่ (สำหรับเด็กเล็กมาก)

  const WHORecommendation({
    required this.ageGroup,
    required this.recommendation,
    required this.details,
    required this.maxMinutes,
    this.showWarning = false,
  });
}

/// เครื่องมือดึงคำแนะนำ WHO ตามอายุเด็ก
class WHOGuidelines {
  /// ดึงคำแนะนำ WHO ตามอายุเด็ก
  /// คืน WHORecommendation ที่มีข้อมูลครบ (กลุ่มอายุ, คำแนะนำ, รายละเอียด)
  static WHORecommendation getRecommendation(int age) {
    if (age < 1) {
      return const WHORecommendation(
        ageGroup: 'ทารก (0-1 ปี)',
        recommendation: 'ไม่ควรมีเวลาหน้าจอ',
        details: 'ควรให้ทารกเล่นบนพื้นและมีปฏิสัมพันธ์กับผู้ดูแล',
        maxMinutes: 0,
        showWarning: true,
      );
    } else if (age <= 2) {
      return const WHORecommendation(
        ageGroup: '1-2 ปี',
        recommendation: 'ไม่เกิน 1 ชั่วโมง',
        details: 'ยิ่งน้อยยิ่งดี ควรเป็นเนื้อหาที่เหมาะสม',
        maxMinutes: 60,
        showWarning: true,
      );
    } else if (age <= 4) {
      return const WHORecommendation(
        ageGroup: '3-4 ปี',
        recommendation: 'ไม่เกิน 1 ชั่วโมง',
        details: 'ยิ่งน้อยยิ่งดีต่อพัฒนาการ',
        maxMinutes: 60,
      );
    } else if (age <= 12) {
      return const WHORecommendation(
        ageGroup: '5-12 ปี',
        recommendation: 'ไม่เกิน 2 ชั่วโมง',
        details: 'ควรมีกิจกรรมอื่นที่หลากหลาย',
        maxMinutes: 120,
      );
    } else {
      return const WHORecommendation(
        ageGroup: '13+ ปี',
        recommendation: 'ควบคุมอย่างเหมาะสม',
        details: 'สร้างสมดุลระหว่างหน้าจอและกิจกรรมอื่น',
        maxMinutes: 120,
      );
    }
  }

  /// ดึง icon ตามกลุ่มอายุ
  /// เด็กเล็ก = warning, เด็กโต = school, วัยรุ่น = person
  static IconData getIcon(int age) {
    if (age < 1) return Icons.warning_rounded;
    if (age <= 2) return Icons.child_care_rounded;
    if (age <= 4) return Icons.face_rounded;
    if (age <= 12) return Icons.school_rounded;
    return Icons.person_rounded;
  }

  /// ดึงสีตามกลุ่มอายุ
  /// แดง = ห้ามใช้, ส้ม = จำกัด, น้ำเงิน = ปานกลาง
  static Color getColor(int age) {
    if (age < 1) return const Color(0xFFEF4444); // แดง - ห้ามใช้หน้าจอ
    if (age <= 2) return const Color(0xFFF59E0B); // ส้ม - จำกัดมาก
    if (age <= 4) return const Color(0xFFF59E0B); // ส้ม - จำกัด
    return const Color(0xFF3B82F6); // น้ำเงิน - ปานกลาง
  }

  /// ดึงสี gradient สำหรับ card แสดงคำแนะนำ
  static List<Color> getGradientColors(int age) {
    if (age < 1) {
      return [
        const Color(0xFFEF4444).withValues(alpha: 0.15),
        const Color(0xFFF87171).withValues(alpha: 0.08),
      ];
    } else if (age <= 4) {
      return [
        const Color(0xFFF59E0B).withValues(alpha: 0.15),
        const Color(0xFFFBBF24).withValues(alpha: 0.08),
      ];
    } else {
      return [
        const Color(0xFF3B82F6).withValues(alpha: 0.12),
        const Color(0xFF60A5FA).withValues(alpha: 0.06),
      ];
    }
  }

  /// เช็คว่าเวลาที่ตั้งเกินคำแนะนำ WHO หรือไม่
  /// ใช้แสดง warning ในหน้า Time Limit เมื่อ parent ตั้งค่าเกิน
  static bool isExceedingRecommendation(int age, int setMinutes) {
    final recommendation = getRecommendation(age);
    if (recommendation.maxMinutes == 0 && setMinutes > 0) return true;
    if (setMinutes > recommendation.maxMinutes) return true;
    return false;
  }
}
