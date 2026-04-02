// ── Reusable Small Widgets ────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class MissPunchesCardWidget extends StatelessWidget {
  final Widget child;
  const MissPunchesCardWidget({super.key, required this.child});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: child,
      );
}
