import 'package:flutter/material.dart';
import 'package:my_delivery/db/assignment_dao.dart';
import 'package:my_delivery/screens/widgets/dashboard.dart';
import 'package:my_delivery/util/report_helper.dart';

class TotalEarning extends StatefulWidget {
  const TotalEarning({super.key});

  @override
  State<StatefulWidget> createState() => _TotalEarning();
}

class _TotalEarning extends State<TotalEarning> {
  bool loading = false;
  int todayTotalCount = 0;
  double todayTotalEarning = 0;
  DateTimeRange customRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  final ReportHelper reportHelper = ReportHelper();
  final AssignmentDao assignmentDao = AssignmentDao();

  Future<void> _loadData() async {
    final summary = await assignmentDao.getSumByRange(
      _dateKey(customRange.start),
      _dateKey(customRange.end),
    );

    if (!mounted) return;

    setState(() {
      todayTotalCount = (summary['totalCount'] as num?)?.toInt() ?? 0;
      todayTotalEarning = (summary['totalAmount'] as num?)?.toDouble() ?? 0.0;
    });
  }

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Earning Dashboard"),
        actionsPadding: EdgeInsets.only(right: 10),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {});
              _loadData();
            },
            icon: Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          reportHelper.dateRangeSelector(
            range: customRange,
            context: context,
            onChanged: (r) {
              setState(() => customRange = r);
              _loadData();
            },
          ),
          DashboardCard(
            title: "Total Deliveries",
            value: loading ? "..." : todayTotalCount.toString(),
          ),
          DashboardCard(
            title: "Total Earnings",
            value: loading
                ? "..."
                : "₹ ${todayTotalEarning.toStringAsFixed(2)}",
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
