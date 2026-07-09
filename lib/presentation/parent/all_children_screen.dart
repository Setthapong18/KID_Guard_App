import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../logic/providers/auth_provider.dart';
import '../../data/models/child_model.dart';
import 'child_setup_screen.dart';
import '../../core/utils/responsive_helper.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/shimmer_loading.dart';

class AllChildrenScreen extends StatelessWidget {
  const AllChildrenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final colorScheme = Theme.of(context).colorScheme;
    final r = ResponsiveHelper.of(context);

    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text('โปรไฟล์ลูก', style: TextStyle(fontSize: r.sp(18))),
        centerTitle: true,
        backgroundColor: colorScheme.surface,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const ChildSetupScreen()),
        ),
        label: Text('เพิ่มลูก', style: TextStyle(fontSize: r.sp(14))),
        icon: Icon(Icons.add_rounded, size: r.iconSize(20)),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('children')
            .snapshots(),
        builder: (context, snapshot) {
          // Loading state — shimmer
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.all(r.wp(20)),
              child: const ShimmerList(count: 4, cardHeight: 80),
            );
          }

          // Empty state
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return EmptyStateWidget(
              icon: Icons.child_friendly_rounded,
              title: 'ยังไม่มีโปรไฟล์ลูก',
              subtitle: 'เพิ่มโปรไฟล์ลูกเพื่อเริ่มใช้งาน\nKid Guard ได้เลย',
              actionLabel: 'เพิ่มลูกคนแรก',
              onAction: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChildSetupScreen()),
              ),
            );
          }

          final children = snapshot.data!.docs
              .map(
                (doc) => ChildModel.fromMap(
                  doc.data()! as Map<String, dynamic>,
                  doc.id,
                ),
              )
              .toList();

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(
              r.wp(20),
              r.hp(20),
              r.wp(20),
              r.hp(100), // room for FAB
            ),
            itemCount: children.length,
            separatorBuilder: (_, _) => SizedBox(height: r.hp(12)),
            itemBuilder: (context, index) {
              return _buildChildCard(context, children[index], colorScheme);
            },
          );
        },
      ),
    );
  }

  Widget _buildChildCard(
    BuildContext context,
    ChildModel child,
    ColorScheme colorScheme,
  ) {
    final r = ResponsiveHelper.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(r.wp(16)),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(r.radius(20)),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: r.wp(56),
            height: r.wp(56),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: child.avatar != null
                ? ClipOval(
                    child: Image.asset(child.avatar!, fit: BoxFit.cover),
                  )
                : Icon(
                    Icons.person_rounded,
                    color: colorScheme.primary,
                    size: r.iconSize(28),
                  ),
          ),
          SizedBox(width: r.wp(14)),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  child.name,
                  style: TextStyle(
                    fontSize: r.sp(16),
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: r.hp(3)),
                Text(
                  '${child.age} ปี • '
                  '${child.dailyTimeLimit == 0 ? "ไม่จำกัดเวลา" : "${(child.dailyTimeLimit / 3600).toStringAsFixed(1)} ชม./วัน"}',
                  style: TextStyle(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontSize: r.sp(13),
                  ),
                ),
              ],
            ),
          ),
          // Status badge
          if (child.isChildModeActive)
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: r.wp(8),
                vertical: r.hp(4),
              ),
              decoration: BoxDecoration(
                color: Colors.green.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(r.radius(20)),
              ),
              child: Text(
                'Active',
                style: TextStyle(
                  fontSize: r.sp(11),
                  fontWeight: FontWeight.w600,
                  color: Colors.green.shade600,
                ),
              ),
            ),
          SizedBox(width: r.wp(8)),
          // Edit Button
          IconButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChildSetupScreen(child: child),
              ),
            ),
            icon: Container(
              padding: EdgeInsets.all(r.wp(8)),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(r.radius(12)),
              ),
              child: Icon(
                Icons.edit_rounded,
                size: r.iconSize(18),
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
