import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class BackupService {
  static const dbName = 'delivery_app.db';

  static Future<File> getDatabaseFile() async {
    final dbPath = await getDatabasesPath();
    return File(join(dbPath, dbName));
  }

  static Future<Directory> getBackupDir() async {
    final dir = await getExternalStorageDirectory();
    final backupDir = Directory('${dir!.path}/backups');
    if (!backupDir.existsSync()) {
      backupDir.createSync(recursive: true);
    }
    return backupDir;
  }
}
