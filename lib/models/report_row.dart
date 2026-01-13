import 'package:flutter/material.dart';

class ReportRow {
  final int boyId;
  final String boyName;
  final DateTime date; // ✅ NEVER NULL

  int cod;
  int prepaid;
  int pickup;
  int bfsi;
  double codPrice;
  double prepaidPrice;
  double pickupPrice;
  double bfsiPrice;

  ReportRow({
    required this.boyId,
    required this.boyName,
    required this.date,
    int cod = 0,
    int prepaid = 0,
    int pickup = 0,
    int bfsi = 0,
    double codPrice = 0,
    double prepaidPrice = 0,
    double pickupPrice = 0,
    double bfsiPrice = 0,
  }) : cod = cod,
       prepaid = prepaid,
       pickup = pickup,
       bfsi = bfsi,
       codPrice = codPrice,
       pickupPrice = pickupPrice,
       prepaidPrice = prepaidPrice,
       bfsiPrice = bfsiPrice;

  int get total => cod + prepaid + pickup + bfsi;
  double get codAmount => cod * codPrice;
  double get prepaidAmount => prepaid * prepaidPrice;
  double get pickupAmount => pickup * pickupPrice;
  double get bfsiAmount => bfsi * bfsiPrice;

  double get totalAmount =>
      codAmount + prepaidAmount + pickupAmount + bfsiAmount;
}
