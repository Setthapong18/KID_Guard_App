// ==================== Shimmer Widgets ====================
// Widget สำหรับแสดง Loading State แบบ Shimmer Effect
//
// แทนการใช้ CircularProgressIndicator ซึ่งดูธรรมดา
// Shimmer จะแสดง skeleton ของ UI ทำให้ผู้ใช้รู้สึกว่าแอปตอบสนองเร็วกว่า
// (Perceived Performance) และดูเป็น Professional มากขึ้น
//
// วิธีใช้:
// ```dart
// // แทน CircularProgressIndicator ด้วย:
// ShimmerLoading(child: ShimmerWidgets.listCard())
//
// // หรือใช้ pre-built shimmer:
// ShimmerWidgets.childCardLoading()
// ShimmerWidgets.statCardLoading()
// ShimmerWidgets.listTileLoading()
// ```
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Widget ครอบ Shimmer Effect
/// ใช้ wrap รอบ placeholder widget ใดๆ ก็ได้
class ShimmerLoading extends StatelessWidget {
  final Widget child;
  final bool isLoading;

  const ShimmerLoading({
    required this.child,
    this.isLoading = true,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!isLoading) return child;

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: child,
    );
  }
}

/// Collection ของ Shimmer Placeholder Widgets พร้อมใช้งาน
class ShimmerWidgets {
  ShimmerWidgets._();

  // ==================== Child Card Shimmer ====================
  /// Skeleton สำหรับ Card ของเด็กใน Dashboard
  static Widget childCardLoading() {
    return Container(
      width: 140,
      height: 170,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // ==================== Stat Card Shimmer ====================
  /// Skeleton สำหรับ Stat Card (เวลาใช้หน้าจอ, แต้มสะสม)
  static Widget statCardLoading() {
    return Container(
      height: 90,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }

  // ==================== List Tile Shimmer ====================
  /// Skeleton สำหรับ ListTile ทั่วไป (แอป, ผู้ติดต่อ, รายการ)
  static Widget listTileLoading() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Avatar/Icon placeholder
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title placeholder
                Container(
                  height: 14,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle placeholder (shorter)
                Container(
                  height: 12,
                  width: double.infinity * 0.6,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==================== App List Shimmer ====================
  /// Skeleton สำหรับรายการแอปใน App Control Screen
  static Widget appListLoading({int itemCount = 6}) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (_, i) => ShimmerLoading(
        child: listTileLoading(),
      ),
    );
  }

  // ==================== Chart Shimmer ====================
  /// Skeleton สำหรับ Chart (กราฟสถิติใน Activity Screen)
  static Widget chartLoading() {
    return Container(
      height: 200,
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }

  // ==================== Full Screen Shimmer ====================
  /// Skeleton สำหรับ Loading หน้าจอทั้งหมด (Parent Dashboard)
  static Widget dashboardLoading(BuildContext context) {
    return ShimmerLoading(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              height: 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(height: 20),
            // Child cards row
            SizedBox(
              height: 170,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                separatorBuilder: (_, i) => const SizedBox(width: 12),
                itemBuilder: (_, j) => childCardLoading(),
              ),
            ),
            const SizedBox(height: 20),
            // Stat cards grid
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: 4,
              itemBuilder: (_, i) => statCardLoading(),
            ),
            const SizedBox(height: 20),
            // List tiles
            ...List.generate(
              3,
              (_) => Column(
                children: [
                  listTileLoading(),
                  const SizedBox(height: 4),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
