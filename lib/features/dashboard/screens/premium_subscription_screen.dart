import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../../core/localization/translations.dart';

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
          'Premium Plan',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              Icons.star_rounded,
              color: AppColors.primaryPink,
              size: 80,
            ),
            const SizedBox(height: 16),
            Text(
              'Upgrade to Premium',
              style: GoogleFonts.outfit(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock powerful features for your entire family workspace. One subscription covers everyone.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            
            // Benefits List
            _buildBenefitItem(
              icon: Icons.auto_awesome_rounded,
              title: 'AI Financial Assistant',
              desc: 'Get personalized insights and chat with AI about your spending habits.',
              color: AppColors.primaryPurple,
            ),
            _buildBenefitItem(
              icon: Icons.document_scanner_rounded,
              title: 'Unlimited Receipt Scanning',
              desc: 'Scan receipts with AI and automatically extract amounts and categories.',
              color: AppColors.primaryCyan,
            ),
            _buildBenefitItem(
              icon: Icons.pie_chart_rounded,
              title: 'Advanced Analytics & Reports',
              desc: 'Export detailed PDF/Excel reports and view advanced breakdown charts.',
              color: AppColors.primaryBlue,
            ),
            _buildBenefitItem(
              icon: Icons.family_restroom_rounded,
              title: 'Up to 10 Family Members',
              desc: 'Add extended family members with custom roles and permissions.',
              color: AppColors.success,
            ),
            
            const SizedBox(height: 40),
            
            // Pricing Box
            Container(
              padding: const EdgeInsets.all(24),
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
                  const Text(
                    'Yearly Plan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryPink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹500',
                        style: GoogleFonts.outfit(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(bottom: 8.0, left: 4.0),
                        child: Text('/ year', style: TextStyle(color: Colors.grey)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            PrimaryButton(
              text: 'Subscribe Now',
              isLoading: _isProcessing,
              onPressed: () async {
                setState(() => _isProcessing = true);
                
                // Simulate payment gateway delay
                await Future.delayed(const Duration(seconds: 2));
                
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
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.pop(),
              child: const Text('Maybe Later', style: TextStyle(color: Colors.grey)),
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
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
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
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 13,
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
