import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/localization/translations.dart';
import '../../admin/controllers/app_config_provider.dart';
import '../../../core/widgets/custom_app_bar.dart';

class PremiumSubscriptionScreen extends ConsumerStatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  ConsumerState<PremiumSubscriptionScreen> createState() =>
      _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState
    extends ConsumerState<PremiumSubscriptionScreen> {
  bool _isProcessing = false;
  String _selectedPlanKey = '1_year';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: CustomAppBar(
        title: context.tr('premiumPlan', ref),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(Icons.star_rounded, color: AppColors.primaryPink, size: 80),
            SizedBox(height: 16.h),
            Text(
              context.tr('upgradePremium', ref),
              style: GoogleFonts.outfit(
                fontSize: 28.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              context.tr('premiumSubtitle', ref),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            SizedBox(height: 40.h),

            // Benefits List
            _buildBenefitItem(
              icon: Icons.auto_awesome_rounded,
              title: context.tr('aiAssistantTitle', ref),
              desc: context.tr('aiAssistantDesc', ref),
              color: AppColors.primaryPurple,
            ),
            _buildBenefitItem(
              icon: Icons.document_scanner_rounded,
              title: context.tr('unlimitedScanTitle', ref),
              desc: context.tr('unlimitedScanDesc', ref),
              color: AppColors.primaryCyan,
            ),
            _buildBenefitItem(
              icon: Icons.pie_chart_rounded,
              title: context.tr('advancedAnalyticsTitle', ref),
              desc: context.tr('advancedAnalyticsDesc', ref),
              color: AppColors.primaryBlue,
            ),
            _buildBenefitItem(
              icon: Icons.family_restroom_rounded,
              title: context.tr('upTo10FamilyTitle', ref),
              desc: context.tr('upTo10FamilyDesc', ref),
              color: AppColors.success,
            ),

            SizedBox(height: 40.h),

            // Pricing Box
            Consumer(
              builder: (context, ref, child) {
                final config = ref.watch(appConfigControllerProvider);

                final plans = [
                  {'key': '1_month', 'title': '1 Month', 'suffix': 'month'},
                  {
                    'key': '3_months',
                    'title': '3 Months',
                    'suffix': '3 months',
                  },
                  {
                    'key': '6_months',
                    'title': '6 Months',
                    'suffix': '6 months',
                  },
                  {'key': '1_year', 'title': '1 Year', 'suffix': 'year'},
                ];

                return Column(
                  children: plans.map((plan) {
                    final isSelected = _selectedPlanKey == plan['key'];
                    final price = config.premiumPrices[plan['key']] ?? '0';

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedPlanKey = plan['key'] as String;
                        });
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 12.h),
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primaryPink.withValues(alpha: 0.1)
                              : (isDark
                                    ? AppColors.darkBackground
                                    : Colors.white),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primaryPink
                                : (isDark
                                      ? Colors.grey[800]!
                                      : Colors.grey[300]!),
                            width: 2,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              plan['title'] as String,
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? AppColors.primaryPink
                                    : (isDark ? Colors.white : Colors.black),
                              ),
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '₹$price',
                                  style: GoogleFonts.outfit(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(
                                    bottom: 4.0,
                                    left: 4.0,
                                  ),
                                  child: Text(
                                    '/ ${plan['suffix']}',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),

            SizedBox(height: 32.h),

            PrimaryButton(
              text: context.tr('subscribeNow', ref),
              isLoading: _isProcessing,
              onPressed: () async {
                setState(() => _isProcessing = true);

                // Simulate payment gateway delay
                await Future.delayed(Duration(seconds: 2));

                if (!context.mounted) return;

                await ref
                    .read(profileControllerProvider.notifier)
                    .upgradeSubscription(_selectedPlanKey);

                if (!context.mounted) return;

                setState(() => _isProcessing = false);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(context.tr('upgradeSuccess', ref)),
                    backgroundColor: AppColors.success,
                  ),
                );

                context.pop(); // Go back to dashboard
              },
            ),
            SizedBox(height: 16.h),
            TextButton(
              onPressed: () => context.pop(),
              child: Text(
                context.tr('maybeLater', ref),
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBenefitItem({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13.sp,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
