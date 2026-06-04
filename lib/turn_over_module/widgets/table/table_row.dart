
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../../helpers/turnover_helper.dart';
import '../../models/turnover_record.dart';
import 'table_cell.dart';

class TablerowWidget extends StatelessWidget {
  final TurnoverRecord rec;
  final bool even;
  const TablerowWidget({super.key, required this.rec, required this.even});

  @override
  Widget build(BuildContext ctx) {
    final rc = riskColor(rec.pct);
    return Container(
        color: even ? kCBg : kCCard,
        child: Row(children: [
          Expanded(
              child: TableCellWidget(rec.tableLabel, left: true, bold: true)),
          Expanded(child: TableCellWidget(fmtK(rec.beginHC.toDouble()))),
          Expanded(child: TableCellWidget(fmtK(rec.endHC.toDouble()))),
          Expanded(child: TableCellWidget(fmtK(rec.left.toDouble()))),
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 3, vertical: 8),
                  child: Align(
                      alignment: Alignment.centerRight,
                      child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 2),
                          decoration: BoxDecoration(
                              color: rc.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(4)),
                          child: Text('${rec.pct.toStringAsFixed(1)}%',
                              style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  color: rc)))))),
          Expanded(
              child: TableCellWidget(
                  '${rec.retentionPct.toStringAsFixed(1)}%',
                  color: kCTeal)),
          Expanded(
              child: TableCellWidget(
                  '${rec.netChange >= 0 ? '+' : ''}${rec.netChange}',
                  color: rec.netChange >= 0 ? kCTeal : kCRose)),
        ]));
  }
}