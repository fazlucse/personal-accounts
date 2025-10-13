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
  return Table(
    border: TableBorder.all(color: isDark ? Colors.grey[700]! : Colors.grey[200]!),
    children: [
      TableRow(
        decoration: BoxDecoration(color: isDark ? Colors.grey[700] : Colors.grey[50]),
        children: [
          Padding(padding: EdgeInsets.all(8.w), child: Text(t['date']!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold))),
          Padding(padding: EdgeInsets.all(8.w), child: Text(t['description']!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold))),
          Padding(padding: EdgeInsets.all(8.w), child: Text(t['category']!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold))),
          Padding(padding: EdgeInsets.all(8.w), child: Text(t['amount']!, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold))),
        ],
      ),
      ...recent.map((transaction) {
        return TableRow(
          children: [
            Padding(padding: EdgeInsets.all(8.w), child: Text(transaction.date, style: TextStyle(fontSize: 12.sp))),
            Padding(padding: EdgeInsets.all(8.w), child: Text(transaction.description, style: TextStyle(fontSize: 12.sp))),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Chip(
                label: Text(t[transaction.category]!, style: TextStyle(fontSize: 10.sp)),
                backgroundColor: transaction.type == 'income' ? Colors.green[100] : Colors.red[100],
                labelStyle: TextStyle(color: transaction.type == 'income' ? Colors.green[800] : Colors.red[800]),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                '${transaction.type == 'income' ? '+' : '-'}${profile.currency} ${transaction.amount.toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: transaction.type == 'income' ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      }),
    ],
  );
}