import 'package:flutter/material.dart';
import 'package:my_delivery/db/delivery_boy_dao.dart';
import 'package:my_delivery/screens/dialog_screen/add_delivery_boy_dialog.dart';
import 'package:my_delivery/screens/dialog_screen/edit_delivery_boy_dialog.dart';
import 'package:my_delivery/util/dialog_helper.dart';
import 'package:my_delivery/util/table_helper.dart';

class IDsManagement extends StatefulWidget {
  const IDsManagement({super.key});

  @override
  State<StatefulWidget> createState() => _IDsManagement();
}

class _IDsManagement extends State<IDsManagement> {
  TableHelper tableHelper = TableHelper();

  List<Map<String, dynamic>> deliveryBoys = [];

  @override
  void initState() {
    super.initState();
    _loadDeliveryBoys();
  }

  Future<void> _loadDeliveryBoys() async {
    final data = await DeliveryBoyDao().getAll();
    if (!mounted) return;
    setState(() {
      deliveryBoys = data;
    });
    print(data);
  }

  Future<void> _openAddDialog() async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AddDeliveryBoyDialog(),
    );

    if (result == true && mounted) {
      _loadDeliveryBoys();
    }
  }

  Future<void> _edit(Map<String, dynamic> row) async {
    final updated = await showDialog<bool>(
      context: context,
      builder: (_) => EditDeliveryBoyDialog(
        id: row['id'],
        name: row['name'],
        contact: row['contact'],
      ),
    );

    if (updated == true && mounted) {
      _loadDeliveryBoys();
    }
  }

  Future<void> _delete(Map<String, dynamic> row) async {
    final confirm = await showDeleteDialog(
      context,
      title: "Delete Delivery Boy",
      message: "Delete ${row['name']} permanently?",
    );

    if (confirm != true) return;

    await DeliveryBoyDao().delete(row['id']);
    if (!mounted) return;

    _loadDeliveryBoys();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text("${row['name']} deleted")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("IDs Management"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDeliveryBoys,
          ),
        ],
      ),
      body: Column(
        children: [
          tableHelper.title("Delivery Boys"),
          tableHelper.table(deliveryBoys, _edit, _delete),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // reuse Add dialog
          final added = await showDialog<bool>(
            context: context,
            builder: (_) => AddDeliveryBoyDialog(),
          );

          if (added == true && mounted) {
            _loadDeliveryBoys();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
