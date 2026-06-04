import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../controllers/admin_controller.dart';

class AdminUsersView extends ConsumerStatefulWidget {
  const AdminUsersView({super.key});

  @override
  ConsumerState<AdminUsersView> createState() => _AdminUsersViewState();
}

class _AdminUsersViewState extends ConsumerState<AdminUsersView> {
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

    final allUsers = adminState.stats?.allUsers ?? [];
    final filteredUsers = allUsers.where((u) {
      final name = u['display_name']?.toString().toLowerCase() ?? '';
      final email = u['email']?.toString().toLowerCase() ?? '';
      final q = _searchQuery.toLowerCase();
      return name.contains(q) || email.contains(q);
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search users by name or email/phone...',
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              filled: true,
              fillColor: Colors.grey.withValues(alpha: 0.1),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
          ),
        ),
        Expanded(
          child: filteredUsers.isEmpty
              ? const Center(
                  child: Text(
                    'No users found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    final dateStr = user['created_at']?.toString();
                    final formattedDate = dateStr != null
                        ? DateFormat.yMMMd().format(
                            DateTime.tryParse(dateStr) ?? DateTime.now(),
                          )
                        : 'Unknown Date';

                    return _buildUserFeedRow(
                      name: user['display_name']?.toString() ?? 'Unnamed User',
                      contact:
                          user['email']?.toString().replaceAll(
                            '@familywallet.auth',
                            '',
                          ) ??
                          'No contact',
                      role: user['role']?.toString() ?? 'user',
                      joinedAt: 'Joined $formattedDate',
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
    required String joinedAt,
  }) {
    final isSuperAdmin = role == 'super_admin';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: isSuperAdmin
                ? AppColors.primaryPurple.withValues(alpha: 0.2)
                : Colors.grey.withValues(alpha: 0.2),
            child: Icon(
              isSuperAdmin ? Icons.shield_rounded : Icons.person_rounded,
              color: isSuperAdmin ? AppColors.primaryPurple : Colors.grey[600],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  contact,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (isSuperAdmin)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primaryCyan.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'SUPER ADMIN',
                    style: TextStyle(
                      color: AppColors.primaryCyan,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              else
                const Text(
                  'USER',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 4),
              Text(
                joinedAt,
                style: TextStyle(fontSize: 10, color: Colors.grey[500]),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
