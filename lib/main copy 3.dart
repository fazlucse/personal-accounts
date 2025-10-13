import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

// Transaction Model
class Transaction {
  final int id;
  final String type;
  final String category;
  final double amount;
  final String date;
  final String description;

  Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'],
      type: json['type'],
      category: json['category'],
      amount: json['amount'].toDouble(),
      date: json['date'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'category': category,
      'amount': amount,
      'date': date,
      'description': description,
    };
  }
}

// Profile Model
class Profile {
  final String name;
  final String email;
  final String currency;
  final double budget;

  Profile({
    required this.name,
    required this.email,
    required this.currency,
    required this.budget,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      name: json['name'],
      email: json['email'],
      currency: json['currency'],
      budget: json['budget'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'email': email,
      'currency': currency,
      'budget': budget,
    };
  }
}

// Transaction Cubit
class TransactionCubit extends Cubit<List<Transaction>> {
  TransactionCubit() : super([]) {
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('transactions');
    if (jsonString != null) {
      final List<dynamic> jsonList = json.decode(jsonString);
      emit(jsonList.map((json) => Transaction.fromJson(json)).toList());
    }
  }

  Future<void> _saveTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(state.map((t) => t.toJson()).toList());
    await prefs.setString('transactions', jsonString);
  }

  void addTransaction(Transaction transaction) {
    emit([...state, transaction]);
    _saveTransactions();
  }
}

// Settings Cubit
class SettingsCubit extends Cubit<Map<String, dynamic>> {
  SettingsCubit()
      : super({
          'language': 'en',
          'theme': 'light',
        }) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final language = prefs.getString('language') ?? 'en';
    final theme = prefs.getString('theme') ?? 'light';
    emit({
      'language': language,
      'theme': theme,
    });
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', state['language']);
    await prefs.setString('theme', state['theme']);
  }

  void setLanguage(String lang) {
    emit({...state, 'language': lang});
    _saveSettings();
  }

  void setTheme(String theme) {
    emit({...state, 'theme': theme});
    _saveSettings();
  }
}

// Profile Cubit
class ProfileCubit extends Cubit<Profile> {
  ProfileCubit()
      : super(Profile(
          name: 'User Name',
          email: 'user@example.com',
          currency: 'BDT',
          budget: 40000,
        )) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('profile');
    if (jsonString != null) {
      final json = jsonDecode(jsonString);
      emit(Profile.fromJson(json));
    }
  }

  Future<void> _saveProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(state.toJson());
    await prefs.setString('profile', jsonString);
  }

  void updateProfile({
    String? name,
    String? email,
    String? currency,
    double? budget,
  }) {
    emit(Profile(
      name: name ?? state.name,
      email: email ?? state.email,
      currency: currency ?? state.currency,
      budget: budget ?? state.budget,
    ));
    _saveProfile();
  }
}

// Translations
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
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TransactionCubit()),
        BlocProvider(create: (_) => SettingsCubit()),
        BlocProvider(create: (_) => ProfileCubit()),
      ],
      child: const FinanceTrackerApp(),
    ),
  );
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Map<String, dynamic>>(
      builder: (context, settings) {
        final language = settings['language'];
        final theme = settings['theme'];
        return ScreenUtilInit(
          designSize: const Size(360, 690), // Base design size
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              title: translations[language]!['appName']!,
              theme: ThemeData.light().copyWith(
                primaryColor: Colors.indigo,
                scaffoldBackgroundColor: Colors.blue[50],
                cardColor: Colors.white,
                textTheme: TextTheme(
                  bodyLarge: TextStyle(color: Colors.grey[900]),
                  bodyMedium: TextStyle(color: Colors.grey[600]),
                  bodySmall: TextStyle(color: Colors.grey[500]),
                ),
              ),
              darkTheme: ThemeData.dark().copyWith(
                primaryColor: Colors.indigo,
                scaffoldBackgroundColor: Colors.grey[900],
                cardColor: Colors.grey[800],
                textTheme: TextTheme(
                  bodyLarge: TextStyle(color: Colors.white),
                  bodyMedium: TextStyle(color: Colors.grey[300]),
                  bodySmall: TextStyle(color: Colors.grey[400]),
                ),
              ),
              themeMode: theme == 'dark' ? ThemeMode.dark : ThemeMode.light,
              home: const FinanceTracker(),
              locale: Locale(language),
            );
          },
        );
      },
    );
  }
}

