// lib/app/home/presentation/widgets/add_transaction_bottom_sheet.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:test_app/app/home/presentation/widgets/category_dropdown.dart';
import 'package:get_it/get_it.dart';
import '../../data/models/transaction_model.dart';
import '../../presentation/cubits/transaction_cubit.dart';
import '../../presentation/cubits/category_cubit.dart';

final getIt = GetIt.instance;

void showAddTransactionBottomSheet({
  required BuildContext context,
  required Map<String, String> translations,
  required bool isDark,
  required ThemeData themeData,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
    ),
    backgroundColor: isDark ? themeData.scaffoldBackgroundColor : Colors.white,
    builder: (context) {
      return AddTransactionScreen(
        t: translations,
        isDark: isDark,
        themeData: themeData,
      );
    },
  );
}

class AddTransactionScreen extends StatelessWidget {
  final Map<String, String> t;
  final bool isDark;
  final ThemeData themeData;

  const AddTransactionScreen({
    super.key,
    required this.t,
    required this.isDark,
    required this.themeData,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return _AddTransactionForm(
          t: t,
          isDark: isDark,
          themeData: themeData,
          scrollController: scrollController,
        );
      },
    );
  }
}

class _AddTransactionForm extends StatefulWidget {
  final Map<String, String> t;
  final bool isDark;
  final ThemeData themeData;
  final ScrollController scrollController;

  const _AddTransactionForm({
    required this.t,
    required this.isDark,
    required this.themeData,
    required this.scrollController,
  });

  @override
  State<_AddTransactionForm> createState() => _AddTransactionFormState();
}

class _AddTransactionFormState extends State<_AddTransactionForm> {
  final _formKey = GlobalKey<FormState>();
  String type = 'expense';
  String? category;
  final TextEditingController amountController = TextEditingController();
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final TextEditingController descriptionController = TextEditingController();

  late final CategoryCubit _categoryCubit;

  // Validation flags
  bool _amountValid = true;
  bool _categoryValid = true;

  @override
  void initState() {
    super.initState();
    _categoryCubit = getIt<CategoryCubit>();
  }

