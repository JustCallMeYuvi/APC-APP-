// ════════════════════════════════════════════════════════════
//  INSIGHTS TAB
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../constants/turnover_colors.dart';
import '../helpers/turnover_helper.dart';
import '../models/turnover_record.dart';
import '../widgets/common/section_label.dart';
import '../widgets/insights/insight_card.dart';
import '../widgets/insights/yoy_widget.dart';
import '../widgets/states/empty_view.dart';

class InsightsTab extends StatelessWidget {
  final List<TurnoverRecord> data;
  final TurnoverRecord agg;
  final bool isMonth;
  const InsightsTab(
      {super.key,
      required this.data,
      required this.agg,
      required this.isMonth});

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const EmptyWidget();
    final sorted = [...data]..sort((a, b) => a.pct.compareTo(b.pct));
    final best = sorted.first, worst = sorted.last;
    final highestAttrition = data.reduce((a, b) => a.left > b.left ? a : b);
    final avg = data.fold(0.0, (s, r) => s + r.pct) / data.length;
    final trend = data.length > 1 ? data.last.pct - data.first.pct : 0.0;
    final hi = data.where((r) => r.pct >= 20).length;
    final totalLeft = data.fold(0, (s, r) => s + r.left);
    final period = isMonth ? 'Month' : 'Year';

    return ListView(padding: const EdgeInsets.all(14), children: [
      const SecLabelWidget('Key Insights'),
      const SizedBox(height: 10),
      InsCard(
          icon: Icons.emoji_events_rounded,
          color: kCTeal,
          title: 'Best $period: ${best.tableLabel}',
          body:
              // 'Lowest turnover at ${best.pct.toStringAsFixed(2)}% — '
              // '${commas(best.left)} departures from ${fmtK(best.avgHC)} avg staff.'
              'Lowest turnover at ${best.pct.toStringAsFixed(2)}% — '
              '${commas(best.left)} employees left during this period.'),
      const SizedBox(height: 8),
      InsCard(
          icon: Icons.warning_amber_rounded,
          color: kCRose,
          title: 'Highest Turnover: ${worst.tableLabel}',
          body: 'Peak at ${worst.pct.toStringAsFixed(2)}% — '
              '${commas(worst.left)} left. Investigate attrition drivers.'),
      if (isMonth) ...[
        const SizedBox(height: 8),
        InsCard(
          icon: Icons.person_remove_alt_1_rounded,
          color: kCRose,
          title: 'Highest Attrition: ${highestAttrition.tableLabel}',
          body:
              '${commas(highestAttrition.left)} employees left during this month.',
        ),
      ],
      const SizedBox(height: 8),
      InsCard(
          icon: Icons.trending_up_rounded,
          color: kCAmber,
          title:
              'Trend: ${trend >= 0 ? '▲ Rising' : '▼ Declining'} ${trend.abs().toStringAsFixed(2)}pp',
          body: trend >= 0
              ? 'Turnover is worsening. Consider escalating to leadership.'
              : 'Positive trend — retention is improving. Reinforce initiatives.'),
      const SizedBox(height: 8),
      InsCard(
          icon: Icons.bar_chart_rounded,
          color: kCBlue,
          title: 'Period Avg: ${avg.toStringAsFixed(2)}%',
          body:
              '${commas(totalLeft)} total departures over ${data.length} ${isMonth ? 'month(s)' : 'year(s)'}. '
              'Industry benchmark is typically 10–15%.'),
      const SizedBox(height: 8),
      InsCard(
          icon: Icons.gpp_bad_rounded,
          color: kCPurp,
          title: 'High-Risk Periods: $hi of ${data.length}',
          body:
              '${(hi / data.length * 100).toStringAsFixed(0)}% of periods had turnover ≥ 20%. '
              '${hi == 0 ? 'Excellent stability.' : 'Root-cause analysis recommended.'}'),
      const SizedBox(height: 16),
      SecLabelWidget(
          '${isMonth ? 'Month-over-Month' : 'Year-over-Year'} Δ Turnover'),
      const SizedBox(height: 8),
      if (data.length > 1)
        ...List.generate(data.length - 1, (i) {
          final d = data[i + 1].pct - data[i].pct;
          return YoYWidget(label: data[i + 1].tableLabel, delta: d);
        }),
    ]);
  }
}
