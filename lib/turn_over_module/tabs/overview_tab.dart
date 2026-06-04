
// ════════════════════════════════════════════════════════════
//  OVERVIEW TAB
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../constants/turnover_colors.dart';
import '../helpers/turnover_helper.dart';
import '../models/filter_state.dart';
import '../models/turnover_record.dart';
import '../widgets/common/grid_widget.dart';
import '../widgets/common/section_label.dart';
import '../widgets/kpi/donut_chart.dart';
import '../widgets/kpi/gauge_widget.dart';
import '../widgets/kpi/kpi_card.dart';
import '../widgets/kpi/spark_line.dart';

class OverviewTab extends StatelessWidget {
  final List<TurnoverRecord> data;
  final FilterState filter;
  final TurnoverRecord agg;

  const OverviewTab(
      {super.key, required this.data, required this.filter, required this.agg});

  bool get _isMonth => filter.subView == SubView.monthwise;

  String get _rangeLabel => _isMonth
      ? '${filter.monthYear}  •  ${monthName(filter.fromMonth)} – ${monthName(filter.toMonth)}  •  ${data.length} months'
      : 'Year-by-Year  •  ${filter.fromYear} – ${filter.toYear}  •  ${data.length} records';

  @override
  Widget build(BuildContext ctx) {
    final d = agg;
    final w = MediaQuery.of(ctx).size.width;
    final cols = w >= 900 ? 4 : w >= 600 ? 3 : 2;
    final pad = w >= 600 ? 20.0 : 14.0;

    // totals across all records for overview when monthwise
    final totalLeft = data.fold(0, (s, r) => s + r.left);
    final avgPct = data.fold(0.0, (s, r) => s + r.pct) / data.length;

    return ListView(padding: EdgeInsets.all(pad), children: [
      SecLabelWidget(_rangeLabel),
      const SizedBox(height: 12),
      GridWidget(cols: cols, gap: 10, children: [
        Kpi('Begin HC', commas(d.beginHC), 'Start of period',
            Icons.groups_rounded, kCBlue),
        Kpi('End HC', commas(d.endHC), 'End of period',
            Icons.group_rounded, kCTeal),
        Kpi('Avg HC', fmtK(d.avgHC), 'Workforce avg',
            Icons.people_outline_rounded, kCIndi),
        Kpi('Total Left',
            _isMonth ? commas(totalLeft) : commas(d.left),
            'Departures', Icons.exit_to_app_rounded, kCRose),
        Kpi('Retention',
            '${d.retentionPct.toStringAsFixed(1)}%', 'Stayed',
            Icons.favorite_rounded, kCTeal),
        Kpi('Turnover',
            '${(_isMonth ? avgPct : d.pct).toStringAsFixed(2)}%',
            riskLabel(_isMonth ? avgPct : d.pct),
            Icons.trending_down_rounded,
            riskColor(_isMonth ? avgPct : d.pct)),
        Kpi(
            'Net Change',
            '${d.netChange >= 0 ? '+' : ''}${d.netChange}',
            d.netChange >= 0 ? 'Grew' : 'Shrank',
            d.netChange >= 0
                ? Icons.arrow_upward_rounded
                : Icons.arrow_downward_rounded,
            d.netChange >= 0 ? kCTeal : kCRose),
        Kpi(
            _isMonth ? 'Months' : 'Years',
            '${data.length}',
            _isMonth
                ? '${monthName(filter.fromMonth)} – ${monthName(filter.toMonth)}'
                : '${filter.fromYear} – ${filter.toYear}',
            Icons.calendar_month_rounded,
            kCPurp),
      ]),
      const SizedBox(height: 16),
      Gauge(pct: _isMonth ? avgPct : d.pct),
      const SizedBox(height: 12),
      Donut(retPct: d.retentionPct),
      const SizedBox(height: 12),
      if (data.length > 1) Spark(data: data),
    ]);
  }
}
