import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../data/models/profile_model.dart';
import '../../data/models/transaction_model.dart';
import '../cubits/transaction_cubit.dart';
import '../cubits/profile_cubit.dart';
import '../../data/repositories/report_repository.dart';
import '../widgets/category_chart.dart';

class ReportsScreen extends StatelessWidget {
  final Map<String, String> t;
  final bool isDark;
  final ThemeData themeData;

  const ReportsScreen({
    super.key,
    required this.t,
    required this.isDark,
    required this.themeData,
  });

  Future<void> _exportToCsv(
    BuildContext context,
    List<Transaction> transactions,
  ) async {
    try {
      final List<List<dynamic>> csvData = [
        [
          'Type',
          'Category',
          'Amount',
          'Date',
          'Description',
          'Created By',
          'Created At',
        ],
        ...transactions.map(
          (t) => [
            t.type,
            t.category,
            t.amount,
            t.date,
            t.description,
            t.created_by,
            t.created_at,
          ],
        ),
      ];

      String csv = const ListToCsvConverter().convert(csvData);
      final directory = await getTemporaryDirectory();
      final path =
          '${directory.path}/financial_report_${DateTime.now().millisecondsSinceEpoch}.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([
        XFile(path),
      ], text: t['report_share_message'] ?? 'Financial Report');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t['export_error'] ?? 'Error exporting report')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isTablet = MediaQuery.of(context).size.width > 600;
    final bool isDesktop = MediaQuery.of(context).size.width > 1200;
    final bool isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return BlocBuilder<TransactionCubit, List<Transaction>>(
            builder: (context, transactions) {
              return BlocBuilder<ProfileCubit, Profile>(
                builder: (context, profile) {
                  final expenseByCategory = <String, double>{};
                  final incomeByCategory = <String, double>{};

                  for (var t in transactions) {
                    if (t.type == 'expense') {
                      expenseByCategory[t.category] =
                          (expenseByCategory[t.category] ?? 0) + t.amount;
                    } else {
                      incomeByCategory[t.category] =
                          (incomeByCategory[t.category] ?? 0) + t.amount;
                    }
                  }

                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isDesktop
                          ? 32.w
                          : isTablet
                          ? 24.w
                          : 16.w,
                      vertical: isDesktop ? 24.h : 16.h,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: Text(
                                t['reports']!,
                                style: TextStyle(
                                  fontSize: isDesktop
                                      ? 24.sp
                                      : isTablet
                                      ? 22.sp
                                      : 20.sp,
                                  fontWeight: FontWeight.bold,
                                  color: themeData.textTheme.bodyLarge!.color,
                                ),
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                try {
                                  await _exportToCsv(context, transactions);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Report downloaded successfully',
                                      ),
                                    ),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error downloading report: $e',
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.download,
                                size: isDesktop ? 24.sp : 20.sp,
                              ),
                              label: Text(
                                t['download']!,
                                style: TextStyle(
                                  fontSize: isDesktop ? 16.sp : 14.sp,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.indigo[600],
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(
                                  horizontal: isDesktop
                                      ? 24.w
                                      : isTablet
                                      ? 20.w
                                      : 16.w,
                                  vertical: isDesktop ? 12.h : 8.h,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isDesktop ? 32.h : 24.h),
                        // Constrain GridView height for charts
                        SizedBox(
                          height: isLandscape
                              ? constraints.maxHeight * 0.5
                              : constraints.maxHeight * 0.7,
                          child: GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: isDesktop
                                ? 3
                                : isTablet
                                ? 2
                                : 1,
                            crossAxisSpacing: isDesktop ? 24.w : 16.w,
                            mainAxisSpacing: isDesktop ? 24.h : 16.h,
                            childAspectRatio: isDesktop
                                ? 1.8
                                : isTablet
                                ? 1.5
                                : isLandscape
                                ? 1.4
                                : 1.2,
                            children: [
                              buildCategoryChart(
                                expenseByCategory,
                                expenseByCategory.values.fold(
                                  0.0,
                                  (sum, amt) => sum + amt,
                                ),
                                Colors.red,
                                profile,
                                t,
                                t['expenseByCategory']!,
                              ),
                              buildCategoryChart(
                                incomeByCategory,
                                incomeByCategory.values.fold(
                                  0.0,
                                  (sum, amt) => sum + amt,
                                ),
                                Colors.green,
                                profile,
                                t,
                                t['incomeByCategory']!,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: isDesktop ? 32.h : 24.h),
                        // Transaction cards section
                        Text(
                          t['transactions'] ?? 'Transactions',
                          style: TextStyle(
                            fontSize: isDesktop ? 20.sp : 18.sp,
                            fontWeight: FontWeight.bold,
                            color: themeData.textTheme.bodyLarge!.color,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        transactions.isEmpty
                            ? Center(
                                child: Text(
                                  t['no_data'] ?? 'No transactions available',
                                  style: TextStyle(
                                    fontSize: isDesktop ? 16.sp : 14.sp,
                                    color: themeData.textTheme.bodyLarge!.color,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: transactions.length,
                                itemBuilder: (context, index) {
                                  final transaction = transactions[index];
                                  return _buildTransactionCard(
                                    context,
                                    transaction: transaction,
                                    isDesktop: isDesktop,
                                    isTablet: isTablet,
                                  );
                                },
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
    );
  }

  Widget _buildTransactionCard(
    BuildContext context, {
    required Transaction transaction,
    required bool isDesktop,
    required bool isTablet,
  }) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      color: isDark ? themeData.cardColor : Colors.white,
      child: Padding(
        padding: EdgeInsets.all(isDesktop ? 16.w : 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  transaction.category,
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 16.sp
                        : isTablet
                        ? 15.sp
                        : 14.sp,
                    fontWeight: FontWeight.w600,
                    color: themeData.textTheme.bodyLarge!.color,
                  ),
                ),
                Text(
                  '\$${transaction.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: isDesktop
                        ? 16.sp
                        : isTablet
                        ? 15.sp
                        : 14.sp,
                    fontWeight: FontWeight.bold,
                    color: transaction.type == 'expense'
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              '${t['type'] ?? 'Type'}: ${transaction.type}',
              style: TextStyle(
                fontSize: isDesktop
                    ? 14.sp
                    : isTablet
                    ? 13.sp
                    : 12.sp,
                color: themeData.textTheme.bodyMedium!.color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              '${t['date'] ?? 'Date'}: ${transaction.date.split('T')[0]}',
              style: TextStyle(
                fontSize: isDesktop
                    ? 14.sp
                    : isTablet
                    ? 13.sp
                    : 12.sp,
                color: themeData.textTheme.bodyMedium!.color,
              ),
            ),
            if (transaction.description != null &&
                transaction.description!.isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                '${t['description'] ?? 'Description'}: ${transaction.description}',
                style: TextStyle(
                  fontSize: isDesktop
                      ? 14.sp
                      : isTablet
                      ? 13.sp
                      : 12.sp,
                  color: themeData.textTheme.bodyMedium!.color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
