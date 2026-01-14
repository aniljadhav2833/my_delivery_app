import 'dart:io';
import 'package:excel/excel.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';

class ExcelExportService {
  static Future<File?> exportAllTables() async {
    final hasPermission = await requestStoragePermission();
    if (!hasPermission) return null;

    final db = await AppDatabase.instance.database;

    final deliveryBoys = await db.query('delivery_boys');
    final assignments = await db.query('assignments');
    final prices = await db.query('prices');

    return await compute(_buildExcelInBackground, {
      'delivery_boys': deliveryBoys,
      'assignments': assignments,
      'prices': prices,
    });
  }

  static Future<File?> _buildExcelInBackground(
    Map<String, List<Map<String, Object?>>> tables,
  ) async {
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    for (final entry in tables.entries) {
      final table = entry.key;
      final rows = entry.value;

      if (rows.isEmpty) continue;

      final sheet = excel[table];

      // Header
      sheet.appendRow(rows.first.keys.map((e) => TextCellValue(e)).toList());

      // Rows
      for (final row in rows) {
        sheet.appendRow(row.values.map(_toCellValue).toList());
      }
    }

    final dir = Directory('/storage/emulated/0/Download/MyDelivery');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File('${dir.path}/delivery_backup.xlsx');
    debugPrint("${file} is placed here");
    await file.writeAsBytes(excel.encode()!);
    debugPrint("${file} is placed here");
    return file;
  }

  static Future<File?> _exportInBackground(String dbPath) async {
    final db = await openDatabase(dbPath);
    final excel = Excel.createExcel();
    excel.delete('Sheet1');

    await _addSheet(excel, db, 'delivery_boys');
    await _addSheet(excel, db, 'assignments');
    await _addSheet(excel, db, 'prices');

    final dir = Directory('/storage/emulated/0/Download/MyDelivery');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }

    final file = File('${dir.path}/delivery_backup.xlsx');
    await file.writeAsBytes(excel.encode()!);

    return file;
  }

  static Future<void> _addSheet(Excel excel, Database db, String table) async {
    final sheet = excel[table];
    final data = await db.query(table);

    if (data.isEmpty) return;

    // Header
    sheet.appendRow(data.first.keys.map((e) => TextCellValue(e)).toList());
    // Rows
    for (final row in data) {
      sheet.appendRow(row.values.map(_toCellValue).toList());
    }
  }

  static CellValue _toCellValue(dynamic value) {
    if (value == null) return TextCellValue('');
    if (value is int) return IntCellValue(value);
    if (value is double) return DoubleCellValue(value);
    if (value is bool) return BoolCellValue(value);
    return TextCellValue(value.toString());
  }

  static Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.manageExternalStorage.isGranted) {
        return true;
      }

      final status = await Permission.manageExternalStorage.request();
      return status.isGranted;
    }

    final status = await Permission.storage.request();

    if (status.isGranted) {
      return true;
    }

    if (status.isPermanentlyDenied) {
      openAppSettings();
    }

    return false;
  }

  static Directory getDownloadDirectory() {
    return Directory('/storage/emulated/0/Download');
  }
}
