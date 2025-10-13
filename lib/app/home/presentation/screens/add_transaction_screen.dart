import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../cubits/transaction_cubit.dart';
import '../../data/models/transaction_model.dart';

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
    backgroundColor: themeData.scaffoldBackgroundColor,
    builder: (context) {
      return BlocProvider.value(
        value: context.read<TransactionCubit>(),
        child: AddTransactionScreen(
          t: translations,
          isDark: isDark,
          themeData: themeData,
        ),
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
  String type = 'expense';
  String category = 'food';
  final TextEditingController amountController = TextEditingController();
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    return SingleChildScrollView(
      controller: widget.scrollController,
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 32.w : 16.w,
        vertical: 16.h,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              margin: EdgeInsets.only(bottom: 16.h),
              decoration: BoxDecoration(
                color: widget.themeData.textTheme.bodyMedium!.color!.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Text(
            widget.t['addTransaction']!,
            style: TextStyle(
              fontSize: isTablet ? 24.sp : 20.sp,
              fontWeight: FontWeight.bold,
              color: widget.themeData.textTheme.bodyLarge!.color,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      type = 'income';
                      category = 'salary';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == 'income' ? Colors.green[50] : null,
                    side: BorderSide(color: type == 'income' ? Colors.green : Colors.grey),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    widget.t['income']!,
                    style: TextStyle(
                      color: type == 'income' ? Colors.green[700] : widget.themeData.textTheme.bodyMedium!.color,
                      fontSize: isTablet ? 16.sp : 14.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      type = 'expense';
                      category = 'food';
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: type == 'expense' ? Colors.red[50] : null,
                    side: BorderSide(color: type == 'expense' ? Colors.red : Colors.grey),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    widget.t['expense']!,
                    style: TextStyle(
                      color: type == 'expense' ? Colors.red[700] : widget.themeData.textTheme.bodyMedium!.color,
                      fontSize: isTablet ? 16.sp : 14.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            widget.t['category']!,
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 14.sp,
              color: widget.themeData.textTheme.bodyMedium!.color,
            ),
          ),
          DropdownButton<String>(
            value: category,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                setState(() => category = value);
              }
            },
            items: (type == 'income'
                    ? ['salary', 'freelance', 'business', 'investment', 'other']
                    : ['food', 'transport', 'bills', 'shopping', 'entertainment', 'health', 'education', 'other'])
                .map((cat) => DropdownMenuItem(
                      value: cat,
                      child: Text(
                        widget.t[cat]!,
                        style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
                      ),
                    ))
                .toList(),
          ),
          SizedBox(height: 16.h),
          Text(
            widget.t['amount']!,
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 14.sp,
              color: widget.themeData.textTheme.bodyMedium!.color,
            ),
          ),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
            style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            widget.t['date']!,
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 14.sp,
              color: widget.themeData.textTheme.bodyMedium!.color,
            ),
          ),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: date),
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.parse(date),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                builder: (context, child) {
                  return Theme(
                    data: widget.isDark ? ThemeData.dark() : ThemeData.light(),
                    child: child!,
                  );
                },
              );
              if (selectedDate != null) {
                setState(() => date = DateFormat('yyyy-MM-dd').format(selectedDate));
              }
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
            style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
          ),
          SizedBox(height: 16.h),
          Text(
            widget.t['description']!,
            style: TextStyle(
              fontSize: isTablet ? 16.sp : 14.sp,
              color: widget.themeData.textTheme.bodyMedium!.color,
            ),
          ),
          TextField(
            controller: descriptionController,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
            ),
            style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              final amount = double.tryParse(amountController.text);
              if (amount != null && descriptionController.text.isNotEmpty) {
                context.read<TransactionCubit>().addTransaction(
                      Transaction(
                        id: DateTime.now().millisecondsSinceEpoch,
                        type: type,
                        category: category,
                        amount: amount,
                        date: date,
                        description: descriptionController.text,
                      ),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(widget.t['add']! + ' Successful')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Please enter valid amount and description')),
                );
              }
            },
            icon: Icon(Icons.add, size: isTablet ? 24.sp : 20.sp),
            label: Text(
              widget.t['add']!,
              style: TextStyle(fontSize: isTablet ? 16.sp : 14.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, isTablet ? 56.h : 48.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
        ],
      ),
    );
  }
}