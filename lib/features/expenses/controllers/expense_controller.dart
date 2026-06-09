import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../repositories/expense_repository.dart';
import '../../../models/finance_models.dart';
import '../../../services/local_db_service.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:uuid/uuid.dart';

class ExpenseState {
  final List<ExpenseModel> expenses;
  final List<BudgetLimitModel> budgetLimits;
  final bool isLoading;
  final String? errorMessage;

  ExpenseState({
    this.expenses = const [],
    this.budgetLimits = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ExpenseState copyWith({
    List<ExpenseModel>? expenses,
    List<BudgetLimitModel>? budgetLimits,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ExpenseState(
      expenses: expenses ?? this.expenses,
      budgetLimits: budgetLimits ?? this.budgetLimits,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ExpenseController extends StateNotifier<ExpenseState> {
  final ExpenseRepository _repository;
  String? _familyId;
  final LocalDbService _localDb = LocalDbService();

  ExpenseController(this._repository) : super(ExpenseState());

  void updateFamilyId(String? familyId) {
    if (_familyId == familyId) return;
    _familyId = familyId;
    if (_familyId != null && _familyId!.isNotEmpty) {
      loadExpensesAndBudgets();
    } else {
      state = ExpenseState();
    }
  }

  Future<void> loadExpensesAndBudgets() async {
    final familyId = _familyId;
    if (familyId == null || familyId.isEmpty) return;
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final list = await _repository.getExpenses(familyId);
      final limits = await _repository.getBudgetLimits(familyId);
      state = state.copyWith(expenses: list, budgetLimits: limits, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<bool> addExpense({
    required double amount,
    required String category,
    required String? description,
    required DateTime date,
    required String addedByName,
    required String? addedBy,
    required String? receiptUrl,
    required String? paymentMethod,
  }) async {
    final familyId = _familyId;
    if (familyId == null) return false;
    state = state.copyWith(isLoading: true);
    try {
      final expense = ExpenseModel(
        id: '',
        familyId: familyId,
        amount: amount,
        category: category,
        description: description,
        date: date,
        addedBy: addedBy,
        addedByName: addedByName,
        receiptUrl: receiptUrl,
        paymentMethod: paymentMethod,
        createdAt: DateTime.now(),
      );

      final added = await _repository.addExpense(expense);
      
      // Dynamic budget limits threshold warnings
      _checkBudgetBreaches(added);

      state = state.copyWith(
        expenses: [added, ...state.expenses],
        isLoading: false,
      );
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }

  Future<void> deleteExpense(String id) async {
    final familyId = _familyId;
    if (familyId == null) return;
    try {
      await _repository.deleteExpense(id, familyId);
      state = state.copyWith(
        expenses: state.expenses.where((element) => element.id != id).toList(),
      );
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
    }
  }

  Future<void> saveBudget(String category, double amount) async {
    final familyId = _familyId;
    if (familyId == null) return;
    state = state.copyWith(isLoading: true);
    try {
      final limit = BudgetLimitModel(
        id: '',
        familyId: familyId,
        category: category,
        limitAmount: amount,
        month: DateTime.now().month,
        year: DateTime.now().year,
      );
      await _repository.saveBudgetLimit(limit);
      final limits = await _repository.getBudgetLimits(familyId);
      state = state.copyWith(budgetLimits: limits, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void _checkBudgetBreaches(ExpenseModel added) {
    // Look for matching budget cap for this category or 'All'
    final limit = state.budgetLimits.firstWhere(
      (element) => element.category == added.category,
      orElse: () => state.budgetLimits.firstWhere(
        (element) => element.category == 'All',
        orElse: () => BudgetLimitModel(id: '', familyId: '', category: '', limitAmount: 0.0, month: 0, year: 0),
      ),
    );

    if (limit.limitAmount > 0) {
      // Sum expenses in this category for this month
      final currentMonthExpenses = state.expenses
          .where((element) => 
              element.category == limit.category && 
              element.date.month == DateTime.now().month && 
              element.date.year == DateTime.now().year)
          .fold<double>(0.0, (previousValue, element) => previousValue + element.amount) + added.amount;

      if (currentMonthExpenses > limit.limitAmount) {
        // Trigger simulated push notification locally
        _localDb.insertRow('notifications', {
          'id': const Uuid().v4(),
          'family_id': _familyId,
          'title': 'Budget Cap Exceeded!',
          'message': 'Your monthly budget limit of ₹${limit.limitAmount.toStringAsFixed(2)} for category ${limit.category} has been breached. Current total: ₹${currentMonthExpenses.toStringAsFixed(2)}.',
          'type': 'low_balance',
          'is_read': false,
          'created_at': DateTime.now().toIso8601String(),
        });
      }
    }
  }
}

// PROVIDERS
final expenseRepositoryProvider = Provider<ExpenseRepository>((ref) => ExpenseRepository());

final expenseControllerProvider = StateNotifierProvider<ExpenseController, ExpenseState>((ref) {
  final repo = ref.watch(expenseRepositoryProvider);
  final controller = ExpenseController(repo);
  
  ref.listen(profileControllerProvider, (previous, next) {
    if (previous?.family?.id != next.family?.id) {
      controller.updateFamilyId(next.family?.id);
    }
  });

  // Initial load
  final initialFamilyId = ref.read(profileControllerProvider).family?.id;
  controller.updateFamilyId(initialFamilyId);

  return controller;
});
