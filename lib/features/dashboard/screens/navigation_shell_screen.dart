import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../dashboard/screens/dashboard_view.dart';
import '../../expenses/screens/expenses_timeline_view.dart';
import '../../reports/screens/reports_view.dart';
import '../../profile/screens/profile_view.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/widgets/glass_card.dart';
import '../../expenses/screens/add_expense_view.dart';
import '../../contributions/screens/add_contribution_view.dart';
import '../../../core/localization/translations.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationShellScreen extends ConsumerStatefulWidget {
  const NavigationShellScreen({super.key});

  @override
  ConsumerState<NavigationShellScreen> createState() =>
      _NavigationShellScreenState();
}

class _NavigationShellScreenState extends ConsumerState<NavigationShellScreen> {
  int _currentIndex = 0;

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardView(
        onAvatarTapped: () {
          setState(() {
            _currentIndex = 4;
          });
        },
        onSeeAllTapped: () {
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      ExpensesTimelineView(),
      SizedBox.shrink(), // Placeholder for quick add tab
      ReportsView(),
      ProfileView(),
    ];
  }

  void _showQuickAddBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: 20),
          child: GlassCard(
            borderRadius: 32,
            padding: EdgeInsets.all(24.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                SizedBox(height: 24.h),
                Text(
                  context.tr('quickAction', ref),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.h),
                Text(
                  context.tr('selectTxTypePrompt', ref),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
                ),
                SizedBox(height: 32.h),
                Row(
                  children: [
                    // LOG CONTRIBUTION
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddContributionView(),
                            ),
                          );
                        },
                        child: _buildQuickAddCard(
                          title: context.tr('addContribution', ref),
                          subtitle: context.tr('logMoneyIn', ref),
                          icon: Icons.add_card_rounded,
                          gradient: AppColors.primaryGradient,
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    // LOG EXPENSE
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AddExpenseView(),
                            ),
                          );
                        },
                        child: _buildQuickAddCard(
                          title: context.tr('addExpense', ref),
                          subtitle: context.tr('logMoneyOut', ref),
                          icon: Icons.receipt_long_rounded,
                          gradient: AppColors.secondaryGradient,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickAddCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: EdgeInsets.all(20.w),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 32, color: Colors.white),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: TextStyle(fontSize: 11.sp, color: Colors.white70),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final isDark = profileState.isDarkMode;
    
    // Check Active Status
    final family = profileState.family;
    final user = ref.watch(authControllerProvider).user;
    final isSuperAdmin = user?.role == 'super_admin' || user?.email == 'alisadik99@gmail.com' || user?.email == 'admin@familywallet.com';

    if (family != null && !family.isActive && !isSuperAdmin) {
      return Theme(
        data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
        child: Scaffold(
          body: Container(
            width: double.infinity,
            padding: EdgeInsets.all(32.w),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [AppColors.darkBackground, Color(0xFF14151F)]
                    : [AppColors.lightBackground, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 80, color: AppColors.error),
                SizedBox(height: 24.h),
                Text(
                  'Workspace Suspended',
                  style: GoogleFonts.outfit(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  'Your family workspace subscription has expired or been suspended by the App Owner. Please renew your ₹500 yearly charge to regain access to your ledger.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14.sp, height: 1.5),
                ),
                SizedBox(height: 48.h),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).logout();
                  },
                  icon: Icon(Icons.logout_rounded),
                  label: Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Theme(
      data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
      child: Scaffold(
        body: IndexedStack(index: _currentIndex, children: _pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              if (profileState.family == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Please create or join a family workspace first in the Profile tab.',
                      style: TextStyle(color: Colors.white),
                    ),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }
              _showQuickAddBottomSheet(context);
            } else {
              setState(() {
                _currentIndex = index;
              });
              // Refresh data automatically when tabs are opened
              if (index == 4) {
                ref.read(profileControllerProvider.notifier).loadFamilyAndMembers();
              }
            }
          },
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_outlined),
              activeIcon: Icon(Icons.dashboard_rounded),
              label: context.tr('home', ref),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long_rounded),
              label: context.tr('ledger', ref),
            ),
            BottomNavigationBarItem(
              icon: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryPurple,
                child: Icon(Icons.add, color: Colors.white),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart_rounded),
              label: context.tr('reportsTab', ref),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline_rounded),
              activeIcon: Icon(Icons.person_rounded),
              label: context.tr('profileTab', ref),
            ),
          ],
        ),
      ),
    );
  }
}
