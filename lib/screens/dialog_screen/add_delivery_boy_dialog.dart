import 'package:flutter/material.dart';
import 'package:my_delivery/db/delivery_boy_dao.dart';

class AddDeliveryBoyDialog extends StatefulWidget {
  const AddDeliveryBoyDialog({super.key});

  @override
  State<AddDeliveryBoyDialog> createState() => _AddDeliveryBoyDialogState();
}

class _AddDeliveryBoyDialogState extends State<AddDeliveryBoyDialog> {
  final nameCtrl = TextEditingController();
  final contactCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Add Delivery Boy"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: nameCtrl,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: contactCtrl,
            decoration: const InputDecoration(labelText: "Contact"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: () async {
            if (nameCtrl.text.isEmpty || contactCtrl.text.isEmpty) return;

            await DeliveryBoyDao().insert({
              'contact': contactCtrl.text,
              'name': nameCtrl.text,
            });

            if (!mounted) return;
            Navigator.pop(context, true); // ✅ safe
          },
          child: const Text("Save"),
        ),
      ],
    );
  }
}
