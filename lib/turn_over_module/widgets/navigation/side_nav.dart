
// ════════════════════════════════════════════════════════════
//  SIDE NAV
// ════════════════════════════════════════════════════════════

import 'package:animated_movies_app/turn_over_module/widgets/common/app_icon.dart';
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../common/live_badge.dart';

class SideNavWidget extends StatelessWidget {
  final int tab;
  final void Function(int) onTab;
  const SideNavWidget({super.key, required this.tab, required this.onTab});

  static const _items = [
    (Icons.dashboard_rounded, 'Overview'),
    (Icons.bar_chart_rounded, 'Charts'),
    (Icons.table_chart_rounded, 'Table'),
    (Icons.lightbulb_rounded, 'Insights'),
    (Icons.summarize_rounded, 'Summary'),
  ];

  @override
  Widget build(BuildContext ctx) => Container(
        width: 200,
        color: kC0,
        child: Column(children: [
          const SizedBox(height: 24),
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Row(children: [
                AppIcon(),
                SizedBox(width: 10),
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('HR Analytics',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Colors.white)),
                      Text('Turnover',
                          style: TextStyle(fontSize: 10, color: kC3)),
                    ]),
              ])),
          const SizedBox(height: 24),
          ..._items.asMap().entries.map((e) {
            final sel = tab == e.key;
            return GestureDetector(
                onTap: () => onTab(e.key),
                child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                        color: sel ? kCBlue : Colors.transparent,
                        borderRadius: BorderRadius.circular(10)),
                    child: Row(children: [
                      Icon(e.value.$1,
                          size: 18, color: sel ? Colors.white : kC3),
                      const SizedBox(width: 10),
                      Text(e.value.$2,
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              color: sel ? Colors.white : kC3)),
                    ])));
          }),
          const Spacer(),
          const LiveBadgeWidget(dark: true),
          const SizedBox(height: 20),
        ]),
      );
}