import 'package:flutter/material.dart';

class CellW extends StatelessWidget {
  final String text;
  final double width;
  final bool bold;
  final Color bg;

  const CellW({
    super.key,
    required this.text,
    required this.width,
    this.bold = false,
    this.bg = Colors.transparent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 60,
      padding: const EdgeInsets.all(8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        color: bg,
      ),
      child: Text(
        text,
        style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
      ),
    );
  }
}
