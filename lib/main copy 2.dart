import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as path;

class ResponsiveLayout2 {
  static int getGridColumns(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return 3; // Desktop - 3 columns
    } else if (width >= 600) {
      return 3; // Tablet - 3 columns
    } else {
      return 1; // Mobile - 1 column (stacked)
    }
  }

  static double getCardAspectRatio(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    if (width >= 1200) {
      return 2.5; // Desktop - wider cards
    } else if (width >= 600) {
      return 2.0; // Tablet - medium cards
    } else {
      return 3.0; // Mobile - shorter cards (stacked view)
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FinanceTrackerApp());
}

class FinanceTrackerApp extends StatelessWidget {
  const FinanceTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Finance Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const FinanceTrackerHome(),
    );
  }
}

class ResponsiveLayout {
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1200;

  static double getMargin(BuildContext context) {
    if (isDesktop(context)) return 24;
    if (isTablet(context)) return 20;
    return 16;
  }

  static double getPadding(BuildContext context) {
    if (isDesktop(context)) return 20;
    if (isTablet(context)) return 16;
    return 12;
  }

  static int getGridColumns(BuildContext context) {
    if (isDesktop(context)) return 3;
    if (isTablet(context)) return 2;
    return 1;
  }
}

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  DatabaseHelper._internal();

  factory DatabaseHelper() {
    return _instance;
  }

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String dbPath = path.join(await getDatabasesPath(), 'finance_tracker.db');
    return openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, version) async {
        await db.execute(
          'CREATE TABLE transactions('
          'id INTEGER PRIMARY KEY,'
          'type TEXT,'
          'category TEXT,'
          'amount REAL,'
          'date TEXT,'
          'notes TEXT,'
          'recurring INTEGER,'
          'tags TEXT'
          ')',
        );
        await db.execute(
          'CREATE TABLE users('
          'id INTEGER PRIMARY KEY,'
          'name TEXT,'
          'email TEXT,'
          'phone TEXT,'
          'occupation TEXT'
          ')',
        );
        await db.execute(
          'CREATE TABLE budgets('
          'category TEXT PRIMARY KEY,'
          'amount REAL'
          ')',
        );
      },
    );
  }

  Future<void> insertTransaction(Transaction transaction) async {
    final db = await database;
    await db.insert(
      'transactions',
      {
        'id': transaction.id,
        'type': transaction.type,
        'category': transaction.category,
        'amount': transaction.amount,
        'date': transaction.date,
        'notes': transaction.notes,
        'recurring': transaction.recurring ? 1 : 0,
        'tags': transaction.tags.join(','),
      },
    );
  }

  Future<List<Transaction>> getTransactions() async {
    final db = await database;
    final maps = await db.query('transactions');
    return List.generate(maps.length, (i) {
      return Transaction(
        id: maps[i]['id'] as int,
        type: maps[i]['type'] as String,
        category: maps[i]['category'] as String,
        amount: maps[i]['amount'] as double,
        date: maps[i]['date'] as String,
        notes: maps[i]['notes'] as String,
        recurring: (maps[i]['recurring'] as int) == 1,
        tags: (maps[i]['tags'] as String).split(',').where((t) => t.isNotEmpty).toList(),
      );
    });
  }

  Future<void> deleteTransaction(int id) async {
    final db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      {
        'id': user.id,
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
        'occupation': user.occupation,
      },
    );
  }

  Future<List<User>> getUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return List.generate(maps.length, (i) {
      return User(
        id: maps[i]['id'] as int,
        name: maps[i]['name'] as String,
        email: maps[i]['email'] as String,
        phone: maps[i]['phone'] as String,
        occupation: maps[i]['occupation'] as String,
      );
    });
  }

  Future<void> insertBudget(String category, double amount) async {
    final db = await database;
    await db.insert(
      'budgets',
      {'category': category, 'amount': amount},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<Map<String, double>> getBudgets() async {
    final db = await database;
    final maps = await db.query('budgets');
    final budgets = <String, double>{};
    for (var map in maps) {
      budgets[map['category'] as String] = map['amount'] as double;
    }
    return budgets;
  }
}

class Transaction {
  final int id;
  final String type;
  final String category;
  final double amount;
  final String date;
  final String notes;
  final bool recurring;
  final List<String> tags;

  Transaction({
    required this.id,
    required this.type,
    required this.category,
    required this.amount,
    required this.date,
    required this.notes,
    required this.recurring,
    required this.tags,
  });
}

class User {
  final int id;
  String name;
  String email;
  String phone;
  String occupation;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.occupation,
  });
}

