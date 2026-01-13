import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class DeliveryBoyDao {
  Future<void> insert(Map<String, dynamic> data) async {
    final db = await AppDatabase.instance.database;
    await db.insert(
      'delivery_boys',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await AppDatabase.instance.database;
    return await db.query('delivery_boys');
  }

  Future<List<Map<String, dynamic>>> getByName(String name) async {
    final db = await AppDatabase.instance.database;
    return await db.query(
      'delivery_boys',
      where: 'name = ?',
      whereArgs: [name],
    );
  }

  Future<void> update(int id, String name, String contact) async {
    final db = await AppDatabase.instance.database;
    await db.update(
      'delivery_boys',
      {'name': name, 'contact': contact},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> delete(int id) async {
    final db = await AppDatabase.instance.database;
    await db.delete('delivery_boys', where: 'id = ?', whereArgs: [id]);
  }
}
