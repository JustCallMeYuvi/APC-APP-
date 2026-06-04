
import 'package:animated_movies_app/turn_over_module/constants/turnover_colors.dart';
import 'package:flutter/material.dart';

class ErrorViewWidget extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const ErrorViewWidget({super.key, required this.error, required this.onRetry});
  @override
  Widget build(BuildContext ctx) => Center(
          child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.wifi_off_rounded, size: 48, color: kCRose),
          const SizedBox(height: 12),
          const Text('Failed to load data',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: kC0)),
          const SizedBox(height: 6),
          Text(error,
              style: const TextStyle(fontSize: 11, color: kC3),
              textAlign: TextAlign.center),
          const SizedBox(height: 18),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
                backgroundColor: kCBlue, foregroundColor: Colors.white),
          ),
        ]),
      ));
}