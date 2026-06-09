import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../contributions/controllers/contribution_controller.dart';
import '../../expenses/controllers/expense_controller.dart';

class MonthlySavings {
  final String monthYearKey; // Format: "YYYY-MM"
  final DateTime date;
  final double totalIncome;
  final double totalExpense;
  final double remainingBalance;

  MonthlySavings({
    required this.monthYearKey,
    required this.date,
    required this.totalIncome,
    required this.totalExpense,
    required this.remainingBalance,
  });
}

final monthlySavingsProvider = Provider<List<MonthlySavings>>((ref) {
  final contributionState = ref.watch(contributionControllerProvider);
  final expenseState = ref.watch(expenseControllerProvider);

  final contributions = contributionState.contributions;
  final expenses = expenseState.expenses;

  final Map<String, MonthlySavings> monthlyData = {};

  // Process Contributions
  for (final c in contributions) {
    final key = "${c.date.year}-${c.date.month.toString().padLeft(2, '0')}";
    if (!monthlyData.containsKey(key)) {
      monthlyData[key] = MonthlySavings(
        monthYearKey: key,
        date: DateTime(c.date.year, c.date.month),
        totalIncome: 0,
        totalExpense: 0,
        remainingBalance: 0,
      );
    }
    
    final existing = monthlyData[key]!;
    monthlyData[key] = MonthlySavings(
      monthYearKey: existing.monthYearKey,
      date: existing.date,
      totalIncome: existing.totalIncome + c.amount,
      totalExpense: existing.totalExpense,
      remainingBalance: existing.remainingBalance + c.amount,
    );
  }

  // Process Expenses
  for (final e in expenses) {
    final key = "${e.date.year}-${e.date.month.toString().padLeft(2, '0')}";
    if (!monthlyData.containsKey(key)) {
      monthlyData[key] = MonthlySavings(
        monthYearKey: key,
        date: DateTime(e.date.year, e.date.month),
        totalIncome: 0,
        totalExpense: 0,
        remainingBalance: 0,
      );
    }
    
    final existing = monthlyData[key]!;
    monthlyData[key] = MonthlySavings(
      monthYearKey: existing.monthYearKey,
      date: existing.date,
      totalIncome: existing.totalIncome,
      totalExpense: existing.totalExpense + e.amount,
      remainingBalance: existing.remainingBalance - e.amount,
    );
  }

  // Convert to list and sort descending (latest first)
  final result = monthlyData.values.toList();
  result.sort((a, b) => b.date.compareTo(a.date));

  return result;
});
