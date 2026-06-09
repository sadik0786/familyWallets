import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/app_config_provider.dart';

class AdminSettingsView extends ConsumerWidget {
  const AdminSettingsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authControllerProvider).user;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Owner Profile',
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 24.h),
          GlassCard(
            padding: EdgeInsets.all(24.w),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: AppColors.primaryPurple.withValues(
                    alpha: 0.2,
                  ),
                  child: Icon(
                    Icons.shield_rounded,
                    color: AppColors.primaryPurple,
                    size: 32,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'App Owner',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        user?.email ?? 'admin@familywallet.com',
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 14.sp,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            'Global App Settings',
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16.h),
          Consumer(
            builder: (context, ref, child) {
              final configState = ref.watch(appConfigControllerProvider);
              return GlassCard(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Premium Price',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.sp,
                          ),
                        ),
                        if (configState.isLoading)
                          SizedBox(
                            width: 16.w,
                            height: 16.w,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    _buildPriceRow(
                      context,
                      ref,
                      configState,
                      '1 Month Plan',
                      '1_month',
                    ),
                    SizedBox(height: 12.h),
                    _buildPriceRow(
                      context,
                      ref,
                      configState,
                      '3 Months Plan',
                      '3_months',
                    ),
                    SizedBox(height: 12.h),
                    _buildPriceRow(
                      context,
                      ref,
                      configState,
                      '6 Months Plan',
                      '6_months',
                    ),
                    SizedBox(height: 12.h),
                    _buildPriceRow(
                      context,
                      ref,
                      configState,
                      '1 Year Plan',
                      '1_year',
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Changes will immediately apply to all users.',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12.sp,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: 32.h),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text(
                'Sign Out',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () =>
                  ref.read(authControllerProvider.notifier).logout(),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceRow(
    BuildContext context,
    WidgetRef ref,
    AppConfigState configState,
    String title,
    String key,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(title, style: TextStyle(fontSize: 14.sp)),
        ),
        SizedBox(width: 8.w),
        Expanded(
          flex: 3,
          child: TextFormField(
            initialValue: configState.premiumPrices[key] ?? '0',
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              prefixText: '₹ ',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
            ),
            onFieldSubmitted: (value) async {
              if (value.trim().isEmpty) return;
              final success = await ref
                  .read(appConfigControllerProvider.notifier)
                  .updatePremiumPrice(key, value.trim());
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      success
                          ? '$title updated globally.'
                          : 'Failed to update price.',
                    ),
                    backgroundColor: success
                        ? AppColors.success
                        : AppColors.error,
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }
}
