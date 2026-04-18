import 'package:flutter/material.dart';
import 'package:my_delivery/models/office_row.dart';
import 'package:my_delivery/models/report_row.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';

class OfficeReportTable {
  late DateTimeRange customRange;
  late List<OfficeRow> rows;
  late String title;
  late double perParcelRate;

  OfficeReportTable(
    this.customRange,
    this.rows,
    this.title, {
    required this.perParcelRate,
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
          final totalParcels = rows.fold(0, (s, r) => s + r.totalParcels);
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

            _calculationSummary(totalParcels),
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
          final totalParcels = rows.fold(0, (s, r) => s + r.totalParcels);
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

            _calculationSummary(totalParcels),
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
      "Total Parcel",
      "Per Parcel Price",
      "Total Amount",
    ];

    return pw.Table(
      border: pw.TableBorder.all(),
      columnWidths: {
        0: const pw.FixedColumnWidth(60),
        1: const pw.FixedColumnWidth(80),
        2: const pw.FixedColumnWidth(80),
        3: const pw.FixedColumnWidth(80),
        4: const pw.FixedColumnWidth(80),
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
              _cell(r.totalParcels.toString()),
              _cell(r.perParcelPrice.toStringAsFixed(2)),
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
    int totalParcel = 0;
    double totalAmount = 0;

    for (final r in rows) {
      totalParcel += r.totalParcels;

      totalAmount += r.totalAmount;
    }

    return pw.TableRow(
      decoration: const pw.BoxDecoration(color: PdfColors.grey200),
      children: [
        _cell("TOTAL"),
        _cell(""),
        _cell(totalParcel.toString()),
        _cell(perParcelRate.toStringAsFixed(2)),
        _cell(totalAmount.toStringAsFixed(2)),
      ],
    );
  }

  pw.Widget _calculationSummary(int totalParcel) {
    final double totalAmount = totalParcel * perParcelRate;

    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(border: pw.Border.all()),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.center,
        children: [
          _calcRow("Total", totalParcel, perParcelRate, totalAmount),
          pw.Divider(thickness: 2),
          pw.Text(
            "Final : Rs ${totalAmount.toStringAsFixed(2)}",
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
