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

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<StatefulWidget> createState() => _HomeScreen();
}

class _HomeScreen extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actionsPadding: EdgeInsets.only(right: 10),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NavigationButton(
            title: "Configure Prices",
            screen: PriceConfigScreen(),
          ),
          NavigationButton(title: "Total Earning", screen: TotalEarning()),
          NavigationButton(title: "Assign Delivery", screen: AssignIdScreen()),
          NavigationButton(title: "View Reports", screen: ReportScreen()),
          NavigationButton(title: "IDs Management", screen: IDsManagement()),
          SecuritySettings(),
        ],
      ),
    );
  }
}
