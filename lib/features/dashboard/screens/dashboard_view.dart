import 'package:flutter_screenutil/flutter_screenutil.dart';
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
import '../../../core/widgets/primary_button.dart';
import '../controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/localization/translations.dart';
import '../../../core/widgets/dynamic_translated_text.dart';

class DashboardView extends ConsumerWidget {
  final VoidCallback? onAvatarTapped;
  final VoidCallback? onSeeAllTapped;

  const DashboardView({super.key, this.onAvatarTapped, this.onSeeAllTapped});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardData = ref.watch(dashboardControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final selectedMonth = ref.watch(selectedMonthProvider);

    final List<String> monthNames = [
      context.tr('jan', ref),
      context.tr('feb', ref),
      context.tr('mar', ref),
      context.tr('apr', ref),
      context.tr('may', ref),
      context.tr('jun', ref),
      context.tr('jul', ref),
      context.tr('aug', ref),
      context.tr('sep', ref),
      context.tr('oct', ref),
      context.tr('nov', ref),
      context.tr('dec', ref),
    ];
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isPremium = profileState.family?.subscriptionTier == 'premium';

    final familyName = profileState.family?.name ?? 'My Family Ledger';

    return Scaffold(
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
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
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
                            'Hello, ${authState.user?.displayName ?? "Dad"}',
                            style: GoogleFonts.outfit(
                              fontSize: 14.sp,
                              color: Colors.grey[500],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            familyName,
                            style: GoogleFonts.outfit(
                              fontSize: 16.sp,
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
                                  ? Icon(
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
                  SizedBox(height: 16.h),

                  // MONTH SELECTOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.chevron_left_rounded),
                        onPressed: () {
                          final prev = DateTime(
                            selectedMonth.year,
                            selectedMonth.month - 1,
                          );
                          ref.read(selectedMonthProvider.notifier).state = prev;
                        },
                      ),
                      InkWell(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (ctx) {
                              int dialogYear = selectedMonth.year;
                              int dialogMonth = selectedMonth.month;
                              return StatefulBuilder(
                                builder: (context, setState) {
                                  return Padding(
                                    padding: EdgeInsets.all(20.w),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          context.tr('selectMonthYear', ref),
                                          style: GoogleFonts.outfit(
                                            fontSize: 18.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 10.h),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                Icons
                                                    .arrow_back_ios_new_rounded,
                                              ),
                                              onPressed: () =>
                                                  setState(() => dialogYear--),
                                            ),
                                            Text(
                                              '$dialogYear',
                                              style: GoogleFonts.outfit(
                                                fontSize: 20.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                Icons.arrow_forward_ios_rounded,
                                              ),
                                              onPressed: () =>
                                                  setState(() => dialogYear++),
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 16.h),
                                        GridView.count(
                                          shrinkWrap: true,
                                          crossAxisCount: 4,
                                          mainAxisSpacing: 12,
                                          crossAxisSpacing: 12,
                                          childAspectRatio: 2.0,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          children: List.generate(12, (index) {
                                            final monthIndex = index + 1;
                                            final isSelected =
                                                monthIndex == dialogMonth;
                                            return ChoiceChip(
                                              label: SizedBox(
                                                width: double.infinity,
                                                child: Text(
                                                  monthNames[index],
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                              padding: EdgeInsets.zero,
                                              showCheckmark: false,
                                              selected: isSelected,
                                              selectedColor: AppColors
                                                  .primaryCyan
                                                  .withValues(alpha: 0.2),
                                              onSelected: (selected) {
                                                if (selected) {
                                                  setState(
                                                    () => dialogMonth =
                                                        monthIndex,
                                                  );
                                                }
                                              },
                                            );
                                          }),
                                        ),
                                        SizedBox(height: 24.h),
                                        SizedBox(
                                          width: double.infinity,
                                          child: PrimaryButton(
                                            text: context.tr('apply', ref),
                                            onPressed: () {
                                              ref
                                                  .read(
                                                    selectedMonthProvider
                                                        .notifier,
                                                  )
                                                  .state = DateTime(
                                                dialogYear,
                                                dialogMonth,
                                              );
                                              Navigator.pop(context);
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                          );
                        },
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.05)
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Row(
                            children: [
                              Text(
                                '${monthNames[selectedMonth.month - 1]} ${selectedMonth.year}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.arrow_drop_down, size: 20),
                            ],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.chevron_right_rounded),
                        onPressed: () {
                          final next = DateTime(
                            selectedMonth.year,
                            selectedMonth.month + 1,
                          );
                          ref.read(selectedMonthProvider.notifier).state = next;
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              context.tr('remainingBalance', ref),
                              style: GoogleFonts.outfit(
                                fontSize: 14.sp,
                                color: isDark
                                    ? Colors.white70
                                    : Colors.grey[600],
                              ),
                            ),
                            SizedBox(width: 4.w),
                            InkWell(
                              onTap: () {
                                context.push('/monthly-savings');
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryCyan.withValues(
                                    alpha: 0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  context.tr('history', ref),
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryCyan,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 6.h),
                        AnimatedCounter(
                          value: dashboardData.remainingBalance,
                          style: GoogleFonts.outfit(
                            fontSize: 36.sp,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Color(0xFF0F172A),
                          ),
                        ),
                        SizedBox(height: 24.h),
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
                        SizedBox(height: 16.h),
                        // CASH VS ONLINE BREAKDOWN
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.black.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.5),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.money_rounded,
                                        size: 14,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        context.tr('cashSpent', ref),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '₹${dashboardData.cashSpent.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                width: 1,
                                height: 30,
                                color: Colors.grey.withValues(alpha: 0.3),
                              ),
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.account_balance_wallet_rounded,
                                        size: 14,
                                        color: Colors.blue,
                                      ),
                                      SizedBox(width: 4.w),
                                      Text(
                                        context.tr('onlineSpent', ref),
                                        style: TextStyle(
                                          fontSize: 11.sp,
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    '₹${dashboardData.onlineSpent.toStringAsFixed(2)}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // QUICK ACTIONS HORIZONTAL SCRoll
                  Text(
                    context.tr('quickTools', ref),
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickToolItem(
                          context: context,
                          icon: Icons.psychology_rounded,
                          label: context.tr('aiChat', ref),
                          color: AppColors.primaryPurple,
                          isLocked: !isPremium,
                          onTap: () {
                            if (isPremium) {
                              context.push('/ai-chat');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'AI Assistant is a Premium feature. You are not eligible.',
                                    style: GoogleFonts.outfit(),
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
                        ),
                        _buildQuickToolItem(
                          context: context,
                          icon: Icons.document_scanner_rounded,
                          label: context.tr('scanReceipt', ref),
                          color: AppColors.primaryCyan,
                          isLocked: !isPremium,
                          onTap: () {
                            if (isPremium) {
                              context.push('/ocr-scanner');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'OCR Scan is a Premium feature. You are not eligible.',
                                    style: GoogleFonts.outfit(),
                                  ),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          },
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
                  SizedBox(height: 24.h),

                  // SPENDING CHARTS VISUALIZATION
                  Text(
                    context.tr('monthlySpendingBreakdown', ref),
                    style: GoogleFonts.outfit(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 12.h),
                  GlassCard(
                    child: dashboardData.categoryBreakdown.isEmpty
                        ? SizedBox(
                            height: 160.h,
                            child: Center(
                              child: Text(
                                'No expenses registered yet.',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                          )
                        : SizedBox(
                            height: 200.h,
                            child: Row(
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: PieChart(
                                    PieChartData(
                                      sectionsSpace: 2,
                                      centerSpaceRadius: 35,
                                      sections: _getPieChartSections(
                                        dashboardData.categoryBreakdown,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 16.w),
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
                  SizedBox(height: 24.h),

                  // RECENT ACTIVITIES TIMELINE
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        context.tr('recentActivity', ref),
                        style: GoogleFonts.outfit(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      TextButton(
                        onPressed: onSeeAllTapped,
                        child: Text(
                          context.tr('seeAll', ref),
                          style: TextStyle(
                            color: isDark
                                ? AppColors.primaryCyan
                                : AppColors.primaryBlue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  if (dashboardData.recentExpenses.isEmpty &&
                      dashboardData.recentContributions.isEmpty)
                    EmptyStateView(
                      title: 'No recent transactions',
                      description:
                          'Taps the + button to log contributions and expenses dynamically.',
                      icon: Icons.description_outlined,
                    )
                  else ...[
                    ...dashboardData.recentExpenses.map(
                      (e) => _buildRecentActivityRow(
                        context: context,
                        ref: ref,
                        title:
                            e.description ??
                            context.tr(e.category.toLowerCase(), ref),
                        subtitle: context
                            .tr('addedByTemplate', ref)
                            .replaceAll('{name}', e.addedByName)
                            .replaceAll(
                              '{category}',
                              context.tr(e.category.toLowerCase(), ref),
                            ),
                        amount: '- ₹${e.amount.toStringAsFixed(2)}',
                        color: AppColors.error,
                        icon: AppColors.getCategoryIcon(e.category),
                        paymentMethod: e.paymentMethod,
                      ),
                    ),
                    ...dashboardData.recentContributions.map(
                      (c) => _buildRecentActivityRow(
                        context: context,
                        ref: ref,
                        title: context
                            .tr('contributionTemplate', ref)
                            .replaceAll('{name}', c.contributorName),
                        subtitle: c.note ?? context.tr('sharedMoneyLog', ref),
                        amount: '+ ₹${c.amount.toStringAsFixed(2)}',
                        color: AppColors.success,
                        icon: Icons.savings_rounded,
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
            SizedBox(width: 4.w),
            Text(
              title,
              style: TextStyle(fontSize: 11.sp, color: Colors.grey),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: GoogleFonts.outfit(
            fontSize: 18.sp,
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
    bool isLocked = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 12),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark
              ? Colors.white.withValues(alpha: 0.05)
              : Colors.black.withValues(alpha: 0.02),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
        child: Opacity(
          opacity: isLocked ? 0.6 : 1.0,
          child: Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.outfit(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isLocked) ...[
                SizedBox(width: 6.w),
                Icon(
                  Icons.lock_rounded,
                  size: 14,
                  color: AppColors.primaryPink,
                ),
              ],
            ],
          ),
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
        titleStyle: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildChartLegendItem(String category, Color color) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8.w),
          Text(
            category,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityRow({
    required BuildContext context,
    required WidgetRef ref,
    required String title,
    required String subtitle,
    required String amount,
    required Color color,
    required IconData icon,
    String? paymentMethod,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16.w),
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
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: DynamicTranslatedText(
                              title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14.sp,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (paymentMethod != null)
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: paymentMethod == 'cash'
                                    ? Colors.green.withValues(alpha: 0.1)
                                    : Colors.blue.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: paymentMethod == 'cash'
                                      ? Colors.green.withValues(alpha: 0.3)
                                      : Colors.blue.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                context.tr(paymentMethod.toLowerCase(), ref).toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9.sp,
                                  fontWeight: FontWeight.bold,
                                  color: paymentMethod == 'cash'
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 4),
                      DynamicTranslatedText(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12.sp,
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
          SizedBox(width: 12.w),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.bold,
              fontSize: 15.sp,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
