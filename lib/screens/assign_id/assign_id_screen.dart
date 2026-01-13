import 'dart:async';

import 'package:flutter/material.dart';
import 'package:my_delivery/db/assignment_dao.dart';
import 'package:my_delivery/db/delivery_boy_dao.dart';
import 'package:my_delivery/models/assignment_row.dart';
import 'package:my_delivery/screens/widgets/cellw.dart';
import 'package:my_delivery/screens/widgets/hcell.dart';
import 'package:my_delivery/util/report_helper.dart';

class AssignIdScreen extends StatefulWidget {
  const AssignIdScreen({super.key});

  @override
  State<AssignIdScreen> createState() => _AssignIdScreenState();
}

class _AssignIdScreenState extends State<AssignIdScreen> {
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

  String? selectedDeliveryBoy;

  List<AssignmentRow> rows = [];
  List<Map<String, dynamic>> deliveryBoys = [];
  bool loading = true;

  final Map<String, Timer> _debounce = {};
  bool editOffice = false;
  bool editOthers = false;
  bool filterOption = false;

  final ScrollController _verticalController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTable();
    _loadDeliveryBoys();
  }

  @override
  void dispose() {
    _verticalController.dispose();
    super.dispose();
  }

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
          AssignmentRow(
            boyId: b['id'],
            boyName: b['name'],
            date: current, // ✅ valid now
            office: a?['office'] ?? 0,
            cod: a?['cod'] ?? 0,
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

  void _debouncedSave(AssignmentRow r) {
    final key = "${r.boyId}_${_dateKey(r.date)}";

    _debounce[key]?.cancel();

    _debounce[key] = Timer(const Duration(milliseconds: 600), () async {
      r.syncFromControllers();

      setState(() {}); // mismatch refresh

      await AssignmentDao().upsert({
        'date': _dateKey(r.date),
        'delivery_boy_id': r.boyId,
        'office': r.office,
        'cod': r.cod,
        'prepaid': r.prepaid,
        'pickup': r.pickup,
        'bfsi': r.bfsi,
        'mismatch': r.hasMismatch ? 1 : 0,
      });
    });
  }

  String _dateKey(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assign Delivery ID"),
        actions: [
          IconButton(
            onPressed: () {
              _loadDeliveryBoys();
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
          Row(
            children: [
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: Text(editOffice ? "Lock Office" : "Edit Office"),
                onPressed: () {
                  setState(() => editOffice = !editOffice);
                },
              ),
              const SizedBox(width: 1),
              ElevatedButton.icon(
                icon: const Icon(Icons.edit_calendar),
                label: Text(editOthers ? "Lock Others" : "Edit Weekly"),
                onPressed: () {
                  setState(() => editOthers = !editOthers);
                },
              ),
              const SizedBox(width: 1),
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
                  width: colDate + colName + colNum * 5 + colTotal,
                  child: Row(children: [_table()]),
                ),
              ),
            ),
          ),
          SizedBox(height: 15),
        ],
      ),
    );
  }

  Widget _table() {
    return SizedBox(
      width: colDate + colName + colNum * 5 + colTotal,
      child: Column(
        children: [
          Row(
            children: const [
              HCell("Date", width: colDate),
              HCell("Name", width: colName),
              HCell("Office", width: colNum),
              HCell("COD", width: colNum),
              HCell("Prepaid", width: colNum),
              HCell("Pickup", width: colNum),
              HCell("BFSI", width: colNum),
              HCell("Total", width: colTotal),
            ],
          ),
          Expanded(
            child: ListView.builder(
              controller: _verticalController,
              itemCount: rows.length,
              itemBuilder: (_, i) {
                final r = rows[i];
                return Row(
                  children: [
                    CellW(text: _fmt(r.date), width: colDate),
                    CellW(text: r.boyName, width: colName),
                    _num(
                      r.officeCtrl,
                      r,
                      'office',
                      editOffice,
                      totalMismatch: r.hasMismatch,
                    ),
                    _num(r.codCtrl, r, 'cod', editOthers),
                    _num(r.prepaidCtrl, r, 'prepaid', editOthers),
                    _num(r.pickupCtrl, r, 'pickup', editOthers),
                    _num(r.bfsiCtrl, r, 'bfsi', editOthers),

                    // TOTAL (read-only)
                    CellW(
                      width: colTotal,
                      text: r.total.toString(),
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
        ],
      ),
    );
  }

  String _fmt(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
    //return "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
  }

  Widget _num(
    TextEditingController ctrl,
    AssignmentRow r,
    String field,
    bool enabled, {
    bool totalMismatch = false,
  }) {
    return SizedBox(
      width: colNum,
      child: TextField(
        controller: ctrl,
        enabled: enabled,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          filled: !enabled,
          fillColor: !totalMismatch
              ? enabled
                    ? null
                    : Colors.grey.shade200
              : Colors.red,
          border: const OutlineInputBorder(),
        ),
        onChanged: enabled ? (_) => _debouncedSave(r) : null,
      ),
    );
  }

  Widget _footerTotals() {
    int office = 0, cod = 0, pre = 0, pick = 0, bfsi = 0;

    for (final r in rows) {
      office += r.office;
      cod += r.cod;
      pre += r.prepaid;
      pick += r.pickup;
      bfsi += r.bfsi;
    }

    return Row(
      children: [
        CellW(text: "TOTAL", width: colDate + colName, bold: true),
        CellW(
          text: office.toString(),
          width: colNum,
          bold: true,
          bg: Colors.grey.shade400,
        ),
        CellW(
          text: cod.toString(),
          width: colNum,
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
          text: pick.toString(),
          width: colNum,
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
          text: (cod + pre + pick + bfsi).toString(),
          width: colTotal,
          bold: true,
          bg: Colors.grey.shade400,
        ),
      ],
    );
  }
}
