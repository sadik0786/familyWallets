import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';

class AdminStats {
  final int totalUsers;
  final int totalFamilies;
  final double totalRevenue;
  final List<dynamic> activeFamilies;
  final List<dynamic> allUsers;

  AdminStats({
    required this.totalUsers,
    required this.totalFamilies,
    required this.totalRevenue,
    required this.activeFamilies,
    required this.allUsers,
  });

  factory AdminStats.fromJson(Map<String, dynamic> json) {
    return AdminStats(
      totalUsers: json['totalUsers'] as int? ?? 0,
      totalFamilies: json['totalFamilies'] as int? ?? 0,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble() ?? 0.0,
      activeFamilies: json['activeFamilies'] as List<dynamic>? ?? [],
      allUsers: json['allUsers'] as List<dynamic>? ?? [],
    );
  }
}

class AdminRepository {
  final SupabaseService _supabase = SupabaseService();

  Future<AdminStats> getGlobalStats() async {
    if (_supabase.isDemoMode) {
      // Mock data for demo mode
      return AdminStats(
        totalUsers: 14280,
        totalFamilies: 3840,
        totalRevenue: 184500.0,
        activeFamilies: [
          {
            'name': 'Demo Household (Father)',
            'member_count': 5,
            'plan': 'premium'
          },
          {
            'name': 'Ahmad Household',
            'member_count': 3,
            'plan': 'free'
          },
        ],
        allUsers: [
          {
            'display_name': 'Sadik Ali',
            'email': 'alisadik99@gmail.com',
            'role': 'super_admin',
            'created_at': DateTime.now().toIso8601String(),
          },
          {
            'display_name': 'Demo (Father)',
            'email': 'demo@familywallet.com',
            'role': 'user',
            'created_at': DateTime.now().toIso8601String(),
          }
        ],
      );
    }

    try {
      final response = await _supabase.client.rpc('get_super_admin_stats');
      return AdminStats.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      debugPrint('[AdminRepository] Error fetching global stats: $e');
      rethrow;
    }
  }

  Future<bool> toggleFamilyStatus(String familyId, bool isActive) async {
    if (_supabase.isDemoMode) return true;

    try {
      await _supabase.client.rpc(
        'toggle_family_status',
        params: {
          'target_family_id': familyId,
          'new_status': isActive,
        },
      );
      return true;
    } catch (e) {
      debugPrint('[AdminRepository] Error toggling status: $e');
      return false;
    }
  }
}
