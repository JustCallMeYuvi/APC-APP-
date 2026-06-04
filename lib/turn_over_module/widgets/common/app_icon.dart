
import 'package:flutter/material.dart';

import '../../constants/turnover_colors.dart';

class AppIcon extends StatelessWidget {
  const AppIcon({super.key});

  @override
  Widget build(BuildContext ctx) => Container(
      width: 32,
      height: 32,
      decoration:
          BoxDecoration(color: kCBlue, borderRadius: BorderRadius.circular(9)),
      child:
          const Icon(Icons.people_alt_rounded, color: Colors.white, size: 17));
}