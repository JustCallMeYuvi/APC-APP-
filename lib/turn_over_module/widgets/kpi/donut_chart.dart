
import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../common/c_card.dart';
import '../common/l_dot.dart';

class Donut extends StatelessWidget {
  final double retPct;
  const Donut({super.key, required this.retPct});

  @override
  Widget build(BuildContext ctx) => CCard(
      title: 'Retention vs Attrition',
      child: SizedBox(
          height: 160,
          child: Row(children: [
            SizedBox(
                width: 160,
                child: CustomPaint(
                    size: const Size(160, 160),
                    painter: _DonutP(retained: retPct))),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                  LDot(color: kCTeal, label: 'Retained'),
                  const SizedBox(height: 4),
                  Text('${retPct.toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: kCTeal)),
                  const SizedBox(height: 12),
                  LDot(color: kCRose, label: 'Attrition'),
                  const SizedBox(height: 4),
                  Text('${(100 - retPct).toStringAsFixed(1)}%',
                      style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: kCRose)),
                ])),
          ])));
}

class _DonutP extends CustomPainter {
  final double retained;
  _DonutP({required this.retained});

  @override
  void paint(Canvas c, Size s) {
    final cx = s.width / 2, cy = s.height / 2, r = min(cx, cy) - 16;
    const sw = 22.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: r);
    final frac = 2 * pi * (retained / 100);
    c.drawArc(rect, -pi / 2, 2 * pi, false,
        Paint()..color = kCBdr..style = PaintingStyle.stroke..strokeWidth = sw);
    c.drawArc(rect, -pi / 2, frac, false,
        Paint()..color = kCTeal..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
    c.drawArc(rect, -pi / 2 + frac, 2 * pi - frac, false,
        Paint()..color = kCRose..style = PaintingStyle.stroke..strokeWidth = sw..strokeCap = StrokeCap.round);
    final tp = TextPainter(textDirection: TextDirection.ltr)
      ..text = TextSpan(
          text: '${retained.toStringAsFixed(0)}%',
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w800, color: kC0))
      ..layout();
    tp.paint(c, Offset(cx - tp.width / 2, cy - tp.height / 2));
  }

  @override
  bool shouldRepaint(_) => true;
}