class FinanceTrackerHome extends StatefulWidget {
  const FinanceTrackerHome({Key? key}) : super(key: key);

  @override
  State<FinanceTrackerHome> createState() => _FinanceTrackerHomeState();
}

class _FinanceTrackerHomeState extends State<FinanceTrackerHome> {
  int _selectedIndex = 0;
  bool _darkMode = false;
  String _currency = 'USD';
  int _selectedUserIndex = 0;

  List<Transaction> transactions = [];
  List<String> incomeCategories = [];
  List<String> expenseCategories = [];
  Map<String, double> budgets = {};
  List<User> users = [];
  final DatabaseHelper dbHelper = DatabaseHelper();

  String _filterCategory = 'All';
  String _filterType = 'All';
  String _filterStartDate = '';
  String _filterEndDate = '';

  final Map<String, String> currencySymbols = {
    'USD': '\$',
    'EUR': '€',
    'GBP': '£',
    'INR': '₹'
  };

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() async {
    transactions = await dbHelper.getTransactions();
    users = await dbHelper.getUsers();
    budgets = await dbHelper.getBudgets();

    incomeCategories = ['Salary', 'Freelance', 'Investment', 'Bonus'];
    expenseCategories = ['Groceries', 'Transport', 'Utilities', 'Entertainment', 'Healthcare'];

    if (transactions.isEmpty) {
      final defaultTransactions = [
        Transaction(
          id: 1,
          type: 'income',
          category: 'Salary',
          amount: 5000,
          date: '2025-10-10',
          notes: 'Monthly salary',
          recurring: true,
          tags: ['work'],
        ),
        Transaction(
          id: 2,
          type: 'expense',
          category: 'Groceries',
          amount: 250,
          date: '2025-10-09',
          notes: 'Weekly shopping',
          recurring: false,
          tags: ['food'],
        ),
        Transaction(
          id: 3,
          type: 'expense',
          category: 'Transport',
          amount: 80,
          date: '2025-10-08',
          notes: 'Gas',
          recurring: true,
          tags: ['transport'],
        ),
      ];
      for (var t in defaultTransactions) {
        await dbHelper.insertTransaction(t);
      }
      transactions = defaultTransactions;
    }

    if (users.isEmpty) {
      final defaultUsers = [
        User(
          id: 0,
          name: 'John Doe',
          email: 'john@example.com',
          phone: '555-0123',
          occupation: 'Software Engineer',
        ),
        User(
          id: 1,
          name: 'Jane Smith',
          email: 'jane@example.com',
          phone: '555-0124',
          occupation: 'Designer',
        ),
      ];
      for (var u in defaultUsers) {
        await dbHelper.insertUser(u);
      }
      users = defaultUsers;
    }

    if (budgets.isEmpty) {
      budgets = {
        'Groceries': 500,
        'Transport': 200,
        'Entertainment': 300,
      };
      for (var entry in budgets.entries) {
        await dbHelper.insertBudget(entry.key, entry.value);
      }
    }

    if (mounted) setState(() {});
  }

  List<Transaction> _getFilteredTransactions() {
    return transactions.where((t) {
      bool dateMatch = true;
      if (_filterStartDate.isNotEmpty) {
        dateMatch = t.date.compareTo(_filterStartDate) >= 0;
      }
      if (_filterEndDate.isNotEmpty) {
        dateMatch = dateMatch && t.date.compareTo(_filterEndDate) <= 0;
      }
      bool categoryMatch = _filterCategory == 'All' || t.category == _filterCategory;
      bool typeMatch = _filterType == 'All' || t.type == _filterType;
      return dateMatch && categoryMatch && typeMatch;
    }).toList();
  }

