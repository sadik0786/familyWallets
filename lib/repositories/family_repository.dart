import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../services/local_db_service.dart';
import '../models/family_model.dart';
import '../models/member_model.dart';
import '../models/user_model.dart';
import 'package:uuid/uuid.dart';

class FamilyRepository {
  final SupabaseService _supabase = SupabaseService();
  final LocalDbService _localDb = LocalDbService();

  Future<FamilyModel?> getFamilyDetails(String familyId) async {
    if (_supabase.isDemoMode) {
      final list = await _localDb.getList('families');
      var match = list.firstWhere(
        (element) => element['id'] == familyId,
        orElse: () => <String, dynamic>{}, // Return empty map if not found
      );

      if (match.isEmpty) {
        match = {
          'id': familyId,
          'name': 'Demo Household',
          'invite_code': 'FA-7729',
          'subscription_tier': 'free',
          'created_at': DateTime.now().toIso8601String(),
        };
        // Save it to local DB so subsequent updates work!
        await _localDb.insertRow('families', match);
      }
      return FamilyModel.fromJson(match);
    }

    try {
      final res = await _supabase.client
          .from('families')
          .select()
          .eq('id', familyId)
          .single();
      return FamilyModel.fromJson(res);
    } catch (e) {
      debugPrint('[FamilyRepository] Error getting family details: $e');
      return null;
    }
  }

  Future<FamilyModel?> getUserFamily(String userId) async {
    if (_supabase.isDemoMode) return null;
    
    try {
      final res = await _supabase.client
          .from('family_members')
          .select('families(*)')
          .eq('user_id', userId)
          .maybeSingle();
      
      if (res != null && res['families'] != null) {
        return FamilyModel.fromJson(res['families'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      debugPrint('[FamilyRepository] Error finding user family: $e');
      return null;
    }
  }

  Future<FamilyModel?> createFamily(String name, String userId, String displayName) async {
    final inviteCode = 'FW-${const Uuid().v4().substring(0, 4).toUpperCase()}';
    final familyId = const Uuid().v4();

    final familyData = {
      'id': familyId,
      'name': name,
      'invite_code': inviteCode,
      'created_by': userId,
      'subscription_tier': 'free',
      'created_at': DateTime.now().toIso8601String(),
    };

    final memberData = {
      'id': const Uuid().v4(),
      'family_id': familyId,
      'user_id': userId,
      'role': 'admin',
      'joined_at': DateTime.now().toIso8601String(),
    };

    if (_supabase.isDemoMode) {
      await _localDb.insertRow('families', familyData);
      await _localDb.insertRow('family_members', memberData);
      await _localDb.setString('current_family_id', familyId);
      return FamilyModel.fromJson(familyData);
    }

    try {
      // 1. Create family
      await _supabase.client.from('families').insert(familyData);
      // 2. Add creator as admin member
      await _supabase.client.from('family_members').insert(memberData);
      return FamilyModel.fromJson(familyData);
    } catch (e) {
      throw Exception('Failed to create family workspace: $e');
    }
  }

  Future<FamilyModel?> joinFamily(String inviteCode, String userId, String displayName) async {
    if (_supabase.isDemoMode) {
      // Find matching family locally or create a dummy one
      final list = await _localDb.getList('families');
      var matched = list.firstWhere(
        (element) => element['invite_code'] == inviteCode,
        orElse: () => {},
      );

      if (matched.isEmpty) {
        // If not found, create a new mock one with this invite code
        matched = {
          'id': const Uuid().v4(),
          'name': 'Joined Household',
          'invite_code': inviteCode,
          'subscription_tier': 'free',
          'created_at': DateTime.now().toIso8601String(),
        };
        await _localDb.insertRow('families', matched);
      }

      final memberData = {
        'id': const Uuid().v4(),
        'family_id': matched['id'],
        'user_id': userId,
        'role': 'member',
        'joined_at': DateTime.now().toIso8601String(),
      };

      await _localDb.insertRow('family_members', memberData);
      await _localDb.setString('current_family_id', matched['id'].toString());
      return FamilyModel.fromJson(matched);
    }

    try {
      final response = await _supabase.client.rpc('join_workspace_by_code', params: {
        'p_invite_code': inviteCode,
        'p_user_id': userId,
      });

      if (response == null) {
        throw Exception('Invalid invite code or workspace suspended.');
      }

      return FamilyModel.fromJson(response as Map<String, dynamic>);
    } catch (e) {
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<List<MemberModel>> getFamilyMembers(String familyId) async {
    if (_supabase.isDemoMode) {
      // Return a set of mock family members
      return [
        MemberModel(
          id: 'member-1',
          familyId: familyId,
          userId: 'mock-user-uuid-12345',
          role: 'admin',
          joinedAt: DateTime.now().subtract(const Duration(days: 30)),
          userDetails: UserModel(
            id: 'mock-user-uuid-12345',
            email: 'demo@familywallet.com',
            displayName: 'Demo (Father)',
            createdAt: DateTime.now(),
          ),
        ),
        MemberModel(
          id: 'member-2',
          familyId: familyId,
          userId: 'mock-member-brother',
          role: 'manager',
          joinedAt: DateTime.now().subtract(const Duration(days: 25)),
          userDetails: UserModel(
            id: 'mock-member-brother',
            email: 'brother@familywallet.com',
            displayName: 'Ahmad (Brother)',
            createdAt: DateTime.now(),
          ),
        ),
        MemberModel(
          id: 'member-3',
          familyId: familyId,
          userId: 'mock-member-viewer',
          role: 'viewer',
          joinedAt: DateTime.now().subtract(const Duration(days: 15)),
          userDetails: UserModel(
            id: 'mock-member-viewer',
            email: 'sister@familywallet.com',
            displayName: 'Fatima (Sister)',
            createdAt: DateTime.now(),
          ),
        ),
      ];
    }

    try {
      final res = await _supabase.client
          .from('family_members')
          .select('*, users(*)')
          .eq('family_id', familyId);

      return (res as List).map((e) => MemberModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[FamilyRepository] Error fetching members: $e');
      return [];
    }
  }

  Future<void> updateSubscriptionTier(String familyId, String tier, {int? durationDays}) async {
    if (_supabase.isDemoMode) {
      final updateData = <String, dynamic>{'subscription_tier': tier};
      if (tier == 'premium' && durationDays != null) {
        updateData['premium_until'] = DateTime.now().add(Duration(days: durationDays)).toIso8601String();
      }
      await _localDb.updateRow('families', 'id', familyId, updateData);
      return;
    }
    try {
      final updateData = <String, dynamic>{'subscription_tier': tier};
      if (tier == 'premium' && durationDays != null) {
        updateData['premium_until'] = DateTime.now().add(Duration(days: durationDays)).toIso8601String();
      }

      final response = await _supabase.client
          .from('families')
          .update(updateData)
          .eq('id', familyId)
          .select()
          .maybeSingle();
      
      if (response == null) {
        throw Exception('Update failed. You may not have admin privileges.');
      }
    } catch (e) {
      debugPrint('[FamilyRepository] Error updating subscription: $e');
      throw Exception(e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<void> removeMember(String familyId, String userId) async {
    if (_supabase.isDemoMode) return;
    try {
      await _supabase.client
          .from('family_members')
          .delete()
          .eq('family_id', familyId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('[FamilyRepository] Error removing member: $e');
      throw Exception('Failed to remove member: $e');
    }
  }
}
