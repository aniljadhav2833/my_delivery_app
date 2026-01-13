import 'package:flutter/material.dart';
import 'package:my_delivery/db/delivery_boy_dao.dart';

class EditDeliveryBoyDialog extends StatefulWidget {
  final int id;
  final String name;
  final String contact;
  const EditDeliveryBoyDialog({
    super.key,
    required this.id,
    required this.name,
    required this.contact,
  });

  @override
  State<EditDeliveryBoyDialog> createState() => _EditDeliveryBoyDialogState();
}

class _EditDeliveryBoyDialogState extends State<EditDeliveryBoyDialog> {
  late TextEditingController nameCtrl;
  late TextEditingController contactCtrl;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.name);
    contactCtrl = TextEditingController(text: widget.contact);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Edit Delivery Boy"),
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

            await DeliveryBoyDao().update(
              widget.id,
              nameCtrl.text,
              contactCtrl.text,
            );

            if (!mounted) return;
            Navigator.pop(context, true);
          },
          child: const Text("Update"),
        ),
      ],
    );
  }
}