class FinanceTracker extends StatefulWidget {
  const FinanceTracker({super.key});

  @override
  State<FinanceTracker> createState() => _FinanceTrackerState();
}

class _FinanceTrackerState extends State<FinanceTracker> {
  int _activeTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, Map<String, dynamic>>(
      builder: (context, settings) {
        final language = settings['language'];
        final theme = settings['theme'];
        final t = translations[language]!;
        final isDark = theme == 'dark';
        final themeData = Theme.of(context);

        final List<Widget> tabs = [
          DashboardScreen(t: t, isDark: isDark, themeData: themeData),
          AddTransactionScreen(t: t, isDark: isDark, themeData: themeData),
          ReportsScreen(t: t, isDark: isDark, themeData: themeData),
          ProfileScreen(t: t, isDark: isDark, themeData: themeData),
          SettingsScreen(t: t, isDark: isDark, themeData: themeData),
        ];

        return Scaffold(
          appBar: AppBar(
            title: Text(
              t['appName']!,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.indigo[400] : Colors.indigo[600],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.wb_sunny : Icons.nights_stay),
                onPressed: () {
                  context.read<SettingsCubit>().setTheme(isDark ? 'light' : 'dark');
                },
              ),
              Padding(
                padding: EdgeInsets.only(right: 16.w),
                child: DropdownButton<String>(
                  value: language,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<SettingsCubit>().setLanguage(value);
                    }
                  },
                  items: [
                    const DropdownMenuItem(value: 'en', child: Text('English')),
                    const DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
                  ],
                ),
              ),
            ],
          ),
          body: tabs[_activeTabIndex],
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _activeTabIndex,
            onTap: (index) => setState(() => _activeTabIndex = index),
            selectedItemColor: Colors.indigo[600],
            unselectedItemColor: themeData.textTheme.bodySmall!.color,
            items: [
              BottomNavigationBarItem(icon: Icon(Icons.home, size: 24.sp), label: t['dashboard']),
              BottomNavigationBarItem(icon: Icon(Icons.add_circle, size: 24.sp), label: t['add']),
              BottomNavigationBarItem(icon: Icon(Icons.description, size: 24.sp), label: t['reports']),
              BottomNavigationBarItem(icon: Icon(Icons.person, size: 24.sp), label: t['profile']),
              BottomNavigationBarItem(icon: Icon(Icons.settings, size: 24.sp), label: t['settings']),
            ],
          ),
        );
      },
    );
  }
}

