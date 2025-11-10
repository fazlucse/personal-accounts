// lib/app/home/presentation/screens/reports_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';

import '../../data/models/profile_model.dart';
import '../../data/models/transaction_model.dart';
import '../cubits/profile_cubit.dart';
import '../../data/repositories/report_repository.dart';
import '../widgets/category_chart.dart';
import '../cubits/category_cubit.dart'; // <-- NEW

final getIt = GetIt.instance;

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
  bool _filtersExpanded = false;
  List<Transaction> _filteredTransactions = [];
  bool _isLoading = false;

  final _reportRepo = ReportRepository();
  final Map<String, bool> _expandedCategories = {};

  late final CategoryCubit _categoryCubit;

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime(DateTime.now().year, DateTime.now().month, 1);
    _categoryCubit = getIt<CategoryCubit>();
  }

  // ──────────────────────────────────────────────────────────────
  //  FILTER LOGIC
  // ──────────────────────────────────────────────────────────────
  Future<void> _pickMonth() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (c, child) => Theme(data: widget.themeData, child: child!),
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
      final allTransactions = await _reportRepo.getTransactions(
        from: from,
        to: to,
      );

      final filtered = allTransactions.where((t) {
        final typeMatch = _selectedType == 'all' || t.type == _selectedType;
        final catMatch =
            _selectedCategory == 'all' || t.category == _selectedCategory;
        return typeMatch && catMatch;
      }).toList();

      filtered.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _filteredTransactions = filtered;
        _showTransactions = true;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _downloadReport() async {
    if (_filteredTransactions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No data to download')));
      return;
    }
    try {
      await _reportRepo.downloadReport(_filteredTransactions);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Download failed: $e')));
    }
  }

  // ──────────────────────────────────────────────────────────────
  //  UI
  // ──────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final isDesktop = MediaQuery.of(context).size.width > 1200;

    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return BlocBuilder<ProfileCubit, Profile>(
              builder: (context, profile) {
                return BlocBuilder<CategoryCubit, CategoryState>(
                  bloc: _categoryCubit,
                  builder: (context, catState) {
                    // ── CATEGORIES FROM SQLITE ──
                    final allCategories = [
                      'all',
                      ...catState.expense,
                      ...catState.income,
                    ];
                    final uniqueCategories = allCategories.toSet().toList();

                    // ── TOTALS ──
                    double totalIncome = 0, totalExpense = 0;
                    for (var t in _filteredTransactions) {
                      if (t.type == 'income')
                        totalIncome += t.amount;
                      else
                        totalExpense += t.amount;
                    }
                    final balance = totalIncome - totalExpense;

                    // ── GROUP BY CATEGORY ──
                    final grouped = <String, List<Transaction>>{};
                    for (var t in _filteredTransactions) {
                      final cat = (t.category?.trim().isNotEmpty == true)
                          ? t.category!
                          : 'Other';
                      grouped.putIfAbsent(cat, () => []).add(t);
                    }

                    final sortedCats = grouped.keys.toList()
                      ..sort((a, b) {
                        final sumA = grouped[a]!.fold(
                          0.0,
                          (s, t) => s + t.amount,
                        );
                        final sumB = grouped[b]!.fold(
                          0.0,
                          (s, t) => s + t.amount,
                        );
                        return sumB.compareTo(sumA);
                      });

                    // ── CHARTS ──
                    final expenseByCat = <String, double>{};
                    final incomeByCat = <String, double>{};
                    for (var t in _filteredTransactions) {
                      final cat = (t.category?.trim().isNotEmpty == true)
                          ? t.category!
                          : 'Other';
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
                          // ── HEADER ──
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.t['reports']!,
                                style: TextStyle(
                                  fontSize: 24.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _downloadReport,
                                icon: Icon(Icons.download, size: 20.sp),
                                label: Text(
                                  widget.t['download']!,
                                  style: TextStyle(fontSize: 14.sp),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.indigo[600],
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 8.h,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16.h),

                          // ── TOTAL SUMMARY ──
                          Card(
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Container(
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12.r),
                                gradient: LinearGradient(
                                  colors: widget.isDark
                                      ? [Colors.grey[850]!, Colors.grey[900]!]
                                      : [Colors.white, Colors.grey[50]!],
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  _buildTotalBox(
                                    'Income',
                                    totalIncome,
                                    Colors.green,
                                    profile,
                                  ),
                                  _buildTotalBox(
                                    'Expense',
                                    totalExpense,
                                    Colors.red,
                                    profile,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // ── COLLAPSIBLE FILTERS ──
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    _filtersExpanded
                                        ? Icons.filter_alt
                                        : Icons.filter_alt_off,
                                  ),
                                  title: Text(
                                    widget.t['filters'] ?? 'Filters',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.sp,
                                    ),
                                  ),
                                  trailing: Icon(
                                    _filtersExpanded
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                  ),
                                  onTap: () => setState(
                                    () => _filtersExpanded = !_filtersExpanded,
                                  ),
                                ),
                                ClipRect(
                                  child: AnimatedCrossFade(
                                    firstChild: const SizedBox.shrink(),
                                    secondChild: _buildFilterContent(
                                      uniqueCategories,
                                    ),
                                    crossFadeState: _filtersExpanded
                                        ? CrossFadeState.showSecond
                                        : CrossFadeState.showFirst,
                                    duration: const Duration(milliseconds: 250),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 24.h),

                          // ── CHARTS ──
                          if (_showTransactions &&
                              _filteredTransactions.isNotEmpty)
                            SizedBox(
                              height: isDesktop ? 350.h : 300.h,
                              child: GridView.count(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                crossAxisCount: isDesktop ? 2 : 1,
                                childAspectRatio: isDesktop ? 1.8 : 1.5,
                                mainAxisSpacing: 16.h,
                                children: [
                                  buildCategoryChart(
                                    expenseByCat,
                                    expenseByCat.values.fold(
                                      0.0,
                                      (a, b) => a + b,
                                    ),
                                    Colors.red,
                                    profile,
                                    widget.t,
                                    widget.t['expenseByCategory']!,
                                  ),
                                ],
                              ),
                            )
                          else if (_showTransactions)
                            Center(
                              child: Card(
                                child: Padding(
                                  padding: EdgeInsets.all(24.w),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.bar_chart_outlined,
                                        size: 48.sp,
                                        color: Colors.grey,
                                      ),
                                      SizedBox(height: 8.h),
                                      Text(
                                        widget.t['no_data'] ??
                                            'No data to display',
                                        style: TextStyle(fontSize: 16.sp),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),

                          SizedBox(height: 24.h),

                          // ── GROUPED TRANSACTIONS ──
                          if (_showTransactions)
                            _filteredTransactions.isEmpty
                                ? Center(
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.inbox_outlined,
                                          size: 64.sp,
                                          color: Colors.grey,
                                        ),
                                        SizedBox(height: 8.h),
                                        Text(
                                          widget.t['no_data'] ??
                                              'No transactions found',
                                          style: TextStyle(fontSize: 16.sp),
                                        ),
                                      ],
                                    ),
                                  )
                                : Column(
                                    children: sortedCats.map((cat) {
                                      final txns = grouped[cat]!;
                                      final total = txns.fold(
                                        0.0,
                                        (s, t) => s + t.amount,
                                      );
                                      final isExpanded =
                                          _expandedCategories[cat] ?? false;

                                      return Card(
                                        margin: EdgeInsets.symmetric(
                                          vertical: 6.h,
                                        ),
                                        elevation: 2,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10.r,
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            ListTile(
                                              contentPadding:
                                                  EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 8.h,
                                                  ),
                                              leading: CircleAvatar(
                                                radius: 18.r,
                                                backgroundColor:
                                                    txns.first.type == 'income'
                                                    ? Colors.green
                                                    : Colors.red,
                                                child: Text(
                                                  cat[0].toUpperCase(),
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.sp,
                                                  ),
                                                ),
                                              ),
                                              title: Text(
                                                cat,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16.sp,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              subtitle: Text(
                                                '${txns.length} items',
                                                style: TextStyle(
                                                  fontSize: 13.sp,
                                                ),
                                              ),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text(
                                                    '${profile.currency} ${total.toStringAsFixed(2)}',
                                                    style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          txns.first.type ==
                                                              'income'
                                                          ? Colors.green
                                                          : Colors.red,
                                                      fontSize: 14.sp,
                                                    ),
                                                  ),
                                                  SizedBox(width: 8.w),
                                                  Icon(
                                                    isExpanded
                                                        ? Icons.expand_less
                                                        : Icons.expand_more,
                                                  ),
                                                ],
                                              ),
                                              onTap: () => setState(
                                                () => _expandedCategories[cat] =
                                                    !isExpanded,
                                              ),
                                            ),
                                            if (isExpanded)
                                              ...txns.map(
                                                (t) => Padding(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 16.w,
                                                    vertical: 6.h,
                                                  ),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                        t.description ?? '',
                                                        style: TextStyle(
                                                          fontSize: 14.sp,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        maxLines: 1,
                                                      ),
                                                      SizedBox(height: 2.h),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            t.date,
                                                            style: TextStyle(
                                                              fontSize: 12.sp,
                                                              color: Colors
                                                                  .grey[600],
                                                            ),
                                                          ),
                                                          Text(
                                                            '${profile.currency} ${t.amount.toStringAsFixed(2)}',
                                                            style: TextStyle(
                                                              color:
                                                                  t.type ==
                                                                      'income'
                                                                  ? Colors.green
                                                                  : Colors.red,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              fontSize: 14.sp,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            if (isExpanded)
                                              const Divider(height: 1),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                  )
                          else
                            Center(
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.bar_chart_outlined,
                                    size: 64.sp,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8.h),
                                  Text(
                                    widget.t['click_show'] ??
                                        'Click "Show" to view data',
                                    style: TextStyle(fontSize: 16.sp),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  FILTER CONTENT
  // ──────────────────────────────────────────────────────────────
  Widget _buildFilterContent(List<String> categories) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isSmall = constraints.maxWidth < 500;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMonthField(),
              SizedBox(height: 16.h),
              isSmall
                  ? Column(
                      children: [
                        _buildDropdown(
                          value: _selectedType,
                          label: widget.t['type'] ?? 'Type',
                          items: [
                            {'value': 'all', 'label': 'All'},
                            {'value': 'income', 'label': 'Income'},
                            {'value': 'expense', 'label': 'Expense'},
                          ],
                          onChanged: (v) => setState(() => _selectedType = v!),
                        ),
                        SizedBox(height: 12.h),
                        _buildDropdown(
                          value: _selectedCategory,
                          label: widget.t['category'] ?? 'Category',
                          items: categories
                              .map(
                                (c) => {
                                  'value': c,
                                  'label': c == 'all' ? 'All' : c,
                                },
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedCategory = v!),
                        ),
                      ],
                    )
                  : Row(
                      children: [
                        Expanded(
                          child: _buildDropdown(
                            value: _selectedType,
                            label: widget.t['type'] ?? 'Type',
                            items: [
                              {'value': 'all', 'label': 'All'},
                              {'value': 'income', 'label': 'Income'},
                              {'value': 'expense', 'label': 'Expense'},
                            ],
                            onChanged: (v) =>
                                setState(() => _selectedType = v!),
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: _buildDropdown(
                            value: _selectedCategory,
                            label: widget.t['category'] ?? 'Category',
                            items: categories
                                .map(
                                  (c) => {
                                    'value': c,
                                    'label': c == 'all' ? 'All' : c,
                                  },
                                )
                                .toList(),
                            onChanged: (v) =>
                                setState(() => _selectedCategory = v!),
                          ),
                        ),
                      ],
                    ),
              SizedBox(height: 16.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _fetchFilteredData,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo[600],
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                  child: _isLoading
                      ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.t['show'] ?? 'Show',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                          ),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ──────────────────────────────────────────────────────────────
  //  HELPERS
  // ──────────────────────────────────────────────────────────────
  Widget _buildTotalBox(
    String title,
    double amount,
    Color color,
    Profile profile,
  ) {
    return Column(
      children: [
        Text(
          title,
          style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
        ),
        SizedBox(height: 4.h),
        Text(
          '${profile.currency} ${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildMonthField() {
    final monthStr = _selectedMonth != null
        ? '${_getMonthName(_selectedMonth!.month)} ${_selectedMonth!.year}'
        : '--';
    return GestureDetector(
      onTap: _pickMonth,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
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
                Text(
                  widget.t['month'] ?? 'Month',
                  style: TextStyle(fontSize: 13.sp, color: Colors.grey[600]),
                ),
                Text(
                  monthStr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Icon(Icons.calendar_today, size: 20.sp),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required String label,
    required List<Map<String, String>> items,
    required void Function(String?) onChanged,
  }) {
    return GestureDetector(
      onTap: () => _showDropdownWithSearch(
        label: label,
        value: value,
        items: items,
        onChanged: onChanged,
      ),
      child: AbsorbPointer(
        child: DropdownButtonFormField<String>(
          value: value.isNotEmpty ? value : null,
          isExpanded: true,
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 16.h,
            ),
          ),
          items: items
              .map(
                (i) => DropdownMenuItem(
                  value: i['value'],
                  child: Text(
                    i['label']!,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              )
              .toList(),
          onChanged: onChanged,
          style: TextStyle(
            fontSize: 14.sp,
            color: widget.isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }

void _showDropdownWithSearch({
  required String label,
  required String value,
  required List<Map<String, String>> items,
  required void Function(String?) onChanged,
}) {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, String>> filteredItems = List.from(items);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Theme.of(context).cardColor,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    builder: (context) {
      return DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16.w,
              right: 16.w,
              top: 16.h,
            ),
            child: StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  // 🔍 Search Field (pinned)
                  TextField(
                    controller: searchController,
                    onChanged: (query) {
                      setState(() {
                        filteredItems = items
                            .where((i) => i['label']!
                                .toLowerCase()
                                .contains(query.toLowerCase()))
                            .toList();
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search $label...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 10.h,
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),

                  // 📋 Scrollable List
                  Expanded(
                    child: filteredItems.isEmpty
                        ? Center(
                            child: Text(
                              'No $label found',
                              style: TextStyle(fontSize: 14.sp),
                            ),
                          )
                        : ListView.builder(
                            controller: scrollController,
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              final item = filteredItems[index];
                              return InkWell(
                                onTap: () {
                                  onChanged(item['value']);
                                  Navigator.pop(context);
                                },
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w,
                                    vertical: 12.h,
                                  ),
                                  decoration: BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: Colors.grey.shade200.withOpacity(0.6),
  width: 0.8, // slightly thicker
                                      ),
                                    ),
                                  ),
                                  child: Text(
                                    item['label']!,
                                    style: TextStyle(fontSize: 14.sp),
                                  ),
                                ),
                              );
                            },
                          ),
                  ),

                  // 🚫 Cancel Button
                  SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[300],
                          foregroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

  String _getMonthName(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return months[month - 1];
  }
}
