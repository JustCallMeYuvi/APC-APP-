
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class CCardWidget extends StatelessWidget {
  final String title;
  final Widget child;
  final Widget? legend;
  const CCardWidget({super.key, required this.title, required this.child, this.legend});

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: kCCard,
          border: Border.all(color: kCBdr),
          borderRadius: BorderRadius.circular(14)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title,
            style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: kC0)),
        if (legend != null) ...[const SizedBox(height: 6), legend!],
        const SizedBox(height: 12),
        child,
      ]));
}
