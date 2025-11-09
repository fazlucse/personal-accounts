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

  int _getCrossAxisCount(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final width = MediaQuery.of(context).size.width;

    if (orientation == Orientation.landscape) {
      return width > 900 ? 4 : 2;
    } else {
      return width > 600 ? 4 : 2;
    }
  }

  double _getChildAspectRatio(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final width = MediaQuery.of(context).size.width;

    if (orientation == Orientation.landscape) {
      return width > 900 ? 1.5 : 1.2;
    } else {
      return width > 600 ? 1.5 : 1.7;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionCubit, List<Transaction>>(
      builder: (context, transactions) {
        return BlocBuilder<ProfileCubit, Profile>(
          builder: (context, profile) {
            final income = transactions
                .where((t) => t.type == 'income')
                .fold(0.0, (sum, t) => sum + (t.amount ?? 0));
            final expense = transactions
                .where((t) => t.type == 'expense')
                .fold(0.0, (sum, t) => sum + (t.amount ?? 0));
            final balance = income - expense;

            final orientation = MediaQuery.of(context).orientation;
            final isLandscape = orientation == Orientation.landscape;

            return SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Stats Grid with constrained height
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: _getCrossAxisCount(context),
                        crossAxisSpacing: 5.w,
                        mainAxisSpacing: 5.h,
                        childAspectRatio: _getChildAspectRatio(context),
                        children: [
                          buildStatCard(
                            title: t['totalIncome']!,
                            value:
                                '${profile.currency} ${income.toStringAsFixed(0)}',
                            color: Colors.green,
                            icon: Icons.trending_up,
                            themeData: themeData,
                          ),
                          buildStatCard(
                            title: t['totalExpense']!,
                            value:
                                '${profile.currency} ${expense.toStringAsFixed(0)}',
                            color: Colors.red,
                            icon: Icons.trending_down,
                            themeData: themeData,
                          ),
                          // buildStatCard(
                          //   title: t['balance']!,
                          //   value:
                          //       '${profile.currency} ${balance.toStringAsFixed(0)}',
                          //   color: Colors.blue,
                          //   icon: Icons.account_balance_wallet,
                          //   themeData: themeData,
                          // ),
                          // buildStatCard(
                          //   title: t['budget']!,
                          //   value:
                          //       '${profile.currency} ${profile.budget.toStringAsFixed(0)}',
                          //   color: Colors.purple,
                          //   icon: Icons.pie_chart,
                          //   themeData: themeData,
                          // ),
                        ],
                      );
                    },
                  ),

                  SizedBox(height: 24.h),

                  // Recent Transactions Section
                  Container(
                    padding: EdgeInsets.only(left: 10.w),
                    decoration: BoxDecoration(
                      border: Border(
                        left: BorderSide(
                          color: themeData.primaryColor,
                          width: 4.w,
                        ),
                      ),
                    ),
                    child: Text(
                      t['recentTransactions']!,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: themeData.textTheme.bodyLarge!.color,
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  // Transactions table
                  buildRecentTransactionsTable(
                    transactions: transactions,
                    profile: profile,
                    t: t,
                    isDark: isDark,
                    themeData: themeData,
                    context: context, // Add this line
                    onDelete: (transaction) {
                      context.read<TransactionCubit>().deleteTransaction(
                        transaction,
                      );
                    },
                  ),

                  // Bottom padding for better scroll experience
                  SizedBox(height: 16.h),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
