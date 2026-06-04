
// ════════════════════════════════════════════════════════════
//  KPI + VISUAL COMPONENTS
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../../helpers/turnover_helper.dart';

class Kpi extends StatelessWidget {
  final String label, value, sub;
  final IconData icon;
  final Color color;
  const Kpi(this.label, this.value, this.sub, this.icon, this.color);

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
          color: kCCard,
          border: Border.all(color: kCBdr),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: tint(color),
                      borderRadius: BorderRadius.circular(9)),
                  child: Icon(icon, color: color, size: 16)),
              const Spacer(),
              Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                      color: color, shape: BoxShape.circle)),
            ]),
            const SizedBox(height: 10),
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: kC0)),
            const SizedBox(height: 1),
            Text(label,
                style: const TextStyle(
                    fontSize: 10.5,
                    color: kC1,
                    fontWeight: FontWeight.w600)),
            Text(sub,
                style: const TextStyle(fontSize: 9.5, color: kC3)),
          ]));
}
