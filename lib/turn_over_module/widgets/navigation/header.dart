
// ════════════════════════════════════════════════════════════
//  HEADER (narrow only)
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../common/app_icon.dart';
import '../common/live_badge.dart';

class TurnOutHeaderWidget extends StatelessWidget {
  const TurnOutHeaderWidget({super.key});

  @override
  Widget build(BuildContext ctx) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(bottom: BorderSide(color: kCBdr))),
        child: const Row(children: [
          AppIcon(),
          SizedBox(width: 10),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                Text('HR Analytics',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: kC0)),
                Text('Turnover Dashboard',
                    style: TextStyle(fontSize: 11, color: kC2)),
              ])),
          LiveBadgeWidget(),
        ]),
      );
}
