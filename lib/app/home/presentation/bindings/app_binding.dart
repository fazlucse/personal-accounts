import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/repositories/category_repository.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../cubits/category_cubit.dart';
import '../cubits/transaction_cubit.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/settings_cubit.dart';

final getIt = GetIt.instance;

Future<void> setupBindings() async {
  // -------------------------------------------------
  // 1. SQLite Database (creates tables + defaults)
  // -------------------------------------------------
  getIt.registerSingletonAsync<Database>(() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'finance_tracker.db');

    return await openDatabase(
      path,
      version: 2, // bump version to run onUpgrade if needed
      onCreate: (db, version) async {
        // ---- Transactions table (you already have) ----
        await db.execute('''
          CREATE TABLE transactions (
            id INTEGER PRIMARY KEY,
            type TEXT,
            category TEXT,
            amount REAL,
            date TEXT,
            description TEXT,
            created_by TEXT,
            created_at TEXT
          )
        ''');

        // ---- Category table (NEW) ----
        await db.execute('''
          CREATE TABLE category (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            name TEXT NOT NULL,
            created_by TEXT DEFAULT 'system',
            created_at TEXT DEFAULT (datetime('now'))
          )
        ''');

        // ---- Insert default categories ----
        await _insertDefaultCategories(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE category (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              type TEXT NOT NULL,
              name TEXT NOT NULL,
              created_by TEXT DEFAULT 'system',
              created_at TEXT DEFAULT (datetime('now'))
            )
          ''');
          await _insertDefaultCategories(db);
        }
      },
    );
  });

  // -------------------------------------------------
  // 2. Repositories
  // -------------------------------------------------
  getIt.registerSingletonAsync<TransactionRepository>(() async {
    await getIt.isReady<Database>();
    return TransactionRepository(getIt<Database>());
  }, dependsOn: [Database]);

  getIt.registerSingletonAsync<CategoryRepository>(() async {
    await getIt.isReady<Database>();
    return CategoryRepository(getIt<Database>());
  }, dependsOn: [Database]);

  getIt.registerSingleton<ProfileRepository>(ProfileRepository());
  getIt.registerSingleton<SettingsRepository>(SettingsRepository());
  getIt.registerSingleton<ReportRepository>(ReportRepository());

  // -------------------------------------------------
  // 3. Cubits
  // -------------------------------------------------
  getIt.registerSingletonAsync<TransactionCubit>(() async {
    await getIt.isReady<TransactionRepository>();
    return TransactionCubit(getIt<TransactionRepository>());
  }, dependsOn: [TransactionRepository]);

  getIt.registerSingletonAsync<CategoryCubit>(() async {
    await getIt.isReady<CategoryRepository>();
    final cubit = CategoryCubit(getIt<CategoryRepository>());
    await cubit.loadCategories(); // Load once at startup
    return cubit;
  }, dependsOn: [CategoryRepository]);

  getIt.registerFactory(() => ProfileCubit(getIt<ProfileRepository>()));
  getIt.registerFactory(() => SettingsCubit(getIt<SettingsRepository>()));
}

// -------------------------------------------------
// Helper: Insert default categories (alphabetical)
// -------------------------------------------------
Future<void> _insertDefaultCategories(Database db) async {
  final income = ['Salary', 'Freelance', 'Business', 'Investment', 'Other'];

  final expense = [
    'Beauty & Personal Care', 'Bills', 'Childcare', 'Clothing',
    'Credit Card Payment', 'Dining Out', 'Donations', 'Education',
    'Electronics', 'Entertainment', 'Food', 'Fruits', 'Fuel', 'Gifts',
    'Groceries', 'Health', 'Home Supplies', 'Insurance', 'Internet',
    'Loan Payment', 'Maintenance', 'Medicine', 'Others', 'Pets',
    'Phone', 'Rent', 'Repairs', 'Savings Deposit', 'Shopping',
    'Sports & Fitness', 'Stationery', 'Subscriptions', 'Taxes',
    'Transport', 'Travel', 'Utilities',
  ];

  final batch = db.batch();
  for (final name in income) {
    batch.insert('category', {'type': 'income', 'name': name},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  for (final name in expense) {
    batch.insert('category', {'type': 'expense', 'name': name},
        conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  await batch.commit(noResult: true);
}