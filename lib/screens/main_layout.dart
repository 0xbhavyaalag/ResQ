import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../providers/app_state_provider.dart';
import 'home/home_screen.dart';
import 'scan/scan_screen.dart';
import 'software/software_safety_screen.dart';
import 'history/history_screen.dart';
import 'profile/profile_screen.dart';

class MainLayout extends StatelessWidget {
  const MainLayout({super.key});

  static final List<Widget> _screens = [
    const HomeScreen(),
    const ScanScreen(),
    const SoftwareSafetyScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      body: IndexedStack(
        index: appState.currentNavIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(
            top: BorderSide(
              color: AppTheme.strokeBlack,
              width: AppTheme.strokeWidth,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 68,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(
                  context: context,
                  index: 0,
                  icon: Icons.home_rounded,
                  label: 'HOME',
                  isSelected: appState.currentNavIndex == 0,
                ),
                _buildNavItem(
                  context: context,
                  index: 1,
                  icon: Icons.document_scanner_rounded,
                  label: 'SCAN',
                  isSelected: appState.currentNavIndex == 1,
                ),
                _buildNavItem(
                  context: context,
                  index: 2,
                  icon: Icons.shield_rounded,
                  label: 'SAFETY',
                  isSelected: appState.currentNavIndex == 2,
                ),
                _buildNavItem(
                  context: context,
                  index: 3,
                  icon: Icons.history_rounded,
                  label: 'HISTORY',
                  isSelected: appState.currentNavIndex == 3,
                ),
                _buildNavItem(
                  context: context,
                  index: 4,
                  icon: Icons.person_rounded,
                  label: 'PROFILE',
                  isSelected: appState.currentNavIndex == 4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required IconData icon,
    required String label,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        context.read<AppStateProvider>().setNavIndex(index);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: isSelected
            ? BoxDecoration(
                color: AppTheme.pastelPurple,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
              )
            : null,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 24,
              color: AppTheme.strokeBlack,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                color: AppTheme.strokeBlack,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
