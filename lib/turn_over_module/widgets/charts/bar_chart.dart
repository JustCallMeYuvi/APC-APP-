
// ════════════════════════════════════════════════════════════
//  CHART PAINTERS
// ════════════════════════════════════════════════════════════

import 'dart:math';

import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../../helpers/turnover_helper.dart';
import '../../models/turnover_record.dart';
import '../common/card_container.dart';

class BarChartWidget extends StatelessWidget {
  final List<TurnoverRecord> data;
  final List<double> vals;
  final String metric;
  const BarChartWidget(
      {super.key, required this.data, required this.vals, required this.metric});

  String _lbl(double v) =>
      (metric == 'Turnover %' || metric == 'Retention %')
          ? '${v.toStringAsFixed(1)}%'
          : fmtK(v);

  @override
  Widget build(BuildContext ctx) {
    if (vals.isEmpty) return const SizedBox();
    final hasNeg = vals.any((v) => v < 0);
    final maxV = vals.map((v) => v.abs()).reduce(max);
    final bW = MediaQuery.of(ctx).size.width >= 600 ? 28.0 : 20.0;
    return CCardWidget(
        title: metric,
        child: SizedBox(
            height: 210,
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                    width: max(data.length * (bW + 12) + 20, 280),
                    child: CustomPaint(
                        painter: _BPainter(
                            vals: vals,
                            // ✅ Use chartLabel — works for both year and month
                            labels: data.map((r) => r.chartLabel).toList(),
                            maxV: maxV,
                            hasNeg: hasNeg,
                            bW: bW,
                            fmt: _lbl))))));
  }
}

class _BPainter extends CustomPainter {
  final List<double> vals;
  final List<String> labels;
  final double maxV, bW;
  final bool hasNeg;
  final String Function(double) fmt;

  _BPainter(
      {required this.vals,
      required this.labels,
      required this.maxV,
      required this.hasNeg,
      required this.bW,
      required this.fmt});

  @override
  void paint(Canvas c, Size s) {
    const bP = 28.0, tP = 14.0;
    final h = s.height - bP - tP;
    final base = hasNeg ? tP + h / 2 : tP + h;
    final step = s.width / vals.length;
    final tp = TextPainter(textDirection: TextDirection.ltr);

    c.drawLine(Offset(0, base), Offset(s.width, base),
        Paint()..color = kCBdr..strokeWidth = 0.8);

    for (int i = 0; i < vals.length; i++) {
      final v = vals[i];
      final x = step * i + step / 2;
      final frac = maxV > 0 ? v.abs() / maxV : 0;
      final bH = (frac * (hasNeg ? h / 2 : h) * 0.88)
          .clamp(2.0, double.infinity);
      final isPos = v >= 0;
      final col = v < 0
          ? kCRose
          : frac > 0.75
              ? kCRose
              : frac > 0.45
                  ? kCAmber
                  : kCBlue;

      final top = isPos ? base - bH : base;
      c.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(x - bW / 2, top, bW, bH),
              const Radius.circular(4)),
          Paint()..color = col);

      if (bH > 20) {
        tp.text = TextSpan(
            text: fmt(v),
            style: const TextStyle(
                fontSize: 8,
                color: Colors.white,
                fontWeight: FontWeight.w700));
        tp.layout();
        tp.paint(
            c,
            Offset(x - tp.width / 2,
                isPos ? top + 3 : top + bH - tp.height - 3));
      }

      // ✅ Use pre-built chartLabel directly — no more substring(2)
      tp.text = TextSpan(
          text: labels[i],
          style: const TextStyle(fontSize: 8.5, color: kC3));
      tp.layout();
      tp.paint(c, Offset(x - tp.width / 2, s.height - bP + 5));
    }
  }

  @override
  bool shouldRepaint(_) => true;
}
