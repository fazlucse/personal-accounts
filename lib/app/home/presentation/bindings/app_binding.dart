
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get_it/get_it.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../../data/repositories/transaction_repository.dart';
import '../../data/repositories/profile_repository.dart';
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/report_repository.dart';
import '../cubits/transaction_cubit.dart';
import '../cubits/profile_cubit.dart';
import '../cubits/settings_cubit.dart';

final getIt = GetIt.instance;

 setupBindings() {
  // Initialize Firebase and Database
//   getIt.registerSingleton<FirebaseFirestore>(FirebaseFirestore.instance);

  getIt.registerSingletonAsync<Database>(() async {
    final dbPath = await getDatabasesPath();
    final database = await openDatabase(
      join(dbPath, 'finance_tracker.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
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
          ''',
        );
      },
    //       onOpen: (db) async {
    //   // Optional: Drop table if exists (careful: will delete all data)
    //   await db.execute('DROP TABLE IF EXISTS transactions');
    //   await db.execute(
    //     '''
    //     CREATE TABLE transactions (
    //       id INTEGER PRIMARY KEY,
    //       type TEXT,
    //       category TEXT,
    //       amount REAL,
    //       date TEXT,
    //       description TEXT,
    //       created_by TEXT,
    //       created_at TEXT
    //     )
    //     '''
    //   );
    // },
      version: 1,
    );
    return database;
  });

  // Repositories
  getIt.registerSingletonAsync<TransactionRepository>(() async {
    await getIt.isReady<Database>(); // Wait for Database to be ready
    return TransactionRepository(getIt<Database>()); // , getIt<FirebaseFirestore>() 
  }, dependsOn: [Database]);

  getIt.registerSingleton<ProfileRepository>(ProfileRepository());
  getIt.registerSingleton<SettingsRepository>(SettingsRepository());
  getIt.registerSingleton<ReportRepository>(ReportRepository());

  // Cubits
  getIt.registerSingletonAsync<TransactionCubit>(() async {
    await getIt.isReady<TransactionRepository>();
    return TransactionCubit(getIt<TransactionRepository>());
  });

  getIt.registerFactory(() => ProfileCubit(getIt<ProfileRepository>()));
  getIt.registerFactory(() => SettingsCubit(getIt<SettingsRepository>()));
}