import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/admin_controller.dart';

class AdminUsersView extends ConsumerStatefulWidget {
  const AdminUsersView({super.key});

  @override
  ConsumerState<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends ConsumerState<AdminUsersView>
    with SingleTickerProviderStateMixin {
  String _searchQuery = '';
  late AnimationController _glowController;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _glowAnimation = Tween<double>(begin: 0.1, end: 0.6).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

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

    final allUsers = adminState.stats?.allUsers ?? [];
    final filteredUsers = allUsers.where((u) {
      final name = u['display_name']?.toString().toLowerCase() ?? '';
      final email = u['email']?.toString().toLowerCase() ?? '';
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();

    filteredUsers.sort((a, b) {
      final aRole = a['role']?.toString();
      final bRole = b['role']?.toString();
      final aIsSuper = aRole == 'super_admin';
      final bIsSuper = bRole == 'super_admin';

      if (aIsSuper && !bIsSuper) return -1;
      if (!aIsSuper && bIsSuper) return 1;
      return 0; // Maintain original creation date order otherwise
    });

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
                hintText: 'Search users by name or contact...',
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
          child: filteredUsers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.person_off_rounded,
                        size: 64,
                        color: Colors.grey.withValues(alpha: 0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No users found.',
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
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final dateStr = user['created_at']?.toString();
                    final formattedDate = dateStr != null
                        ? DateFormat.yMMMd().format(
                            DateTime.tryParse(dateStr) ?? DateTime.now(),
                          )
                        : 'Unknown Date';

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: _buildUserFeedRow(
                        name:
                            user['display_name']?.toString() ?? 'Unnamed User',
                        contact:
                            user['email']?.toString().replaceAll(
                              '@familywallet.auth',
                              '',
                            ) ??
                            'No contact',
                        role: user['role']?.toString() ?? 'user',
                        familyRole: user['family_role']?.toString(),
                        joinedAt: 'Joined $formattedDate',
                        familyName: user['family_name']?.toString(),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildUserFeedRow({
    required String name,
    required String contact,
    required String role,
    required String? familyRole,
    required String joinedAt,
    required String? familyName,
  }) {
    final isSuperAdmin = role == 'super_admin';
    final isAdmin = role == 'admin' || familyRole == 'admin';

    String roleText = 'MEMBER';
    Color roleColor1 = AppColors.primaryBlue;
    Color roleColor2 = AppColors.primaryCyan;
    IconData roleIcon = Icons.person_rounded;

    if (isSuperAdmin) {
      roleText = 'SUPER ADMIN';
      roleColor1 = AppColors.primaryPurple;
      roleColor2 = AppColors.primaryCyan;
      roleIcon = Icons.admin_panel_settings_rounded;
    } else if (isAdmin) {
      roleText = 'ADMIN';
      roleColor1 = AppColors.primaryPink;
      roleColor2 = AppColors.primaryPurple;
      roleIcon = Icons.manage_accounts_rounded;
    }

    Widget buildCard(BorderSide? customBorder) {
      return Stack(
        children: [
          GlassCard(
            padding: const EdgeInsets.all(16),
            borderRadius: 16.0,
            borderSide: customBorder,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Avatar
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isSuperAdmin
                          ? [
                              AppColors.primaryPurple.withValues(alpha: 0.3),
                              AppColors.primaryPink.withValues(alpha: 0.3),
                            ]
                          : isAdmin
                          ? [
                              AppColors.primaryPink.withValues(alpha: 0.3),
                              AppColors.primaryPurple.withValues(alpha: 0.3),
                            ]
                          : [
                              Colors.grey.withValues(alpha: 0.2),
                              Colors.grey.withValues(alpha: 0.1),
                            ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSuperAdmin
                          ? AppColors.primaryPurple.withValues(alpha: 0.5)
                          : isAdmin
                          ? AppColors.primaryPink.withValues(alpha: 0.5)
                          : Colors.grey.withValues(alpha: 0.2),
                    ),
                  ),
                  child: Icon(
                    isSuperAdmin
                        ? Icons.shield_rounded
                        : isAdmin
                        ? Icons.manage_accounts_rounded
                        : Icons.person_rounded,
                    color: isSuperAdmin
                        ? AppColors.primaryPink
                        : isAdmin
                        ? AppColors.primaryPurple
                        : Colors.grey[400],
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
                      const SizedBox(height: 4),
                      Text(
                        contact,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          color: Colors.grey[400],
                        ),
                      ),
                      if (familyName != null && familyName.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primaryBlue.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppColors.primaryBlue.withValues(
                                alpha: 0.3,
                              ),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.family_restroom_rounded,
                                size: 12,
                                color: AppColors.primaryBlue,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  familyName,
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: AppColors.primaryBlue,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Trailing Info (Date)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 24), // Spacer for badge if any
                    Text(
                      joinedAt,
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        color: Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Role Badge (Top Right)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [roleColor1, roleColor2]),
                borderRadius: const BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomLeft: Radius.circular(12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: roleColor1.withValues(alpha: 0.4),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(roleIcon, size: 10, color: Colors.white),
                  const SizedBox(width: 4),
                  Text(
                    roleText,
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    if (isSuperAdmin) {
      return AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return buildCard(
            BorderSide(
              color: AppColors.primaryPurple.withValues(
                alpha: 0.3 + (_glowAnimation.value * 0.7),
              ),
              width: 2.0,
            ),
          );
        },
      );
    }

    return buildCard(null);
  }
}
