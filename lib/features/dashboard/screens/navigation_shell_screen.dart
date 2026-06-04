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
      ),
      const ExpensesTimelineView(),
      const SizedBox.shrink(), // Placeholder for quick add tab
      const ReportsView(),
      const ProfileView(),
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
          padding: const EdgeInsets.only(bottom: 20),
          child: GlassCard(
            borderRadius: 32,
            padding: const EdgeInsets.all(24),
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
                const SizedBox(height: 24),
                Text(
                  context.tr('quickAction', ref),
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  context.tr('selectTxTypePrompt', ref),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 32),
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
                              builder: (_) => const AddContributionView(),
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
                    const SizedBox(width: 16),
                    // LOG EXPENSE
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const AddExpenseView(),
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
                const SizedBox(height: 24),
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
      padding: const EdgeInsets.all(20),
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
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
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark 
                    ? [AppColors.darkBackground, const Color(0xFF14151F)]
                    : [AppColors.lightBackground, Colors.white],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline_rounded, size: 80, color: AppColors.error),
                const SizedBox(height: 24),
                Text(
                  'Workspace Suspended',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Your family workspace subscription has expired or been suspended by the App Owner. Please renew your ₹500 yearly charge to regain access to your ledger.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[500], fontSize: 14, height: 1.5),
                ),
                const SizedBox(height: 48),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.read(authControllerProvider.notifier).logout();
                  },
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text('Sign Out'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                      style: const TextStyle(color: Colors.white),
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
              icon: const Icon(Icons.dashboard_outlined),
              activeIcon: const Icon(Icons.dashboard_rounded),
              label: context.tr('home', ref),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.receipt_long_outlined),
              activeIcon: const Icon(Icons.receipt_long_rounded),
              label: context.tr('ledger', ref),
            ),
            const BottomNavigationBarItem(
              icon: CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.primaryPurple,
                child: Icon(Icons.add, color: Colors.white),
              ),
              label: '',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.bar_chart_outlined),
              activeIcon: const Icon(Icons.bar_chart_rounded),
              label: context.tr('reportsTab', ref),
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.person_outline_rounded),
              activeIcon: const Icon(Icons.person_rounded),
              label: context.tr('profileTab', ref),
            ),
          ],
        ),
      ),
    );
  }
}
