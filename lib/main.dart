import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'app/home/presentation/bindings/app_binding.dart';
import 'app/home/presentation/cubits/transaction_cubit.dart';
import 'app/home/presentation/cubits/profile_cubit.dart';
import 'app/home/presentation/cubits/settings_cubit.dart';
import 'app/home/presentation/screens/finance_tracker.dart';
import 'app/home/data/models/settings_model.dart';

final Map<String, Map<String, String>> translations = {
  'en': {
    'appName': 'Finance Tracker',
    'dashboard': 'Dashboard',
    'addTransaction': 'Add Transaction',
    'reports': 'Reports',
    'settings': 'Settings',
    'profile': 'Profile',
    'totalIncome': 'Total Income',
    'totalExpense': 'Total Expense',
    'balance': 'Balance',
    'budget': 'Budget',
    'recentTransactions': 'Recent Transactions',
    'income': 'Income',
    'expense': 'Expense',
    'category': 'Category',
    'amount': 'Amount',
    'date': 'Date',
    'description': 'Description',
    'add': 'Add',
    'save': 'Save',
    'name': 'Name',
    'email': 'Email',
    'currency': 'Currency',
    'monthlyBudget': 'Monthly Budget',
    'language': 'Language',
    'expenseByCategory': 'Expense by Category',
    'incomeByCategory': 'Income by Category',
    'monthlyTrend': 'Monthly Trend',
    'download': 'Download Report',
    'salary': 'Salary',
    'freelance': 'Freelance',
    'business': 'Business',
    'investment': 'Investment',
    'other': 'Other',
    'food': 'Food',
    'transport': 'Transport',
    'bills': 'Bills',
    'shopping': 'Shopping',
    'entertainment': 'Entertainment',
    'health': 'Health',
    'education': 'Education',
    'theme': 'Theme',
    'light': 'Light',
    'dark': 'Dark'
  },
  'bn': {
    'appName': 'আর্থিক ব্যবস্থাপক',
    'dashboard': 'ড্যাশবোর্ড',
    'addTransaction': 'লেনদেন যোগ করুন',
    'reports': 'রিপোর্ট',
    'settings': 'সেটিংস',
    'profile': 'প্রোফাইল',
    'totalIncome': 'মোট আয়',
    'totalExpense': 'মোট ব্যয়',
    'balance': 'ব্যালেন্স',
    'budget': 'বাজেট',
    'recentTransactions': 'সাম্প্রতিক লেনদেন',
    'income': 'আয়',
    'expense': 'ব্যয়',
    'category': 'বিভাগ',
    'amount': 'পরিমাণ',
    'date': 'তারিখ',
    'description': 'বিবরণ',
    'add': 'যোগ করুন',
    'save': 'সংরক্ষণ',
    'name': 'নাম',
    'email': 'ইমেইল',
    'currency': 'মুদ্রা',
    'monthlyBudget': 'মাসিক বাজেট',
    'language': 'ভাষা',
    'expenseByCategory': 'বিভাগ অনুযায়ী ব্যয়',
    'incomeByCategory': 'বিভাগ অনুযায়ী আয়',
    'monthlyTrend': 'মাসিক প্রবণতা',
    'download': 'রিপোর্ট ডাউনলোড',
    'salary': 'বেতন',
    'freelance': 'ফ্রিল্যান্স',
    'business': 'ব্যবসা',
    'investment': 'বিনিয়োগ',
    'other': 'অন্যান্য',
    'food': 'খাদ্য',
    'transport': 'পরিবহন',
    'bills': 'বিল',
    'shopping': 'কেনাকাটা',
    'entertainment': 'বিনোদন',
    'health': 'স্বাস্থ্য',
    'education': 'শিক্ষা',
    'theme': 'থিম',
    'light': 'হালকা',
    'dark': 'গাঢ়'
  }
};

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupBindings(); // Initialize dependencies
  await getIt.allReady(); // Wait for async dependencies
  runApp(const FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getIt.allReady(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false, // Remove debug banner
            home: Scaffold(body: Center(child: CircularProgressIndicator())),
          );
        }
        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => getIt<TransactionCubit>()..loadTransactions()),
            BlocProvider(create: (_) => getIt<ProfileCubit>()..loadProfile()),
            BlocProvider(create: (_) => getIt<SettingsCubit>()..loadSettings()),
          ],
          child: BlocBuilder<SettingsCubit, Settings>(
            builder: (context, settings) {
              final language = settings.language;
              return ScreenUtilInit(
                designSize: const Size(360, 690),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return MaterialApp(
                    debugShowCheckedModeBanner: false, // Remove debug banner
                    title: translations[language]!['appName']!,
                    theme: ThemeData.light().copyWith(
                      primaryColor: Colors.indigo,
                      scaffoldBackgroundColor: Colors.white, // background color
                      cardColor: Colors.white,
                      cardTheme: CardThemeData(
                        color: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: const Color.fromARGB(255, 247, 241, 241)!, width: 1),
                        ),
                      ),
                      textTheme: TextTheme(
                        bodyLarge: TextStyle(color: Colors.grey[900]),
                        bodyMedium: TextStyle(color: Colors.grey[600]),
                        bodySmall: TextStyle(color: Colors.grey[500]),
                      ),
                    ),
                    darkTheme: ThemeData.dark().copyWith(
                      primaryColor: Colors.indigo,
                      scaffoldBackgroundColor: Colors.grey[900],
                      cardColor: Colors.grey[850],
                      cardTheme: CardThemeData(
                        color: Colors.grey[850],
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey[700]!, width: 1),
                        ),
                      ),
                      textTheme: TextTheme(
                        bodyLarge: TextStyle(color: Colors.white),
                        bodyMedium: TextStyle(color: Colors.grey[300]),
                        bodySmall: TextStyle(color: Colors.grey[400]),
                      ),
                    ),
                    themeMode: settings.theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
                    home: const FinanceTracker(),
                    locale: Locale(language),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}