import 'package:flutter/material.dart';

class CarTrackingDetailsStep extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final bool isLast;
  final bool isCurrent;

  const CarTrackingDetailsStep({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.isLast,
    this.isCurrent = false,
  });

  @override
  Widget build(BuildContext context) {
    Color activeColor = Colors.greenAccent;
    Color pendingColor = Colors.grey;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isCompleted
                    ? activeColor
                    : isCurrent
                        ? Colors.orangeAccent
                        : pendingColor,
                shape: BoxShape.circle,
              ),
              child: isCompleted
                  ? const Icon(Icons.check,
                      size: 14, color: Colors.black)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 45,
                color: isCompleted ? activeColor : pendingColor,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              title,
              style: TextStyle(
                color: isCompleted
                    ? Colors.white
                    : isCurrent
                        ? Colors.orangeAccent
                        : Colors.white54,
                fontWeight:
                    isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
