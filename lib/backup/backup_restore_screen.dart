import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'encrypted_backup.dart';

class BackupRestoreScreen extends StatelessWidget {
  const BackupRestoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup & Restore')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.backup),
              label: const Text('Create Backup'),
              onPressed: () async {
                await EncryptedBackup.createBackup();
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Backup created')));
              },
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.restore),
              label: const Text('Restore Backup'),
              onPressed: () async {
                await EncryptedBackup.restoreLatestBackup();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Backup restored')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
