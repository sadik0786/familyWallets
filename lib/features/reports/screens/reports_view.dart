import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../expenses/controllers/expense_controller.dart';
import '../../contributions/controllers/contribution_controller.dart';
import '../../../services/ai_insights_service.dart';
import '../../../services/pdf_service.dart';
import '../../../core/localization/translations.dart';
import '../../../core/widgets/fade_in_slide.dart';

class ReportsView extends ConsumerStatefulWidget {
  const ReportsView({super.key});

  @override
  ConsumerState<ReportsView> createState() => _ReportsViewState();
}

class _ReportsViewState extends ConsumerState<ReportsView> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final dashboardData = ref.watch(dashboardControllerProvider);
    final profileState = ref.watch(profileControllerProvider);
    final conState = ref.watch(contributionControllerProvider);
    final expState = ref.watch(expenseControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final familyName = profileState.family?.name ?? 'Demo Household';
    final subscriptionTier = profileState.family?.subscriptionTier ?? 'free';
    final selectedMonth = ref.watch(selectedMonthProvider);

    final monthNames = [
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
    final selectedMonthName = monthNames[selectedMonth.month - 1];
    final formattedMonthYear = '$selectedMonthName ${selectedMonth.year}';

    // Group expenses by category
    final categoryTotals = <String, double>{};
    for (final exp in expState.expenses) {
      categoryTotals[exp.category] =
          (categoryTotals[exp.category] ?? 0) + exp.amount;
    }

    // Sort categories by amount (descending)
    final sortedCategories = categoryTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Colors for pie chart
    final List<Color> pieColors = [
      AppColors.primaryPurple,
      AppColors.primaryCyan,
      AppColors.primaryBlue,
      AppColors.primaryPink,
      Colors.orange,
      Colors.teal,
    ];

    // AI Insights
    final aiService = AiInsightsService();
    final aiReport = aiService.generateInsights(
      familyName: familyName,
      totalContributions: dashboardData.totalContributions,
      totalExpenses: dashboardData.totalExpenses,
      expenses: expState.expenses,
      locale: profileState.language,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('reportsTitle', ref),
          style: GoogleFonts.outfit(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
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
        child: SafeArea(
          child: expState.expenses.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.insert_chart_outlined,
                        size: 80,
                        color: Colors.grey.withValues(alpha: 0.3),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No data to generate reports.',
                        style: TextStyle(color: Colors.grey[500]),
                      ),
                    ],
                  ),
                )
              : FadeInSlide(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.all(20.0.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // SUMMARY WIDGETS
                        Row(
                          children: [
                            Expanded(
                              child: _buildSummaryCard(
                                title: context.tr('totalSpend', ref),
                                amount:
                                    '₹${dashboardData.totalExpenses.toStringAsFixed(0)}',
                                icon: Icons.arrow_upward_rounded,
                                color: AppColors.error,
                                isDark: isDark,
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: _buildSummaryCard(
                                title: context.tr('remaining', ref),
                                amount:
                                    '₹${dashboardData.remainingBalance.toStringAsFixed(0)}',
                                icon: Icons.account_balance_wallet_rounded,
                                color: AppColors.success,
                                isDark: isDark,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 32.h),

                        // PIE CHART SECTION
                        Text(
                          context.tr('categoryBreakdown', ref),
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GlassCard(
                          child: Column(
                            children: [
                              SizedBox(height: 220.h,
                                child: PieChart(
                                  PieChartData(
                                    pieTouchData: PieTouchData(
                                      touchCallback:
                                          (
                                            FlTouchEvent event,
                                            pieTouchResponse,
                                          ) {
                                            setState(() {
                                              if (!event
                                                      .isInterestedForInteractions ||
                                                  pieTouchResponse == null ||
                                                  pieTouchResponse
                                                          .touchedSection ==
                                                      null) {
                                                _touchedIndex = -1;
                                                return;
                                              }
                                              _touchedIndex = pieTouchResponse
                                                  .touchedSection!
                                                  .touchedSectionIndex;
                                            });
                                          },
                                    ),
                                    borderData: FlBorderData(show: false),
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 50,
                                    sections: List.generate(
                                      sortedCategories.length,
                                      (i) {
                                        final isTouched = i == _touchedIndex;
                                        final radius = isTouched ? 60.0 : 50.0;
                                        final item = sortedCategories[i];
                                        final color =
                                            pieColors[i % pieColors.length];
                                        final percentage =
                                            (item.value /
                                                dashboardData.totalExpenses) *
                                            100;

                                        return PieChartSectionData(
                                          color: color,
                                          value: item.value,
                                          title: percentage > 5
                                              ? '${percentage.toStringAsFixed(0)}%'
                                              : '',
                                          radius: radius,
                                          titleStyle: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: 24.h),
                              // Legend
                              Wrap(
                                spacing: 16,
                                runSpacing: 12,
                                alignment: WrapAlignment.center,
                                children: List.generate(sortedCategories.length, (
                                  i,
                                ) {
                                  final item = sortedCategories[i];
                                  final color = pieColors[i % pieColors.length];
                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Container(
                                        width: 12,
                                        height: 12,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: color,
                                        ),
                                      ),
                                      SizedBox(width: 6.w),
                                      Text(
                                        '${context.tr(item.key.toLowerCase(), ref)} (₹${item.value.toStringAsFixed(0)})',
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                          fontWeight: i == _touchedIndex
                                              ? FontWeight.bold
                                              : FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // AI INSIGHTS BLOCK
                        Text(
                          context.tr('aiRecommendations', ref),
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GlassCard(
                          gradientColors: isDark
                              ? [
                                  AppColors.primaryPurple.withValues(
                                    alpha: 0.1,
                                  ),
                                  Colors.transparent,
                                ]
                              : [
                                  AppColors.primaryBlue.withValues(alpha: 0.05),
                                  Colors.white,
                                ],
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.psychology_rounded,
                                    color: AppColors.primaryCyan,
                                    size: 28,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      aiReport.title,
                                      style: GoogleFonts.outfit(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.primaryCyan,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              Text(
                                aiReport.content,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  height: 1.6,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              if (aiReport.warnings.isNotEmpty) ...[
                                Text(
                                  context.tr('warningsLabel', ref),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: AppColors.primaryPink,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                ...aiReport.warnings.map(
                                  (w) => Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.warning_amber_rounded,
                                          size: 16,
                                          color: AppColors.primaryPink,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            w,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(height: 16.h),
                              ],
                              if (aiReport.actionItems.isNotEmpty) ...[
                                Text(
                                  context.tr('recActionsLabel', ref),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
                                    color: AppColors.success,
                                  ),
                                ),
                                SizedBox(height: 8.h),
                                ...aiReport.actionItems.map(
                                  (a) => Padding(
                                    padding: EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_circle_outline_rounded,
                                          size: 16,
                                          color: AppColors.success,
                                        ),
                                        SizedBox(width: 8.w),
                                        Expanded(
                                          child: Text(
                                            a,
                                            style: TextStyle(
                                              fontSize: 13.sp,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        SizedBox(height: 32.h),

                        // PDF EXPORT
                        Text(
                          'Export Data',
                          style: GoogleFonts.outfit(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        GlassCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    context.tr('exportLog', ref),
                                    style: GoogleFonts.outfit(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: subscriptionTier == 'premium'
                                          ? AppColors.success.withValues(
                                              alpha: 0.2,
                                            )
                                          : Colors.grey.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      subscriptionTier == 'premium'
                                          ? context.tr('premiumUnlocked', ref)
                                          : context.tr('freePlan', ref),
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.bold,
                                        color: subscriptionTier == 'premium'
                                            ? AppColors.success
                                            : Colors.grey[400],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                context.tr('exportDesc', ref),
                                style: TextStyle(
                                  color: Colors.grey[400],
                                  fontSize: 13.sp,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: 24.h),
                              PrimaryButton(
                                text: context
                                    .tr('exportPdfButton', ref)
                                    .replaceAll(
                                      '{monthYear}',
                                      formattedMonthYear,
                                    ),
                                icon: Icons.picture_as_pdf_rounded,
                                onPressed: () async {
                                  if (subscriptionTier == 'free') {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          context.tr('exportLocked', ref),
                                        ),
                                        backgroundColor: AppColors.primaryPink,
                                      ),
                                    );
                                    return;
                                  }

                                  final pdfService = PDFService();
                                  await pdfService.generateFamilyReportPDF(
                                    familyName: familyName,
                                    totalContributions:
                                        dashboardData.totalContributions,
                                    totalExpenses: dashboardData.totalExpenses,
                                    balance: dashboardData.remainingBalance,
                                    contributions: conState.contributions,
                                    expenses: expState.expenses,
                                    monthYear: formattedMonthYear,
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 40.h), // Bottom padding
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return GlassCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              SizedBox(width: 8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            amount,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
