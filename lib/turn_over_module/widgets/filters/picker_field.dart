
// ════════════════════════════════════════════════════════════
//  UNIFIED PICKER FIELD  (bottom-sheet, identical for year & month)
// ════════════════════════════════════════════════════════════

import 'package:flutter/material.dart';


import '../../constants/turnover_colors.dart';

class PickerField extends StatelessWidget {
  final String label, displayValue;
  final List<int> items;
  final int selectedItem;
  final String Function(int) itemLabel;
  final void Function(int) onChanged;

  const PickerField({
    required this.label,
    required this.displayValue,
    required this.items,
    required this.selectedItem,
    required this.itemLabel,
    required this.onChanged,
  });

  void _open(BuildContext ctx) {
    final idx = items.indexOf(selectedItem);
    final sc = ScrollController(
        initialScrollOffset: idx > 3 ? (idx - 3) * 52.0 : 0);
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        constraints:
            BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.55),
        decoration: const BoxDecoration(
          color: kCCard,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(height: 10),
          Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                  color: kCBdr, borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: kC0)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.pop(ctx),
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                      color: kCBg,
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: kC2),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: kCBdr),
          Flexible(
            child: ListView.builder(
              controller: sc,
              padding: const EdgeInsets.symmetric(vertical: 6),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final item = items[i];
                final sel = item == selectedItem;
                return GestureDetector(
                  onTap: () {
                    onChanged(item);
                    Navigator.pop(ctx);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    margin: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 13),
                    decoration: BoxDecoration(
                      color: sel
                          ? kCBlue.withOpacity(0.08)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: sel
                              ? kCBlue.withOpacity(0.3)
                              : Colors.transparent),
                    ),
                    child: Row(children: [
                      Text(itemLabel(item),
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w400,
                              color: sel ? kCBlue : kC0)),
                      const Spacer(),
                      if (sel)
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                              color: kCBlue, shape: BoxShape.circle),
                          child: const Icon(Icons.check_rounded,
                              size: 13, color: Colors.white),
                        ),
                    ]),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: MediaQuery.of(ctx).padding.bottom + 8),
        ]),
      ),
    ).whenComplete(() => sc.dispose());
  }

  @override
  Widget build(BuildContext ctx) => SizedBox(
        width: 130,
        child:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: kC2,
                  letterSpacing: 0.3)),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: () => _open(ctx),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: kCCard,
                border: Border.all(color: kCBdr),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(displayValue,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: kC0),
                      overflow: TextOverflow.ellipsis),
                ),
                const Icon(Icons.keyboard_arrow_down_rounded,
                    size: 18, color: kC3),
              ]),
            ),
          ),
        ]),
      );
}