  void _validateAndSubmit() {
    setState(() {
      _amountValid = amountController.text.trim().isNotEmpty && double.tryParse(amountController.text) != null;
      _categoryValid = category != null;
    });

    if (_amountValid && _categoryValid) {
      final amount = double.parse(amountController.text);
      getIt<TransactionCubit>().addTransaction(
        Transaction(
          id: DateTime.now().millisecondsSinceEpoch,
          type: type,
          category: category!,
          amount: amount,
          date: date,
          description: descriptionController.text.trim(),
        ),
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${widget.t['add']!} Successful')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(widget.t['fillRequired'] ?? 'Please fill all required fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;
    final textColor = widget.isDark ? Colors.white : Colors.black;
    final backgroundColor = widget.isDark
        ? widget.themeData.scaffoldBackgroundColor
        : Colors.white;
    final errorColor = Colors.red[400]!;

    return Container(
      color: backgroundColor,
      child: BlocBuilder<CategoryCubit, CategoryState>(
        bloc: _categoryCubit,
        builder: (context, catState) {
          if (catState.status == CategoryStatus.loading ||
              catState.status == CategoryStatus.initial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (catState.status == CategoryStatus.error) {
            return Center(
              child: Text(
                'Error: ${catState.error}',
                style: TextStyle(color: errorColor),
              ),
            );
          }

          final incomeCategories = catState.income;
          final expenseCategories = catState.expense;

          return Stack(
            children: [
              Form(
                key: _formKey,
                child: SingleChildScrollView(
                  controller: widget.scrollController,
                  padding: EdgeInsets.symmetric(
                    horizontal: isTablet ? 32.w : 16.w,
                    vertical: 16.h,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Drag handle
                      Center(
                        child: Container(
                          width: 40.w,
                          height: 4.h,
                          margin: EdgeInsets.only(bottom: 16.h),
                          decoration: BoxDecoration(
                            color: textColor.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),

                      // Title
                      Text(
                        widget.t['addTransaction']!,
                        style: TextStyle(
                          fontSize: isTablet ? 24.sp : 20.sp,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      SizedBox(height: 16.h),

                      // Income / Expense Toggle
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() {
                                type = 'income';
                                category = null; // Reset category
                              }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: type == 'income'
                                    ? Colors.green[50]
                                    : (widget.isDark ? Colors.grey[800] : Colors.grey[200]),
                                side: BorderSide(color: type == 'income' ? Colors.green : Colors.grey),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text(
                                widget.t['income']!,
                                style: TextStyle(
                                  color: type == 'income' ? Colors.green[700] : textColor,
                                  fontSize: isTablet ? 16.sp : 14.sp,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 16.w),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() {
                                type = 'expense';
                                category = null;
                              }),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: type == 'expense'
                                    ? Colors.red[50]
                                    : (widget.isDark ? Colors.grey[800] : Colors.grey[200]),
                                side: BorderSide(color: type == 'expense' ? Colors.red : Colors.grey),
                                padding: EdgeInsets.symmetric(vertical: 12.h),
                              ),
                              child: Text(
                                widget.t['expense']!,
                                style: TextStyle(
                                  color: type == 'expense' ? Colors.red[700] : textColor,
                                  fontSize: isTablet ? 16.sp : 14.sp,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),

                      // Category (MANDATORY)
                      Text(
                        '${widget.t['category']!}',
                        style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp, color: textColor),
                      ),
                      CategoryDropdown(
                        value: category,
                        isExpanded: true,
                        isTablet: isTablet,
                        type: type,
                        translations: widget.t,
                        onChanged: (v) => setState(() => category = v),
                        incomeCategories: incomeCategories,
                        expenseCategories: expenseCategories,
                      ),
                      if (!_categoryValid)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            widget.t['categoryRequired'] ?? 'Please select a category',
                            style: TextStyle(color: errorColor, fontSize: 12.sp),
                          ),
                        ),

                      // Amount (MANDATORY)
                      SizedBox(height: 16.h),
                      Text(
                        '${widget.t['amount']!}',
                        style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp, color: textColor),
                      ),
                      TextField(
                        controller: amountController,
                        keyboardType: TextInputType.numberWithOptions(decimal: true),
                        style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp, color: textColor),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: _amountValid
                                  ? (widget.isDark ? Colors.grey[700]! : Colors.grey[300]!)
                                  : errorColor,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: Colors.indigo[600]!),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(color: errorColor),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                          hintText: '0.00',
                        ),
                        onChanged: (_) => setState(() => _amountValid = true),
                      ),
                      if (!_amountValid)
                        Padding(
                          padding: EdgeInsets.only(top: 4.h),
                          child: Text(
                            widget.t['amountRequired'] ?? 'Please enter a valid amount',
                            style: TextStyle(color: errorColor, fontSize: 12.sp),
                          ),
                        ),

                      // Date (MANDATORY)
                      SizedBox(height: 16.h),
                      Text(
                        '${widget.t['date']!}',
                        style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp, color: textColor),
                      ),
                      TextField(
                        readOnly: true,
                        controller: TextEditingController(text: date),
                        style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp, color: textColor),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.parse(date),
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2100),
                            builder: (c, child) => Theme(
                              data: widget.isDark ? ThemeData.dark() : ThemeData.light(),
                              child: child!,
                            ),
                          );
                          if (picked != null) {
                            setState(() => date = DateFormat('yyyy-MM-dd').format(picked));
                          }
                        },
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: widget.isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        ),
                      ),

                      // Description (Optional)
                      SizedBox(height: 16.h),
                      Text(
                        widget.t['description']!,
                        style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp, color: textColor),
                      ),
                      TextField(
                        controller: descriptionController,
                        style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp, color: textColor),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            borderSide: BorderSide(
                              color: widget.isDark ? Colors.grey[700]! : Colors.grey[300]!,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        ),
                      ),

                      SizedBox(height: 24.h),

                      // Add Button
                      ElevatedButton.icon(
                        onPressed: _validateAndSubmit,
                        icon: Icon(Icons.add, size: isTablet ? 24.sp : 20.sp),
                        label: Text(widget.t['add']!, style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[600],
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, isTablet ? 56.h : 48.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        ),
                      ),
                      SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
                    ],
                  ),
                ),
              ),

              // TOP-RIGHT CLOSE BUTTON
              Positioned(
                top: 8.h,
                right: 8.w,
                child: IconButton(
                  icon: Icon(Icons.close, color: textColor, size: 28.sp),
                  onPressed: () => Navigator.pop(context),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                  splashRadius: 24.r,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}