// ==================== Parent Shell ====================
// โครงหน้าจอหลักของ Parent พร้อม Bottom Navigation Bar
//
// เป็น "เปลือก" ที่ครอบหน้าจอ 3 tab:
// 1. Home (ParentHomeScreen) - หน้าหลัก
// 2. Activity (ParentActivityScreen) - สถิติการใช้งาน
// 3. Settings (ParentSettingsScreen) - ตั้งค่า
//
// ใช้ IndexedStack เพื่อ keep state ของแต่ละ tab ไว้ (ไม่ rebuild ทุกครั้ง)
//
// Back button behavior:
// - ถ้าอยู่ tab อื่น → กลับไป Home
// - ถ้าอยู่ Home แล้ว → ออกจากแอพ (SystemNavigator.pop)
//   แต่ background service ยังทำงานอยู่
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../parent/parent_home_screen.dart';
import '../parent/parent_activity_screen.dart';
import '../parent/parent_settings_screen.dart';
import '../../core/utils/responsive_helper.dart';
import 'package:kidguard/l10n/app_localizations.dart';

class ParentShell extends StatefulWidget {
  const ParentShell({super.key});

  @override
  State<ParentShell> createState() => _ParentShellState();
}

class _ParentShellState extends State<ParentShell> {
  int _selectedIndex = 0;

  Future<void> _onPopInvoked(bool didPop, dynamic result) async {
    if (didPop) return;

    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;
      });
      return;
    }

    // Exit app but keep background services running
    await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final r = ResponsiveHelper.of(context);

    const screens = [
      ParentHomeScreen(),
      ParentActivityScreen(),
      ParentSettingsScreen(),
    ];

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: _onPopInvoked,
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: NavigationBar(
            elevation: 0,
            height: r.hp(70),
            backgroundColor: colorScheme.surface,
            indicatorColor: colorScheme.primaryContainer,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: [
              NavigationDestination(
                icon: Icon(
                  Icons.home_outlined,
                  size: r.iconSize(24),
                  color: Colors.grey[600],
                ),
                selectedIcon: Icon(
                  Icons.home_rounded,
                  size: r.iconSize(24),
                  color: colorScheme.primary,
                ),
                label: AppLocalizations.of(context)!.homeTab,
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.insights_outlined,
                  size: r.iconSize(24),
                  color: Colors.grey[600],
                ),
                selectedIcon: Icon(
                  Icons.insights_rounded,
                  size: r.iconSize(24),
                  color: colorScheme.primary,
                ),
                label: AppLocalizations.of(context)!.activityTab,
              ),
              NavigationDestination(
                icon: Icon(
                  Icons.settings_outlined,
                  size: r.iconSize(24),
                  color: Colors.grey[600],
                ),
                selectedIcon: Icon(
                  Icons.settings_rounded,
                  size: r.iconSize(24),
                  color: colorScheme.primary,
                ),
                label: AppLocalizations.of(context)!.settingsTab,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
