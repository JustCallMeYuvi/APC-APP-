import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class LiveBadgeWidget extends StatelessWidget {
  final bool dark;
  const LiveBadgeWidget({super.key, this.dark = false});

  @override
  Widget build(BuildContext ctx) => Container(
      margin: EdgeInsets.only(right: dark ? 0 : 10),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
          color:
              dark ? Colors.white.withOpacity(0.08) : kCBlue.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.circle, color: kCTeal, size: 7),
        const SizedBox(width: 5),
        Text('Live',
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: dark ? kC3 : kCBlue)),
      ]));
}

