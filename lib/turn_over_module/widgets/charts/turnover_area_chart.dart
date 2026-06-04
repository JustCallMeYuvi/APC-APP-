
import 'dart:math';

import 'package:animated_movies_app/turn_over_module/widgets/common/card_container.dart';
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../../models/turnover_record.dart';
import '../common/l_dot.dart';

class TurnoverArea extends StatelessWidget {
  final List<TurnoverRecord> data;
  const TurnoverArea({super.key, required this.data});

  @override
  Widget build(BuildContext ctx) {
    if (data.length < 2) return const SizedBox();
    return CCardWidget(
        title: 'Turnover % — Color-zoned',
        legend: const Row(children: [
          LDot(color: kCTeal, label: '< 10%'),
          SizedBox(width: 10),
          LDot(color: kCAmber, label: '10–20%'),
          SizedBox(width: 10),
          const LDot(color: kCRose, label: '> 20%'),
        ]),
        child: SizedBox(
            height: 170,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                    width: max(data.length * 34.0, 260),
                    child: CustomPaint(
                        painter: _TAPainter(data: data))))));
  }
}

class _TAPainter extends CustomPainter {
  final List<TurnoverRecord> data;
  _TAPainter({required this.data});

  @override
  void paint(Canvas c, Size s) {
    const bP = 22.0, tP = 8.0, mxP = 40.0;
    final h = s.height - bP - tP;
    final step = s.width / (data.length - 1);

    for (var th in [10.0, 20.0]) {
      final y = tP + h * (1 - th / mxP);
      c.drawLine(Offset(0, y), Offset(s.width, y),
          Paint()..color = kCBdr..strokeWidth = 0.8);
    }

    for (int i = 0; i < data.length - 1; i++) {
      final x0 = i * step, x1 = (i + 1) * step;
      final y0 = tP + h * (1 - (data[i].pct / mxP).clamp(0, 1));
      final y1 = tP + h * (1 - (data[i + 1].pct / mxP).clamp(0, 1));
      final avg = (data[i].pct + data[i + 1].pct) / 2;
      final col = avg < 10 ? kCTeal : avg < 20 ? kCAmber : kCRose;
      c.drawPath(
          Path()
            ..moveTo(x0, s.height - bP)
            ..lineTo(x0, y0)
            ..lineTo(x1, y1)
            ..lineTo(x1, s.height - bP)
            ..close(),
          Paint()
            ..color = col.withOpacity(0.16)
            ..style = PaintingStyle.fill);
    }

    final lp = Path();
    for (int i = 0; i < data.length; i++) {
      final x = i * step,
          y = tP + h * (1 - (data[i].pct / mxP).clamp(0, 1));
      i == 0 ? lp.moveTo(x, y) : lp.lineTo(x, y);
    }
    c.drawPath(
        lp,
        Paint()
          ..color = kCSlate
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    for (int i = 0; i < data.length; i++) {
      final x = i * step,
          y = tP + h * (1 - (data[i].pct / mxP).clamp(0, 1));
      final col = data[i].pct < 10
          ? kCTeal
          : data[i].pct < 20
              ? kCAmber
              : kCRose;
      c.drawCircle(Offset(x, y), 4, Paint()..color = kCCard);
      c.drawCircle(Offset(x, y), 4,
          Paint()..color = col..style = PaintingStyle.stroke..strokeWidth = 2);
    }

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
