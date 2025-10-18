import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../data/models/transaction_model.dart';
import '../../data/models/profile_model.dart';

Widget buildRecentTransactionsTable({
  required List<Transaction> transactions,
  required Profile profile,
  required Map<String, String> t,
  required bool isDark,
  required ThemeData themeData,
  required Function(Transaction) onDelete,
  required BuildContext context, // Add context parameter
}) {
  // Filter transactions to include only those with non-null date, category, amount, and type
  final recent = transactions
      .where((transaction) =>
          transaction.date != null &&
          transaction.category != null &&
          transaction.amount != null &&
          transaction.type != null)
      .take(100)
      .toList()
      .reversed
      .toList();

  // Show fallback UI if no transactions remain after filtering
  if (recent.isEmpty) {
    return Center(
      child: Text(
        'No transactions available',
        style: TextStyle(
          fontSize: 16.sp,
          color: isDark ? Colors.grey[400] : Colors.grey[600],
        ),
      ),
    );
  }

  // Confirmation dialog for deletion
  Future<bool> _confirmDelete(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Delete Transaction',
              style: TextStyle(
                color: isDark ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Are you sure you want to delete this transaction?',
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[700],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancel',
                  style: TextStyle(
                    color: isDark ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Delete',
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
            backgroundColor: isDark ? Colors.grey[850] : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ) ??
        false; // Return false if dialog is dismissed
  }

  return Column(
    children: recent.map((transaction) {
      // Since we filtered out nulls for these fields, we can safely use non-null assertions
      final category = transaction.category!;
      final date = transaction.date!;
      final amount = transaction.amount!;
      final type = transaction.type!;
      final description = transaction.description; // Keep description nullable
      final categoryText = t.containsKey(category) ? t[category]! : category;

      return Dismissible(
        key: Key(transaction.hashCode.toString()), // Unique key for each transaction
        direction: DismissDirection.endToStart, // Swipe left to delete
        confirmDismiss: (direction) async {
          // Show confirmation dialog before deletion
          return await _confirmDelete(context);
        },
        onDismissed: (direction) {
          // Call the onDelete callback when confirmed
          onDelete(transaction);
        },
        background: Container(
          color: Colors.red,
          alignment: Alignment.centerRight,
          padding: EdgeInsets.only(right: 20.w),
          child: Icon(
            Icons.delete,
            color: Colors.white,
            size: 24.sp,
          ),
        ),
        child: Card(
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
                  backgroundColor: type == 'income' ? Colors.green[100] : Colors.red[100],
                  child: Icon(
                    type == 'income' ? Icons.arrow_downward : Icons.arrow_upward,
                    color: type == 'income' ? Colors.green[800] : Colors.red[800],
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                // Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      Text(
                        categoryText,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      // Date
                      Text(
                        date,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: isDark ? Colors.grey[400] : Colors.grey[600],
                        ),
                      ),
                      // Conditionally show description and its SizedBox
                      if (description != null) ...[
                        SizedBox(height: 4.h),
                        // Description
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // Amount
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'BDT',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: type == 'income' ? Colors.green : Colors.red,
                      ),
                    ),
                    Text(
                      amount.toStringAsFixed(0),
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: type == 'income' ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }).toList(),
  );
}