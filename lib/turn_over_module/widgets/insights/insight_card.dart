
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';
import '../../helpers/turnover_helper.dart';

class InsCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, body;
  const InsCard(
      {required this.icon,
      required this.color,
      required this.title,
      required this.body});

  @override
  Widget build(BuildContext ctx) => Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: kCCard,
          border: Border.all(color: kCBdr),
          borderRadius: BorderRadius.circular(12)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
                color: tint(color), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 18)),
        const SizedBox(width: 12),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 13, fontWeight: FontWeight.w600, color: kC0)),
          const SizedBox(height: 4),
          Text(body,
              style: const TextStyle(fontSize: 12, color: kC2, height: 1.45)),
        ])),
      ]));
}

