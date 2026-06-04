
import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../../models/turnover_record.dart';
import '../common/c_card.dart';

class Spark extends StatelessWidget {
  final List<TurnoverRecord> data;
  const Spark({super.key, required this.data});

  @override
  Widget build(BuildContext ctx) {
    final mx = data.map((r) => r.pct).reduce(max);
    return CCard(
        title: 'Turnover Trend',
        child: SizedBox(
            height: 72,
            child: CustomPaint(
                size: const Size(double.infinity, 72),
                painter: _SparkP(
                    vals: data
                        .map((r) => r.pct / max(mx, 1))
                        .toList()))));
  }
}

class _SparkP extends CustomPainter {
  final List<double> vals;
  _SparkP({required this.vals});

  @override
  void paint(Canvas c, Size s) {
    if (vals.length < 2) return;
    final step = s.width / (vals.length - 1);
    final lp = Path(), fp = Path();
    for (int i = 0; i < vals.length; i++) {
      final x = i * step, y = s.height - vals[i] * s.height * 0.88;
      if (i == 0) {
        lp.moveTo(x, y);
        fp..moveTo(x, s.height)..lineTo(x, y);
      } else {
        lp.lineTo(x, y);
        fp.lineTo(x, y);
      }
    }
    fp..lineTo(s.width, s.height)..close();
    c.drawPath(fp,
        Paint()..color = kCBlue.withOpacity(0.07)..style = PaintingStyle.fill);
    c.drawPath(
        lp,
        Paint()
          ..color = kCBlue
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round);
  }

  @override
  bool shouldRepaint(_) => false;
}