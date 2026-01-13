import 'package:flutter/material.dart';
import 'package:my_delivery/db/delivery_boy_dao.dart';
import 'package:my_delivery/screens/report/reports_by_id.dart';

class OtherReport extends StatefulWidget {
  const OtherReport({super.key});

  @override
  State<StatefulWidget> createState() => _OtherReport();
}

class _OtherReport extends State<OtherReport> {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Delivery Boys Report")),
      body: Padding(padding: EdgeInsets.all(12), child: _entityDropdown()),
    );
  }

  Widget _entityDropdown() {
    return /*StreamBuilder<QuerySnapshot>(
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }



        return*/ ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: deliveryBoys.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final doc = deliveryBoys;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ReportsById(
                  id: deliveryBoys[index]['id'],
                  title: deliveryBoys[index]['name'],
                ),
              ),
            );
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  // Leading icon
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.delivery_dining, color: Colors.indigo),
                  ),

                  const SizedBox(width: 14),

                  Text(
                    "${deliveryBoys[index]['id']}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(width: 14),

                  // Title & subtitle
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${deliveryBoys[index]['name']}",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "Delivery Boy",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Trailing arrow
                  Icon(Icons.chevron_right, color: Colors.grey.shade400),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
