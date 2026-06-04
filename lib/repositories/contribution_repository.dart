import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../services/local_db_service.dart';
import '../models/finance_models.dart';
import 'package:uuid/uuid.dart';

class ContributionRepository {
  final SupabaseService _supabase = SupabaseService();
  final LocalDbService _localDb = LocalDbService();

  Future<List<ContributionModel>> getContributions(String familyId) async {
    if (_supabase.isDemoMode) {
      final list = await _localDb.getList('contributions');
      if (list.isEmpty) {
        // Generate beautiful initial demo contributions!
        final demoContributions = [
          ContributionModel(
            id: 'con-demo-1',
            familyId: familyId,
            amount: 1500.0,
            contributorId: 'mock-user-uuid-12345',
            contributorName: 'Demo (Father)',
            note: 'Monthly salary contribution',
            date: DateTime.now().subtract(const Duration(days: 1)),
            createdAt: DateTime.now().subtract(const Duration(days: 1)),
          ),
          ContributionModel(
            id: 'con-demo-2',
            familyId: familyId,
            amount: 800.0,
            contributorId: 'mock-member-brother',
            contributorName: 'Ahmad (Brother)',
            note: 'Contribution for utilities and food',
            date: DateTime.now().subtract(const Duration(days: 4)),
            createdAt: DateTime.now().subtract(const Duration(days: 4)),
          ),
          ContributionModel(
            id: 'con-demo-3',
            familyId: familyId,
            amount: 300.0,
            contributorId: 'mock-member-brother',
            contributorName: 'Ahmad (Brother)',
            note: 'Emergency spare contributions',
            date: DateTime.now().subtract(const Duration(days: 14)),
            createdAt: DateTime.now().subtract(const Duration(days: 14)),
          ),
        ];

        for (final con in demoContributions) {
          await _localDb.insertRow('contributions', con.toJson());
        }
        return demoContributions;
      }
      return list.map((e) => ContributionModel.fromJson(e)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }

    try {
      final res = await _supabase.client
          .from('contributions')
          .select()
          .eq('family_id', familyId)
          .order('date', ascending: false);

      final list = (res as List).map((e) => ContributionModel.fromJson(e as Map<String, dynamic>)).toList();
      // Cache locally
      await _localDb.saveList('contributions_$familyId', list.map((e) => e.toJson()).toList());
      return list;
    } catch (e) {
      debugPrint('[ContributionRepository] Error fetching network contributions: $e. Using cache.');
      final list = await _localDb.getList('contributions_$familyId');
      return list.map((e) => ContributionModel.fromJson(e)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  Future<ContributionModel> addContribution(ContributionModel contribution) async {
    final conId = const Uuid().v4();
    final contributionData = contribution.copyWith(id: conId).toJson();

    if (_supabase.isDemoMode) {
      await _localDb.insertRow('contributions', contributionData);
      return ContributionModel.fromJson(contributionData);
    }

    try {
      await _supabase.client.from('contributions').insert(contributionData);
      return ContributionModel.fromJson(contributionData);
    } catch (e) {
      debugPrint('[ContributionRepository] Network insert failed: $e');
      rethrow;
    }
  }

  Future<void> deleteContribution(String id, String familyId) async {
    if (_supabase.isDemoMode) {
      await _localDb.deleteRow('contributions', 'id', id);
      return;
    }
    try {
      await _supabase.client.from('contributions').delete().eq('id', id);
    } catch (e) {
      debugPrint('[ContributionRepository] Error deleting contribution: $e');
    }
  }
}
