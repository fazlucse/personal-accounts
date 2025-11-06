// lib/app/home/presentation/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/profile_model.dart';
import '../../data/models/transaction_model.dart';
import '../cubits/profile_cubit.dart';
import '../../data/repositories/report_repository.dart';
import '../widgets/category_chart.dart';

class ReportsScreen extends StatefulWidget {
  final Map<String, String> t;
  final bool isDark;
  final ThemeData themeData;

  const ReportsScreen({
    super.key,
    required this.t,
    required this.isDark,
    required this.themeData,
  });

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _selectedMonth;
  String _selectedType = 'all';
  String _selectedCategory = 'all';
  bool _showTransactions = false;
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = false;

  final _reportRepo = ReportRepository();
  final Map<String, bool> _expandedCategories = {};

  final List<String> _categories = [
    'all', 'Food', 'Transport', 'Shopping', 'Bills', 'Entertainment',
    'Health', 'Education', 'Salary', 'Other'
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
  }

  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedMonth = DateTime(picked.year, picked.month, 1);
        _showTransactions = false;
        _expandedCategories.clear();
      });
    }
  }

  Future<void> _fetchFilteredData() async {
    if (_selectedMonth == null) return;

    setState(() {
      _isLoading = true;
      _showTransactions = false;
      _expandedCategories.clear();
    });

    try {
      final from = _selectedMonth!;
      final to = DateTime(from.year, from.month + 1, 0, 23, 59, 59);
      final allTransactions = await _reportRepo.getTransactions(from: from, to: to);

      final filtered = allTransactions.where((t) {
        final typeMatch = _selectedType == 'all' || t.type == _selectedType;
        final catMatch = _selectedCategory == 'all' || t.category == _selectedCategory;
        return typeMatch && catMatch;
      }).toList();

      filtered.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _filteredTransactions = filtered;
        _showTransactions = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadReport() async {
    if (_filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No data to download')),
      );
      return;
    }
    try {
      await _reportRepo.downloadReport(_filteredTransactions);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Download failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isDesktop = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return BlocBuilder<ProfileCubit, Profile>(
            builder: (context, profile) {
              // === TOTALS ===
              double totalIncome = 0, totalExpense = 0;
              for (var t in _filteredTransactions) {
                if (t.type == 'income') totalIncome += t.amount;
                else totalExpense += t.amount;
              }
              final balance = totalIncome - totalExpense;

              // === GROUP BY CATEGORY (SAFE) ===
              final grouped = <String, List<Transaction>>{};
              for (var t in _filteredTransactions) {
                final cat = (t.category?.trim().isNotEmpty == true) ? t.category! : 'Other';
                grouped.putIfAbsent(cat, () => []).add(t);
              }

              final sortedCats = grouped.keys.toList()
                ..sort((a, b) {
                  final sumA = grouped[a]!.fold(0.0, (s, t) => s + t.amount);
                  final sumB = grouped[b]!.fold(0.0, (s, t) => s + t.amount);
                  return sumB.compareTo(sumA);
                });

              // === CHARTS (SAFE) ===
              final expenseByCat = <String, double>{};
              final incomeByCat = <String, double>{};
              for (var t in _filteredTransactions) {
                final cat = (t.category?.trim().isNotEmpty == true) ? t.category! : 'Other';
                if (t.type == 'expense') {
                  expenseByCat[cat] = (expenseByCat[cat] ?? 0) + t.amount;
                } else {
                  incomeByCat[cat] = (incomeByCat[cat] ?? 0) + t.amount;
                }
              }

              return SingleChildScrollView(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(widget.t['reports']!, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold)),
                        ElevatedButton.icon(
                          onPressed: _downloadReport,
                          icon: Icon(Icons.download),
                          label: Text(widget.t['download']!),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo[600]),
                        ),
                      ],
                    ),

                    SizedBox(height: 16.h),

                    // TOTAL SUMMARY
                    Card(
                      elevation: 4,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      child: Container(
                        padding: EdgeInsets.all(16.w),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12.r),
                          gradient: LinearGradient(
                            colors: widget.isDark ? [Colors.grey[850]!, Colors.grey[900]!] : [Colors.white, Colors.grey[50]!],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildTotalBox('Income', totalIncome, Colors.green, profile),
                            _buildTotalBox('Expense', totalExpense, Colors.red, profile),
                            _buildTotalBox('Balance', balance, balance >= 0 ? Colors.blue : Colors.orange, profile),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // FILTERS
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: widget.isDark ? Colors.grey[850] : Colors.grey[50],
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: widget.isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildMonthField(),
                          SizedBox(height: 16.h),
                          Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedType,
                                  decoration: InputDecoration(
                                    labelText: widget.t['type'] ?? 'Type',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                  ),
                                  items: [
                                    DropdownMenuItem(value: 'all', child: Text('All')),
                                    DropdownMenuItem(value: 'income', child: Text('Income')),
                                    DropdownMenuItem(value: 'expense', child: Text('Expense')),
                                  ],
                                  onChanged: (v) => setState(() => _selectedType = v!),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  value: _selectedCategory,
                                  decoration: InputDecoration(
                                    labelText: widget.t['category'] ?? 'Category',
                                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                                  ),
                                  items: _categories.map((c) => DropdownMenuItem(
                                    value: c,
                                    child: Text(c == 'all' ? 'All' : c),
                                  )).toList(),
                                  onChanged: (v) => setState(() => _selectedCategory = v!),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _fetchFilteredData,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[600]),
                              child: _isLoading
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : Text(widget.t['show'] ?? 'Show', style: const TextStyle(color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 24.h),

                    // CHARTS
                    if (_showTransactions && _filteredTransactions.isNotEmpty)
                      SizedBox(
                        height: 300.h,
                        child: GridView.count(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          crossAxisCount: isDesktop ? 2 : 1,
                          childAspectRatio: 1.5,
                          children: [
                            buildCategoryChart(
                              expenseByCat,
                              expenseByCat.values.fold(0.0, (a, b) => a + b),
                              Colors.red,
                              profile,
                              widget.t,
                              widget.t['expenseByCategory']!,
                            ),
                            buildCategoryChart(
                              incomeByCat,
                              incomeByCat.values.fold(0.0, (a, b) => a + b),
                              Colors.green,
                              profile,
                              widget.t,
                              widget.t['incomeByCategory']!,
                            ),
                          ],
                        ),
                      )
                    else
                      Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(24.w),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.bar_chart_outlined, size: 48, color: Colors.grey),
                                SizedBox(height: 8.h),
                                Text(widget.t['no_data'] ?? 'No data to display', style: TextStyle(fontSize: 16.sp)),
                              ],
                            ),
                          ),
                        ),
                      ),

                    SizedBox(height: 24.h),

                    // GROUPED TRANSACTIONS
                    if (_showTransactions)
                      _filteredTransactions.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.inbox_outlined, size: 64, color: Colors.grey),
                                  SizedBox(height: 8.h),
                                  Text(widget.t['no_data'] ?? 'No transactions found'),
                                ],
                              ),
                            )
                          : Column(
                              children: sortedCats.map((cat) {
                                final txns = grouped[cat]!;
                                final total = txns.fold(0.0, (s, t) => s + t.amount);
                                final isExpanded = _expandedCategories[cat] ?? false;

                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 6.h),
                                  child: Column(
                                    children: [
                                      ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor: txns.first.type == 'income' ? Colors.green : Colors.red,
                                          child: Text(cat[0].toUpperCase(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                        ),
                                        title: Text(cat, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp)),
                                        subtitle: Text('${txns.length} items'),
                                        trailing: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Text('${profile.currency}${total.toStringAsFixed(2)}',
                                                style: TextStyle(fontWeight: FontWeight.bold, color: txns.first.type == 'income' ? Colors.green : Colors.red)),
                                            Icon(isExpanded ? Icons.expand_less : Icons.expand_more),
                                          ],
                                        ),
                                        onTap: () => setState(() => _expandedCategories[cat] = !isExpanded),
                                      ),
                                      if (isExpanded)
                                        ...txns.map((t) => Padding(
                                              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
                                              child: Row(
                                                children: [
                                                  Expanded(child: Text(t.description ?? '')),
                                                  Text(t.date, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
                                                  SizedBox(width: 8.w),
                                                  Text('${profile.currency}${t.amount.toStringAsFixed(2)}',
                                                      style: TextStyle(color: t.type == 'income' ? Colors.green : Colors.red, fontWeight: FontWeight.w500)),
                                                ],
                                              ),
                                            )),
                                      if (isExpanded) Divider(height: 1),
                                    ],
                                  ),
                                );
                              }).toList(),
                            )
                    else
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bar_chart_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 8.h),
                            Text(widget.t['click_show'] ?? 'Click "Show" to view data'),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTotalBox(String title, double amount, Color color, Profile profile) {
    return Column(
      children: [
        Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.grey[600])),
        SizedBox(height: 4.h),
        Text('${profile.currency}${amount.toStringAsFixed(2)}', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }

  Widget _buildMonthField() {
    final monthStr = _selectedMonth != null ? '${_getMonthName(_selectedMonth!.month)} ${_selectedMonth!.year}' : '--';
    return GestureDetector(
      onTap: _pickMonth,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: widget.isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[400]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.t['month'] ?? 'Month', style: TextStyle(fontSize: 13.sp, color: Colors.grey)),
                Text(monthStr, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
              ],
            ),
            Icon(Icons.calendar_today, size: 20.sp),
          ],
        ),
      ),
    );
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }
}