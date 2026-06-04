import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/animated_counter.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../../core/widgets/fade_in_slide.dart';
import '../controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/localization/translations.dart';

class DashboardView extends ConsumerWidget {
  final VoidCallback? onAvatarTapped;
  
  const DashboardView({super.key, this.onAvatarTapped});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final familyName = profileState.family?.name ?? 'My Family Ledger';

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkBackground, const Color(0xFF14151F)]
                : [AppColors.lightBackground, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 16.0,
            ),
            child: FadeInSlide(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TOP PROFILE HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello, ${authState.user?.displayName ?? "Dad"} 👋',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            familyName,
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              if (authState.user?.role == 'super_admin' ||
                                  authState.user?.email ==
                                      'alisadik99@gmail.com') {
                                context.push('/admin');
                              } else {
                                if (onAvatarTapped != null) {
                                  onAvatarTapped!();
                                }
                              }
                            },
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.primaryBlue.withValues(
                                alpha: 0.2,
                              ),
                              backgroundImage: authState.user?.avatarUrl != null
                                  ? NetworkImage(authState.user!.avatarUrl!)
                                  : null,
                              child: authState.user?.avatarUrl == null
                                  ? const Icon(
                                      Icons.person_rounded,
                                      size: 24,
                                      color: AppColors.primaryBlue,
                                    )
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // GLASS BALANCES CARD
                  GlassCard(
                    gradientColors: isDark
                        ? [
                            AppColors.primaryPurple.withValues(alpha: 0.2),
                            AppColors.primaryCyan.withValues(alpha: 0.05),
                          ]
                        : [
                            AppColors.primaryBlue.withValues(alpha: 0.1),
                            Colors.white,
                          ],
                    child: Column(
                      children: [
                        Text(
                          context.tr('remainingBalance', ref),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 6),
                        AnimatedCounter(
                          value: dashboardData.remainingBalance,
                          style: GoogleFonts.outfit(
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: _buildBalanceItem(
                                title: context.tr('totalContributions', ref),
                                amount: dashboardData.totalContributions,
                                icon: Icons.arrow_downward_rounded,
                                color: AppColors.success,
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey.withValues(alpha: 0.3),
                            ),
                            Expanded(
                              child: _buildBalanceItem(
                                title: context.tr('totalExpenses', ref),
                                amount: dashboardData.totalExpenses,
                                icon: Icons.arrow_upward_rounded,
                                color: AppColors.error,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // QUICK ACTIONS HORIZONTAL SCRoll
                  Text(
                    context.tr('quickTools', ref),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickToolItem(
                          context: context,
                          icon: Icons.psychology_rounded,
                          label: context.tr('aiChat', ref),
                          color: AppColors.primaryPurple,
                          onTap: () => context.push('/ai-chat'),
                        ),
                        _buildQuickToolItem(
                          context: context,
                          icon: Icons.document_scanner_rounded,
                          label: context.tr('scanReceipt', ref),
                          color: AppColors.primaryCyan,
                          onTap: () => context.push('/ocr-scanner'),
                        ),
                        _buildQuickToolItem(
                          context: context,
                          icon: Icons.qr_code_rounded,
                          label: 'Invite Code',
                          color: AppColors.primaryBlue,
                          onTap: () {
                            if (profileState.family != null) {
                              Clipboard.setData(
                                ClipboardData(
                                  text: profileState.family!.inviteCode,
                                ),
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${context.tr('copied', ref)} (Family ID: ${profileState.family!.inviteCode})',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    context.tr('notInFamilyPrompt', ref),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        _buildQuickToolItem(
                          context: context,
                          icon: Icons.star_rounded,
                          label: context.tr('goPremium', ref),
                          color: AppColors.primaryPink,
                          onTap: () {
                            context.push('/premium');
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // SPENDING CHARTS VISUALIZATION
                  Text(
                    context.tr('monthlySpendingBreakdown', ref),
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    child: dashboardData.categoryBreakdown.isEmpty
                        ? const SizedBox(
                            height: 160,
                            child: Center(
                              child: Text(
                                'No expenses registered yet.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 200,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 4,
                                      centerSpaceRadius: 40,
                                      sections: _getPieChartSections(
                                        dashboardData.categoryBreakdown,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  flex: 2,
                                  child: SingleChildScrollView(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: dashboardData
                                          .categoryBreakdown
                                          .entries
                                          .map((e) {
                                            return _buildChartLegendItem(
                                              e.key,
                                              AppColors.getCategoryColor(e.key),
                                            );
                                          })
                                          .toList(),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),

                  // RECENT ACTIVITIES TIMELINE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('recentLedgerActivity', ref),
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          context.tr('seeAll', ref),
                          style: const TextStyle(color: AppColors.primaryCyan),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (dashboardData.recentExpenses.isEmpty &&
                      dashboardData.recentContributions.isEmpty)
                    const EmptyStateView(
                      title: 'No recent transactions',
                      description:
                          'Taps the + button to log contributions and expenses dynamically.',
                      icon: Icons.description_outlined,
                    )
                  else ...[
                    ...dashboardData.recentExpenses.map(
                      (e) => _buildRecentActivityRow(
                        title: e.description ?? e.category,
                        subtitle: 'Added by ${e.addedByName} - ${e.category}',
                        amount: '- ₹${e.amount.toStringAsFixed(2)}',
                        color: AppColors.error,
                        icon: AppColors.getCategoryIcon(e.category),
                      ),
                    ),
                    ...dashboardData.recentContributions.map(
                      (c) => _buildRecentActivityRow(
                        title: 'Contribution: ${c.contributorName}',
                        subtitle: c.note ?? 'Shared money log',
                        amount: '+ ₹${c.amount.toStringAsFixed(2)}',
                        color: AppColors.success,
                        icon: Icons.add_card_rounded,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceItem({
    required String title,
    required double amount,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              title,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickToolItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.02),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: GoogleFonts.outfit(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<PieChartSectionData> _getPieChartSections(
    Map<String, double> categoryBreakdown,
  ) {
    return categoryBreakdown.entries.map((e) {
      return PieChartSectionData(
        color: AppColors.getCategoryColor(e.key),
        value: e.value,
        title: '₹${e.value.toStringAsFixed(0)}',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildChartLegendItem(String category, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            category,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityRow({
    required String title,
    required String subtitle,
    required String amount,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey.withValues(alpha: 0.05),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 15,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
