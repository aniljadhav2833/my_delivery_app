import 'package:my_delivery/db/app_database.dart';
import 'package:sqflite/sqflite.dart';

class PriceDao {
  /// Insert or Update (UPSERT by type)
  Future<void> upsert(Map<String, dynamic> data) async {
    final db = await AppDatabase.instance.database;

    await db.insert(
      'prices',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("Price saved" + data.toString());
  }

  /// Get by type (my / others)
  Future<Map<String, dynamic>?> getByType(String type) async {
    final db = await AppDatabase.instance.database;

    final result = await db.query(
      'prices',
      where: 'type = ?',
      whereArgs: [type],
      limit: 1,
    );

    return result.isNotEmpty ? result.first : null;
  }

  /// Get all
  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await AppDatabase.instance.database;
    return await db.query('prices');
  }

  /// Update by type ONLY
  Future<int> updateByType(String type, Map<String, dynamic> data) async {
    final db = await AppDatabase.instance.database;

    return await db.update(
      'prices',
      data,
      where: 'type = ?',
      whereArgs: [type],
    );
  }

  /// Delete by type
  Future<int> deleteByType(String type) async {
    final db = await AppDatabase.instance.database;

    return await db.delete('prices', where: 'type = ?', whereArgs: [type]);
  }
}
