
// ════════════════════════════════════════════════════════════
//  FILTER BAR
// ════════════════════════════════════════════════════════════

import 'package:animated_movies_app/turn_over_module/helpers/turnover_helper.dart';
import 'package:animated_movies_app/turn_over_module/models/filter_state.dart';
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../../constants/turnover_constants.dart';
import 'picker_field.dart';
import 'subview_toggle.dart';

class FilterBar extends StatelessWidget {
  final FilterState filter;
  final void Function(FilterState) onChanged;
  final bool isWide;

  const FilterBar(
      {super.key, required this.filter,
      required this.onChanged,
      required this.isWide});

  static final List<int> _allYears =
      List.generate(kCurrentYear - 2006 + 1, (i) => 2006 + i);
  static const List<int> _months = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12];

  @override
  Widget build(BuildContext ctx) => Container(
        color: kCCard,
        padding: EdgeInsets.symmetric(
            horizontal: isWide ? 24 : 14, vertical: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ── Type toggle ──
          SubViewToggle(
            value: filter.subView,
            onChanged: (sv) => onChanged(filter.copyWith(subView: sv)),
          ),
          const SizedBox(height: 10),
          // ── Date pickers ──
          if (filter.subView == SubView.yearwise)
            Wrap(spacing: 10, runSpacing: 10, children: [
              PickerField(
                label: 'From Year',
                displayValue: filter.fromYear.toString(),
                items: _allYears
                    .where((y) => y <= filter.toYear)
                    .toList(),
                selectedItem: filter.fromYear,
                itemLabel: (y) => y.toString(),
                onChanged: (y) => onChanged(filter.copyWith(fromYear: y)),
              ),
              PickerField(
                label: 'To Year',
                displayValue: filter.toYear.toString(),
                items: _allYears
                    .where((y) => y >= filter.fromYear)
                    .toList(),
                selectedItem: filter.toYear,
                itemLabel: (y) => y.toString(),
                onChanged: (y) => onChanged(filter.copyWith(toYear: y)),
              ),
            ])
          else
            Wrap(spacing: 10, runSpacing: 10, children: [
              PickerField(
                label: 'Year',
                displayValue: filter.monthYear.toString(),
                items: _allYears,
                selectedItem: filter.monthYear,
                itemLabel: (y) => y.toString(),
                onChanged: (y) => onChanged(filter.copyWith(monthYear: y)),
              ),
              PickerField(
                label: 'From Month',
                displayValue:
                    '${monthName(filter.fromMonth)} (${filter.fromMonth})',
                // cap at current month if current year selected
                items: _months
                    .where((m) =>
                        m <= filter.toMonth &&
                        (filter.monthYear < kCurrentYear ||
                            m <= kCurrentMonth))
                    .toList(),
                selectedItem: filter.fromMonth,
                itemLabel: (m) => '$m — ${monthName(m)}',
                onChanged: (m) => onChanged(filter.copyWith(fromMonth: m)),
              ),
              PickerField(
                label: 'To Month',
                displayValue:
                    '${monthName(filter.toMonth)} (${filter.toMonth})',
                // cap at current month if current year selected
                items: _months
                    .where((m) =>
                        m >= filter.fromMonth &&
                        (filter.monthYear < kCurrentYear ||
                            m <= kCurrentMonth))
                    .toList(),
                selectedItem: filter.toMonth,
                itemLabel: (m) => '$m — ${monthName(m)}',
                onChanged: (m) => onChanged(filter.copyWith(toMonth: m)),
              ),
            ]),
        ]),
      );
}