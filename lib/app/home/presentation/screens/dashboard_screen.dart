import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:test_app/app/home/data/models/transaction_model.dart';
import '../../data/models/profile_model.dart';
import '../cubits/transaction_cubit.dart';
import '../cubits/profile_cubit.dart';
import '../widgets/stat_card.dart';
import '../widgets/recent_transactions_table.dart';

final getIt = GetIt.instance;

class DashboardScreen extends StatelessWidget {
  final Map<String, String> t;
  final bool isDark;
  final ThemeData themeData;

  const DashboardScreen({
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
            final income = transactions.where((t) => t.type == 'income').fold(0.0, (sum, t) => sum + t.amount);
            final expense = transactions.where((t) => t.type == 'expense').fold(0.0, (sum, t) => sum + t.amount);
            final balance = income - expense;

            return SingleChildScrollView(
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
                    crossAxisSpacing: 16.w,
                    mainAxisSpacing: 16.h,
                    children: [
                      buildStatCard(
                        title: t['totalIncome']!,
                        value: '${profile.currency} ${income.toStringAsFixed(0)}',
                        color: Colors.green,
                        icon: Icons.trending_up,
                        themeData: themeData,
                      ),
                      buildStatCard(
                        title: t['totalExpense']!,
                        value: '${profile.currency} ${expense.toStringAsFixed(0)}',
                        color: Colors.red,
                        icon: Icons.trending_down,
                        themeData: themeData,
                      ),
                      buildStatCard(
                        title: t['balance']!,
                        value: '${profile.currency} ${balance.toStringAsFixed(0)}',
                        color: Colors.blue,
                        icon: Icons.account_balance_wallet,
                        themeData: themeData,
                      ),
                      buildStatCard(
                        title: t['budget']!,
                        value: '${profile.currency} ${profile.budget.toStringAsFixed(0)}',
                        color: Colors.purple,
                        icon: Icons.pie_chart,
                        themeData: themeData,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    t['recentTransactions']!,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: themeData.textTheme.bodyLarge!.color),
                  ),
                  SizedBox(height: 8.h),
                  buildRecentTransactionsTable(transactions, profile, t, isDark, themeData),
                ],
              ),
            );
          },
        );
      },
    );
  }
}