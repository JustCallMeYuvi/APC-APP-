
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class YoYWidget extends StatelessWidget {
  final String label;
  final double delta;
  const YoYWidget({super.key, required this.label, required this.delta});

  @override
  Widget build(BuildContext ctx) {
    final imp = delta < 0;
    final color = imp ? kCTeal : kCRose;
    return Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
        decoration: BoxDecoration(
            color: kCCard,
            border: Border.all(color: kCBdr),
            borderRadius: BorderRadius.circular(9)),
        child: Row(children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: kC0)),
          const Spacer(),
          Icon(imp ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color, size: 14),
          const SizedBox(width: 4),
          Text('${delta > 0 ? '+' : ''}${delta.toStringAsFixed(2)}pp',
              style: TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        ]));
  }
}

