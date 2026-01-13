import 'package:shared_preferences/shared_preferences.dart';

import '../db/app_database.dart';
import 'encrypted_backup.dart';

class AutoBackupService {
  static const _key = 'last_backup_date';

  static Future<void> runDailyBackup() async {
    await AppDatabase.instance.database;

    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().substring(0, 10);

    final lastBackup = prefs.getString(_key);
    if (lastBackup == today) return;

    await EncryptedBackup.createBackup();
    await prefs.setString(_key, today);
  }
}
