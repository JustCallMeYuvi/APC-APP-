import 'package:flutter/material.dart';

class StatsSection extends StatelessWidget {
  final String totalTrips;
  final String totalKms;
  final String travellers;
  final String activeCars;

  const StatsSection({
    super.key,
    required this.totalTrips,
    required this.totalKms,
    required this.travellers,
    required this.activeCars,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatTile(
                title: "Total Trips",
                value: totalTrips,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                title: "Total KM",
                value: totalKms,
                color: Colors.orange,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                title: "Travellers",
                value: travellers,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                title: "Total Cars",
                value: activeCars,
                color: Colors.purple,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class StatTile extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const StatTile({
    super.key,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 5,
            width: 35,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
                fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}