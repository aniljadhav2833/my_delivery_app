import 'package:flutter/material.dart';

class TableHelper {
  Widget title(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget table(
    List<Map<String, dynamic>> data,
    void Function(Map<String, dynamic>) onEdit,
    void Function(Map<String, dynamic>) onDelete,
  ) {
    return Expanded(
      child: ListView.builder(
        itemCount: data.length,
        itemBuilder: (_, i) {
          final row = data[i];
          return Card(
            child: ListTile(
              title: Text("${row['name']} (${row['contact']}) "),
              subtitle: Text(
                "ID: ${(i + 1).toString()}",
              ), //Text("ID: ${row['id']}")
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () => onEdit(row),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => onDelete(row),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<bool?> showDeleteDialog(BuildContext context, String name) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete"),
        content: Text("Delete $name permanently?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }
}
