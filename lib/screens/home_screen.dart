import 'package:flutter/material.dart';
import 'package:my_delivery/auth/biometric_service.dart';
import 'package:my_delivery/auth/securtiy_settings.dart';
import 'package:my_delivery/db/repo.dart';
import 'package:my_delivery/screens/ids_management_screen.dart';
import 'package:my_delivery/screens/assign_id/assign_id_screen.dart';
import 'package:my_delivery/screens/price_config_screen.dart';
import 'package:my_delivery/screens/report/reports_screen.dart';
import 'package:my_delivery/screens/total_earnings.dart';
import 'package:my_delivery/screens/widgets/dashboard.dart';
import 'package:my_delivery/screens/widgets/navigation_button.dart';

import '../excel/excel_export_service.dart';
import '../excel/excel_import_service.dart';
import '../models/import_progress.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        centerTitle: true,
        elevation: 0,
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _sectionTitle('Management'),

          _dashboardCard(
            context,
            children: const [
              _NavItem(
                title: 'Configure Prices',
                icon: Icons.currency_rupee,
                screen: PriceConfigScreen(),
              ),
              _NavItem(
                title: 'Assign Delivery',
                icon: Icons.assignment,
                screen: AssignIdScreen(),
              ),
              _NavItem(
                title: 'IDs Management',
                icon: Icons.badge,
                screen: IDsManagement(),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _sectionTitle('Reports'),

          _dashboardCard(
            context,
            children: const [
              _NavItem(
                title: 'Total Earnings',
                icon: Icons.bar_chart,
                screen: TotalEarning(),
              ),
              _NavItem(
                title: 'View Reports',
                icon: Icons.receipt_long,
                screen: ReportScreen(),
              ),
            ],
          ),

          const SizedBox(height: 20),
          _sectionTitle('Security'),

          _dashboardCard(context, children: const [SecuritySettings()]),

          const SizedBox(height: 90), // space for bottom bar
        ],
      ),

      // 🔥 Bottom fixed action bar
      bottomNavigationBar: _bottomActions(context),
    );
  }

  /// 🔹 Bottom Import / Export actions
  Widget _bottomActions(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.table_chart),
                label: const Text('Export Excel'),
                onPressed: () async {
                  final file = await ExcelExportService.exportAllTables();

                  if (!mounted) return;

                  if (file == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Permission denied')),
                    );
                    return;
                  }

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Saved to ${file.path}')),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Import Excel'),
                onPressed: () => _startImport(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔹 Import with polished dialog
  void _startImport(BuildContext context) async {
    final file = await ExcelImportService.pickExcelFile();
    if (file == null) return;

    final stream = ExcelImportService.importExcel(file);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: StreamBuilder<ImportProgress>(
            stream: stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return _progressLayout(
                  title: 'Preparing import…',
                  subtitle: 'Reading Excel file',
                  progress: null,
                );
              }

              final p = snapshot.data!;
              final progress = p.total == 0 ? 0.0 : p.current / p.total;

              return _progressLayout(
                title: 'Importing ${p.table}',
                subtitle: '${p.current} / ${p.total} records',
                progress: progress,
              );
            },
          ),
        ),
      ),
    );

    stream.listen(
      (_) {},
      onError: (e) {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Import failed: $e')));
      },
      onDone: () async {
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Import completed successfully')),
        );
      },
    );
  }

  /// 🔹 Helpers
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _dashboardCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Column(children: children),
    );
  }

  Widget _progressLayout({
    required String title,
    required String subtitle,
    double? progress,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        if (progress == null)
          const Center(child: CircularProgressIndicator())
        else
          LinearProgressIndicator(value: progress),
        const SizedBox(height: 10),
        Text(subtitle),
      ],
    );
  }
}

class _NavItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget screen;

  const _NavItem({
    required this.title,
    required this.icon,
    required this.screen,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
