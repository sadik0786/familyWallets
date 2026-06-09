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

class PremiumSubscriptionScreen extends ConsumerStatefulWidget {
  const PremiumSubscriptionScreen({super.key});

  @override
  ConsumerState<PremiumSubscriptionScreen> createState() => _PremiumSubscriptionScreenState();
}

class _PremiumSubscriptionScreenState extends ConsumerState<PremiumSubscriptionScreen> {
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: Text(
          context.tr('premiumPlan', ref),
          style: GoogleFonts.outfit(fontSize: 20.sp, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              Icons.star_rounded,
              color: AppColors.primaryPink,
              size: 80,
            ),
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
            Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryPink.withValues(alpha: 0.1),
                    AppColors.primaryPurple.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: AppColors.primaryPink.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final config = ref.watch(appConfigControllerProvider);
                      return Text(
                        '${config.premiumDuration} Plan',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryPink,
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Consumer(
                        builder: (context, ref, child) {
                          final config = ref.watch(appConfigControllerProvider);
                          return Text(
                            '₹${config.premiumPrice}',
                            style: GoogleFonts.outfit(
                              fontSize: 40.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                      Consumer(
                        builder: (context, ref, child) {
                          final config = ref.watch(appConfigControllerProvider);
                          String durationSuffix = config.premiumDuration.toLowerCase();
                          // e.g., '1 year' -> '/ 1 year'
                          return Padding(
                            padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                            child: Text('/ $durationSuffix', style: TextStyle(color: Colors.grey)),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
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
                
                await ref.read(profileControllerProvider.notifier).upgradeSubscription();
                
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
              child: Text(context.tr('maybeLater', ref), style: TextStyle(color: Colors.grey)),
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
