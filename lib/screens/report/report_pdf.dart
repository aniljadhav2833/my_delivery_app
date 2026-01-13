import 'package:flutter/material.dart';
import 'package:my_delivery/models/report_row.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class ReportTable {
  late DateTimeRange customRange;
  late List<ReportRow> rows;
  late String title;
  late double codRate;
  late double ppRate;
  late double rvpRate;
  late double bfsiRate;

  ReportTable(
    this.customRange,
    this.rows,
    this.title, {
    required this.codRate,
    required this.ppRate,
    required this.rvpRate,
    required this.bfsiRate,
  });

  String _fmt(DateTime d) {
    return "${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}";
  }

  Future<void> shareToWhatsapp() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          final totalCod = rows.fold(0, (s, r) => s + r.cod);
          final totalPre = rows.fold(0, (s, r) => s + r.prepaid);
          final totalPick = rows.fold(0, (s, r) => s + r.pickup);
          final totalBfsi = rows.fold(0, (s, r) => s + r.bfsi);

          return [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            pw.Text(
              "Date Range: ${_fmt(customRange.start)} - ${_fmt(customRange.end)}",
            ),

            pw.SizedBox(height: 15),

            _buildPdfTable(),
            pw.SizedBox(height: 20),

            pw.Text(
              "Calculation Summary",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 8),

            _calculationSummary(totalCod, totalPre, totalPick, totalBfsi),
          ];
        },
      ),
    );

    final bytes = await pdf.save();

    final dir = await getTemporaryDirectory();
    final filePath = "${dir.path}/${title.replaceAll(' ', '_')}.pdf";
    final file = File(filePath);

    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)], text: "My Delivery Report");
  }

  Future<void> generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(20),
        build: (context) {
          final totalCod = rows.fold(0, (s, r) => s + r.cod);
          final totalPre = rows.fold(0, (s, r) => s + r.prepaid);
          final totalPick = rows.fold(0, (s, r) => s + r.pickup);
          final totalBfsi = rows.fold(0, (s, r) => s + r.bfsi);

          return [
            pw.Text(
              title,
              style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),

            pw.Text(
              "Date Range: ${_fmt(customRange.start)} - ${_fmt(customRange.end)}",
            ),

            pw.SizedBox(height: 15),

            _buildPdfTable(),
            pw.SizedBox(height: 20),

            pw.Text(
              "Calculation Summary",
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),

            pw.SizedBox(height: 8),

            _calculationSummary(totalCod, totalPre, totalPick, totalBfsi),
          ];
        },
      ),
    );

    await Printing.sharePdf(bytes: await pdf.save(), filename: "$title.pdf");
  }

  pw.Widget _buildPdfTable() {
    final headers = [
      "Date",
      "Name",
      "COD",
      "COD Amount",
      "Prepaid",
      "Prepaid Amount",
      "Pickup",
      "Pickup Amount",
      "BFSI",
      "BFSI Amount",
      "Total",
      "Total Amount",
    ];

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FixedColumnWidth(60),
        1: const pw.FixedColumnWidth(80),
        2: const pw.FixedColumnWidth(40),
        3: const pw.FixedColumnWidth(60),
        4: const pw.FixedColumnWidth(40),
        5: const pw.FixedColumnWidth(60),
        6: const pw.FixedColumnWidth(40),
        7: const pw.FixedColumnWidth(60),
        8: const pw.FixedColumnWidth(40),
        9: const pw.FixedColumnWidth(60),
        10: const pw.FixedColumnWidth(40),
        11: const pw.FixedColumnWidth(60),
      },
      children: [
        // HEADER
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey300),
          children: headers
              .map(
                (h) => pw.Padding(
                  padding: const pw.EdgeInsets.all(4),
                  child: pw.Text(
                    h,
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
                ),
              )
              .toList(),
        ),

        // ROWS
        ...rows.map((r) {
          return pw.TableRow(
            children: [
              _cell(_fmt(r.date)),
              _cell(r.boyName),
              _cell(r.cod.toString()),
              _cell(r.codAmount.toStringAsFixed(2)),
              _cell(r.prepaid.toString()),
              _cell(r.prepaidAmount.toStringAsFixed(2)),
              _cell(r.pickup.toString()),
              _cell(r.pickupAmount.toStringAsFixed(2)),
              _cell(r.bfsi.toString()),
              _cell(r.bfsiAmount.toStringAsFixed(2)),
              _cell(r.total.toString()),
              _cell(r.totalAmount.toStringAsFixed(2)),
            ],
          );
        }),

        // FOOTER TOTAL
        _pdfFooterRow(),
      ],
    );
  }

  pw.Widget _cell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(4),
      child: pw.Text(text, style: const pw.TextStyle(fontSize: 9)),
    );
  }

  pw.TableRow _pdfFooterRow() {
    int cod = 0, pre = 0, pick = 0, bfsi = 0;
    double codAmt = 0, preAmt = 0, pickAmt = 0, bfsiAmt = 0;

    for (final r in rows) {
      cod += r.cod;
      pre += r.prepaid;
      pick += r.pickup;
      bfsi += r.bfsi;

      codAmt += r.codAmount;
      preAmt += r.prepaidAmount;
      pickAmt += r.pickupAmount;
      bfsiAmt += r.bfsiAmount;
    }

    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        _cell("TOTAL"),
        _cell(""),
        _cell(cod.toString()),
        _cell(codAmt.toStringAsFixed(2)),
        _cell(pre.toString()),
        _cell(preAmt.toStringAsFixed(2)),
        _cell(pick.toString()),
        _cell(pickAmt.toStringAsFixed(2)),
        _cell(bfsi.toString()),
        _cell(bfsiAmt.toStringAsFixed(2)),
        _cell((cod + pre + pick + bfsi).toString()),
        _cell((codAmt + preAmt + pickAmt + bfsiAmt).toStringAsFixed(2)),
      ],
    );
  }

  pw.Widget _calculationSummary(int cod, int pp, int rvp, int bfsi) {
    final double codAmount = cod * codRate;
    final double ppAmount = pp * ppRate;
    final double rvpAmount = rvp * rvpRate;
    final double bfsiAmount = bfsi * bfsiRate;

    final double total = codAmount + ppAmount + rvpAmount + bfsiAmount;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _calcRow("COD", cod, codRate, codAmount),
          _calcRow("PP", pp, ppRate, ppAmount),
          _calcRow("RVP", rvp, rvpRate, rvpAmount),
          _calcRow("BFSI", bfsi, bfsiRate, bfsiAmount),
          pw.Divider(thickness: 2),
          pw.Text(
            "TOTAL : Rs ${total.toStringAsFixed(2)}",
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
          ),
        ],
      ),
    );
  }

  pw.Widget _calcRow(String label, int count, double rate, double amount) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 3),
      child: pw.Text(
        "$label : $count × Rs $rate = Rs ${amount.toStringAsFixed(2)}",
        style: const pw.TextStyle(fontSize: 12),
      ),
    );
  }
}
