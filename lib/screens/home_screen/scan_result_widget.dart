import 'dart:convert';

import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ScanResultWidget extends StatefulWidget {
  final String jsonString;
  final LoginModelApi userData;

  const ScanResultWidget(
      {super.key, required this.jsonString, required this.userData});

  @override
  State<ScanResultWidget> createState() => _ScanResultWidgetState();
}

class _ScanResultWidgetState extends State<ScanResultWidget> {
  @override
  Widget build(BuildContext context) {
    final Map<String, String> stopPointNames = {
      "stop_Point_1": "Plant A",
      "stop_Point_2": "Plant B",
      "stop_Point_3": "Gate 1",
      "stop_Point_4": "Warehouse",
      "stop_Point_5": "Security Office",
      "stop_Point_6": "Main Office",
      "stop_Point_7": "Control Room",
      "stop_Point_8": "Parking Area",
      "stop_Point_9": "Cafeteria",
      "stop_Point_10": "Loading Dock",
      "stop_Point_11": "Plant C",
      "stop_Point_12": "Inspection Area",
      "stop_Point_13": "Plant D",
      "stop_Point_14": "Emergency Exit",
      "stop_Point_15": "Plant E",
      "stop_Point_16": "Plant D",
      "stop_Point_17": "Area",
      "stop_Point_18": "Plant G",
      "stop_Point_19": "Exit",
      "stop_Point_20": "Plant Y",
    };

    if (widget.jsonString.isEmpty) {
      return const Center(
        child: Text(
          "No data scanned.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    // Clean "API Response:" prefix if present
    String cleanJsonString = widget.jsonString.trim();
    if (cleanJsonString.startsWith("API Response:")) {
      cleanJsonString =
          cleanJsonString.replaceFirst("API Response:", "").trim();
    }

// Print the JSON string before parsing
    print("Raw JSON String: $cleanJsonString");
    Map<String, dynamic> jsonData;
    try {
      jsonData = json.decode(cleanJsonString);
      print("Parsed JSON: $jsonData"); // Print parsed JSON for debugging
    } catch (e) {
      print("JSON Parsing Error: $e"); // Print error in console
      return const Center(
        child: Text(
          "Failed to parse scan data.",
          style: TextStyle(fontSize: 16, color: Colors.red),
        ),
      );
    }

    final String message = jsonData['message'] ?? 'No message';
    final List<dynamic> data = jsonData['data']['data'] ?? [];

    if (data.isEmpty) {
      return const Center(
        child: Text(
          "No patrolling data found.",
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    final patrollingData = data.first;
    final stopPoints = patrollingData['stop_Points'] as Map<String, dynamic>;

    // final nonNullStopPoints = stopPoints.entries.where((e) => e.value != null);
    final allStopPoints = stopPoints.entries;
    // Find the next stop point
    String nextStopPointName = "Patrolling completed";
    for (var entry in stopPoints.entries) {
      if (entry.value == null || entry.value.toString().isEmpty) {
        nextStopPointName = stopPointNames[entry.key] ?? entry.key;
        break;
      }
    }
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Patrolling Details",
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue),
            ),
            const SizedBox(height: 8),
            // Show a different message when it's "Invalid value"
            message == "Invalid value"
                ? const Center(
                    child: Text(
                      "This Stop point is not available",
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  )
                : _infoRow("Message", message),

            // _infoRow("Message", message),
            _infoRow("User ID", patrollingData['userID']),
            _infoRow("Patrolling Type", patrollingData['patrollingType']),
            _infoRow("Shift", patrollingData['shift']),
            _infoRow("Created At", patrollingData['createdAt']),
            const SizedBox(height: 16),

            const Text(
              "Stop Points",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.green),
            ),
            Text(
              'Next Stop Point is $nextStopPointName',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

// if (nonNullStopPoints.isEmpty)
//   Center(
//     child: Text(
//       "No stop points found.",
//       style: TextStyle(fontSize: 16, color: Colors.grey),
//     ),
//   )
// else
//   Column(
//     children: nonNullStopPoints.map((entry) {
//       final stopPointName = stopPointNames[entry.key] ?? entry.key;  // Use mapped name
//       return _animatedStopPointTile(stopPointName, entry.value);  // Pass mapped name
//     }).toList(),
//   ),
            Column(
              children: allStopPoints.map((entry) {
                final stopPointName = stopPointNames[entry.key] ?? entry.key;
                final time =
                    entry.value ?? ''; // Handle null by showing empty string
                return _animatedStopPointTile(stopPointName, time);
              }).toList(),
            ),
            Visibility(
              visible: patrollingData['userID'] ==
                  widget.userData
                      .empNo, // Button visible only when both are the same
              child: Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Colors.blueAccent,
                      Colors.purpleAccent
                    ], // Gradient colors
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26, // Soft shadow
                      blurRadius: 6,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
                child: MaterialButton(
                  onPressed: () {},
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedStopPointTile(String stopPointName, String time) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(-100 + (100 * value), 0),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Icon(FontAwesomeIcons.solidCircleDot, color: Colors.red, size: 14),
                const Icon(FontAwesomeIcons.locationDot, color: Colors.red),

                Container(
                    width: 2,
                    height: 30,
                    color: Colors.grey), // Line connecting dots
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    stopPointName,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    time,
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value ?? 'N/A',
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}
