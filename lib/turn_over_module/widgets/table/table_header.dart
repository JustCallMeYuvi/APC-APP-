
// ════════════════════════════════════════════════════════════
//  TABLE WIDGETS
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class TableHeaderWidget extends StatelessWidget {
  final int col;
  final bool asc, isMonth;
  final void Function(int) onSort;
  const TableHeaderWidget(
      {super.key, required this.col,
      required this.asc,
      required this.isMonth,
      required this.onSort});

  @override
  Widget build(BuildContext ctx) {
    final cols = [
      isMonth ? 'Month' : 'Year',
      'Begin',
      'End',
      'Left',
      'Rate',
      'Retain',
      'Net Δ'
    ];
    return Container(
        decoration: const BoxDecoration(
            color: kC0,
            borderRadius:
                BorderRadius.vertical(top: Radius.circular(10))),
        child: Row(
            children: List.generate(cols.length, (i) {
          final sel = col == i;
          return Expanded(
              child: GestureDetector(
                  onTap: () => onSort(i),
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 10),
                      child: Row(
                          mainAxisAlignment: i == 0
                              ? MainAxisAlignment.start
                              : MainAxisAlignment.end,
                          children: [
                            Text(cols[i],
                                style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w700,
                                    color: sel ? Colors.white : kC3)),
                            if (sel)
                              Icon(
                                  asc
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: 9,
                                  color: Colors.white),
                          ]))));
        })));
  }
}
