import 'package:flutter/material.dart';
import 'package:my_delivery/screens/report/my_report.dart';
import 'package:my_delivery/screens/report/other_report.dart';
import 'package:my_delivery/screens/widgets/navigation_button.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ReportScreen();
}

class _ReportScreen extends State<ReportScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Reports Dashboard"),
        actionsPadding: EdgeInsets.only(right: 10),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          NavigationButton(title: "My Report", screen: MyReport()),
          NavigationButton(title: "Others Reports", screen: OtherReport()),
        ],
      ),
    );
  }
}
