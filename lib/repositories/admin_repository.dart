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
            'family_name': 'Ali Family',
            'created_at': DateTime.now().toIso8601String(),
          },
          {
            'display_name': 'Demo (Father)',
            'email': 'demo@familywallet.com',
            'role': 'user',
            'family_name': 'Demo Household',
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

  Future<bool> toggleFamilyPremium(String familyId, bool isPremium) async {
    if (_supabase.isDemoMode) return true;

    try {
      await _supabase.client.rpc(
        'toggle_family_premium',
        params: {
          'target_family_id': familyId,
          'is_premium': isPremium,
        },
      );
      return true;
    } catch (e) {
      debugPrint('[AdminRepository] Error toggling premium: $e');
      return false;
    }
  }

  Future<Map<String, String>> getPremiumPrices() async {
    if (_supabase.isDemoMode) {
      return {
        '1_month': '50',
        '3_months': '140',
        '6_months': '250',
        '1_year': '500',
      };
    }

    try {
      final res = await _supabase.client
          .from('app_settings')
          .select('key, value')
          .like('key', 'premium_price_%');
      
      final map = <String, String>{
        '1_month': '50',
        '3_months': '140',
        '6_months': '250',
        '1_year': '500',
      };

      for (var row in res as List) {
        final key = (row['key'] as String).replaceAll('premium_price_', '');
        map[key] = row['value'] as String;
      }
      return map;
    } catch (e) {
      debugPrint('[AdminRepository] Error getting premium prices: $e');
      return {
        '1_month': '50',
        '3_months': '140',
        '6_months': '250',
        '1_year': '500',
      };
    }
  }

  Future<bool> updatePremiumPrice(String planKey, String price) async {
    if (_supabase.isDemoMode) return true;

    try {
      // Use update instead of upsert to avoid RLS INSERT permission issues
      await _supabase.client
          .from('app_settings')
          .update({
            'value': price,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('key', 'premium_price_$planKey');
      return true;
    } catch (e) {
      debugPrint('[AdminRepository] Error updating premium price ($planKey): $e');
      return false;
    }
  }
}
