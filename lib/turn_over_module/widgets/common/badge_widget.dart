
import 'package:flutter/material.dart';

import '../../helpers/turnover_helper.dart';

class BadgeWidget extends StatelessWidget {
  final String label;
  final Color color;
  const BadgeWidget({required this.label, required this.color});

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: tint(color), borderRadius: BorderRadius.circular(20)),
      child: Text(label,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.w700, color: color)));
}