import 'package:flutter/material.dart';
import 'package:my_delivery/db/price_dao.dart';
import 'package:my_delivery/models/rate_type.dart';

class RateDashboard extends StatelessWidget {
  final String title;
  final RateType type;
  final TextEditingController pickupCtrl;
  final TextEditingController prepaidCtrl;
  final TextEditingController codCtrl;

  final TextEditingController bfsiCtrl;

  const RateDashboard({
    super.key,
    required this.title,
    required this.type,
    required this.pickupCtrl,
    required this.prepaidCtrl,
    required this.codCtrl,
    required this.bfsiCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            EditField(pickupCtrl, "Pickup"),
            EditField(prepaidCtrl, "Prepaid"),
            EditField(codCtrl, "COD"),
            EditField(bfsiCtrl, "BFSI"),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () async {
                final dao = PriceDao();
                await dao.upsert({
                  'type': type.name,
                  'pickup': _parseRate(pickupCtrl.text),
                  'prepaid': _parseRate(prepaidCtrl.text),
                  'cod': _parseRate(codCtrl.text),
                  'bfsi': _parseRate(bfsiCtrl.text),
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('$title saved successfully')),
                );
              },
              child: const Text("Save"),
            ),
          ],
        ),
      ),
    );
  }

  double _parseRate(String value) {
    final v = double.tryParse(value);
    return (v == null || v < 0) ? 0 : v;
  }

  Widget EditField(TextEditingController editingController, String label) {
    return TextField(
      controller: editingController,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label),
    );
  }
}
