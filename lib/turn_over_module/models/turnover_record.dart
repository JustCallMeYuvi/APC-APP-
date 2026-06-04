
// ════════════════════════════════════════════════════════════
//  DATA MODELS
// ════════════════════════════════════════════════════════════

import '../helpers/turnover_helper.dart';

class TurnoverRecord {
  final int year;
  final String monthYear; // e.g. "2025-01" for monthwise, "" for yearwise
  final int beginHC, endHC, left;
  final double avgHC, rate, pct;

  const TurnoverRecord({
    required this.year,
    required this.monthYear,
    required this.beginHC,
    required this.endHC,
    required this.avgHC,
    required this.left,
    required this.rate,
    required this.pct,
  });

  int get netChange => endHC - beginHC;
  double get retentionPct => 100 - pct;

  /// Short label for chart x-axis: "Jan" for monthwise, "'25" for yearwise
  String get chartLabel {
    if (monthYear.isNotEmpty && monthYear.length >= 7) {
      final m = int.tryParse(monthYear.substring(5, 7)) ?? 0;
      return monthName(m);
    }
    return "'${year.toString().substring(2)}";
  }

  /// Full label for table first column
  String get tableLabel {
    if (monthYear.isNotEmpty && monthYear.length >= 7) {
      final m = int.tryParse(monthYear.substring(5, 7)) ?? 0;
      return '${monthName(m)} $year';
    }
    return year.toString();
  }

  factory TurnoverRecord.fromJson(Map<String, dynamic> e,
      {bool isMonth = false}) =>
      TurnoverRecord(
        year: e['year'] ?? 0,
        monthYear: (e['monthYear'] ?? '') as String,
        beginHC: e['beginHeadCount'] ?? 0,
        endHC: e['endHeadCount'] ?? 0,
        avgHC: (e['averageHeadCount'] ?? 0).toDouble(),
        left: e['employeesLeft'] ?? 0,
        rate: (e['turnoverRate'] ?? 0).toDouble(),
        pct: (e['turnoverPercentage'] ?? 0).toDouble(),
      );
}
