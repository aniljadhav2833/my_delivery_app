import 'package:flutter/material.dart';

class AssignmentRow {
  final int boyId;
  final String boyName;
  final DateTime date; // ✅ NEVER NULL

  int office;
  int cod;
  int prepaid;
  int pickup;
  int bfsi;

  final TextEditingController officeCtrl;
  final TextEditingController codCtrl;
  final TextEditingController prepaidCtrl;
  final TextEditingController pickupCtrl;
  final TextEditingController bfsiCtrl;

  AssignmentRow({
    required this.boyId,
    required this.boyName,
    required this.date,
    int office = 0,
    int cod = 0,
    int prepaid = 0,
    int pickup = 0,
    int bfsi = 0,
  }) : office = office,
       cod = cod,
       prepaid = prepaid,
       pickup = pickup,
       bfsi = bfsi,
       officeCtrl = TextEditingController(text: office.toString()),
       codCtrl = TextEditingController(text: cod.toString()),
       prepaidCtrl = TextEditingController(text: prepaid.toString()),
       pickupCtrl = TextEditingController(text: pickup.toString()),
       bfsiCtrl = TextEditingController(text: bfsi.toString());

  void syncFromControllers() {
    office = int.tryParse(officeCtrl.text) ?? 0;
    cod = int.tryParse(codCtrl.text) ?? 0;
    prepaid = int.tryParse(prepaidCtrl.text) ?? 0;
    pickup = int.tryParse(pickupCtrl.text) ?? 0;
    bfsi = int.tryParse(bfsiCtrl.text) ?? 0;
  }

  int get total => cod + prepaid + pickup + bfsi;

  bool get hasMismatch => office != total;
}
