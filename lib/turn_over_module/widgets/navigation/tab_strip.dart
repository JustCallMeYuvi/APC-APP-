
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class TabStripWidget extends StatelessWidget {
  final int tab;
  final void Function(int) onTab;
  const TabStripWidget({super.key, required this.tab, required this.onTab});
  static const _lbl = ['Overview', 'Charts', 'Table', 'Insights', 'Summary'];

  @override
  Widget build(BuildContext ctx) => Container(
        color: kCCard,
        child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
                children: List.generate(_lbl.length, (i) {
              final sel = tab == i;
              return GestureDetector(
                  onTap: () => onTab(i),
                  child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color:
                                      sel ? kCBlue : Colors.transparent,
                                  width: 2.5))),
                      child: Text(_lbl[i],
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: sel ? kCBlue : kC2))));
            }))),
      );
}
