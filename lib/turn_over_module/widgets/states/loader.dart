// ════════════════════════════════════════════════════════════
//  LOADING / ERROR / EMPTY
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';


class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});
  @override
  Widget build(BuildContext ctx) => const Center(
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        CircularProgressIndicator(color: kCBlue, strokeWidth: 2.5),
        SizedBox(height: 14),
        Text('Loading turnover data…',
            style: TextStyle(fontSize: 13, color: kC2)),
      ]));
}
