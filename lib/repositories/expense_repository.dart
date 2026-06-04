import 'package:flutter/foundation.dart';
import '../services/supabase_service.dart';
import '../services/local_db_service.dart';
import '../models/finance_models.dart';
import 'package:uuid/uuid.dart';

class ExpenseRepository {
  final SupabaseService _supabase = SupabaseService();
  final LocalDbService _localDb = LocalDbService();

  Future<List<ExpenseModel>> getExpenses(String familyId) async {
    if (_supabase.isDemoMode) {
      final list = await _localDb.getList('expenses');
      if (list.isEmpty) {
        // Generate beautiful initial demo expenses!
        final demoExpenses = [
          ExpenseModel(
            id: 'exp-demo-1',
            familyId: familyId,
            amount: 320.0,
            category: 'Grocery',
            description: 'Monthly pantry restocking',
            date: DateTime.now().subtract(const Duration(days: 2)),
            addedByName: 'Demo (Father)',
            createdAt: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ExpenseModel(
            id: 'exp-demo-2',
            familyId: familyId,
            amount: 85.50,
            category: 'Electricity',
            description: 'Electricity utility bill',
            date: DateTime.now().subtract(const Duration(days: 5)),
            addedByName: 'Ahmad (Brother)',
            createdAt: DateTime.now().subtract(const Duration(days: 5)),
          ),
          ExpenseModel(
            id: 'exp-demo-3',
            familyId: familyId,
            amount: 1200.0,
            category: 'Rent',
            description: 'May Month Rent payment',
            date: DateTime.now().subtract(const Duration(days: 10)),
            addedByName: 'Demo (Father)',
            createdAt: DateTime.now().subtract(const Duration(days: 10)),
          ),
          ExpenseModel(
            id: 'exp-demo-4',
            familyId: familyId,
            amount: 45.0,
            category: 'Transport',
            description: 'Car fuel refill',
            date: DateTime.now().subtract(const Duration(days: 12)),
            addedByName: 'Ahmad (Brother)',
            createdAt: DateTime.now().subtract(const Duration(days: 12)),
          ),
          ExpenseModel(
            id: 'exp-demo-5',
            familyId: familyId,
            amount: 60.0,
            category: 'Internet',
            description: 'Fiber internet subscription',
            date: DateTime.now().subtract(const Duration(days: 15)),
            addedByName: 'Fatima (Sister)',
            createdAt: DateTime.now().subtract(const Duration(days: 15)),
          ),
        ];

        for (final exp in demoExpenses) {
          await _localDb.insertRow('expenses', exp.toJson());
        }
        return demoExpenses;
      }
      return list.map((e) => ExpenseModel.fromJson(e)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }

    try {
      final res = await _supabase.client
          .from('expenses')
          .select()
          .eq('family_id', familyId)
          .order('date', ascending: false);

      final list = (res as List).map((e) => ExpenseModel.fromJson(e as Map<String, dynamic>)).toList();
      // Cache locally
      await _localDb.saveList('expenses_$familyId', list.map((e) => e.toJson()).toList());
      return list;
    } catch (e) {
      debugPrint('[ExpenseRepository] Error getting expenses from network: $e. Using local cache.');
      final list = await _localDb.getList('expenses_$familyId');
      return list.map((e) => ExpenseModel.fromJson(e)).toList()
        ..sort((a, b) => b.date.compareTo(a.date));
    }
  }

  Future<ExpenseModel> addExpense(ExpenseModel expense) async {
    final expId = const Uuid().v4();
    final expenseData = expense.copyWith(id: expId).toJson();

    if (_supabase.isDemoMode) {
      await _localDb.insertRow('expenses', expenseData);
      return ExpenseModel.fromJson(expenseData);
    }

    try {
      await _supabase.client.from('expenses').insert(expenseData);
      return ExpenseModel.fromJson(expenseData);
    } catch (e) {
      debugPrint('[ExpenseRepository] Network insert failed: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(String id, String familyId) async {
    if (_supabase.isDemoMode) {
      await _localDb.deleteRow('expenses', 'id', id);
      return;
    }
    try {
      await _supabase.client.from('expenses').delete().eq('id', id);
    } catch (e) {
      debugPrint('[ExpenseRepository] Error deleting expense: $e');
    }
  }

  // ==========================================
  // BUDGET LIMITS MANAGEMENT
  // ==========================================
  Future<List<BudgetLimitModel>> getBudgetLimits(String familyId) async {
    if (_supabase.isDemoMode) {
      final list = await _localDb.getList('budget_limits');
      if (list.isEmpty) {
        final initialLimits = [
          BudgetLimitModel(id: 'lim-1', familyId: familyId, category: 'All', limitAmount: 3000.0, month: DateTime.now().month, year: DateTime.now().year),
          BudgetLimitModel(id: 'lim-2', familyId: familyId, category: 'Grocery', limitAmount: 500.0, month: DateTime.now().month, year: DateTime.now().year),
          BudgetLimitModel(id: 'lim-3', familyId: familyId, category: 'Electricity', limitAmount: 150.0, month: DateTime.now().month, year: DateTime.now().year),
        ];
        for (final lim in initialLimits) {
          await _localDb.insertRow('budget_limits', lim.toJson());
        }
        return initialLimits;
      }
      return list.map((e) => BudgetLimitModel.fromJson(e)).toList();
    }

    try {
      final res = await _supabase.client
          .from('budget_limits')
          .select()
          .eq('family_id', familyId);
      return (res as List).map((e) => BudgetLimitModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('[ExpenseRepository] Error getting budget limits: $e');
      return [];
    }
  }

  Future<void> saveBudgetLimit(BudgetLimitModel limit) async {
    final limitId = limit.id.isEmpty ? const Uuid().v4() : limit.id;
    final limitData = limit.toJson()..['id'] = limitId;

    if (_supabase.isDemoMode) {
      final list = await _localDb.getList('budget_limits');
      final index = list.indexWhere((element) => 
          element['category'] == limit.category && 
          element['month'] == limit.month && 
          element['year'] == limit.year);

      if (index != -1) {
        list[index] = limitData;
        await _localDb.saveList('budget_limits', list);
      } else {
        await _localDb.insertRow('budget_limits', limitData);
      }
      return;
    }

    try {
      await _supabase.client.from('budget_limits').upsert(limitData);
    } catch (e) {
      debugPrint('[ExpenseRepository] Error saving budget limit: $e');
    }
  }
}
