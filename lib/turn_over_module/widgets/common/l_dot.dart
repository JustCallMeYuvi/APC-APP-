
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class LDot extends StatelessWidget {
  final Color color;
  final String label;
  const LDot({required this.color, required this.label});

  @override
  Widget build(BuildContext ctx) =>
      Row(mainAxisSize: MainAxisSize.min, children: [
        Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(fontSize: 11, color: kC2)),
      ]);
}