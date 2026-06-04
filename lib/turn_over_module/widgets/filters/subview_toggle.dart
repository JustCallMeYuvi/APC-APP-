

// ── SubView toggle ────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../constants/turnover_colors.dart';
import '../../models/filter_state.dart';

class SubViewToggle extends StatelessWidget {
  final SubView value;
  final void Function(SubView) onChanged;
  const SubViewToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext ctx) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Type',
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: kC2,
                letterSpacing: 0.3)),
        const SizedBox(height: 4),
        Container(
          height: 38,
          decoration: BoxDecoration(
              color: kCBg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kCBdr)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            _btn('Yearwise', SubView.yearwise),
            _btn('Monthwise', SubView.monthwise),
          ]),
        ),
      ]);

  Widget _btn(String label, SubView sv) {
    final sel = value == sv;
    return GestureDetector(
      onTap: () => onChanged(sv),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
            color: sel ? kCIndi : Colors.transparent,
            borderRadius: BorderRadius.circular(9)),
        child: Text(label,
            style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: sel ? Colors.white : kC2)),
      ),
    );
  }
}