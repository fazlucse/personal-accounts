
// import 'package:cloud_firestore/cloud_firestore.dart' hide Transaction;
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class TransactionRepository {
  final Database _database; // SQLite database instance
//   final FirebaseFirestore _firestore; // Firestore instance

  TransactionRepository(this._database); // , this._firestore

  // Public getter for the database
  Database get database => _database;

  Future<void> initDatabase() async {
  final dbPath = await getDatabasesPath();
  await openDatabase(
    join(dbPath, 'finance_tracker.db'),
    version: 1,
    onCreate: (db, version) async {
      // Create table
      await db.execute(
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
        '''
      );
    },
    // onOpen: (db) async {
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
  );
}


  Future<List<Transaction>> getTransactions() async {
    final List<Map<String, dynamic>> maps = await _database.query('transactions');
    final transactions = maps.map((map) => Transaction.fromMap(map)).toList();

    // Sync with Firestore
    // final firestoreTransactions = await _firestore.collection('transactions').get();
    // for (var doc in firestoreTransactions.docs) {
    //   final transaction = Transaction.fromJson(doc.data());
    //   await _database.insert(
    //     'transactions',
    //     transaction.toMap(),
    //     conflictAlgorithm: ConflictAlgorithm.replace,
    //   );
    // }

    return transactions;
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _database.insert(
      'transactions',
      transaction.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    // Sync to Firestore
    // await _firestore.collection('transactions').doc(transaction.id.toString()).set(transaction.toJson());
  }
}
