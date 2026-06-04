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
      return const Center(child: CircularProgressIndicator());
    }

    if (adminState.errorMessage != null) {
      return Center(
        child: Text(
          adminState.errorMessage!,
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Platform Performance',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Multi-tenant statistics across all global families',
            style: TextStyle(color: Colors.grey[500], fontSize: 13),
          ),
          const SizedBox(height: 24),

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
              const SizedBox(width: 16),
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
          const SizedBox(height: 16),
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
              const SizedBox(width: 16),
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
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(
            value,
            style: GoogleFonts.outfit(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(sub, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}
