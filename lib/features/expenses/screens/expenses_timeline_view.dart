import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state_view.dart';
import '../../contributions/controllers/contribution_controller.dart';
import '../../expenses/controllers/expense_controller.dart';
import '../../dashboard/controllers/dashboard_controller.dart';
import '../../../core/localization/translations.dart';
import '../../../core/widgets/dynamic_translated_text.dart';

class ExpensesTimelineView extends ConsumerStatefulWidget {
  const ExpensesTimelineView({super.key});

  @override
  ConsumerState<ExpensesTimelineView> createState() =>
      _ExpensesTimelineViewState();
}

class _ExpensesTimelineViewState extends ConsumerState<ExpensesTimelineView> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'All'; // 'All', 'In', 'Out'
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final conState = ref.watch(contributionControllerProvider);
    final expState = ref.watch(expenseControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final selectedMonth = ref.watch(selectedMonthProvider);

    // 1. Group contributions and expenses into unified transactions list
    final List<Map<String, dynamic>> transactions = [];

    final filteredContributions = conState.contributions.where((c) {
      return c.date.year == selectedMonth.year && c.date.month == selectedMonth.month;
    });

    final filteredExpenses = expState.expenses.where((e) {
      return e.date.year == selectedMonth.year && e.date.month == selectedMonth.month;
    });

    for (final con in filteredContributions) {
      transactions.add({
        'id': con.id,
        'type': 'in',
        'amount': con.amount,
        'category': 'Contribution',
        'description': con.note ?? 'Contribution',
        'date': con.date,
        'user': con.contributorName,
      });
    }

    for (final exp in filteredExpenses) {
      transactions.add({
        'id': exp.id,
        'type': 'out',
        'amount': exp.amount,
        'category': exp.category,
        'description': exp.description ?? exp.category,
        'date': exp.date,
        'user': exp.addedByName,
        'receipt_url': exp.receiptUrl,
        'payment_method': exp.paymentMethod,
      });
    }

    // 2. Sort by date descending
    transactions.sort(
      (a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime),
    );

    // 3. Filter transactions
    final filtered = transactions.where((item) {
      // Filter by Search Query (Description, Category, or Member)
      final matchQuery =
          _searchQuery.isEmpty ||
          item['description'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item['category'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          ) ||
          item['user'].toString().toLowerCase().contains(
            _searchQuery.toLowerCase(),
          );

      // Filter by Type
      final matchType =
          _selectedFilter == 'All' ||
          (_selectedFilter == 'In' && item['type'] == 'in') ||
          (_selectedFilter == 'Out' && item['type'] == 'out');

      // Filter by Category
      final matchCategory =
          _selectedCategory == 'All' ||
          item['category'].toString().toLowerCase() ==
              _selectedCategory.toLowerCase();

      return matchQuery && matchType && matchCategory;
    }).toList();

    // 4. Group by Day/Month
    final Map<String, List<Map<String, dynamic>>> groupedTransactions = {};
    for (final item in filtered) {
      final date = item['date'] as DateTime;
      final formattedDay = _formatDayHeader(date);
      if (!groupedTransactions.containsKey(formattedDay)) {
        groupedTransactions[formattedDay] = [];
      }
      groupedTransactions[formattedDay]!.add(item);
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.darkBackground, Color(0xFF14151F)]
                : [AppColors.lightBackground, Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PAGE TITLE
              Padding(
                padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Text(
                  context.tr('timelineTitle', ref),
                  style: GoogleFonts.outfit(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // SEARCH BAR & FILTERS
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20.0,
                  vertical: 8.0,
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _searchController,
                      onChanged: (val) {
                        setState(() {
                          _searchQuery = val;
                        });
                      },
                      decoration: InputDecoration(
                        hintText: context.tr('searchHint', ref),
                        prefixIcon: Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(
                                  Icons.clear,
                                  color: Colors.grey,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                            : null,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(
                            color: AppColors.primaryCyan,
                            width: 1.5,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.black26 : Colors.white60,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context.tr('all', ref),
                            'type_all',
                            _selectedFilter == 'All',
                            () {
                              setState(() => _selectedFilter = 'All');
                            },
                          ),
                          _buildFilterChip(
                            context.tr('moneyIn', ref),
                            'type_in',
                            _selectedFilter == 'In',
                            () {
                              setState(() => _selectedFilter = 'In');
                            },
                          ),
                          _buildFilterChip(
                            context.tr('moneyOut', ref),
                            'type_out',
                            _selectedFilter == 'Out',
                            () {
                              setState(() => _selectedFilter = 'Out');
                            },
                          ),
                          SizedBox(width: 8.w),
                          _buildFilterCategoryDropdown(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // TRANSACTIONS TIMELINE LIST
              Expanded(
                child: filtered.isEmpty
                    ? EmptyStateView(
                        title: context.tr('noTxFound', ref),
                        description: context.tr('adjustFilters', ref),
                        icon: Icons.search_off_rounded,
                      )
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(
                          horizontal: 20.0,
                          vertical: 16.0,
                        ),
                        itemCount: groupedTransactions.keys.length,
                        itemBuilder: (context, index) {
                          final dateKey = groupedTransactions.keys.elementAt(
                            index,
                          );
                          final dayTransactions = groupedTransactions[dateKey]!;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: 8.0,
                                ),
                                child: Text(
                                  dateKey,
                                  style: GoogleFonts.outfit(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primaryCyan,
                                  ),
                                ),
                              ),
                              ...dayTransactions.map(
                                (tx) => _buildTransactionCard(tx),
                              ),
                              SizedBox(height: 16.h),
                            ],
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    String id,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 8),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: isSelected
              ? AppColors.primaryCyan
              : Colors.grey[Theme.of(context).brightness == Brightness.dark
                    ? 800
                    : 300],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.black
                : Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFilterCategoryDropdown() {
    final categories = [
      'All',
      'Grocery',
      'Electricity',
      'Water',
      'Gas',
      'Rent',
      'Internet',
      'Medicine',
      'Education',
      'Transport',
      'Other',
    ];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButton<String>(
        value: _selectedCategory,
        underline: SizedBox(),
        style: TextStyle(
          color: Theme.of(context).textTheme.bodyMedium?.color,
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
        ),
        dropdownColor: isDark ? AppColors.darkCard : Colors.white,
        items: categories.map((cat) {
          return DropdownMenuItem<String>(value: cat, child: Text(cat));
        }).toList(),
        onChanged: (val) {
          if (val != null) {
            setState(() {
              _selectedCategory = val;
            });
          }
        },
      ),
    );
  }

  String _formatDayHeader(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final txDate = DateTime(date.year, date.month, date.day);

    if (txDate == today) return context.tr('today', ref);
    if (txDate == yesterday) return context.tr('yesterday', ref);
    return DateFormat('EEEE, MMMM dd, yyyy').format(date);
  }

  Widget _buildTransactionCard(Map<String, dynamic> tx) {
    final isOut = tx['type'] == 'out';
    final amountColor = isOut ? AppColors.error : AppColors.success;
    final iconColor = isOut
        ? AppColors.getCategoryColor(tx['category'])
        : AppColors.success;
    final icon = isOut
        ? AppColors.getCategoryIcon(tx['category'])
        : Icons.add_card_rounded;

    return Dismissible(
      key: Key(tx['id']),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.error,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        if (isOut) {
          ref.read(expenseControllerProvider.notifier).deleteExpense(tx['id']);
        } else {
          ref
              .read(contributionControllerProvider.notifier)
              .deleteContribution(tx['id']);
        }
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 6.0),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.grey.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: iconColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: iconColor, size: 20),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: DynamicTranslatedText(
                                tx['description'],
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.sp,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            if (tx['payment_method'] != null)
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                                decoration: BoxDecoration(
                                  color: tx['payment_method'] == 'cash' 
                                    ? Colors.green.withValues(alpha: 0.1) 
                                    : Colors.blue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: tx['payment_method'] == 'cash' 
                                      ? Colors.green.withValues(alpha: 0.3) 
                                      : Colors.blue.withValues(alpha: 0.3),
                                  ),
                                ),
                                child: Text(
                                  context.tr(tx['payment_method'].toString().toLowerCase(), ref).toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 9.sp,
                                    fontWeight: FontWeight.bold,
                                    color: tx['payment_method'] == 'cash' ? Colors.green : Colors.blue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        SizedBox(height: 4),
                        DynamicTranslatedText(
                          isOut 
                            ? context.tr('addedByTemplate', ref)
                                .replaceAll('{name}', tx['added_by_name']?.toString() ?? 'User')
                                .replaceAll('{category}', context.tr(tx['category']?.toString().toLowerCase() ?? 'other', ref))
                            : tx['note'] ?? context.tr('sharedMoneyLog', ref),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12.sp,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isOut ? "-" : "+"} ₹${tx['amount'].toStringAsFixed(2)}',
                  style: GoogleFonts.outfit(
                    fontWeight: FontWeight.bold,
                    fontSize: 15.sp,
                    color: amountColor,
                  ),
                ),
                if (tx['receipt_url'] != null) ...[
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(
                        Icons.receipt_long_rounded,
                        size: 10,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 2.w),
                      GestureDetector(
                        onTap: () {
                          _showReceiptDialog(context, tx['receipt_url']);
                        },
                        child: Text(
                          context.tr('receiptLabel', ref),
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: AppColors.primaryCyan,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReceiptDialog(BuildContext context, String url) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(url, fit: BoxFit.cover),
              ),
              SizedBox(height: 16.h),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close),
                label: Text(context.tr('closeLabel', ref)),
              ),
            ],
          ),
        );
      },
    );
  }
}
