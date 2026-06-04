
import 'dart:math';

import 'package:flutter/material.dart';

class GridWidget extends StatelessWidget {
  final int cols;
  final double gap;
  final List<Widget> children;
  const GridWidget({super.key, required this.cols, required this.gap, required this.children});

  @override
  Widget build(BuildContext ctx) {
    final rows = <Widget>[];
    for (int i = 0; i < children.length; i += cols) {
      final rc = children.sublist(i, min(i + cols, children.length)).toList();
      while (rc.length < cols) rc.add(const SizedBox());
      rows.add(Row(
          children: rc
              .asMap()
              .entries
              .map((e) => Expanded(
                  child: Padding(
                      padding: EdgeInsets.only(
                          right: e.key < rc.length - 1 ? gap : 0),
                      child: e.value)))
              .toList()));
      if (i + cols < children.length) rows.add(SizedBox(height: gap));
    }
    return Column(children: rows);
  }
}