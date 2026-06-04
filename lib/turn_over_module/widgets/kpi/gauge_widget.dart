
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../../helpers/turnover_helper.dart';
import '../common/badge_widget.dart';


class Gauge extends StatelessWidget {
  final double pct;
  const Gauge({super.key, required this.pct});

  @override
  Widget build(BuildContext ctx) {
    final color = riskColor(pct);
    final frac = (pct / 50).clamp(0.0, 1.0);
    return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: kCCard,
            border: Border.all(color: kCBdr),
            borderRadius: BorderRadius.circular(14)),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Text('Turnover Rate',
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: kC0)),
                const Spacer(),
                BadgeWidget(label: riskLabel(pct), color: color),
              ]),
              const SizedBox(height: 12),
              Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('${pct.toStringAsFixed(2)}%',
                        style: TextStyle(
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                            color: color)),
                    const SizedBox(width: 8),
                    const Text('avg',
                        style: TextStyle(fontSize: 13, color: kC3)),
                  ]),
              const SizedBox(height: 14),
              Stack(children: [
                Container(
                    height: 10,
                    decoration: BoxDecoration(
                        color: kCBg,
                        borderRadius: BorderRadius.circular(8))),
                FractionallySizedBox(
                    widthFactor: frac,
                    child: Container(
                        height: 10,
                        decoration: BoxDecoration(
                            color: color,
                            borderRadius: BorderRadius.circular(8)))),
              ]),
              const SizedBox(height: 6),
              const Row(children: [
                Text('0%',
                    style: TextStyle(fontSize: 9, color: kC3)),
                Spacer(),
                Text('Target < 10%',
                    style: TextStyle(
                        fontSize: 9,
                        color: kCTeal,
                        fontWeight: FontWeight.w600)),
                Spacer(),
                Text('50%+',
                    style: TextStyle(fontSize: 9, color: kC3)),
              ]),
            ]));
  }
}