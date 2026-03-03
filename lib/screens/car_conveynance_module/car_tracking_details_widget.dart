import 'package:flutter/material.dart';

class CarTrackingDetailsStep extends StatelessWidget {
  final String title;
  final bool isCompleted;
  final bool isLast;
  final bool isCurrent;
  final bool isRejected;

  const CarTrackingDetailsStep({
    super.key,
    required this.title,
    required this.isCompleted,
    required this.isLast,
    this.isCurrent = false,
    this.isRejected = false,
  });

  @override
  Widget build(BuildContext context) {
    Color activeColor = Colors.greenAccent;
    Color rejectColor = Colors.redAccent;
    Color pendingColor = Colors.grey;

    // 🔥 Decide circle color + icon
    Color circleColor;
    IconData? icon;

    if (isRejected) {
      circleColor = rejectColor;
      icon = Icons.close; // ❌ Reject icon
    } else if (isCompleted) {
      circleColor = activeColor;
      icon = Icons.check; // ✅ Approved icon
    } else if (isCurrent) {
      circleColor = Colors.orangeAccent;
      icon = null;
    } else {
      circleColor = pendingColor;
      icon = null;
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: circleColor,
                shape: BoxShape.circle,
              ),
              child: icon != null
                  ? Icon(icon, size: 14, color: Colors.black)
                  : null,
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 45,
                color: circleColor,
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
                // color: isRejected
                //     ? Colors.redAccent
                //     : isCompleted
                //         ? Colors.white
                //         : isCurrent
                //             ? Colors.orangeAccent
                //             : Colors.white54,
                color: isCompleted
                    ? Colors.white
                    : isCurrent
                        ? Colors.orangeAccent
                        : Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
