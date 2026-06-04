
// ════════════════════════════════════════════════════════════
//  FILTER STATE
// ════════════════════════════════════════════════════════════

import '../constants/turnover_constants.dart';

enum SubView { yearwise, monthwise }

class FilterState {
  final SubView subView;
  final int fromYear;
  final int toYear;
  final int monthYear;
  final int fromMonth;
  final int toMonth;

  const FilterState({
    this.subView = SubView.yearwise,
    this.fromYear = 2006,
    this.toYear = 2026,
    this.monthYear = 2025,
    this.fromMonth = 1,
    this.toMonth = 12,
  });

  FilterState copyWith({
    SubView? subView,
    int? fromYear,
    int? toYear,
    int? monthYear,
    int? fromMonth,
    int? toMonth,
  }) {
    final newMonthYear = monthYear ?? this.monthYear;
    // final maxAllowed =
    //     newMonthYear == _currentYear ? _currentMonth : 12;
    final maxAllowed =
    newMonthYear == kCurrentYear ? kCurrentMonth : 12;
    // clamp toMonth if switching to current year
    final newToMonth = (toMonth ?? this.toMonth).clamp(1, maxAllowed);
    // clamp fromMonth so it never exceeds toMonth
    final newFromMonth = (fromMonth ?? this.fromMonth).clamp(1, newToMonth);
    return FilterState(
      subView: subView ?? this.subView,
      fromYear: fromYear ?? this.fromYear,
      toYear: toYear ?? this.toYear,
      monthYear: newMonthYear,
      fromMonth: newFromMonth,
      toMonth: newToMonth,
    );
  }

  Map<String, dynamic> get yearwiseBody => {
        'type': 'year',
        'fromYear': fromYear,
        'toYear': toYear,
        'year': 0,
        'fromMonth': 0,
        'toMonth': 0,
      };

  Map<String, dynamic> get monthwiseBody => {
        'type': 'month',
        'fromYear': monthYear,
        'toYear': monthYear,
        'year': monthYear,
        'fromMonth': fromMonth,
        'toMonth': toMonth,
      };
}
