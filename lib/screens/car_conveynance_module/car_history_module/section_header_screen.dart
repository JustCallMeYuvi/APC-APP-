import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text("View All",
            style: TextStyle(
                fontSize: 13,
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w500))
      ],
    );
  }
}