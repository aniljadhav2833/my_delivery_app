import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_delivery/db/assignment_dao.dart';
import 'package:my_delivery/db/delivery_boy_dao.dart';
import 'package:my_delivery/db/price_dao.dart';
import 'package:my_delivery/models/report_row.dart';
import 'package:my_delivery/screens/report/report_pdf.dart';
import 'package:my_delivery/screens/widgets/cellw.dart';
import 'package:my_delivery/screens/widgets/hcell.dart';
import 'package:my_delivery/util/report_helper.dart';

class OtherReportAll extends StatefulWidget {
  const OtherReportAll({super.key});

  @override
  State<StatefulWidget> createState() => _OtherReportAll();
}

class _OtherReportAll extends State<OtherReportAll> {
  DateTimeRange customRange = DateTimeRange(
    start: DateTime.now(),
    end: DateTime.now(),
  );

  final ReportHelper reportHelper = ReportHelper();
  final AssignmentDao assignmentDao = AssignmentDao();

  static const double colDate = 110;
  static const double colName = 160;
  static const double colNum = 90;
  static const double colTotal = 90;
  static const double colAmountNum = 140;

  double codPrice = 0;
  double prepaidPrice = 0;
  double pickupPrice = 0;
  double bfsiPrice = 0;

  String? selectedDeliveryBoy;

  List<ReportRow> rows = [];
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
        title: const Text("Others All Report"),
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
                  final report = ReportTable(
                    customRange,
                    rows,
                    "Others full Report",
                    codRate: codPrice,
                    ppRate: prepaidPrice,
                    rvpRate: pickupPrice,
                    bfsiRate: bfsiPrice,
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
                  width:
                      colDate +
                      colName +
                      colNum * 4 +
                      colAmountNum * 5 +
                      colTotal,
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
          ReportRow(
            boyId: b['id'],
            boyName: b['name'],
            date: current, // ✅ valid now
            cod: a?['cod'] ?? 0,
            pickupPrice: pickupPrice,
            prepaidPrice: prepaidPrice,
            bfsiPrice: bfsiPrice,
            codPrice: codPrice,
            prepaid: a?['prepaid'] ?? 0,
            pickup: a?['pickup'] ?? 0,
            bfsi: a?['bfsi'] ?? 0,
          ),
        );

        current = current.add(const Duration(days: 1)); // ✅ stays in scope
      }
    }

    setState(() => loading = false);
  }

  Widget _table() {
    return SizedBox(
      width: colDate + colName + colNum * 4 + colAmountNum * 5 + colTotal,
      child: Column(
        children: [
          Row(
            children: const [
              HCell("Date", width: colDate),
              HCell("Name", width: colName),
              HCell("COD", width: colNum),
              HCell("COD Amount", width: colAmountNum),
              HCell("Prepaid", width: colNum),
              HCell("Prepaid Amount", width: colAmountNum),
              HCell("Pickup", width: colNum),
              HCell("Pickup Amount", width: colAmountNum),
              HCell("BFSI", width: colNum),
              HCell("BFSI Amount", width: colAmountNum),
              HCell("Total", width: colTotal),
              HCell("Total Amount", width: colAmountNum),
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
                    CellW(text: r.cod.toString(), width: colNum),
                    CellW(text: (r.codAmount).toString(), width: colAmountNum),
                    CellW(text: r.prepaid.toString(), width: colNum),
                    CellW(
                      text: (r.prepaidAmount).toString(),
                      width: colAmountNum,
                    ),
                    CellW(text: r.pickup.toString(), width: colNum),
                    CellW(
                      text: (r.pickupAmount).toString(),
                      width: colAmountNum,
                    ),
                    CellW(text: r.bfsi.toString(), width: colNum),
                    CellW(text: (r.bfsiAmount).toString(), width: colAmountNum),
                    //CellW(text: r.total.toString(), width: colNum),

                    // TOTAL (read-only)
                    CellW(
                      width: colTotal,
                      text: r.total.toString(),
                      bg: Colors.grey.shade400,
                      bold: true,
                    ),
                    CellW(
                      width: colAmountNum,
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
    int cod = 0, pre = 0, pick = 0, bfsi = 0;
    double codAmount = 0, prepaidAmount = 0, pickupAmount = 0, bfsiAmount = 0;

    for (final r in rows) {
      cod += r.cod;
      pre += r.prepaid;
      pick += r.pickup;
      bfsi += r.bfsi;
      codAmount += r.codAmount;
      prepaidAmount += r.prepaidAmount;
      pickupAmount += r.pickupAmount;
      bfsiAmount += r.bfsiAmount;
    }

    return Row(
      children: [
        CellW(text: "TOTAL", width: colDate + colName, bold: true),
        CellW(
          text: cod.toString(),
          width: colNum,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: codAmount.toString(),
          width: colAmountNum,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: pre.toString(),
          width: colNum,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: prepaidAmount.toString(),
          width: colAmountNum,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: pick.toString(),
          width: colNum,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: pickupAmount.toString(),
          width: colAmountNum,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: bfsi.toString(),
          width: colNum,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: bfsiAmount.toString(),
          width: colAmountNum,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: (cod + pre + pick + bfsi).toString(),
          width: colTotal,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: (codAmount + prepaidAmount + pickupAmount + bfsiAmount)
              .toString(),
          width: colAmountNum,
          bold: true,
          bg: Colors.grey.shade400,
        ),
      ],
    );
  }

  Future<void> _loadPrices() async {
    final data = await PriceDao().getByType("others");

    if (data != null) {
      pickupPrice = data['pickup'];
      prepaidPrice = data['prepaid'];
      codPrice = data['cod'];
      bfsiPrice = data['bfsi'];
    } else {
      pickupPrice = 0;
      codPrice = 0;
      prepaidPrice = 0;
      bfsiPrice = 0;
    }
  }
}
