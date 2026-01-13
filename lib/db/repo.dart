import 'package:my_delivery/db/app_database.dart';

import 'assignment_dao.dart';
import 'delivery_boy_dao.dart';

class ReportRepository {
  Future<List<Map<String, dynamic>>> getDeliveryReport(
    String deliveryBoyId,
    String startDate,
    String endDate,
  ) async {
    final db = await AppDatabase.instance.database;

    return await db.rawQuery(
      '''
    SELECT 
      a.date,
      a.office,
      a.cod,
      a.prepaid,
      a.pickup,
      a.bfsi,
      (a.cod + a.prepaid + a.pickup + a.bfsi) AS total,
      d.name AS delivery_boy_name
    FROM assignments a
    INNER JOIN delivery_boys d
      ON a.delivery_boy_id = d.id
    WHERE a.delivery_boy_id = ?
      AND a.date BETWEEN ? AND ?
    ORDER BY a.date ASC
  ''',
      [deliveryBoyId, startDate, endDate],
    );
  }

  /* Future<void> sampleInsert() async {
    await DeliveryBoyDao().insert({'id': 'DB001', 'name': 'Anil Jadhav'});

    await AssignmentDao().insert({
      'delivery_boy_id': 'DB001',
      'date': '2026-01-10',
      'office': 12,
      'cod': 5,
      'prepaid': 7,
      'pickup': 3,
      'bfsi': 1,
    });
  }*/
}
