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

  Future<String> getGlobalPremiumPrice() async {
    if (_supabase.isDemoMode) return '500';

    try {
      final res = await _supabase.client
          .from('app_settings')
          .select('value')
          .eq('key', 'premium_price')
          .maybeSingle();
      
      if (res != null) {
        return res['value'] as String;
      }
      return '500';
    } catch (e) {
      debugPrint('[AdminRepository] Error getting premium price: $e');
      return '500';
    }
  }

  Future<bool> updateGlobalPremiumPrice(String price) async {
    if (_supabase.isDemoMode) return true;

    try {
      // Upsert logic for app settings
      await _supabase.client.from('app_settings').upsert({
        'key': 'premium_price',
        'value': price,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[AdminRepository] Error updating premium price: $e');
      return false;
    }
  }

  Future<String> getGlobalPremiumDuration() async {
    if (_supabase.isDemoMode) return '1 Year';

    try {
      final res = await _supabase.client
          .from('app_settings')
          .select('value')
          .eq('key', 'premium_duration')
          .maybeSingle();
      
      if (res != null) {
        return res['value'] as String;
      }
      return '1 Year';
    } catch (e) {
      debugPrint('[AdminRepository] Error getting premium duration: $e');
      return '1 Year';
    }
  }

  Future<bool> updateGlobalPremiumDuration(String duration) async {
    if (_supabase.isDemoMode) return true;

    try {
      await _supabase.client.from('app_settings').upsert({
        'key': 'premium_duration',
        'value': duration,
        'updated_at': DateTime.now().toIso8601String(),
      });
      return true;
    } catch (e) {
      debugPrint('[AdminRepository] Error updating premium duration: $e');
      return false;
    }
  }
}