  double _getTotalIncome() {
    return _getFilteredTransactions()
        .where((t) => t.type == 'income')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double _getTotalExpenses() {
    return _getFilteredTransactions()
        .where((t) => t.type == 'expense')
        .fold(0, (sum, t) => sum + t.amount);
  }

  double _getBalance() {
    return _getTotalIncome() - _getTotalExpenses();
  }

  Map<String, double> _getExpensesByCategory() {
    Map<String, double> result = {};
    for (var t in _getFilteredTransactions().where((t) => t.type == 'expense')) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  Map<String, double> _getIncomeByCategory() {
    Map<String, double> result = {};
    for (var t in _getFilteredTransactions().where((t) => t.type == 'income')) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  void _showAddTransactionDialog() {
    String selectedType = 'expense';
    String selectedCategory = '';
    TextEditingController amountController = TextEditingController();
    TextEditingController notesController = TextEditingController();
    TextEditingController tagsController = TextEditingController();
    String selectedDate = DateTime.now().toString().substring(0, 10);
    bool isRecurring = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: ResponsiveLayout.getMargin(context),
              right: ResponsiveLayout.getMargin(context),
              top: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Add Transaction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedType,
                  isExpanded: true,
                  items: ['income', 'expense']
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child: Text(type.toUpperCase()),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setModalState(() {
                      selectedType = value!;
                      selectedCategory = '';
                    });
                  },
                ),
                const SizedBox(height: 12),
                DropdownButton<String>(
                  hint: const Text('Select Category'),
                  value: selectedCategory.isEmpty ? null : selectedCategory,
                  isExpanded: true,
                  items: (selectedType == 'income' ? incomeCategories : expenseCategories)
                      .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                      .toList(),
                  onChanged: (value) {
                    setModalState(() => selectedCategory = value!);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: TextEditingController(text: selectedDate),
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: 'Date',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.calendar_today),
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setModalState(() =>
                              selectedDate = date.toString().substring(0, 10));
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: notesController,
                  maxLines: 2,
                  decoration: const InputDecoration(
                    hintText: 'Notes (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: tagsController,
                  decoration: const InputDecoration(
                    hintText: 'Tags (comma separated)',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Recurring Transaction'),
                  value: isRecurring,
                  onChanged: (value) => setModalState(() => isRecurring = value!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (selectedCategory.isNotEmpty &&
                              amountController.text.isNotEmpty) {
                            final transaction = Transaction(
                              id: DateTime.now().millisecondsSinceEpoch,
                              type: selectedType,
                              category: selectedCategory,
                              amount: double.parse(amountController.text),
                              date: selectedDate,
                              notes: notesController.text,
                              recurring: isRecurring,
                              tags: tagsController.text
                                  .split(',')
                                  .map((t) => t.trim())
                                  .where((t) => t.isNotEmpty)
                                  .toList(),
                            );
                            await dbHelper.insertTransaction(transaction);
                            setState(() {
                              transactions.add(transaction);
                            });
                            if (mounted) Navigator.pop(context);
                          }
                        },
                        child: const Text('Add'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Color bgColor = _darkMode ? const Color(0xFF121212) : Colors.grey[100]!;
    Color cardColor = _darkMode ? const Color(0xFF1E1E1E) : Colors.white;
    Color textColor = _darkMode ? Colors.white : Colors.black87;
    bool isMobile = ResponsiveLayout.isMobile(context);

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('💰 Finance Tracker'),
        actions: [
          IconButton(
            icon: Icon(_darkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => setState(() => _darkMode = !_darkMode),
          ),
        ],
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          _buildHomePage(cardColor, textColor),
          _buildReportPage(cardColor, textColor),
          _buildProfilePage(cardColor, textColor),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTransactionDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
              items: const [
                BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
                BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Report'),
                BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
              ],
            )
          : null,
    );
  }

  Widget _buildHomePage(Color cardColor, Color textColor) {
    final filtered = _getFilteredTransactions();
    final totalIncome = _getTotalIncome();
    final totalExpenses = _getTotalExpenses();
    final balance = _getBalance();
    final expensesByCategory = _getExpensesByCategory();
    final curr = currencySymbols[_currency]!;
    bool isTablet = ResponsiveLayout.isTablet(context);
    double margin = ResponsiveLayout.getMargin(context);
    double padding = ResponsiveLayout.getPadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(margin),
      child: Column(
        children: [
          GridView.count(
            crossAxisCount: ResponsiveLayout2.getGridColumns(context),
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: padding,
            crossAxisSpacing: padding,
            childAspectRatio: ResponsiveLayout2.getCardAspectRatio(context),
            children: [
              _buildSummaryCard('Income', '$curr${totalIncome.toStringAsFixed(2)}', Colors.green),
              _buildSummaryCard('Expenses', '$curr${totalExpenses.toStringAsFixed(2)}', Colors.red),
              _buildSummaryCard('Balance', '$curr${balance.toStringAsFixed(2)}',
                  balance >= 0 ? Colors.blue : Colors.orange),
            ],
          ),
          SizedBox(height: margin),
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Currency',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                SizedBox(height: padding),
                DropdownButton<String>(
                  value: _currency,
                  isExpanded: true,
                  items: ['USD', 'EUR', 'GBP', 'INR']
                      .map((curr) => DropdownMenuItem(value: curr, child: Text(curr)))
                      .toList(),
                  onChanged: (value) => setState(() => _currency = value!),
                ),
              ],
            ),
          ),
          SizedBox(height: margin),
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Budget Management',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                SizedBox(height: padding),
                ...expensesByCategory.keys.map((cat) {
                  final spent = expensesByCategory[cat] ?? 0;
                  final budget = budgets[cat] ?? 0;
                  final percentage = budget > 0 ? (spent / budget).toDouble() : 0.0;

                  return Padding(
                    padding: EdgeInsets.only(bottom: padding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(cat, style: TextStyle(color: textColor)),
                            ),
                            Flexible(
                              child: Text(
                                '$curr${spent.toStringAsFixed(2)} / $curr${budget.toStringAsFixed(2)}',
                                style: TextStyle(
                                  color: spent > budget ? Colors.red : Colors.green,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: padding / 2),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage > 1.0 ? 1.0 : percentage,
                            minHeight: 8,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              percentage > 1.0
                                  ? Colors.red
                                  : percentage > 0.8
                                      ? Colors.orange
                                      : Colors.green,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
          SizedBox(height: margin),
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Filters',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                SizedBox(height: padding),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        controller: TextEditingController(text: _filterStartDate),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() =>
                                _filterStartDate = date.toString().substring(0, 10));
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'Start Date',
                          border: const OutlineInputBorder(),
                          hintStyle: TextStyle(color: textColor),
                        ),
                      ),
                    ),
                    SizedBox(width: padding),
                    Expanded(
                      child: TextField(
                        readOnly: true,
                        controller: TextEditingController(text: _filterEndDate),
                        onTap: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            setState(() =>
                                _filterEndDate = date.toString().substring(0, 10));
                          }
                        },
                        decoration: InputDecoration(
                          hintText: 'End Date',
                          border: const OutlineInputBorder(),
                          hintStyle: TextStyle(color: textColor),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padding),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: _filterType,
                        isExpanded: true,
                        items: ['All', 'income', 'expense']
                            .map((type) => DropdownMenuItem(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) => setState(() => _filterType = value!),
                      ),
                    ),
                    SizedBox(width: padding),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _filterCategory,
                        isExpanded: true,
                        items: ['All', ...incomeCategories, ...expenseCategories]
                            .toSet()
                            .toList()
                            .map((cat) => DropdownMenuItem(value: cat, child: Text(cat)))
                            .toList(),
                        onChanged: (value) => setState(() => _filterCategory = value!),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: margin),
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recent Transactions',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                SizedBox(height: padding),
                ...filtered.reversed.map((t) => _buildTransactionTile(t, curr, textColor)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String title, String amount, Color color) {
    return Container(
      padding: EdgeInsets.all(ResponsiveLayout.getPadding(context)),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.7), color],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500)),
          SizedBox(height: ResponsiveLayout.getPadding(context) / 2),
          Text(amount,
              style: const TextStyle(
                  fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }

  Widget _buildTransactionTile(Transaction t, String curr, Color textColor) {
    double padding = ResponsiveLayout.getPadding(context);
    bool isMobile = ResponsiveLayout.isMobile(context);

    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(t.category,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Text(
                      '${t.type == 'income' ? '+' : '-'}$curr${t.amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: t.type == 'income' ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: padding / 2),
                Text(t.date, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (t.notes.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: padding / 2),
                    child: Text(t.notes, style: const TextStyle(fontSize: 11)),
                  ),
                if (t.tags.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.only(top: padding / 2),
                    child: Wrap(
                      spacing: 4,
                      children: t.tags
                          .map((tag) => Chip(
                                label: Text(tag, style: const TextStyle(fontSize: 10)),
                                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ))
                          .toList(),
                    ),
                  ),
              ],
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.category, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(t.date, style: const TextStyle(fontSize: 12)),
                      if (t.notes.isNotEmpty)
                        Text(t.notes, style: const TextStyle(fontSize: 11)),
                      if (t.tags.isNotEmpty)
                        Wrap(
                          spacing: 4,
                          children: t.tags
                              .map((tag) => Chip(
                                    label: Text(tag),
                                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ))
                              .toList(),
                        ),
                    ],
                  ),
                ),
                SizedBox(width: padding),
                Text(
                  '${t.type == 'income' ? '+' : '-'}$curr${t.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: t.type == 'income' ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color color, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textColor)),
        Text(value, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildCategoryBar(String category, double amount, double total, Color textColor) {
    final percentage = total > 0 ? (amount / total).toDouble() : 0.0;
    double padding = ResponsiveLayout.getPadding(context);

    return Padding(
      padding: EdgeInsets.only(bottom: padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(category, style: TextStyle(color: textColor)),
              ),
              Text('\${amount.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: padding / 2),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 6,
              backgroundColor: Colors.grey.shade300,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileRow(String label, String value, Color textColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: textColor)),
        Flexible(
          child: Text(value,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis),
        ),
      ],
    );
  }

  Widget _buildReportPage(Color cardColor, Color textColor) {
    final totalIncome = _getTotalIncome();
    final totalExpenses = _getTotalExpenses();
    final balance = _getBalance();
    final incomeByCategory = _getIncomeByCategory();
    final expensesByCategory = _getExpensesByCategory();
    final curr = currencySymbols[_currency]!;
    bool isTablet = ResponsiveLayout.isTablet(context);
    double margin = ResponsiveLayout.getMargin(context);
    double padding = ResponsiveLayout.getPadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(margin),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Summary',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                SizedBox(height: padding),
                _buildSummaryRow('Total Income', '$curr${totalIncome.toStringAsFixed(2)}',
                    Colors.green, textColor),
                SizedBox(height: padding / 2),
                _buildSummaryRow('Total Expenses', '$curr${totalExpenses.toStringAsFixed(2)}',
                    Colors.red, textColor),
                SizedBox(height: padding / 2),
                _buildSummaryRow('Net Balance', '$curr${balance.toStringAsFixed(2)}',
                    balance >= 0 ? Colors.blue : Colors.orange, textColor),
              ],
            ),
          ),
          SizedBox(height: margin),
          GridView.count(
            crossAxisCount: isTablet ? 2 : 1,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: margin,
            crossAxisSpacing: margin,
            childAspectRatio: 1.2,
            children: [
              Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Income by Category',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    SizedBox(height: padding),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: incomeByCategory.entries
                              .map((e) => _buildCategoryBar(e.key, e.value, totalIncome, textColor))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.all(padding),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Expenses by Category',
                        style:
                            TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                    SizedBox(height: padding),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: expensesByCategory.entries
                              .map((e) => _buildCategoryBar(e.key, e.value, totalExpenses, textColor))
                              .toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProfilePage(Color cardColor, Color textColor) {
    if (users.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(ResponsiveLayout.getMargin(context)),
          child: Text('Loading user data...', style: TextStyle(color: textColor)),
        ),
      );
    }

    final user = users[_selectedUserIndex];
    final balance = _getBalance();
    final curr = currencySymbols[_currency]!;
    final expensesByCategory = _getExpensesByCategory();
    double margin = ResponsiveLayout.getMargin(context);
    double padding = ResponsiveLayout.getPadding(context);

    return SingleChildScrollView(
      padding: EdgeInsets.all(margin),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(padding + 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade600, Colors.blue.shade800],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: const Icon(Icons.person, size: 40, color: Colors.white),
                ),
                SizedBox(height: padding),
                Text(user.name,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center),
                Text(user.occupation,
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
          SizedBox(height: margin),
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (users.length > 1)
                  Column(
                    children: [
                      DropdownButton<int>(
                        value: _selectedUserIndex,
                        isExpanded: true,
                        items: List.generate(
                          users.length,
                          (index) => DropdownMenuItem(value: index, child: Text(users[index].name)),
                        ),
                        onChanged: (value) => setState(() => _selectedUserIndex = value!),
                      ),
                      SizedBox(height: padding),
                    ],
                  ),
                _buildProfileRow('Email', user.email, textColor),
                SizedBox(height: padding / 2),
                _buildProfileRow('Phone', user.phone, textColor),
                SizedBox(height: padding / 2),
                _buildProfileRow('Balance', '$curr${balance.toStringAsFixed(2)}', textColor),
              ],
            ),
          ),
          SizedBox(height: margin),
          Container(
            padding: EdgeInsets.all(padding),
            decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Spending Overview',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
                SizedBox(height: padding),
                ...expensesByCategory.entries.map((entry) {
                  return Padding(
                    padding: EdgeInsets.only(bottom: padding / 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key, style: TextStyle(color: textColor)),
                        Text('$curr${entry.value.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}