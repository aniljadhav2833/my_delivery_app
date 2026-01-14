import 'dart:async';
import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sqflite/sqflite.dart';

import '../db/app_database.dart';
import '../models/import_progress.dart';

class ExcelImportService {
  /// Pick Excel file
  static Future<File?> pickExcelFile() async {
    if (Platform.isAndroid == true) {
      final status = await Permission.manageExternalStorage.request();
      if (!status.isGranted) return null;
    }

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result == null || result.files.single.path == null) {
      return null;
    }

    return File(result.files.single.path!);
  }

  /// 🔐 Convert Excel cell → SQLite safe value
  static Object? _cellValueToDbValue(Data? cell) {
    if (cell == null) return null;

    // SQLite supported types only
    if (cell is IntCellValue) return cell.value;
    if (cell is DoubleCellValue) return cell.value;
    if (cell is BoolCellValue) return cell.value != null ? 1 : 0;

    // Text / RichText / Formula / Anything else
    final value = cell.value;
    if (value == null) return null;

    if (value is DateTime) {
      final DateTime dt = value as DateTime;
      return dt.toIso8601String();
    }

    // ✅ This safely flattens TextSpan, formulas, rich text, etc.
    return value.toString();
  }

  static String _richTextToString(TextSpan span) {
    final buffer = StringBuffer();

    if (span.text != null) {
      buffer.write(span.text);
    }

    final children = span.children;
    if (children != null) {
      for (final child in children) {
        if (child is TextSpan) {
          buffer.write(_richTextToString(child));
        }
      }
    }

    return buffer.toString();
  }

  static Future<void> _truncateTables(DatabaseExecutor db) async {
    await db.delete('assignments');
    await db.delete('delivery_boys');
    await db.delete('prices');
  }

  /// Import Excel with progress + transaction + validation
  static Stream<ImportProgress> importExcel(File file) {
    final controller = StreamController<ImportProgress>();

    () async {
      try {
        final bytes = await file.readAsBytes();
        final excel = Excel.decodeBytes(bytes);
        final db = await AppDatabase.instance.database;

        await db.transaction((txn) async {
          await _truncateTables(txn);

          for (final table in excel.tables.keys) {
            final sheet = excel.tables[table];
            if (sheet == null || sheet.rows.length < 2) continue;

            final valid = await _validateSchema(txn, table, sheet);
            if (!valid) {
              throw Exception('Schema mismatch for table: $table');
            }

            // ✅ Safe headers
            final headers = sheet.rows.first
                .map((e) => e?.value?.toString() ?? '')
                .toList();

            final totalRows = sheet.rows.length - 1;

            for (int i = 1; i < sheet.rows.length; i++) {
              final row = sheet.rows[i];
              final Map<String, Object?> data = {};

              for (int j = 0; j < headers.length; j++) {
                final key = headers[j];
                if (key.isEmpty) continue;

                final cell = j < row.length ? row[j] : null;
                data[key] = _cellValueToDbValue(cell);
              }

              await txn.insert(
                table,
                data,
                conflictAlgorithm: ConflictAlgorithm.replace,
              );

              controller.add(
                ImportProgress(current: i, total: totalRows, table: table),
              );
            }
          }
        });

        await controller.close();
      } catch (e, s) {
        controller.addError(e, s);
        await controller.close();
      }
    }();

    return controller.stream.asBroadcastStream();
  }

  /// Validate Excel headers against DB columns
  static Future<bool> _validateSchema(
    DatabaseExecutor db,
    String table,
    Sheet sheet,
  ) async {
    final dbColumns = await db.rawQuery('PRAGMA table_info($table)');
    final columnNames = dbColumns.map((e) => e['name'].toString()).toSet();

    final excelHeaders = sheet.rows.first
        .map((e) => e?.value?.toString())
        .whereType<String>()
        .toSet();

    return excelHeaders.containsAll(columnNames);
  }
}
