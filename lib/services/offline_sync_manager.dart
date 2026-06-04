import 'package:flutter/foundation.dart';
import 'supabase_service.dart';
import 'local_db_service.dart';

class OfflineSyncManager {
  static final OfflineSyncManager _instance = OfflineSyncManager._internal();
  factory OfflineSyncManager() => _instance;
  OfflineSyncManager._internal();

  final SupabaseService _supabase = SupabaseService();
  final LocalDbService _localDb = LocalDbService();

  bool _isSyncing = false;
  bool get isSyncing => _isSyncing;

  Future<void> syncPendingData() async {
    if (_supabase.isDemoMode) return;
    if (_isSyncing) return;

    _isSyncing = true;
    debugPrint('[OfflineSyncManager] Starting background synchronization...');

    try {
      final isConnected = await _supabase.checkConnection();
      if (!isConnected) {
        debugPrint('[OfflineSyncManager] No internet connection. Postponing sync.');
        _isSyncing = false;
        return;
      }

      // 1. Sync pending local expenses
      final pendingExpenses = await _localDb.getList('pending_expenses');
      if (pendingExpenses.isNotEmpty) {
        debugPrint('[OfflineSyncManager] Syncing ${pendingExpenses.length} pending expenses...');
        for (final expense in pendingExpenses) {
          final cleanExpense = Map<String, dynamic>.from(expense)..remove('id'); // Let database generate UUID if needed
          await _supabase.client.from('expenses').insert(cleanExpense);
        }
        await _localDb.saveList('pending_expenses', []); // Clear pending list
      }

      // 2. Sync pending local contributions
      final pendingContributions = await _localDb.getList('pending_contributions');
      if (pendingContributions.isNotEmpty) {
        debugPrint('[OfflineSyncManager] Syncing ${pendingContributions.length} pending contributions...');
        for (final contribution in pendingContributions) {
          final cleanContribution = Map<String, dynamic>.from(contribution)..remove('id');
          await _supabase.client.from('contributions').insert(cleanContribution);
        }
        await _localDb.saveList('pending_contributions', []); // Clear pending list
      }

      debugPrint('[OfflineSyncManager] Synchronization completed successfully.');
    } catch (e) {
      debugPrint('[OfflineSyncManager] Synchronization failed: $e');
    } finally {
      _isSyncing = false;
    }
  }
}
