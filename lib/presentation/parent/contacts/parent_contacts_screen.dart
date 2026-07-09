import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/contact_model.dart';
import '../../../data/services/contact_service.dart';
import '../../../logic/providers/auth_provider.dart';
import '../../../core/utils/responsive_helper.dart';
import '../../../core/widgets/empty_state_widget.dart';
import '../../../core/widgets/shimmer_loading.dart';

class ParentContactsScreen extends StatelessWidget {
  const ParentContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.userModel;
    final r = ResponsiveHelper.of(context);
    final childId = authProvider.children.isNotEmpty
        ? authProvider.children.first.id
        : null;

    if (user == null || childId == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Contacts', style: TextStyle(fontSize: r.sp(18))),
        ),
        body: Center(
          child: Text(
            'No child selected',
            style: TextStyle(fontSize: r.sp(14)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Child Contacts', style: TextStyle(fontSize: r.sp(18))),
      ),
      body: StreamBuilder<List<ContactModel>>(
        stream: ContactService().streamContacts(user.uid, childId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Padding(
              padding: EdgeInsets.all(r.wp(20)),
              child: const ShimmerList(count: 6),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(fontSize: r.sp(14)),
              ),
            );
          }

          final contacts = snapshot.data ?? [];

          if (contacts.isEmpty) {
            return const EmptyStateWidget(
              icon: Icons.contacts_rounded,
              title: 'ยังไม่มีรายชื่อเพื่อน',
              subtitle: 'ข้อมูลรายชื่อเพื่อนจะซิงค์อัตโนมัติ\nเมื่อแอปฝั่งเด็กทำงานอยู่',
            );
          }

          return ListView.builder(
            padding: EdgeInsets.symmetric(vertical: r.hp(8)),
            itemCount: contacts.length,
            itemBuilder: (context, index) {
              final contact = contacts[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  horizontal: r.wp(16),
                  vertical: r.hp(4),
                ),
                leading: CircleAvatar(
                  radius: r.wp(20),
                  child: Text(
                    contact.displayName.isNotEmpty
                        ? contact.displayName[0]
                        : '?',
                    style: TextStyle(fontSize: r.sp(16)),
                  ),
                ),
                title: Text(
                  contact.displayName,
                  style: TextStyle(fontSize: r.sp(16)),
                ),
                subtitle: Text(
                  contact.phones.join(', '),
                  style: TextStyle(fontSize: r.sp(13)),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
