import 'package:flutter/material.dart';

class ReportHelper {
  Widget dateRangeSelector({
    required DateTimeRange range,
    required BuildContext context,
    required ValueChanged<DateTimeRange> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.date_range),
        label: Text("${_fmt(range.start)} → ${_fmt(range.end)}"),
        onPressed: () async {
          final picked = await showDateRangePicker(
            context: context,
            firstDate: DateTime(2024),
            lastDate: DateTime(2030),
            initialDateRange: range,
          );

          if (picked != null) {
            onChanged(picked); // ✅ notify screen
          }
        },
      ),
    );
  }

  String _fmt(DateTime d) =>
      "${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}";
}
