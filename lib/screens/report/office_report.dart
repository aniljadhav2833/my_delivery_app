import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_delivery/db/assignment_dao.dart';
import 'package:my_delivery/db/delivery_boy_dao.dart';
import 'package:my_delivery/db/price_dao.dart';
import 'package:my_delivery/models/office_row.dart';
import 'package:my_delivery/screens/report/office_report_pdf.dart';
import 'package:my_delivery/screens/widgets/cellw.dart';
import 'package:my_delivery/screens/widgets/hcell.dart';
import 'package:my_delivery/util/report_helper.dart';

class OfficeReport extends StatefulWidget {
  const OfficeReport({super.key});

  @override
  State<StatefulWidget> createState() => _OfficeReport();
}

class _OfficeReport extends State<OfficeReport> {
  DateTimeRange customRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  final ReportHelper reportHelper = ReportHelper();
  final AssignmentDao assignmentDao = AssignmentDao();

  static const double colDate = 110;
  static const double colName = 160;

  double PerParcelPrice = 0;

  String? selectedDeliveryBoy;

  List<OfficeRow> rows = [];
  List<Map<String, dynamic>> deliveryBoys = [];
  bool loading = true;

  bool filterOption = false;

  @override
  void initState() {
    super.initState();
    _loadTable();
    _loadDeliveryBoys();
    _loadPrices();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Office Data"),
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
      body: Column(
        children: [
          reportHelper.dateRangeSelector(
            range: customRange,
            context: context,
            onChanged: (r) {
              setState(() => customRange = r);
              _loadTable();
            },
          ),
          const SizedBox(width: 1),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.man),
                label: Text(filterOption ? "Filter on" : "Filter Off"),
                onPressed: () {
                  setState(() {
                    filterOption = !filterOption;
                    if (!filterOption) {
                      selectedDeliveryBoy = null;
                      _loadTable();
                    }
                  });
                },
              ),
              SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () async {
                  final report = OfficeReportTable(
                    customRange,
                    rows,
                    "Office Report",
                    perParcelRate: PerParcelPrice,
                  );
                  //report.generatePdf();
                  report.shareToWhatsapp();
                }, //generatePdf,
              ),
            ],
          ),
          filterOption
              ? DropdownButtonFormField<String>(
                  value: selectedDeliveryBoy,
                  hint: Text("Select delivery boy"),
                  //decoration: InputDecoration(labelText: selectedDeliveryBoy),
                  items: deliveryBoys
                      .map(
                        (d) => DropdownMenuItem<String>(
                          value: d['name'],
                          child: Text(d['name']),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => {
                    setState(() {
                      selectedDeliveryBoy = v!;
                      _loadTable();
                    }),
                  },
                )
              : Container(),
          const Divider(),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: colDate + colName * 4,
                  child: Row(children: [_table()]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  Future<void> _loadDeliveryBoys() async {
    final data = await DeliveryBoyDao().getAll();

    if (!mounted) return;
    setState(() {
      deliveryBoys = data;
    });
  }

  Future<void> _loadTable() async {
    setState(() => loading = true);

    final boys = (!filterOption && selectedDeliveryBoy == null)
        ? await DeliveryBoyDao().getAll()
        : await DeliveryBoyDao().getByName(selectedDeliveryBoy!);

    final assignments = await assignmentDao.getByRange(
      _dateKey(customRange.start),
      _dateKey(customRange.end),
    );

    final Map<String, Map<String, dynamic>> map = {
      for (final a in assignments) "${a['delivery_boy_id']}_${a['date']}": a,
    };

    rows.clear();
    for (final b in boys) {
      DateTime current = customRange.start; // ✅ MUST BE HERE

      while (!current.isAfter(customRange.end)) {
        final key = "${b['id']}_${_dateKey(current)}";
        final a = map[key];

        rows.add(
          OfficeRow(
            boyId: b['id'],
            boyName: b['name'],
            date: current, // ✅ valid now
            totalParcels: a?['office'] ?? 0,
            perParcelPrice: PerParcelPrice,
          ),
        );

        current = current.add(const Duration(days: 1)); // ✅ stays in scope
      }
    }

    setState(() => loading = false);
  }

  Widget _table() {
    return SizedBox(
      width: colDate + colName * 4,
      child: Column(
        children: [
          Row(
            children: const [
              HCell("Date", width: colDate),
              HCell("Name", width: colName),
              HCell("Total Parcels", width: colName),
              HCell("Price Per Parcel", width: colName),
              HCell("Total Amount", width: colName),
            ],
          ),
          Expanded(
            child: ListView.builder(
              itemCount: rows.length,
              itemBuilder: (_, i) {
                final r = rows[i];
                return Row(
                  children: [
                    CellW(text: _fmt(r.date), width: colDate),
                    CellW(text: r.boyName, width: colName),
                    CellW(
                      text: (r.totalParcels).toString(),
                      width: colName,
                      bg: Colors.grey.shade400,
                      bold: true,
                    ),
                    CellW(
                      width: colName,
                      text: r.perParcelPrice.toString(),
                      bg: Colors.grey.shade400,
                      bold: true,
                    ),
                    CellW(
                      width: colName,
                      text: r.totalAmount.toString(),
                      bg: Colors.grey.shade400,
                      bold: true,
                    ),
                  ],
                );
              },
            ),
          ),
          _footerTotals(),
          // Total will come
          SizedBox(height: 15),
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  Widget _footerTotals() {
    int totalParcels = 0;
    double totalAmount = 0;

    for (final r in rows) {
      totalParcels += r.totalParcels;
      totalAmount += r.totalAmount;
    }

    return Row(
      children: [
        CellW(text: "TOTAL", width: colDate + colName, bold: true),
        CellW(
          text: totalParcels.toString(),
          width: colName,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: PerParcelPrice.toString(),
          width: colName,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: totalAmount.toString(),
          width: colName,
          bold: true,
          bg: Colors.grey.shade400,
        ),
      ],
    );
  }

  Future<void> _loadPrices() async {
    final data = await PriceDao().getByType("others");

    if (data != null) {
      PerParcelPrice =
          (data['pickup'] + data['prepaid'] + data['cod'] + data['bfsi']) / 4;
    } else {
      PerParcelPrice = 0;
    }
  }
}
