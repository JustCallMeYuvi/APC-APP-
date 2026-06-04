import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class ChipWidget extends StatelessWidget {
  final String label;
  final bool sel;
  final VoidCallback onTap;
  const ChipWidget({super.key, required this.label, required this.sel, required this.onTap});

  @override
  Widget build(BuildContext ctx) => GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
          decoration: BoxDecoration(
              color: sel ? kCBlue : kCCard,
              border: Border.all(color: sel ? kCBlue : kCBdr),
              borderRadius: BorderRadius.circular(20)),
          child: Text(label,
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: sel ? Colors.white : kC2))));
}
