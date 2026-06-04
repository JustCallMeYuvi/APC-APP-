import 'package:flutter/widgets.dart';

import '../../constants/turnover_colors.dart';

class SecLabelWidget extends StatelessWidget {
  final String text;
  const SecLabelWidget(this.text, {super.key});

  @override
  Widget build(BuildContext ctx) => Text(text,
      style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: kC2,
          letterSpacing: 0.4));
}
