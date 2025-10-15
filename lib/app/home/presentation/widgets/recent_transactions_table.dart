import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/profile_model.dart';

Widget buildRecentTransactionsTable(
  List<Transaction> transactions,
  Profile profile,
  Map<String, String> t,
  bool isDark,
  ThemeData themeData,
) {
  final recent = transactions.take(5).toList().reversed.toList();
  
  return Column(
    children: recent.map((transaction) {
      return Card(
        margin: EdgeInsets.only(bottom: 10.h),
        elevation: 2,
        color: isDark ? Colors.grey[850] : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              CircleAvatar(
                radius: 20.r,
                backgroundColor: transaction.type == 'income' 
                    ? Colors.green[100] 
                    : Colors.red[100],
                child: Icon(
                  transaction.type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                  color: transaction.type == 'income' ? Colors.green[800] : Colors.red[800],
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 12.w),
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Description
                    Text(
                      transaction.description,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    // Category
                    Chip(
                      label: Text(
                        t[transaction.category]!,
                        style: TextStyle(fontSize: 10.sp),
                      ),
                      backgroundColor: transaction.type == 'income' 
                          ? Colors.green[100] 
                          : Colors.red[100],
                      labelStyle: TextStyle(
                        color: transaction.type == 'income' 
                            ? Colors.green[800] 
                            : Colors.red[800],
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 0),
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      visualDensity: VisualDensity.compact,
                    ),
                    SizedBox(height: 4.h),
                    // Date
                    Text(
                      transaction.date,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Amount
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${profile.currency}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: transaction.type == 'income' ? Colors.green : Colors.red,
                    ),
                  ),
                  Text(
                    transaction.amount.toStringAsFixed(0),
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: transaction.type == 'income' ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }).toList(),
  );
}