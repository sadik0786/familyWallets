import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contributions/controllers/contribution_controller.dart';
import '../../expenses/controllers/expense_controller.dart';
import '../../../models/finance_models.dart';

class DashboardData {
  final double totalContributions;
  final double totalExpenses;
  final double remainingBalance;
  final List<ContributionModel> recentContributions;
  final List<ExpenseModel> recentExpenses;
  final Map<String, double> categoryBreakdown;
  final double cashSpent;
  final double onlineSpent;
  final bool isLoading;

  DashboardData({
    this.totalContributions = 0.0,
    this.totalExpenses = 0.0,
    this.remainingBalance = 0.0,
    this.recentContributions = const [],
    this.recentExpenses = const [],
    this.categoryBreakdown = const {},
    this.cashSpent = 0.0,
    this.onlineSpent = 0.0,
    this.isLoading = false,
  });
}

final selectedMonthProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month);
});

final dashboardControllerProvider = Provider<DashboardData>((ref) {
  final contributionState = ref.watch(contributionControllerProvider);
  final expenseState = ref.watch(expenseControllerProvider);

  final selectedMonth = ref.watch(selectedMonthProvider);

  // Filter contributions by selected month/year
  final filteredContributions = contributionState.contributions.where((c) {
    return c.date.year == selectedMonth.year && c.date.month == selectedMonth.month;
  }).toList();

  // Filter expenses by selected month/year
  final filteredExpenses = expenseState.expenses.where((e) {
    return e.date.year == selectedMonth.year && e.date.month == selectedMonth.month;
  }).toList();

  // 1. Calculate Total Contributions for the month
  final double totalIn = filteredContributions.fold(0.0, (sum, item) => sum + item.amount);

  // 2. Calculate Total Expenses and breakdowns for the month
  double totalOut = 0.0;
  double cashSpent = 0.0;
  double onlineSpent = 0.0;
  final categoryTotals = <String, double>{};

  for (final exp in filteredExpenses) {
    totalOut += exp.amount;
    categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0.0) + exp.amount;
    if (exp.paymentMethod == 'cash') {
      cashSpent += exp.amount;
    } else if (exp.paymentMethod == 'online') {
      onlineSpent += exp.amount;
    } else {
      // Default fallback if no paymentMethod is set (legacy data)
      cashSpent += exp.amount;
    }
  }

  // 3. Dynamic Balance calculation for the month
  final double balance = totalIn - totalOut;

  // 5. Slice recent activities
  final recentCons = filteredContributions.take(4).toList();
  final recentExps = filteredExpenses.take(4).toList();

  final isLoading = contributionState.isLoading || expenseState.isLoading;

  return DashboardData(
    totalContributions: totalIn,
    totalExpenses: totalOut,
    remainingBalance: balance,
    recentContributions: recentCons,
    recentExpenses: recentExps,
    categoryBreakdown: categoryTotals,
    cashSpent: cashSpent,
    onlineSpent: onlineSpent,
    isLoading: isLoading,
  );
});
