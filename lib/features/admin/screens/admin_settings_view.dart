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

    return Padding(
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
                      SizedBox(height: 8.h),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 8.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryCyan.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: AppColors.primaryCyan.withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          'SUPER ADMIN',
                          style: TextStyle(
                            color: AppColors.primaryCyan,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
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
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue: configState.premiumPrice,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'Premium Price',
                              prefixText: '₹ ',
                              hintText: 'e.g. 500',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                            onFieldSubmitted: (value) async {
                              if (value.trim().isEmpty) return;
                              final success = await ref
                                  .read(appConfigControllerProvider.notifier)
                                  .updatePremiumPrice(value.trim());
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Premium price updated globally.'
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
                        SizedBox(width: 16.w),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: configState.premiumDuration,
                            decoration: InputDecoration(
                              labelText: 'Duration',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: '1 Month',
                                child: Text('1 Month'),
                              ),
                              DropdownMenuItem(
                                value: '3 Months',
                                child: Text('3 Months'),
                              ),
                              DropdownMenuItem(
                                value: '6 Months',
                                child: Text('6 Months'),
                              ),
                              DropdownMenuItem(
                                value: '1 Year',
                                child: Text('1 Year'),
                              ),
                            ],
                            onChanged: (value) async {
                              if (value == null) return;
                              final success = await ref
                                  .read(appConfigControllerProvider.notifier)
                                  .updatePremiumDuration(value);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      success
                                          ? 'Premium duration updated globally.'
                                          : 'Failed to update duration.',
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
              onPressed: () {
                ref.read(authControllerProvider.notifier).logout();
              },
              icon: Icon(Icons.logout_rounded, color: AppColors.error),
              label: Text('Sign Out', style: TextStyle(color: AppColors.error)),
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
}
