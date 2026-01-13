import 'dart:io';
import 'package:intl/intl.dart';

import 'backup_service.dart';
import 'crypto_helper.dart';

class EncryptedBackup {
  static Future<void> createBackup() async {
    final dbFile = await BackupService.getDatabaseFile();
    final backupDir = await BackupService.getBackupDir();

    final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
    final backupFile = File('${backupDir.path}/backup_$timestamp.enc');

    final encryptedData = CryptoHelper.encrypt(await dbFile.readAsBytes());

    await backupFile.writeAsBytes(encryptedData, flush: true);
  }

  static Future<void> restoreLatestBackup() async {
    final backupDir = await BackupService.getBackupDir();
    final files = backupDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.enc'))
        .toList();

    if (files.isEmpty) return;

    files.sort((a, b) => b.path.compareTo(a.path));
    final latest = files.first;

    final decrypted = CryptoHelper.decrypt(await latest.readAsBytes());

    final dbFile = await BackupService.getDatabaseFile();
    await dbFile.writeAsBytes(decrypted, flush: true);
  }
}
