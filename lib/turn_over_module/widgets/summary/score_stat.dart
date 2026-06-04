
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class ScoreStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const ScoreStat(this.label, this.value, this.color, {super.key});

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.07),
          borderRadius: BorderRadius.circular(10)),
      child: Column(children: [
        Text(value,
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.w800, color: color),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(fontSize: 9, color: kC3),
            textAlign: TextAlign.center),
      ]));
}


