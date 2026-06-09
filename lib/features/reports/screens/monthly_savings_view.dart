import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/monthly_savings_controller.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/localization/translations.dart';

class MonthlySavingsView extends ConsumerWidget {
  const MonthlySavingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savingsList = ref.watch(monthlySavingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final List<String> monthNames = [
      context.tr('jan', ref), context.tr('feb', ref), context.tr('mar', ref), 
      context.tr('apr', ref), context.tr('may', ref), context.tr('jun', ref),
      context.tr('jul', ref), context.tr('aug', ref), context.tr('sep', ref), 
      context.tr('oct', ref), context.tr('nov', ref), context.tr('dec', ref)
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('savingsHistory', ref),
          style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
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
          child: savingsList.isEmpty
              ? Center(child: Text(context.tr('noHistoryData', ref)))
              : ListView.builder(
                  padding: EdgeInsets.all(16.w),
                  itemCount: savingsList.length,
                  itemBuilder: (context, index) {
                    final item = savingsList[index];
                    final monthName = monthNames[item.date.month - 1];
                    final year = item.date.year;

                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.0),
                      child: GlassCard(
                        gradientColors: isDark
                            ? [
                                AppColors.primaryBlue.withValues(alpha: 0.1),
                                Colors.white.withValues(alpha: 0.05),
                              ]
                            : [
                                Colors.white,
                                AppColors.primaryCyan.withValues(alpha: 0.05),
                              ],
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$monthName $year',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                                  decoration: BoxDecoration(
                                    color: item.remainingBalance >= 0
                                        ? AppColors.success.withValues(alpha: 0.1)
                                        : AppColors.error.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: item.remainingBalance >= 0
                                          ? AppColors.success.withValues(alpha: 0.3)
                                          : AppColors.error.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Text(
                                    item.remainingBalance >= 0 ? context.tr('saved', ref) : context.tr('overspent', ref),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                      color: item.remainingBalance >= 0
                                          ? AppColors.success
                                          : AppColors.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('totalIn', ref),
                                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '₹${item.totalIncome.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.success,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      context.tr('totalOut', ref),
                                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '₹${item.totalExpense.toStringAsFixed(2)}',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      context.tr('balance', ref),
                                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      '₹${item.remainingBalance.toStringAsFixed(2)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold,
                                        color: isDark ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
