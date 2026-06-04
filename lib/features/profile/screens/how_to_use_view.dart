import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';

class HowToUseView extends ConsumerWidget {
  const HowToUseView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'How to use Family Wallet',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
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
                ? [AppColors.darkBackground, const Color(0xFF14151F)]
                : [AppColors.lightBackground, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: [
              Text(
                'Welcome to Family Wallet! Here is a simple guide to help you get started with managing your family finances.',
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 24),
              _buildStepCard(
                context: context,
                icon: Icons.group_add_rounded,
                color: AppColors.primaryCyan,
                title: '1. Create or Join a Workspace',
                description:
                    'When you first sign in, you can either create a new Family Workspace or join an existing one using an Invite Code. Only the person who created the workspace can see the Invite Code (in the Dashboard tab).',
              ),
              _buildStepCard(
                context: context,
                icon: Icons.add_card_rounded,
                color: AppColors.success,
                title: '2. Add Contributions (Income)',
                description:
                    'Tap the "+" button at the bottom and select "Add Contribution". Use this when a family member deposits money into the shared wallet (like monthly budget pooling).',
              ),
              _buildStepCard(
                context: context,
                icon: Icons.money_off_rounded,
                color: AppColors.error,
                title: '3. Log Expenses (Spendings)',
                description:
                    'Tap the "+" button and select "Add Expense". Use this when money is spent from the shared wallet (e.g., Grocery, Rent). It will automatically deduct from your remaining balance.',
              ),
              _buildStepCard(
                context: context,
                icon: Icons.pie_chart_rounded,
                color: AppColors.primaryPurple,
                title: '4. View Reports & AI Insights',
                description:
                    'Go to the "Reports" tab to see a beautiful Pie Chart of your spending categories. You will also get smart AI insights on your spending habits and warnings if you are overspending!',
              ),
              _buildStepCard(
                context: context,
                icon: Icons.admin_panel_settings_rounded,
                color: Colors.orange,
                title: '5. Admin Features',
                description:
                    'If you are the Admin (the one who created the workspace), you can go to the Profile tab to manage members, remove them, or upgrade to Premium for PDF exports.',
              ),
              const SizedBox(height: 32),
              Center(
                child: Text(
                  'Need more help? Contact Support.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Center(
                child: TextButton.icon(
                  onPressed: () async {
                    final Uri phoneUri = Uri(scheme: 'tel', path: '+917303224509');
                    if (await canLaunchUrl(phoneUri)) {
                      await launchUrl(phoneUri);
                    }
                  },
                  icon: const Icon(Icons.call_rounded, size: 16, color: AppColors.primaryCyan),
                  label: Text(
                    '+91 7303224509',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryCyan,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepCard({
    required BuildContext context,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: GlassCard(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
