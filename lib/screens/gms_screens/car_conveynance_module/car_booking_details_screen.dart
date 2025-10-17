import 'package:flutter/material.dart';

class CarBookingDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> booking;

  const CarBookingDetailsScreen({Key? key, required this.booking})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: const Text("Car Booking Details"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRow("Name", booking["name"]),
                _buildRow("Department", booking["department"]),
                _buildRow("Booking Type", booking["selectedbookingtype"]),
                _buildRow("Reason", booking["reason"]),
                _buildRow("Travellers", booking["travellers"]),
                _buildRow("Traveller Count", booking["travellerS_COUNT"]),
                _buildRow("Barcode", booking["barcode"]),
                _buildRow("Destination", booking["destination"]),
                _buildRow("Reach Time", booking["reachtime"]),
                _buildRow("Travel From", booking["travelfrom"]),
                _buildRow("Travel To", booking["destinationto"]),
                _buildRow("Distance", booking["distance"]),
                _buildRow("Total Time", booking["total"]),
                _buildRow("Final Status", booking["finaL_STATUS"]),
                _buildRow("Created By", booking["createD_BY"]),
                _buildRow("Email", booking["email"]),
                const SizedBox(height: 20),
                const Divider(thickness: 1),
                const Center(
                  child: Text(
                    "End of Details",
                    style: TextStyle(
                        fontWeight: FontWeight.w500, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              "$title:",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              value == null || value.toString().isEmpty
                  ? "-"
                  : value.toString(),
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