// Dashboard Screen
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
                      _buildStatCard(
                        title: t['totalIncome']!,
                        value: '${profile.currency} ${income.toStringAsFixed(0)}',
                        color: Colors.green,
                        icon: Icons.trending_up,
                      ),
                      _buildStatCard(
                        title: t['totalExpense']!,
                        value: '${profile.currency} ${expense.toStringAsFixed(0)}',
                        color: Colors.red,
                        icon: Icons.trending_down,
                      ),
                      _buildStatCard(
                        title: t['balance']!,
                        value: '${profile.currency} ${balance.toStringAsFixed(0)}',
                        color: Colors.blue,
                        icon: Icons.account_balance_wallet,
                      ),
                      _buildStatCard(
                        title: t['budget']!,
                        value: '${profile.currency} ${profile.budget.toStringAsFixed(0)}',
                        color: Colors.purple,
                        icon: Icons.pie_chart,
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Text(
                    t['recentTransactions']!,
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: themeData.textTheme.bodyLarge!.color),
                  ),
                  SizedBox(height: 8.h),
                  _buildRecentTransactionsTable(transactions, profile, t, isDark, themeData),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard({required String title, required String value, required Color color, required IconData icon}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(fontSize: 12.sp, color: themeData.textTheme.bodySmall!.color)),
            Text(value, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: color)),
            const Spacer(),
            Align(alignment: Alignment.bottomRight, child: Icon(icon, color: color, size: 32.sp)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactionsTable(List<Transaction> transactions, Profile profile, Map<String, String> t, bool isDark, ThemeData themeData) {
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
}

// Add Transaction Screen
class AddTransactionScreen extends StatefulWidget {
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
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  String type = 'expense';
  String category = 'food';
  final TextEditingController amountController = TextEditingController();
  String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  final TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.t['addTransaction']!,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: widget.themeData.textTheme.bodyLarge!.color),
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
                  ),
                  child: Text(widget.t['income']!, style: TextStyle(color: type == 'income' ? Colors.green[700] : widget.themeData.textTheme.bodyMedium!.color)),
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
                  ),
                  child: Text(widget.t['expense']!, style: TextStyle(color: type == 'expense' ? Colors.red[700] : widget.themeData.textTheme.bodyMedium!.color)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(widget.t['category']!, style: TextStyle(fontSize: 14.sp, color: widget.themeData.textTheme.bodyMedium!.color)),
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
                .map((cat) => DropdownMenuItem(value: cat, child: Text(widget.t[cat]!)))
                .toList(),
          ),
          SizedBox(height: 16.h),
          Text(widget.t['amount']!, style: TextStyle(fontSize: 14.sp, color: widget.themeData.textTheme.bodyMedium!.color)),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          Text(widget.t['date']!, style: TextStyle(fontSize: 14.sp, color: widget.themeData.textTheme.bodyMedium!.color)),
          TextField(
            readOnly: true,
            controller: TextEditingController(text: date),
            onTap: () async {
              final selectedDate = await showDatePicker(
                context: context,
                initialDate: DateTime.parse(date),
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
              );
              if (selectedDate != null) {
                setState(() => date = DateFormat('yyyy-MM-dd').format(selectedDate));
              }
            },
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          Text(widget.t['description']!, style: TextStyle(fontSize: 14.sp, color: widget.themeData.textTheme.bodyMedium!.color)),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
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
                amountController.clear();
                descriptionController.clear();
                date = DateFormat('yyyy-MM-dd').format(DateTime.now());
                type = 'expense';
                category = 'food';
              }
            },
            icon: Icon(Icons.add, size: 20.sp),
            label: Text(widget.t['add']!),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48.h),
            ),
          ),
        ],
      ),
    );
  }
}

// Reports Screen
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

  Future<void> _downloadReport(List<Transaction> transactions) async {
    final csvHeader = 'Type,Category,Amount,Date,Description\n';
    final csvContent = transactions.map((t) => '${t.type},${t.category},${t.amount},${t.date},${t.description}').join('\n');
    final csv = csvHeader + csvContent;

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/finance-report.csv');
    await file.writeAsString(csv);

    Share.shareXFiles([XFile(file.path)], text: 'Finance Report');
  }

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
                        onPressed: () => _downloadReport(transactions),
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
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['expenseByCategory']!,
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.h),
                              ...expenseByCategory.entries.map((e) => _buildCategoryBar(e.key, e.value, totalExpense, Colors.red, profile, t)),
                            ],
                          ),
                        ),
                      ),
                      Card(
                        elevation: 2,
                        child: Padding(
                          padding: EdgeInsets.all(16.w),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                t['incomeByCategory']!,
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 8.h),
                              ...incomeByCategory.entries.map((e) => _buildCategoryBar(e.key, e.value, totalIncome, Colors.green, profile, t)),
                            ],
                          ),
                        ),
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

  Widget _buildCategoryBar(String cat, double amt, double total, Color color, Profile profile, Map<String, String> t) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(t[cat]!, style: TextStyle(fontSize: 12.sp)),
              Text('${profile.currency} ${amt.toStringAsFixed(0)}', style: TextStyle(fontSize: 12.sp)),
            ],
          ),
          SizedBox(height: 4.h),
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[700] : Colors.grey[200],
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: total > 0 ? amt / total : 0,
              child: Container(
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Profile Screen
class ProfileScreen extends StatefulWidget {
  final Map<String, String> t;
  final bool isDark;
  final ThemeData themeData;

  const ProfileScreen({
    super.key,
    required this.t,
    required this.isDark,
    required this.themeData,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileCubit>().state;
    nameController = TextEditingController(text: profile.name);
    emailController = TextEditingController(text: profile.email);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.t['profile']!,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: widget.themeData.textTheme.bodyLarge!.color),
          ),
          SizedBox(height: 16.h),
          Text(widget.t['name']!, style: TextStyle(fontSize: 14.sp, color: widget.themeData.textTheme.bodyMedium!.color)),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          Text(widget.t['email']!, style: TextStyle(fontSize: 14.sp, color: widget.themeData.textTheme.bodyMedium!.color)),
          TextField(
            controller: emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              context.read<ProfileCubit>().updateProfile(
                    name: nameController.text,
                    email: emailController.text,
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: Text(widget.t['save']!),
          ),
        ],
      ),
    );
  }
}

