import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../controllers/profile_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/localization/translations.dart';
import '../../expenses/controllers/expense_controller.dart';
import '../../contributions/controllers/contribution_controller.dart';
import 'how_to_use_view.dart';

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key});

  @override
  Widget build(final BuildContext context, final WidgetRef ref) {
    final profileState = ref.watch(profileControllerProvider);
    final authState = ref.watch(authControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final family = profileState.family;
    final user = authState.user;

    return Scaffold(
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // PAGE HEADER
                Text(
                  context.tr('profileWorkspace', ref),
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  context.tr('manageWorkspace', ref),
                  style: TextStyle(color: Colors.grey[500], fontSize: 13),
                ),
                const SizedBox(height: 24),

                // USER PROFILE HEADER CARD
                GlassCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: AppColors.primaryBlue.withValues(alpha: 0.2),
                        backgroundImage: user?.avatarUrl != null
                            ? NetworkImage(user!.avatarUrl!)
                            : null,
                        child: user?.avatarUrl == null
                            ? const Icon(Icons.person_rounded, size: 40, color: AppColors.primaryBlue)
                            : null,
                      ),
                      const SizedBox(width: 20),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Demo',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            user?.email ?? 'demo@familywallet.com',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryCyan.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              profileState.members.any((m) => m.userId == authState.user?.id && m.role == 'admin')
                                  ? 'WORKSPACE OWNER'
                                  : 'WORKSPACE MEMBER',
                              style: const TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primaryCyan,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // WORKSPACE CREATION OR JOINING (SaaS MULTI-TENANCY)
                Text(
                  context.tr('multiFamilyWorkspaces', ref),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                if (family == null)
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          context.tr('notInFamilyPrompt', ref),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          text: context.tr('createFamilyWorkspace', ref),
                          onPressed: () {
                            _showCreateFamilyDialog(context, ref);
                          },
                        ),
                        const SizedBox(height: 12),
                        OutlinedButton(
                          onPressed: () {
                            _showJoinFamilyDialog(context, ref);
                          },
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(context.tr('joinWorkspaceInvite', ref)),
                        ),
                      ],
                    ),
                  )
                else ...[
                  // INVITE SHARING CARD
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              context.tr('inviteMembers', ref),
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(
                              Icons.share_rounded,
                              color: AppColors.primaryCyan,
                              size: 20,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          context.tr('shareCodeDesc', ref),
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 11,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 14,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.black26,
                                  border: Border.all(
                                    color: AppColors.darkBorder,
                                  ),
                                ),
                                child: Text(
                                  family.inviteCode,
                                  textAlign: TextAlign.center,
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryCyan,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton(
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(text: family.inviteCode),
                                );
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(context.tr('copied', ref)),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.copy_rounded,
                                color: AppColors.primaryCyan,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // WORKSPACE MEMBERS LIST
                  Text(
                    '${context.tr('activeFamilyMembers', ref)} (${profileState.members.length})',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ...profileState.members.map(
                    (member) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.04),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: AppColors.primaryBlue
                                    .withValues(alpha: 0.2),
                                child: Text(
                                  member.userDetails?.displayName
                                          .substring(0, 1)
                                          .toUpperCase() ??
                                      'F',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.userDetails?.displayName ??
                                        'Brother Ahmad',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    member.userDetails?.email ??
                                        'brother@gmail.com',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: _getRoleColor(
                                    member.role,
                                  ).withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  member.role.toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.bold,
                                    color: _getRoleColor(member.role),
                                  ),
                                ),
                              ),
                              if (profileState.members.any(
                                    (m) =>
                                        m.userId == authState.user?.id &&
                                        m.role == 'admin',
                                  ) &&
                                  member.userId != authState.user?.id) ...[
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                  padding: EdgeInsets.zero,
                                  constraints: const BoxConstraints(),
                                  onPressed: () {
                                    ref
                                        .read(
                                          profileControllerProvider.notifier,
                                        )
                                        .removeMember(member.userId);
                                  },
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // THEME AND SYSTEM CONTROLS
                Text(
                  context.tr('profileSettings', ref),
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GlassCard(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.dark_mode_outlined, size: 20),
                              const SizedBox(width: 12),
                              Text(context.tr('themeMode', ref)),
                            ],
                          ),
                          Switch(
                            value: profileState.isDarkMode,
                            activeThumbColor: AppColors.primaryCyan,
                            onChanged: (val) {
                              ref
                                  .read(profileControllerProvider.notifier)
                                  .toggleTheme(val);
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      // APP LANGUAGE SELECTION DROPDOWN
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.translate_rounded,
                                size: 20,
                                color: AppColors.primaryCyan,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                context.tr('languageSelection', ref),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? Colors.grey[855]
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withValues(alpha: 0.2),
                              ),
                            ),
                            child: DropdownButton<String>(
                              value: profileState.language,
                              underline: const SizedBox(),
                              dropdownColor: isDark
                                  ? AppColors.darkCard
                                  : Colors.white,
                              style: TextStyle(
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: 'en',
                                  child: Text('English 🇺🇸'),
                                ),
                                DropdownMenuItem(
                                  value: 'hi',
                                  child: Text('हिन्दी 🇮🇳'),
                                ),
                              ],
                              onChanged: (val) {
                                if (val != null) {
                                  ref
                                      .read(profileControllerProvider.notifier)
                                      .changeLanguage(val);
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // HOW TO USE BUTTON
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const HowToUseView()),
                    );
                  },
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.help_outline_rounded,
                              size: 22,
                              color: AppColors.primaryPurple,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'How to use this app',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // LOGOUT BUTTON
                PrimaryButton(
                  text: context.tr('logout', ref),
                  gradientColors: const [Color(0xFFE11D48), Color(0xFFBE123C)],
                  icon: Icons.logout_rounded,
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (context.mounted) context.go('/login');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'admin':
        return AppColors.primaryCyan;
      case 'manager':
        return AppColors.primaryPurple;
      case 'member':
        return AppColors.primaryBlue;
      case 'viewer':
      default:
        return Colors.grey;
    }
  }

  void _showCreateFamilyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(context.tr('createFamilyWorkspace', ref)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'e.g. Demo Family, Apex Ledger',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('cancel', ref)),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = controller.text.trim();
                if (name.isNotEmpty) {
                  Navigator.pop(ctx);
                  final user = ref.read(authControllerProvider).user;
                  if (user != null) {
                    await ref
                        .read(profileControllerProvider.notifier)
                        .createFamilyWorkspace(name, user.id, user.displayName);
                    ref.invalidate(expenseControllerProvider);
                    ref.invalidate(contributionControllerProvider);
                  }
                }
              },
              child: Text(context.tr('createFamilyWorkspace', ref)),
            ),
          ],
        );
      },
    );
  }

  void _showJoinFamilyDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(context.tr('joinWorkspaceInvite', ref)),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              hintText: 'Enter 7-character invite code',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(context.tr('cancel', ref)),
            ),
            ElevatedButton(
              onPressed: () async {
                final code = controller.text.trim();
                if (code.isNotEmpty) {
                  Navigator.pop(ctx);
                  final user = ref.read(authControllerProvider).user;
                  if (user != null) {
                    final success = await ref
                        .read(profileControllerProvider.notifier)
                        .joinFamilyWorkspace(code, user.id, user.displayName);
                    if (!context.mounted) return;
                    if (success) {
                      ref.invalidate(expenseControllerProvider);
                      ref.invalidate(contributionControllerProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(context.tr('upgradeSuccess', ref)),
                          backgroundColor: AppColors.success,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Failed to join workspace. Check code.',
                          ),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  }
                }
              },
              child: Text(context.tr('joinWorkspaceInvite', ref)),
            ),
          ],
        );
      },
    );
  }
}
