// lib/app/home/data/repositories/report_repository.dart

import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:share_plus/share_plus.dart' show XFile;
import 'package:sqflite/sqflite.dart' hide Transaction;
import 'package:path/path.dart';
import '../models/transaction_model.dart';

class ReportRepository {
  // ────── SINGLETON DB (same as before) ──────
  static Database? _database;
  static const _dbName = 'finance_tracker.db';
  static const _table = 'transactions';

  ReportRepository();

  Future<Database> get _db async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            type TEXT NOT NULL,
            category TEXT,
            amount REAL NOT NULL,
            date TEXT NOT NULL,
            description TEXT,
            created_by TEXT,
            created_at TEXT NOT NULL
          )
        ''');
      },
    );
  }

  // ────── GET FILTERED TRANSACTIONS ──────
  Future<List<Transaction>> getTransactions({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await _db;

    final now = DateTime.now();
    final defaultFrom = DateTime(now.year, now.month, 1);
    final defaultTo = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    final start = from ?? defaultFrom;
    final end = to ?? defaultTo;

    final startStr = '${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}';
    final endStr = '${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}';

    final maps = await db.query(
      _table,
      where: "date >= ? AND date <= ?",
      whereArgs: [startStr, endStr],
      orderBy: 'date DESC',
    );

    return maps.map((map) => Transaction.fromMap(map)).toList();
  }

  // ────── DOWNLOAD CSV ──────
  Future<void> downloadReport(List<Transaction> transactions) async {
    if (transactions.isEmpty) {
      throw Exception('No transactions to export');
    }

    final csvData = [
      ['Type', 'Category', 'Amount', 'Date', 'Description', 'Created By', 'Created At'],
      ...transactions.map((t) => [
        t.type,
        t.category ?? '',
        t.amount,
        t.date,
        t.description ?? '',
        t.created_by ?? '',
        t.created_at ?? '',
      ]),
    ];

    final csvString = const ListToCsvConverter().convert(csvData);
    final dir = await getTemporaryDirectory();
    final filePath = '${dir.path}/finance-report-${DateTime.now().millisecondsSinceEpoch}.csv';
    final file = File(filePath);
    await file.writeAsString(csvString);

    await Share.shareXFiles([XFile(filePath)], text: 'Finance Report');
  }
}