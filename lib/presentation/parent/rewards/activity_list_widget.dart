// ==================== Activity List Widget ====================
// แสดงรายการประวัติแต้ม (earn / redeem) ของวันที่เลือกใน Calendar
// แยกออกมาจาก parent_rewards_screen.dart เพื่อลดขนาดไฟล์
import 'package:flutter/material.dart';
import 'package:kidguard/l10n/app_localizations.dart';
import '../../../core/utils/responsive_helper.dart';

class ActivityListWidget extends StatelessWidget {
  final List<Map<String, dynamic>> events;

  const ActivityListWidget({required this.events, super.key});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);

    if (events.isEmpty) {
      return Container(
        padding: EdgeInsets.all(r.wp(24)),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r.radius(16)),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              Icons.event_note_rounded,
              size: r.iconSize(40),
              color: Colors.grey[300],
            ),
            SizedBox(height: r.hp(12)),
            Text(
              AppLocalizations.of(context)!.noActivity,
              style: TextStyle(color: Colors.grey[500], fontSize: r.sp(14)),
            ),
          ],
        ),
      );
    }

    return Column(
      children: events.map((event) {
        return _ActivityItem(event: event);
      }).toList(),
    );
  }
}

/// แถวรายการแต้มแต่ละรายการ
class _ActivityItem extends StatelessWidget {
  final Map<String, dynamic> event;

  const _ActivityItem({required this.event});

  @override
  Widget build(BuildContext context) {
    final r = ResponsiveHelper.of(context);
    final isEarn = event['type'] == 'earn';

    return Container(
      margin: EdgeInsets.only(bottom: r.hp(8)),
      padding: EdgeInsets.all(r.wp(14)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(r.radius(14)),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          // Icon badge
          Container(
            padding: EdgeInsets.all(r.wp(10)),
            decoration: BoxDecoration(
              color: isEarn
                  ? const Color(0xFF10B981).withValues(alpha: 0.1)
                  : Colors.orange.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(r.radius(12)),
            ),
            child: Icon(
              isEarn ? Icons.add_rounded : Icons.remove_rounded,
              color: isEarn ? const Color(0xFF10B981) : Colors.orange,
              size: r.iconSize(20),
            ),
          ),
          SizedBox(width: r.wp(14)),
          // Reason text
          Expanded(
            child: Text(
              event['reason'] as String? ?? '',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: r.sp(14),
              ),
            ),
          ),
          // Points amount
          Text(
            '${isEarn ? '+' : '-'}${event['amount']}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: r.sp(16),
              color: isEarn ? const Color(0xFF10B981) : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}
