// ════════════════════════════════════════════════════════════
//  TABLE TAB
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../constants/turnover_colors.dart';
import '../models/turnover_record.dart';
import '../widgets/table/table_header.dart';
import '../widgets/table/table_row.dart';

class TableTab extends StatefulWidget {
  final List<TurnoverRecord> data;
  final bool isMonth;
  const TableTab({super.key, required this.data, required this.isMonth});

  @override
  State<TableTab> createState() => _TableTabState();
}

class _TableTabState extends State<TableTab> {
  int _col = 0;
  bool _asc = true;
  String _q = '';

  List<TurnoverRecord> get _rows {
    var list = widget.data.where((r) {
      if (_q.isEmpty) return true;
      return r.tableLabel.toLowerCase().contains(_q.toLowerCase()) ||
          r.year.toString().contains(_q);
    }).toList();

    list.sort((a, b) {
      // int c = switch (_col) {
      //   // 0 => a.tableLabel.compareTo(b.tableLabel),
      //   0 => widget.isMonth
      //       ? a.monthYear.compareTo(b.monthYear)
      //       : a.year.compareTo(b.year),
      //   1 => a.beginHC.compareTo(b.beginHC),
      //   2 => a.endHC.compareTo(b.endHC),
      //   3 => a.left.compareTo(b.left),
      //   4 => a.pct.compareTo(b.pct),
      //   5 => a.retentionPct.compareTo(b.retentionPct),
      //   6 => a.netChange.compareTo(b.netChange),
      //   _ => 0,
      // };


int c;

if (widget.isMonth) {
  c = switch (_col) {
    0 => a.monthYear.compareTo(b.monthYear),
    1 => a.beginHC.compareTo(b.beginHC),
    2 => a.left.compareTo(b.left),
    3 => a.pct.compareTo(b.pct),
    _ => 0,
  };
} else {
  c = switch (_col) {
    0 => a.year.compareTo(b.year),
    1 => a.beginHC.compareTo(b.beginHC),
    2 => a.endHC.compareTo(b.endHC),
    3 => a.left.compareTo(b.left),
    4 => a.pct.compareTo(b.pct),
    5 => a.retentionPct.compareTo(b.retentionPct),
    6 => a.netChange.compareTo(b.netChange),
    _ => 0,
  };
}      return _asc ? c : -c;
    });
    return list;
  }

  @override
  Widget build(BuildContext ctx) {
    final rows = _rows;
    return Column(children: [
      Container(
          color: kCCard,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
          child: Row(children: [
            Expanded(
                child: TextField(
              decoration: InputDecoration(
                  hintText:
                      widget.isMonth ? 'Filter by month…' : 'Filter by year…',
                  prefixIcon: const Icon(Icons.search_rounded, size: 16),
                  hintStyle: const TextStyle(fontSize: 12, color: kC3)),
              style: const TextStyle(fontSize: 13),
              onChanged: (v) => setState(() => _q = v),
            )),
            const SizedBox(width: 10),
            Text('${rows.length} rows',
                style: const TextStyle(fontSize: 11, color: kC3)),
          ])),
      Expanded(
          child: SingleChildScrollView(
              padding: const EdgeInsets.all(14),
              child: Column(children: [
                TableHeaderWidget(
                    col: _col,
                    asc: _asc,
                    isMonth: widget.isMonth,
                    onSort: (c) => setState(() {
                          _col == c ? _asc = !_asc : _asc = true;
                          _col = c;
                        })),
                ...rows.asMap().entries.map(
                    (e) => TablerowWidget(rec: e.value, even: e.key.isEven)),
                const SizedBox(height: 20),
              ]))),
    ]);
  }
}
