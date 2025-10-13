import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, List<Transaction>>(
      builder: (context, transactions) {
        return BlocBuilder<ProfileCubit, Profile>(
          builder: (context, profile) {
            final expenseByCategory = <String, double>{};
            final incomeByCategory = <String, double>{};

            for (var t in transactions) {
              if (t.type == 'expense') {
                expenseByCategory[t.category] = (expenseByCategory[t.category] ?? 0) + t.amount;
              } else {
                incomeByCategory[t.category] = (incomeByCategory[t.category] ?? 0) + t.amount;
              }
            }

            final totalExpense = expenseByCategory.values.fold(0.0, (sum, amt) => sum + amt);
            final totalIncome = incomeByCategory.values.fold(0.0, (sum, amt) => sum + amt);

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        t['reports']!,
                        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: themeData.textTheme.bodyLarge!.color),
                      ),
                      ElevatedButton.icon(
                        onPressed: () => context.read<ReportRepository>().downloadReport(transactions),
                        icon: Icon(Icons.download, size: 20.sp),
                        label: Text(t['download']!),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.indigo[600],
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 2 : 1,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    childAspectRatio: 1.5,
                    children: [
                      buildCategoryChart(
                        expenseByCategory,
                        totalExpense,
                        Colors.red,
                        profile,
                        t,
                        t['expenseByCategory']!,
                      ),
                      buildCategoryChart(
                        incomeByCategory,
                        totalIncome,
                        Colors.green,
                        profile,
                        t,
                        t['incomeByCategory']!,
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}