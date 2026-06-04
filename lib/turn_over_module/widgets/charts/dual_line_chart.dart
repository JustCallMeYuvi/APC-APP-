
import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../../models/turnover_record.dart';
import '../common/card_container.dart';
import '../common/l_dot.dart';

class DualLine extends StatelessWidget {
  final List<TurnoverRecord> data;
  const DualLine({super.key, required this.data});

  @override
  Widget build(BuildContext ctx) {
    if (data.length < 2) return const SizedBox();
    return CCardWidget(
        title: 'Avg Headcount vs Departures',
        legend: Row(children: [
          LDot(color: kCBlue, label: 'Avg HC'),
          const SizedBox(width: 12),
          LDot(color: kCRose, label: 'Left'),
        ]),
        child: SizedBox(
            height: 190,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                    width: max(data.length * 34.0, 260),
                    child: CustomPaint(
                        painter: _DLPainter(data: data))))));
  }
}

class _DLPainter extends CustomPainter {
  final List<TurnoverRecord> data;
  _DLPainter({required this.data});

  @override
  void paint(Canvas c, Size s) {
    const bP = 22.0, tP = 8.0;
    final h = s.height - bP - tP;
    final step = s.width / (data.length - 1);
    final hcV = data.map((r) => r.avgHC).toList();
    final lV = data.map((r) => r.left.toDouble()).toList();
    final mx = [...hcV, ...lV].reduce(max);

    for (var f in [0.25, 0.5, 0.75]) {
      final y = tP + h * (1 - f);
      c.drawLine(Offset(0, y), Offset(s.width, y),
          Paint()..color = kCBdr..strokeWidth = 0.5);
    }

    void drawLine(List<double> vals, Color col) {
      final paint = Paint()
        ..color = col
        ..strokeWidth = 2.2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      final fill = Paint()
        ..color = col.withOpacity(0.07)
        ..style = PaintingStyle.fill;
      final lp = Path(), fp = Path();
      for (int i = 0; i < vals.length; i++) {
        final x = i * step, y = tP + h - (vals[i] / mx * h * 0.9);
        if (i == 0) {
          lp.moveTo(x, y);
          fp
            ..moveTo(x, s.height - bP)
            ..lineTo(x, y);
        } else {
          lp.lineTo(x, y);
          fp.lineTo(x, y);
        }
      }
      fp
        ..lineTo(s.width, s.height - bP)
        ..close();
      c.drawPath(fp, fill);
      c.drawPath(lp, paint);
      for (int i = 0; i < vals.length; i++) {
        final x = i * step, y = tP + h - (vals[i] / mx * h * 0.9);
        c.drawCircle(Offset(x, y), 3.5,
            Paint()..color = kCCard..style = PaintingStyle.fill);
        c.drawCircle(Offset(x, y), 3.5,
            Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 1.8);
      }
    }

    drawLine(hcV, kCBlue);
    drawLine(lV, kCRose);

    final tp = TextPainter(textDirection: TextDirection.ltr);
    for (int i = 0; i < data.length; i += max(1, data.length ~/ 7)) {
      tp.text = TextSpan(
          text: data[i].chartLabel,
          style: const TextStyle(fontSize: 8, color: kC3));
      tp.layout();
      tp.paint(
          c, Offset(i * step - tp.width / 2, s.height - bP + 4));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
