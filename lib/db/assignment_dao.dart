import 'package:sqflite/sqflite.dart';

import 'app_database.dart';

class AssignmentDao {
  Future<void> upsert(Map<String, dynamic> data) async {
    final db = await AppDatabase.instance.database;

    await db.insert(
      'assignments',
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getByDeliveryBoy(int deliveryBoyId) async {
    final db = await AppDatabase.instance.database;
    return await db.query(
      'assignments',
      where: 'delivery_boy_id = ?',
      whereArgs: [deliveryBoyId],
      orderBy: 'date ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getByDeliveryBoyByName(
    String deliveryBoyName,
  ) async {
    final db = await AppDatabase.instance.database;
    return await db.query(
      'assignments',
      where: 'delivery_boy_name = ?',
      whereArgs: [deliveryBoyName],
      orderBy: 'date ASC',
    );
  }

  Future<List<Map<String, dynamic>>> getByDate(String date) async {
    final db = await AppDatabase.instance.database;
    return await db.query('assignments', where: 'date = ?', whereArgs: [date]);
  }

  Future<List<Map<String, dynamic>>> getByRange(
    String start,
    String end,
  ) async {
    final db = await AppDatabase.instance.database;
    return db.query(
      'assignments',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date ASC',
    );
  }

  Future<Map<String, dynamic>> getSumByRange(String start, String end) async {
    final db = await AppDatabase.instance.database;

    final result = await db.rawQuery(
      '''
    SELECT 
      SUM(a.cod)            AS cod,
      SUM(a.prepaid)        AS prepaid,
      SUM(a.pickup)         AS pickup,
      SUM(a.bfsi)           AS bfsi,

      SUM(a.cod * p.cod)           AS codAmount,
      SUM(a.prepaid * p.prepaid)   AS prepaidAmount,
      SUM(a.pickup * p.pickup)     AS pickupAmount,
      SUM(a.bfsi * p.bfsi)         AS bfsiAmount,

      SUM(a.cod + a.prepaid + a.pickup + a.bfsi) AS totalCount,

      SUM(
        (a.cod * p.cod) +
        (a.prepaid * p.prepaid) +
        (a.pickup * p.pickup) +
        (a.bfsi * p.bfsi)
      ) AS totalAmount

    FROM assignments a
    JOIN prices p ON p.type = 'my'
    WHERE a.date BETWEEN ? AND ?
  ''',
      [start, end],
    );

    return result.isNotEmpty ? result.first : {};
  }
}
