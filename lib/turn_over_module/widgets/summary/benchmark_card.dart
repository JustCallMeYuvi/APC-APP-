
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class Bench extends StatelessWidget {
  final String range, label;
  final Color color;
  const Bench({super.key, required this.range, required this.label, required this.color});

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
          color: kCCard,
          border: Border.all(color: kCBdr),
          borderRadius: BorderRadius.circular(10)),
      child: Row(children: [
        Container(
            width: 5,
            height: 28,
            decoration: BoxDecoration(
                color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 12),
        Text(range,
            style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(width: 10),
        Expanded(
            child:
                Text(label, style: const TextStyle(fontSize: 12, color: kC2))),
      ]));
}