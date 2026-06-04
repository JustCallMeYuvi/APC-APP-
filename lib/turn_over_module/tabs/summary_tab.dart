
// ════════════════════════════════════════════════════════════
//  SUMMARY TAB
// ════════════════════════════════════════════════════════════

import 'package:flutter/widgets.dart';

import '../constants/turnover_colors.dart';
import '../helpers/turnover_helper.dart';
import '../models/turnover_record.dart';
import '../widgets/common/section_label.dart';
import '../widgets/states/empty_view.dart';
import '../widgets/summary/benchmark_card.dart';
import '../widgets/summary/mini_donut.dart';
import '../widgets/summary/rank_row.dart';
import '../widgets/summary/score_stat.dart';

class SummaryTab extends StatelessWidget {
  final List<TurnoverRecord> data;
  final TurnoverRecord agg;
  final bool isMonth;
  const SummaryTab(
      {super.key, required this.data, required this.agg, required this.isMonth});

  @override
  Widget build(BuildContext ctx) {
    if (data.isEmpty) return const EmptyWidget();
    final avg = data.fold(0.0, (s, r) => s + r.pct) / data.length;
    final best = data.reduce((a, b) => a.pct < b.pct ? a : b);
    final totalLeft = data.fold(0, (s, r) => s + r.left);
    final grade = avg < 10
        ? 'A'
        : avg < 15
            ? 'B'
            : avg < 20
                ? 'C'
                : avg < 25
                    ? 'D'
                    : 'F';
    final gradeC = avg < 15 ? kCTeal : avg < 20 ? kCAmber : kCRose;

    return ListView(padding: const EdgeInsets.all(16), children: [
      const SecLabelWidget('Executive Scorecard'),
      const SizedBox(height: 12),
      Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: kCCard, borderRadius: BorderRadius.circular(16)),
        child: Column(children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Health Grade',
                  style: TextStyle(fontSize: 12, color: kC3)),
              const SizedBox(height: 4),
              Text(grade,
                  style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.w900,
                      color: gradeC,
                      height: 1)),
              const SizedBox(height: 4),
              Text(avg < 15 ? 'Within target' : 'Needs attention',
                  style: TextStyle(
                      fontSize: 11,
                      color: avg < 15 ? kCTeal : kCRose)),
            ]),
            MiniDonutWidget(pct: 100 - avg),
          ]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(
                child: ScoreStat(
                    'Avg Turnover', '${avg.toStringAsFixed(1)}%', kCAmber)),
            const SizedBox(width: 8),
            Expanded(
                child: ScoreStat(
                    'Total Left', fmtK(totalLeft.toDouble()), kCRose)),
            const SizedBox(width: 8),
            Expanded(
                child: ScoreStat(
                    isMonth ? 'Best Month' : 'Best Year',
                    best.tableLabel,
                    kCTeal)),
          ]),
        ]),
      ),
      const SizedBox(height: 16),
      const SecLabelWidget('Benchmarks'),
      const SizedBox(height: 10),
      ...[
        ('< 10%', 'Low turnover — excellent retention', kCTeal),
        ('10–15%', 'Industry average — acceptable', kCAmber),
        ('15–20%', 'Moderate concern — review policies',
            const Color(0xFFEA580C)),
        ('> 20%', 'High turnover — urgent action required', kCRose),
      ].map((b) => Padding(
          padding: const EdgeInsets.only(bottom: 7),
          child: Bench(range: b.$1, label: b.$2, color: b.$3))),
      const SizedBox(height: 16),
      SecLabelWidget('Top 5 Worst ${isMonth ? 'Months' : 'Years'}'),
      const SizedBox(height: 8),
      ...([...data]..sort((a, b) => b.pct.compareTo(a.pct)))
          .take(5)
          .toList()
          .asMap()
          .entries
          .map((e) => RankRowWidget(rank: e.key + 1, rec: e.value)),
    ]);
  }
}
