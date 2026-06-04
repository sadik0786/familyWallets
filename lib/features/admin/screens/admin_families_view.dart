import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
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
          padding: const EdgeInsets.all(20.0),
          child: TextField(
            onChanged: (val) => setState(() => _searchQuery = val),
            decoration: InputDecoration(
              hintText: 'Search families...',
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
          child: filteredFamilies.isEmpty
              ? const Center(
                  child: Text(
                    'No families found.',
                    style: TextStyle(color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filteredFamilies.length,
                  itemBuilder: (context, index) {
                    final family = filteredFamilies[index];
                    return _buildTenantFeedRow(
                      name: family['name']?.toString() ?? 'Unknown Family',
                      sub:
                          '${family['member_count']} members • ${family['plan'] == 'premium' ? 'Premium Plan' : 'Free Plan'}',
                      tierColor: family['plan'] == 'premium'
                          ? AppColors.success
                          : Colors.grey,
                      isActive: family['is_active'] as bool? ?? true,
                      onToggle: (val) {
                        ref
                            .read(adminControllerProvider.notifier)
                            .toggleFamilyStatus(family['id'], val);
                      },
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
    required Color tierColor,
    required bool isActive,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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
                  sub,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Switch(
                value: isActive,
                onChanged: onToggle,
                activeThumbColor: AppColors.primaryCyan,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.circle,
                size: 8,
                color: isActive ? AppColors.success : Colors.red,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
