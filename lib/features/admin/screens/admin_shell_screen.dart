import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import 'admin_dashboard_view.dart';
import 'admin_families_view.dart';
import 'admin_users_view.dart';
import 'admin_settings_view.dart';
import '../controllers/admin_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/widgets/custom_app_bar.dart';

class AdminShellScreen extends ConsumerStatefulWidget {
  const AdminShellScreen({super.key});

  @override
  ConsumerState<AdminShellScreen> createState() => _AdminShellScreenState();
}

class _AdminShellScreenState extends ConsumerState<AdminShellScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages =  [
    AdminDashboardView(),
    AdminFamiliesView(),
    AdminUsersView(),
    AdminSettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(authControllerProvider).user;

    // Trigger data fetch if we switch tabs so it stays fresh
    ref.listen(adminControllerProvider, (prev, next) {});

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Super Admin',
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: AppColors.primaryCyan.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.primaryCyan.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Text(
                  user?.displayName ?? "Sadik Ali",
                  style: TextStyle(
                    color: AppColors.primaryCyan,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkBackground, Color(0xFF14151F)]
                : [AppColors.lightBackground, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: IndexedStack(index: _currentIndex, children: _pages),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Refresh stats when tapping a tab to keep data live
          if (index == 0 || index == 1 || index == 2) {
            ref.read(adminControllerProvider.notifier).fetchStats();
          }
        },
        type: BottomNavigationBarType.fixed,
        items:  [
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Icon(Icons.bar_chart_rounded),
            label: 'Metrics',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.maps_home_work_outlined),
            activeIcon: Icon(Icons.maps_home_work_rounded),
            label: 'Families',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline_rounded),
            activeIcon: Icon(Icons.people_rounded),
            label: 'Users',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings_rounded),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
