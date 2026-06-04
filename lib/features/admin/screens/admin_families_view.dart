import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/admin_controller.dart';

class AdminFamiliesView extends ConsumerStatefulWidget {
  const AdminFamiliesView({super.key});

  @override
  ConsumerState<AdminFamiliesView> createState() => _AdminFamiliesViewState();
}

class _AdminFamiliesViewState extends ConsumerState<AdminFamiliesView> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final adminState = ref.watch(adminControllerProvider);

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

    final allFamilies = adminState.stats?.activeFamilies ?? [];
    final filteredFamilies = allFamilies.where((f) {
      final name = f['name']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.outfit(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search workspaces...',
                hintStyle: GoogleFonts.outfit(color: Colors.grey[500]),
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.primaryCyan,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: filteredFamilies.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.group_off_rounded,
                        size: 64,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No families found.',
                        style: GoogleFonts.outfit(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  itemCount: filteredFamilies.length,
                  itemBuilder: (context, index) {
                    final family = filteredFamilies[index];
                    final isPremium = family['plan'] == 'premium';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildTenantFeedRow(
                        name: family['name']?.toString() ?? 'Unknown Family',
                        sub: '${family['member_count']} members',
                        isPremium: isPremium,
                        isActive: family['is_active'] as bool? ?? true,
                        onToggle: (val) {
                          ref
                              .read(adminControllerProvider.notifier)
                              .toggleFamilyStatus(family['id'], val);
                        },
                        onTogglePremium: () {
                          ref
                              .read(adminControllerProvider.notifier)
                              .toggleFamilyPremium(family['id'], !isPremium);
                        },
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildTenantFeedRow({
    required String name,
    required String sub,
    required bool isPremium,
    required bool isActive,
    required ValueChanged<bool> onToggle,
    required VoidCallback onTogglePremium,
  }) {
    return Stack(
      children: [
        GlassCard(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Avatar
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryCyan.withValues(alpha: 0.2),
                      AppColors.primaryBlue.withValues(alpha: 0.2),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryCyan.withValues(alpha: 0.3),
                  ),
                ),
                child: const Icon(
                  Icons.family_restroom_rounded,
                  color: AppColors.primaryCyan,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 4,
                      children: [
                        Icon(
                          Icons.group_rounded,
                          size: 14,
                          color: Colors.grey[400],
                        ),
                        Text(
                          sub,
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            color: Colors.grey[400],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              isActive
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                              size: 14,
                              color: isActive
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isActive ? 'Active' : 'Disabled',
                              style: GoogleFonts.outfit(
                                fontSize: 13,
                                color: isActive
                                    ? AppColors.success
                                    : AppColors.error,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Actions
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Switch(
                    value: isActive,
                    onChanged: onToggle,
                    activeThumbColor: Colors.white,
                    activeTrackColor: AppColors.primaryCyan,
                    inactiveTrackColor: Colors.grey.withValues(alpha: 0.2),
                    inactiveThumbColor: Colors.grey,
                  ),
                  PopupMenuButton<String>(
                    padding: EdgeInsets.zero,
                    position: PopupMenuPosition.under,
                    icon: const Icon(
                      Icons.more_vert_rounded,
                      size: 22,
                      color: Colors.grey,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: const Color(0xFF1E1E1E), // Dark pop up
                    onSelected: (val) {
                      if (val == 'toggle_premium') {
                        onTogglePremium();
                      }
                    },
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        value: 'toggle_premium',
                        child: Row(
                          children: [
                            Icon(
                              isPremium
                                  ? Icons.remove_moderator_rounded
                                  : Icons.add_moderator_rounded,
                              color: isPremium
                                  ? AppColors.error
                                  : AppColors.success,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              isPremium ? 'Revoke PRO' : 'Upgrade to PRO',
                              style: GoogleFonts.outfit(
                                color: isPremium
                                    ? AppColors.error
                                    : AppColors.success,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        if (isPremium)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primaryPink, AppColors.primaryPurple],
                ),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryPink.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                'PRO',
                style: GoogleFonts.outfit(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
