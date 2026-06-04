
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class TableCellWidget extends StatelessWidget {
  final String text;
  final bool left, bold;
  final Color? color;
  const TableCellWidget(this.text,
      {super.key, this.left = false, this.bold = false, this.color});

  @override
  Widget build(BuildContext ctx) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 9),
      child: Text(text,
          textAlign: left ? TextAlign.left : TextAlign.right,
          style: TextStyle(
              fontSize: 10.5,
              color: color ?? kC0,
              fontWeight:
                  bold ? FontWeight.w700 : FontWeight.w400)));
}
