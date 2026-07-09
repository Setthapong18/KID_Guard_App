// ==================== Reward Card Widget ====================
// แสดง Card รางวัลแบบ horizontal scroll (ทั้ง Default และ Custom Rewards)
// แยกออกมาจาก parent_rewards_screen.dart เพื่อลดขนาดไฟล์
import 'package:flutter/material.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../data/models/reward_model.dart';

/// Reward Card ใช้แสดงรางวัลแต่ละรายการ
/// - canAfford: ถ้า points ไม่พอ จะแสดงเป็น greyed out
/// - isCustom: ถ้าเป็น custom reward จะ enable long-press menu
class RewardCard extends StatelessWidget {
  final Map<String, dynamic> reward;
  final int currentPoints;
  final bool isCustom;
  final void Function(Map<String, dynamic> reward) onRedeem;
  final void Function(RewardModel reward)? onLongPress;

  const RewardCard({
    required this.reward,
    required this.currentPoints,
    required this.isCustom,
    required this.onRedeem,
    this.onLongPress,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);
    final canAfford = currentPoints >= (reward['cost'] as int);

    return GestureDetector(
      onTap: () => onRedeem(reward),
      onLongPress: isCustom && reward['model'] != null
          ? () => onLongPress?.call(reward['model'] as RewardModel)
          : null,
      child: Container(
        width: r.wp(100),
        padding: EdgeInsets.symmetric(horizontal: r.wp(8), vertical: r.hp(8)),
        decoration: BoxDecoration(
          color: canAfford ? Colors.white : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(r.radius(16)),
          border: Border.all(
            color: canAfford
                ? isCustom
                      ? const Color(0xFF6B9080).withValues(alpha: 0.5)
                      : const Color(0xFF6B9080).withValues(alpha: 0.3)
                : Colors.grey.shade200,
          ),
          boxShadow: isCustom
              ? [
                  BoxShadow(
                    color: const Color(0xFF6B9080).withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  reward['emoji'] as String,
                  style: TextStyle(
                    fontSize: r.sp(28),
                    color: canAfford ? null : Colors.grey,
                  ),
                ),
              ),
            ),
            SizedBox(height: r.hp(4)),
            Text(
              reward['name'] as String,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: r.sp(11),
                color: canAfford ? Colors.black87 : Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: r.hp(3)),
            // Cost badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.wp(8),
                vertical: r.hp(2),
              ),
              decoration: BoxDecoration(
                color: canAfford
                    ? const Color(0xFF6B9080).withValues(alpha: 0.1)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(r.radius(8)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.star_rounded,
                    size: r.iconSize(12),
                    color: canAfford ? const Color(0xFF6B9080) : Colors.grey,
                  ),
                  SizedBox(width: r.wp(2)),
                  Text(
                    '${reward['cost']}',
                    style: TextStyle(
                      fontSize: r.sp(11),
                      fontWeight: FontWeight.bold,
                      color: canAfford ? const Color(0xFF6B9080) : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
