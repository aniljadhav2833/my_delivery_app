import 'package:flutter/material.dart';
import 'package:my_delivery/db/price_dao.dart';
import 'package:my_delivery/models/rate_type.dart';
import 'package:my_delivery/screens/widgets/rate_dashboard.dart';

class PriceConfigScreen extends StatefulWidget {
  const PriceConfigScreen({super.key});

  @override
  State<PriceConfigScreen> createState() => _PriceConfigScreenState();
}

class _PriceConfigScreenState extends State<PriceConfigScreen> {
  late final Map<RateType, TextEditingController> pickupCtrl;
  late final Map<RateType, TextEditingController> prepaidCtrl;
  late final Map<RateType, TextEditingController> codCtrl;
  late final Map<RateType, TextEditingController> bfsiCtrl;

  @override
  void dispose() {
    for (var c in pickupCtrl.values) c.dispose();
    for (var c in prepaidCtrl.values) c.dispose();
    for (var c in codCtrl.values) c.dispose();
    for (var c in bfsiCtrl.values) c.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initControllers();
    _loadPrices();
  }

  void _initControllers() {
    pickupCtrl = {
      RateType.my: TextEditingController(),
      RateType.others: TextEditingController(),
    };
    prepaidCtrl = {
      RateType.my: TextEditingController(),
      RateType.others: TextEditingController(),
    };
    codCtrl = {
      RateType.my: TextEditingController(),
      RateType.others: TextEditingController(),
    };
    bfsiCtrl = {
      RateType.my: TextEditingController(),
      RateType.others: TextEditingController(),
    };
  }

  Future<void> _loadPrices() async {
    final dao = PriceDao();

    for (final type in RateType.values) {
      final data = await dao.getByType(type.name);
      if (data != null) {
        pickupCtrl[type]!.text = data['pickup'].toString();
        prepaidCtrl[type]!.text = data['prepaid'].toString();
        codCtrl[type]!.text = data['cod'].toString();
        bfsiCtrl[type]!.text = data['bfsi'].toString();
      } else {
        pickupCtrl[type]!.text = '0';
        prepaidCtrl[type]!.text = '0';
        codCtrl[type]!.text = '0';
        bfsiCtrl[type]!.text = '0';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Price Configuration")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: RateType.values
              .map(
                (type) => RateDashboard(
                  title: type == RateType.my ? "My Rate" : "Others Rate",
                  type: type,
                  pickupCtrl: pickupCtrl[type]!,
                  prepaidCtrl: prepaidCtrl[type]!,
                  codCtrl: codCtrl[type]!,
                  bfsiCtrl: bfsiCtrl[type]!,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
