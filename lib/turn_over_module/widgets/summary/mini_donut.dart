

// ════════════════════════════════════════════════════════════
//  SUMMARY COMPONENTS
// ════════════════════════════════════════════════════════════

import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class MiniDonutWidget extends StatelessWidget {
  final double pct;
  const MiniDonutWidget({super.key, required this.pct});

  @override
  Widget build(BuildContext ctx) => SizedBox(
      width: 90,
      height: 90,
      child: CustomPaint(painter: _MDP(pct: pct)));
}

class _MDP extends CustomPainter {
  final double pct;
  _MDP({required this.pct});

  @override
  void paint(Canvas c, Size s) {
    final cx = s.width / 2, cy = s.height / 2, r = cx - 8;
    const sw = 10.0;
    final frac = (pct / 100).clamp(0.0, 1.0);
    c.drawCircle(Offset(cx, cy), r,
        Paint()..color = Colors.white.withOpacity(0.1)..style = PaintingStyle.stroke..strokeWidth = sw);
    c.drawArc(
        Rect.fromCircle(center: Offset(cx, cy), radius: r),
        -pi / 2,
        2 * pi * frac,
        false,
        Paint()..color = kCTeal..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
          text: '${pct.toStringAsFixed(0)}%',
          style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Colors.white))
      ..layout();
    tp.paint(c, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => true;
}