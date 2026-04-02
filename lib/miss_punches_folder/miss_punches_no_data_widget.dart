
import 'package:flutter/material.dart';

class MissPunchesNoDataWidget extends StatelessWidget {
  const MissPunchesNoDataWidget({super.key});
  @override
  Widget build(BuildContext context) => Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(18)),
            child: const Icon(Icons.inbox_rounded,
                size: 36, color: Color(0xFFCBD5E1)),
          ),
          const SizedBox(height: 16),
          const Text('No Data Found',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF334155))),
          const SizedBox(height: 8),
          const Text('No records found for the selected\ndate range or filter.',
              style: TextStyle(
                  fontSize: 13, color: Color(0xFF94A3B8), height: 1.6),
              textAlign: TextAlign.center),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: const Color(0xFFEEF4FF),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Try a wider date range or select "All"',
                style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFF1A3A6B),
                    fontWeight: FontWeight.w600)),
          ),
        ]),
      );
}
