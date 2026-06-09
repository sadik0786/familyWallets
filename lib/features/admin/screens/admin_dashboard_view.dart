import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/admin_controller.dart';

class AdminDashboardView extends ConsumerWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminControllerProvider);
    final currencyFormatter = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    if (adminState.isLoading) {
      return Center(child: CircularProgressIndicator());
    }

    if (adminState.errorMessage != null) {
      return Center(
        child: Text(
          adminState.errorMessage!,
          style: TextStyle(color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(20.0.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Performance',
            style: GoogleFonts.outfit(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Multi-tenant statistics across all global families',
            style: TextStyle(color: Colors.grey[500], fontSize: 13.sp),
          ),
          SizedBox(height: 24.h),

          // PERFORMANCE STATS GRID
          Row(
            children: [
              Expanded(
                child: _buildAdminMetricCard(
                  title: 'Total Users',
                  value: adminState.stats?.totalUsers.toString() ?? '0',
                  sub: 'Across all tenants',
                  color: AppColors.primaryCyan,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildAdminMetricCard(
                  title: 'Active Families',
                  value: adminState.stats?.totalFamilies.toString() ?? '0',
                  sub: 'Created workspaces',
                  color: AppColors.primaryPurple,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildAdminMetricCard(
                  title: 'Monthly Revenue',
                  value: currencyFormatter.format(
                    adminState.stats?.totalRevenue ?? 0,
                  ),
                  sub: 'Premium plans subscriptions',
                  color: AppColors.success,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: _buildAdminMetricCard(
                  title: 'Reported Issues',
                  value: '0 open',
                  sub: 'SLA priority response',
                  color: AppColors.primaryPink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminMetricCard({
    required String title,
    required String value,
    required String sub,
    required Color color,
  }) {
    return GlassCard(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Text(sub, style: TextStyle(fontSize: 10.sp, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