// Settings Screen
class SettingsScreen extends StatefulWidget {
  final Map<String, String> t;
  final bool isDark;
  final ThemeData themeData;

  const SettingsScreen({
    super.key,
    required this.t,
    required this.isDark,
    required this.themeData,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController budgetController;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileCubit>().state;
    budgetController = TextEditingController(text: profile.budget.toString());
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final profile = context.watch<ProfileCubit>().state;

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.t['settings']!,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: widget.themeData.textTheme.bodyLarge!.color),
          ),
          SizedBox(height: 16.h),
          Text(widget.t['theme']!, style: TextStyle(fontSize: 14.sp, color: widget.themeData.textTheme.bodyMedium!.color)),
          DropdownButton<String>(
            value: settings['theme'],
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsCubit>().setTheme(value);
              }
            },
            items: ['light', 'dark'].map((th) => DropdownMenuItem(value: th, child: Text(widget.t[th]!))).toList(),
          ),
          SizedBox(height: 16.h),
          Text(widget.t['currency']!, style: TextStyle(fontSize: 14.sp, color: widget.themeData.textTheme.bodyMedium!.color)),
          DropdownButton<String>(
            value: profile.currency,
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                context.read<ProfileCubit>().updateProfile(currency: value);
              }
            },
            items: [
              const DropdownMenuItem(value: 'BDT', child: Text('BDT - Bangladeshi Taka')),
              const DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
              const DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
              const DropdownMenuItem(value: 'GBP', child: Text('GBP - British Pound')),
            ],
          ),
          SizedBox(height: 16.h),
          Text(widget.t['monthlyBudget']!, style: TextStyle(fontSize: 14.sp, color: widget.themeData.textTheme.bodyMedium!.color)),
          TextField(
            controller: budgetController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(border: OutlineInputBorder()),
          ),
          SizedBox(height: 16.h),
          Text(widget.t['language']!, style: TextStyle(fontSize: 14.sp, color: widget.themeData.textTheme.bodyMedium!.color)),
          DropdownButton<String>(
            value: settings['language'],
            isExpanded: true,
            onChanged: (value) {
              if (value != null) {
                context.read<SettingsCubit>().setLanguage(value);
              }
            },
            items: [
              const DropdownMenuItem(value: 'en', child: Text('English')),
              const DropdownMenuItem(value: 'bn', child: Text('বাংলা')),
            ],
          ),
          SizedBox(height: 24.h),
          ElevatedButton(
            onPressed: () {
              final budget = double.tryParse(budgetController.text);
              if (budget != null) {
                context.read<ProfileCubit>().updateProfile(budget: budget);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.indigo[600],
              foregroundColor: Colors.white,
              minimumSize: Size(double.infinity, 48.h),
            ),
            child: Text(widget.t['save']!),
          ),
        ],
      ),
    );
  }
}