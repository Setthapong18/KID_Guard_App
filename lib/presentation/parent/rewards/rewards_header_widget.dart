// ==================== Rewards Points Header Widget ====================
// แสดง Avatar เด็ก + แต้มสะสม + Animated counter
// แยกออกมาจาก parent_rewards_screen.dart เพื่อลดขนาดไฟล์
import 'package:flutter/material.dart';
import 'package:kidguard/l10n/app_localizations.dart';
import '../../../data/models/child_model.dart';
import '../../../core/utils/responsive_helper.dart';

class RewardsHeaderWidget extends StatelessWidget {
  final ChildModel child;
  final int currentPoints;

  const RewardsHeaderWidget({
    required this.child,
    required this.currentPoints,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6B9080), Color(0xFF84A98C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: r.wp(16)),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: constraints.maxWidth - r.wp(32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(height: r.hp(16)),
                      // Child Avatar
                      CircleAvatar(
                        radius: r.wp(30),
                        backgroundColor: Colors.white.withValues(alpha: 0.2),
                        backgroundImage: child.avatar != null
                            ? AssetImage(child.avatar!)
                            : null,
                        child: child.avatar == null
                            ? Text(
                                child.name[0],
                                style: TextStyle(
                                  fontSize: r.sp(24),
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(height: r.hp(8)),
                      Text(
                        child.name,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: r.sp(15),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      SizedBox(height: r.hp(4)),
                      // Points Display with Animation
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                            size: r.iconSize(28),
                          ),
                          SizedBox(width: r.wp(6)),
                          TweenAnimationBuilder<int>(
                            tween: IntTween(begin: 0, end: currentPoints),
                            duration: const Duration(milliseconds: 600),
                            builder: (context, value, _) {
                              return Text(
                                '$value',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: r.sp(42),
                                  fontWeight: FontWeight.bold,
                                ),
                              );
                            },
                          ),
                          SizedBox(width: r.wp(4)),
                          Text(
                            AppLocalizations.of(context)!.points,
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: r.sp(16),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: r.hp(8)),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
