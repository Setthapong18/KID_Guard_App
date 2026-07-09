import 'package:flutter/material.dart';

// ==================== Shimmer Loading Widget ====================
// ใช้แทน CircularProgressIndicator ในหน้าที่โหลดรายการข้อมูล
// ให้ความรู้สึก smooth และ professional มากกว่า spinner
class ShimmerLoading extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  const ShimmerLoading.rect({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 12,
  });

  @override
  State<ShimmerLoading> createState() => _ShimmerLoadingState();
}

class _ShimmerLoadingState extends State<ShimmerLoading>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _shimmer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _shimmer = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.black.withValues(alpha: 0.06);
    final highlightColor = isDark
        ? Colors.white.withValues(alpha: 0.18)
        : Colors.black.withValues(alpha: 0.12);

    return AnimatedBuilder(
      animation: _shimmer,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(_shimmer.value - 1, 0),
              end: Alignment(_shimmer.value + 1, 0),
              colors: [baseColor, highlightColor, baseColor],
            ),
          ),
        );
      },
    );
  }
}

// ==================== Shimmer Card — สำหรับ list items ====================
class ShimmerCard extends StatelessWidget {
  final double height;
  final bool hasAvatar;

  const ShimmerCard({super.key, this.height = 72, this.hasAvatar = true});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: height,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          if (hasAvatar) ...[
            ShimmerLoading(width: 40, height: 40, borderRadius: 20),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShimmerLoading(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 7,
                ),
                const SizedBox(height: 8),
                ShimmerLoading(
                  width: 120,
                  height: 10,
                  borderRadius: 5,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          ShimmerLoading(width: 40, height: 28, borderRadius: 8),
        ],
      ),
    );
  }
}

// ==================== Shimmer List — หลายๆ card รวมกัน ====================
class ShimmerList extends StatelessWidget {
  final int count;
  final double cardHeight;
  final bool hasAvatar;

  const ShimmerList({
    super.key,
    this.count = 5,
    this.cardHeight = 72,
    this.hasAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        count,
        (i) => ShimmerCard(height: cardHeight, hasAvatar: hasAvatar),
      ),
    );
  }
}
