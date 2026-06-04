import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class EmptyWidget extends StatelessWidget {
  const EmptyWidget({super.key});
  @override
  Widget build(BuildContext ctx) => const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off_rounded, size: 48, color: kC3),
        SizedBox(height: 10),
        Text('No data for selected range',
            style: TextStyle(color: kC2, fontSize: 14)),
      ]));
}


