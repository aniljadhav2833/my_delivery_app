import 'package:flutter/material.dart';

class OfficeRow {
  final int boyId;
  final String boyName;
  final DateTime date; // ✅ NEVER NULL

  int totalParcels;
  double perParcelPrice;

  OfficeRow({
    required this.boyId,
    required this.boyName,
    required this.date,
    int totalParcels = 0,
    double perParcelPrice = 0,
  }) : totalParcels = totalParcels,
       perParcelPrice = perParcelPrice;

  double get totalAmount => totalParcels * perParcelPrice;
}
