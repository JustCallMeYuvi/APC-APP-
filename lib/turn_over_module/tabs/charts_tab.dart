// ════════════════════════════════════════════════════════════
//  CHARTS TAB
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../models/turnover_record.dart';
import '../widgets/charts/bar_chart.dart';
import '../widgets/charts/dual_line_chart.dart';
import '../widgets/charts/turnover_area_chart.dart';
import '../widgets/common/chip_widget.dart';
import '../widgets/common/section_label.dart';
import '../widgets/states/empty_view.dart';

class ChartsTab extends StatefulWidget {
  final List<TurnoverRecord> data;
  final bool isMonth;
  const ChartsTab({super.key, required this.data, required this.isMonth});

  @override
  State<ChartsTab> createState() => _ChartsTabState();
}

class _ChartsTabState extends State<ChartsTab> {
  String _m = 'Turnover %';
  // static const _opts = [
  //   'Turnover %',
  //   'Headcount',
  //   'Attrition',
  //   'Net Change',
  //   'Retention %',
  // ];

  List<String> get _opts => widget.isMonth
      ? [
          'Active Employees',
          'Employees Left',
          'Turnover %',
        ]
      : [
          'Turnover %',
          'Headcount',
          'Attrition',
          'Net Change',
          'Retention %',
        ];
  // List<double> _vals() => switch (_m) {
  //       'Turnover %' => widget.data.map((r) => r.pct).toList(),
  //       'Headcount' => widget.data.map((r) => r.endHC.toDouble()).toList(),
  //       'Attrition' => widget.data.map((r) => r.left.toDouble()).toList(),
  //       'Net Change' => widget.data.map((r) => r.netChange.toDouble()).toList(),
  //       'Retention %' => widget.data.map((r) => r.retentionPct).toList(),
  //       _ => [],
  //     };

  List<double> _vals() {
    if (widget.isMonth) {
      switch (_m) {
        case 'Active Employees':
          return widget.data.map((r) => r.beginHC.toDouble()).toList();

        case 'Employees Left':
          return widget.data.map((r) => r.left.toDouble()).toList();

        case 'Turnover %':
          return widget.data.map((r) => r.pct).toList();

        default:
          return [];
      }
    }

    switch (_m) {
      case 'Turnover %':
        return widget.data.map((r) => r.pct).toList();

      case 'Headcount':
        return widget.data.map((r) => r.endHC.toDouble()).toList();

      case 'Attrition':
        return widget.data.map((r) => r.left.toDouble()).toList();

      case 'Net Change':
        return widget.data.map((r) => r.netChange.toDouble()).toList();

      case 'Retention %':
        return widget.data.map((r) => r.retentionPct).toList();

      default:
        return [];
    }
  }

  @override
  Widget build(BuildContext ctx) {
    if (widget.data.isEmpty) return const EmptyWidget();
    return ListView(padding: const EdgeInsets.all(16), children: [
      SecLabelWidget(
          'Chart Explorer  •  ${widget.isMonth ? 'Monthly' : 'Yearly'} View'),
      const SizedBox(height: 8),
      SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              children: _opts
                  .map((o) => Padding(
                        padding: const EdgeInsets.only(right: 7),
                        child: ChipWidget(
                            label: o,
                            sel: _m == o,
                            onTap: () => setState(() => _m = o)),
                      ))
                  .toList())),
      const SizedBox(height: 16),
      BarChartWidget(data: widget.data, vals: _vals(), metric: _m),

      // const SizedBox(height: 14),
      // DualLine(data: widget.data),
      // const SizedBox(height: 14),
      // TurnoverArea(data: widget.data),
      if (!widget.isMonth) ...[
        const SizedBox(height: 14),
        DualLine(data: widget.data),
        const SizedBox(height: 14),
        TurnoverArea(data: widget.data),
      ]
    ]);
  }
}
