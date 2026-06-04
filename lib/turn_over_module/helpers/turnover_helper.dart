
import 'dart:ui';

import '../constants/turnover_colors.dart';

// String _monthName(int m) => const [
//       '',
//       'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
//       'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
//     ][m.clamp(0, 12)];
String monthName(int m) => const [
      '',
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][m.clamp(0, 12)];

String fmtK(double v) => v.abs() >= 1000
    ? '${(v / 1000).toStringAsFixed(1)}K'
    : v.round().toString();

String commas(int v) {
  final s = v.toString();
  final b = StringBuffer();
  for (int i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write(',');
    b.write(s[i]);
  }
  return b.toString();
}


// Color _tint(Color c, [double o = 0.10]) => c.withOpacity(o);

// String _riskLabel(double p) =>
//     p < 10 ? 'Healthy' : p < 20 ? 'Moderate' : p < 30 ? 'High' : 'Critical';

// Color _riskColor(double p) => p < 10 ? _cTeal : p < 20 ? _cAmber : _cRose;
Color tint(Color c, [double o = 0.10]) => c.withOpacity(o);

String riskLabel(double p) =>
    p < 10 ? 'Healthy' : p < 20 ? 'Moderate' : p < 30 ? 'High' : 'Critical';

Color riskColor(double p) =>
    p < 10 ? kCTeal : p < 20 ? kCAmber : kCRose;