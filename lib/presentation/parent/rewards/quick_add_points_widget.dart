// ==================== Quick Add Points Widget ====================
// แสดง Quick Buttons สำหรับเพิ่มแต้มเร็ว (การบ้าน, ทำความสะอาด, ฯลฯ)
// แยกออกมาจาก parent_rewards_screen.dart เพื่อลดขนาดไฟล์
import 'package:flutter/material.dart';
import 'package:kidguard/l10n/app_localizations.dart';
import '../../../core/utils/responsive_helper.dart';

class QuickAddPointsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> quickReasons;
  final void Function(int points, String reason) onAddPoints;

  const QuickAddPointsWidget({
    required this.quickReasons,
    required this.onAddPoints,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);

    return Padding(
      padding: EdgeInsets.fromLTRB(r.wp(20), r.hp(24), r.wp(20), r.hp(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.quickAdd,
            style: TextStyle(
              fontSize: r.sp(18),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1F2937),
            ),
          ),
          SizedBox(height: r.hp(12)),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 36) / 4;
              return IntrinsicHeight(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: quickReasons.map((item) {
                    return _QuickReasonCard(
                      emoji: item['emoji'] as String,
                      label: item['label'] as String,
                      points: item['points'] as int,
                      width: cardWidth.clamp(70.0, 90.0),
                      onTap: () => onAddPoints(
                        item['points'] as int,
                        item['label'] as String,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Card เดี่ยวสำหรับ Quick Reason
class _QuickReasonCard extends StatelessWidget {
  final String emoji;
  final String label;
  final int points;
  final double width;
  final VoidCallback onTap;

  const _QuickReasonCard({
    required this.emoji,
    required this.label,
    required this.points,
    required this.width,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        padding: EdgeInsets.symmetric(
          vertical: r.hp(10),
          horizontal: r.wp(6),
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.radius(16)),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(emoji, style: TextStyle(fontSize: r.sp(22))),
            ),
            SizedBox(height: r.hp(3)),
            Text(
              '+$points',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: const Color(0xFF10B981),
                fontSize: r.sp(13),
              ),
            ),
            SizedBox(height: r.hp(2)),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                style: TextStyle(
                  fontSize: r.sp(10),
                  color: Colors.grey[600],
                ),
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
