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
  final bool isLoading;

  DashboardData({
    this.totalContributions = 0.0,
    this.totalExpenses = 0.0,
    this.remainingBalance = 0.0,
    this.recentContributions = const [],
    this.recentExpenses = const [],
    this.categoryBreakdown = const {},
    this.isLoading = false,
  });
}

final dashboardControllerProvider = Provider<DashboardData>((ref) {
  final contributionState = ref.watch(contributionControllerProvider);
  final expenseState = ref.watch(expenseControllerProvider);

  final contributions = contributionState.contributions;
  final expenses = expenseState.expenses;

  // 1. Calculate Total Contributions
  final double totalIn = contributions.fold(0.0, (sum, item) => sum + item.amount);

  // 2. Calculate Total Expenses
  final double totalOut = expenses.fold(0.0, (sum, item) => sum + item.amount);

  // 3. Dynamic Balance calculation
  final double balance = totalIn - totalOut;

  // 4. Calculate Category breakdowns for fl_chart
  final categoryTotals = <String, double>{};
  for (final exp in expenses) {
    categoryTotals[exp.category] = (categoryTotals[exp.category] ?? 0.0) + exp.amount;
  }

  // 5. Slice recent activities
  final recentCons = contributions.take(4).toList();
  final recentExps = expenses.take(4).toList();

  final isLoading = contributionState.isLoading || expenseState.isLoading;

  return DashboardData(
    totalContributions: totalIn,
    totalExpenses: totalOut,
    remainingBalance: balance,
    recentContributions: recentCons,
    recentExpenses: recentExps,
    categoryBreakdown: categoryTotals,
    isLoading: isLoading,
  );
});
