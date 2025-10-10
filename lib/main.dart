import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:csv/csv.dart';

void main() {
  runApp(const ExpenseTrackerApp());
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const ExpenseTrackerHome(),
    );
  }
}

// Database Helper
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('expense_tracker.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        type TEXT NOT NULL
      )
    ''');

    // Insert default categories
    await db.insert('categories', {'name': 'Rent', 'type': 'expense'});
    await db.insert('categories', {'name': 'Food', 'type': 'expense'});
    await db.insert('categories', {'name': 'Transport', 'type': 'expense'});
    await db.insert('categories', {'name': 'Utilities', 'type': 'expense'});
    await db.insert('categories', {'name': 'Entertainment', 'type': 'expense'});
    await db.insert('categories', {'name': 'Healthcare', 'type': 'expense'});
    await db.insert('categories', {'name': 'Shopping', 'type': 'expense'});
    await db.insert('categories', {'name': 'Education', 'type': 'expense'});

    await db.insert('categories', {'name': 'Salary', 'type': 'income'});
    await db.insert('categories', {'name': 'Freelance', 'type': 'income'});
    await db.insert('categories', {'name': 'Investment', 'type': 'income'});
    await db.insert('categories', {'name': 'Business', 'type': 'income'});
    await db.insert('categories', {'name': 'Other', 'type': 'income'});
  }

  Future<int> insertTransaction(Map<String, dynamic> transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction);
  }

  Future<List<Map<String, dynamic>>> getTransactions() async {
    final db = await database;
    return await db.query('transactions', orderBy: 'date DESC');
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertCategory(String name, String type) async {
    final db = await database;
    return await db.insert('categories', {'name': name, 'type': type});
  }

  Future<List<Map<String, dynamic>>> getCategories(String type) async {
    final db = await database;
    return await db.query('categories', where: 'type = ?', whereArgs: [type]);
  }

  Future<void> importData(List<Map<String, dynamic>> transactions) async {
    final db = await database;
    final batch = db.batch();

    for (var transaction in transactions) {
      batch.insert('transactions', transaction);
    }

    await batch.commit();
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }
}

// Transaction Model
class Transaction {
  final int? id;
  final String type;
  final double amount;
  final String category;
  final String date;
  final String? description;

  Transaction({
    this.id,
    required this.type,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'amount': amount,
      'category': category,
      'date': date,
      'description': description,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      amount: map['amount'],
      category: map['category'],
      date: map['date'],
      description: map['description'],
    );
  }
}

class ExpenseTrackerHome extends StatefulWidget {
  const ExpenseTrackerHome({Key? key}) : super(key: key);

  @override
  State<ExpenseTrackerHome> createState() => _ExpenseTrackerHomeState();
}

class _ExpenseTrackerHomeState extends State<ExpenseTrackerHome> {
  int _currentIndex = 0;
  List<Transaction> _transactions = [];
  List<String> _expenseCategories = [];
  List<String> _incomeCategories = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final transactions = await DatabaseHelper.instance.getTransactions();
    final expenseCats = await DatabaseHelper.instance.getCategories('expense');
    final incomeCats = await DatabaseHelper.instance.getCategories('income');

    setState(() {
      _transactions = transactions.map((t) => Transaction.fromMap(t)).toList();
      _expenseCategories = expenseCats.map((c) => c['name'] as String).toList();
      _incomeCategories = incomeCats.map((c) => c['name'] as String).toList();
    });
  }

  double get totalIncome => _transactions
      .where((t) => t.type == 'income')
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => _transactions
      .where((t) => t.type == 'expense')
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;

  Map<String, double> get categoryExpenses {
    final Map<String, double> result = {};
    for (var t in _transactions.where((t) => t.type == 'expense')) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  Map<String, double> get categoryIncomes {
    final Map<String, double> result = {};
    for (var t in _transactions.where((t) => t.type == 'income')) {
      result[t.category] = (result[t.category] ?? 0) + t.amount;
    }
    return result;
  }

  Future<void> _exportData() async {
    try {
      final transactions = await DatabaseHelper.instance.getTransactions();

      List<List<dynamic>> rows = [
        ['ID', 'Type', 'Amount', 'Category', 'Date', 'Description'],
      ];

      for (var t in transactions) {
        rows.add([
          t['id'],
          t['type'],
          t['amount'],
          t['category'],
          t['date'],
          t['description'] ?? '',
        ]);
      }

      String csv = const ListToCsvConverter().convert(rows);

      final directory = await getApplicationDocumentsDirectory();
      final path = '${directory.path}/expense_tracker_export.csv';
      final file = File(path);
      await file.writeAsString(csv);

      await Share.shareXFiles([XFile(path)], text: 'Expense Tracker Data');

      ScaffoldMessenger.of(context as BuildContext).showSnackBar(
        const SnackBar(content: Text('Data exported successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context as BuildContext,
      ).showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  Future<void> _importData() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
      );

      if (result != null) {
        final file = File(result.files.single.path!);
        final csvString = await file.readAsString();

        List<List<dynamic>> rows = const CsvToListConverter().convert(
          csvString,
        );

        if (rows.length > 1) {
          rows.removeAt(0); // Remove header

          for (var row in rows) {
            if (row.length >= 5) {
              await DatabaseHelper.instance.insertTransaction({
                'type': row[1],
                'amount': double.tryParse(row[2].toString()) ?? 0,
                'category': row[3],
                'date': row[4],
                'description': row.length > 5 ? row[5] : null,
              });
            }
          }

          await _loadData();

          ScaffoldMessenger.of(context as BuildContext).showSnackBar(
            const SnackBar(content: Text('Data imported successfully!')),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context as BuildContext,
      ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    }
  }

  void _showAddTransactionDialog(
    BuildContext context, {
    String type = 'expense',
  }) {
    String selectedType = type;
    String? selectedCategory;
    double? amount;
    String date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    String? description;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Add Transaction'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setDialogState(() {
                            selectedType = 'expense';
                            selectedCategory = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedType == 'expense'
                              ? Colors.red
                              : Colors.grey[300],
                          foregroundColor: selectedType == 'expense'
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: const Text('Expense'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          setDialogState(() {
                            selectedType = 'income';
                            selectedCategory = null;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedType == 'income'
                              ? Colors.green
                              : Colors.grey[300],
                          foregroundColor: selectedType == 'income'
                              ? Colors.white
                              : Colors.black,
                        ),
                        child: const Text('Income'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) => amount = double.tryParse(value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedCategory,
                  items:
                      (selectedType == 'expense'
                              ? _expenseCategories
                              : _incomeCategories)
                          .map(
                            (cat) =>
                                DropdownMenuItem(value: cat, child: Text(cat)),
                          )
                          .toList(),
                  onChanged: (value) {
                    setDialogState(() => selectedCategory = value);
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    border: OutlineInputBorder(),
                  ),
                  readOnly: true,
                  controller: TextEditingController(text: date),
                  onTap: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) {
                      setDialogState(() {
                        date = DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextField(
                  decoration: const InputDecoration(
                    labelText: 'Description (optional)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) => description = value,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (amount != null && selectedCategory != null) {
                  await DatabaseHelper.instance.insertTransaction({
                    'type': selectedType,
                    'amount': amount,
                    'category': selectedCategory,
                    'date': date,
                    'description': description,
                  });
                  await _loadData();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryDialog() {
    String categoryType = 'expense';
    String newCategoryName = '';
    final BuildContext currentContext = context as BuildContext;
    showDialog(
      context: currentContext,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Manage Categories'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setDialogState(() => categoryType = 'expense');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryType == 'expense'
                            ? Colors.red
                            : Colors.grey[300],
                        foregroundColor: categoryType == 'expense'
                            ? Colors.white
                            : Colors.black,
                      ),
                      child: const Text('Expense'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        setDialogState(() => categoryType = 'income');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: categoryType == 'income'
                            ? Colors.green
                            : Colors.grey[300],
                        foregroundColor: categoryType == 'income'
                            ? Colors.white
                            : Colors.black,
                      ),
                      child: const Text('Income'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'New Category Name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => newCategoryName = value,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (newCategoryName.isNotEmpty) {
                  await DatabaseHelper.instance.insertCategory(
                    newCategoryName,
                    categoryType,
                  );
                  await _loadData();
                  Navigator.pop(context);
                }
              },
              child: const Text('Add Category'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [_buildDashboard(context), _buildReports(), _buildProfile()],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddTransactionDialog(context),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reports',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildDashboard(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          expandedHeight: 120,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: const Text('Expense Tracker'),
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple, Colors.indigo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              onPressed: () =>
                  _showAddTransactionDialog(context, type: 'income'),
            ),
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () =>
                  _showAddTransactionDialog(context, type: 'expense'),
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: _showCategoryDialog,
            ),
          ],
        ),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              _buildStatsCards(),
              const SizedBox(height: 16),
              _buildRecentTransactions(),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                'Balance',
                '\$${balance.toStringAsFixed(2)}',
                Icons.account_balance_wallet,
                Colors.blue,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildStatCard(
                'Income',
                '\$${totalIncome.toStringAsFixed(2)}',
                Icons.trending_up,
                Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildStatCard(
          'Expense',
          '\$${totalExpense.toStringAsFixed(2)}',
          Icons.trending_down,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, color: color, size: 32),
                Text(
                  title,
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    final recentTransactions = _transactions.take(6).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Transactions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ...recentTransactions.map(
              (t) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: t.type == 'income'
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  child: Icon(
                    t.type == 'income'
                        ? Icons.trending_up
                        : Icons.trending_down,
                    color: t.type == 'income' ? Colors.green : Colors.red,
                  ),
                ),
                title: Text(t.category),
                subtitle: Text(t.description ?? 'No description'),
                trailing: Text(
                  '${t.type == 'income' ? '+' : '-'}\$${t.amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: t.type == 'income' ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReports() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Reports',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: () {
                    // Filter functionality can be added
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.download),
                  onPressed: _exportData,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Summary Cards
        Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.trending_up,
                        color: Colors.green,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\${totalIncome.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                      const Text('Total Income'),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.trending_down,
                        color: Colors.red,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '\${totalExpense.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      const Text('Total Expense'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Expense by Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (categoryExpenses.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No expense data yet'),
                    ),
                  )
                else
                  ...categoryExpenses.entries.map((e) {
                    final percentage = totalExpense > 0
                        ? (e.value / totalExpense) * 100
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\${e.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.red.shade400,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Income by Category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                if (categoryIncomes.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('No income data yet'),
                    ),
                  )
                else
                  ...categoryIncomes.entries.map((e) {
                    final percentage = totalIncome > 0
                        ? (e.value / totalIncome) * 100
                        : 0;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                e.key,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '\${e.value.toStringAsFixed(2)} (${percentage.toStringAsFixed(1)}%)',
                                style: const TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: percentage / 100,
                              backgroundColor: Colors.grey[200],
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.green.shade400,
                              ),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'All Transactions',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${_transactions.length} total',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (_transactions.isEmpty)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text('No transactions yet'),
                        ],
                      ),
                    ),
                  )
                else
                  ..._transactions.map(
                    (t) => Dismissible(
                      key: Key(t.id.toString()),
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 16),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        _deleteTransaction(t.id!);
                      },
                      child: Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        elevation: 0,
                        color: Colors.grey.shade50,
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: t.type == 'income'
                                ? Colors.green.shade50
                                : Colors.red.shade50,
                            child: Icon(
                              t.type == 'income'
                                  ? Icons.trending_up
                                  : Icons.trending_down,
                              color: t.type == 'income'
                                  ? Colors.green
                                  : Colors.red,
                            ),
                          ),
                          title: Text(
                            t.category,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            '${DateFormat('MMM dd, yyyy').format(DateTime.parse(t.date))} • ${t.description ?? "No description"}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: Text(
                            '${t.type == 'income' ? '+' : '-'}\${t.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: t.type == 'income'
                                  ? Colors.green
                                  : Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildProfile() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Profile',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blue,
                  child: const Text(
                    'JD',
                    style: TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'John Doe',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Text('john.doe@email.com'),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Account Statistics',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.5,
                  children: [
                    _buildStatItem(
                      '${_transactions.length}',
                      'Total Transactions',
                      Colors.blue,
                    ),
                    _buildStatItem(
                      '${_transactions.where((t) => t.type == 'income').length}',
                      'Income Records',
                      Colors.green,
                    ),
                    _buildStatItem(
                      '${_transactions.where((t) => t.type == 'expense').length}',
                      'Expense Records',
                      Colors.red,
                    ),
                    _buildStatItem(
                      '${categoryExpenses.length}',
                      'Categories Used',
                      Colors.purple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Categories',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Expense Categories',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _expenseCategories
                      .map(
                        (cat) => Chip(
                          label: Text(cat),
                          backgroundColor: Colors.red.shade50,
                          labelStyle: TextStyle(color: Colors.red.shade700),
                        ),
                      )
                      .toList(),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Income Categories',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _incomeCategories
                      .map(
                        (cat) => Chip(
                          label: Text(cat),
                          backgroundColor: Colors.green.shade50,
                          labelStyle: TextStyle(color: Colors.green.shade700),
                        ),
                      )
                      .toList(),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.upload_file, color: Colors.blue),
                title: const Text('Export Data'),
                subtitle: const Text('Export transactions to CSV'),
                onTap: _exportData,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.download, color: Colors.green),
                title: const Text('Import Data'),
                subtitle: const Text('Import transactions from CSV'),
                onTap: _importData,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.category, color: Colors.orange),
                title: const Text('Manage Categories'),
                subtitle: const Text('Add or view categories'),
                onTap: _showCategoryDialog,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.delete_forever, color: Colors.red),
                title: const Text('Clear All Data'),
                subtitle: const Text('Delete all transactions'),
                onTap: _showClearDataDialog,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String value, String label, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    final BuildContext currentContext = context as BuildContext;
    showDialog(
      context: currentContext,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Data'),
        content: const Text(
          'Are you sure you want to delete all transactions? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final db = await DatabaseHelper.instance.database;
              await db.delete('transactions');
              await _loadData();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All data cleared successfully')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTransaction(int id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    await _loadData();
    ScaffoldMessenger.of(
      context as BuildContext,
    ).showSnackBar(const SnackBar(content: Text('Transaction deleted')));
  }
}
