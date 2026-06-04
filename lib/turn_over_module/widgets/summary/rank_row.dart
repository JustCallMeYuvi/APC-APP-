
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../../helpers/turnover_helper.dart';
import '../../models/turnover_record.dart';
import '../common/badge_widget.dart';

class RankRowWidget extends StatelessWidget {
  final int rank;
  final TurnoverRecord rec;
  const RankRowWidget({super.key, required this.rank, required this.rec});

  @override
  Widget build(BuildContext ctx) {
    final color = riskColor(rec.pct);
    return Container(
        margin: const EdgeInsets.only(bottom: 7),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
            color: kCCard,
            border: Border.all(color: kCBdr),
            borderRadius: BorderRadius.circular(10)),
        child: Row(children: [
          Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                  color: tint(color), borderRadius: BorderRadius.circular(8)),
              child: Center(
                  child: Text('#$rank',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color)))),
          const SizedBox(width: 10),
          Text(rec.tableLabel,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w700, color: kC0)),
          const SizedBox(width: 8),
          Text('${commas(rec.left)} left',
              style: const TextStyle(fontSize: 12, color: kC2)),
          const Spacer(),
          BadgeWidget(label: '${rec.pct.toStringAsFixed(1)}%', color: color),
        ]));
  }
}