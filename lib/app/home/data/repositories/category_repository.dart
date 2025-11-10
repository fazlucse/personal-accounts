// lib/data/repositories/category_repository.dart
import 'package:sqflite/sqflite.dart';

class CategoryRepository {
  final Database db;

  CategoryRepository(this.db);

  Future<List<String>> getByType(String type) async {
    final maps = await db.query(
      'category',
      columns: ['name'],
      where: 'type = ?',
      whereArgs: [type],
      orderBy: 'name ASC',
    );
    return maps.map((m) => m['name'] as String).toList();
  }
  Future<void> insert(String type, String name) async {
    await db.insert(
      'category',
      {'type': type, 'name': name},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  Future<void> delete(String type, String name) async {
    await db.delete(
      'category',
      where: 'type = ? AND name = ?',
      whereArgs: [type, name],
    );
  }
}