import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';

class MissPunchesScreen extends StatefulWidget {
  final LoginModelApi userData;

  MissPunchesScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _MissPunchesScreenState createState() => _MissPunchesScreenState();
}

class _MissPunchesScreenState extends State<MissPunchesScreen> {
  List<Map<String, String>> punches = [];
  DateTimeRange? dateRange;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPunchDetails();
  }

  Future<void> fetchPunchDetails() async {
    final String startDate =
        dateRange?.start.toString().substring(0, 10) ?? '2024-01-01';
    final String endDate =
        dateRange?.end.toString().substring(0, 10) ?? '2024-07-31';
    final String apiUrl =
        "http://10.3.0.70:9040/api/Flutter/GetEmpPunchDetails?employeeNumber=${widget.userData.empNo}&startDate=$startDate&endDate=$endDate";

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final punchDetails = punchDetailsFromJson(response.body);

        // Print the full response data for debugging
        print('API Data: ${response.body}');

        setState(() {
          punches = punchDetails.data
              .map((datum) => {
                    "barcode": datum.empNo,
                    "cardTime":
                        datum.cardTime.toIso8601String().substring(0, 10),
                    "workOnA": datum.workOnaTime ?? 'N/A',
                    "workOffA": datum.workOffaTime ?? 'N/A',
                    "workOnB": datum.workOnbTime ?? 'N/A',
                    "workOffB": datum.workOffbTime ?? 'N/A',
                  })
              .toList();
          isLoading = false;
        });
      } else {
        // Handle non-200 response
        print('Failed to load data. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle error
      print('Error fetching data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDateRange: dateRange,
    );
    if (picked != null && picked != dateRange) {
      setState(() {
        dateRange = picked;
        fetchPunchDetails(); // Fetch data based on the new date range
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPunches = dateRange == null
        ? punches
        : punches.where((punch) {
            final cardTime = DateFormat('yyyy-MM-dd').parse(punch['cardTime']!);
            return cardTime.isAfter(
                    dateRange!.start.subtract(const Duration(days: 1))) &&
                cardTime.isBefore(dateRange!.end.add(const Duration(days: 1)));
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Punch Details'),
        backgroundColor: Colors.lightGreen,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          dateRange == null
                              ? 'Please Select Date Range'
                              : '${DateFormat('yyyy-MM-dd').format(dateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(dateRange!.end)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => _selectDateRange(context),
                        child: const Text('Select Dates'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: filteredPunches.length,
                      itemBuilder: (context, index) {
                        final punch = filteredPunches[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: ExpansionTile(
                              minTileHeight: 02,
                              title: Text('Date: ${punch['cardTime']}'),
                              // crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailRow('Barcode', punch['barcode']!),
                                _buildDetailRow('Date', punch['cardTime']!),
                                _buildDetailRow('In Punch', punch['workOnA']!),
                                _buildDetailRow(
                                    'Lunch Before', punch['workOffA']!),
                                _buildDetailRow(
                                    'Lunch After', punch['workOnB']!),
                                _buildDetailRow(
                                    'End Punch', punch['workOffB']!),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Container(
      padding:
          const EdgeInsets.symmetric(vertical: 8.0), // Add padding to each row
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label with bold text and a fixed width
          Container(
            width: 120, // Adjust width as needed
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors
                    .black87, // Slightly lighter color for better contrast
              ),
            ),
          ),
          const SizedBox(width: 8), // Space between label and value
          Expanded(
            child: Text(
              value.isEmpty ? 'N/A' : value,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black54, // Slightly lighter color for value
              ),
              textAlign: TextAlign.left, // Ensure text is left-aligned
            ),
          ),
        ],
      ),
    );
  }
}

PunchDetails punchDetailsFromJson(String str) =>
    PunchDetails.fromJson(json.decode(str));

String punchDetailsToJson(PunchDetails data) => json.encode(data.toJson());

class PunchDetails {
  bool status;
  String message;
  int httpCode;
  List<Datum> data;
  int statusCode;

  PunchDetails({
    required this.status,
    required this.message,
    required this.httpCode,
    required this.data,
    required this.statusCode,
  });

  factory PunchDetails.fromJson(Map<String, dynamic> json) => PunchDetails(
        status: json["Status"],
        message: json["Message"],
        httpCode: json["HttpCode"],
        data: List<Datum>.from(json["Data"].map((x) => Datum.fromJson(x))),
        statusCode: json["StatusCode"],
      );

  Map<String, dynamic> toJson() => {
        "Status": status,
        "Message": message,
        "HttpCode": httpCode,
        "Data": List<dynamic>.from(data.map((x) => x.toJson())),
        "StatusCode": statusCode,
      };
}

class Datum {
  String empNo;
  DateTime cardTime;
  String? workOnaTime;
  String? workOffaTime;
  String? workOnbTime;
  String? workOffbTime;

  Datum({
    required this.empNo,
    required this.cardTime,
    required this.workOnaTime,
    required this.workOffaTime,
    required this.workOnbTime,
    required this.workOffbTime,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        empNo: json["EMP_NO"],
        cardTime: DateTime.parse(json["CARD_TIME"]),
        workOnaTime: json["WORK_ONA_TIME"],
        workOffaTime: json["WORK_OFFA_TIME"],
        workOnbTime: json["WORK_ONB_TIME"],
        workOffbTime: json["WORK_OFFB_TIME"],
      );

  Map<String, dynamic> toJson() => {
        "EMP_NO": empNo,
        "CARD_TIME":
            "${cardTime.year.toString().padLeft(4, '0')}-${cardTime.month.toString().padLeft(2, '0')}-${cardTime.day.toString().padLeft(2, '0')}",
        "WORK_ONA_TIME": workOnaTime,
        "WORK_OFFA_TIME": workOffaTime,
        "WORK_ONB_TIME": workOnbTime,
        "WORK_OFFB_TIME": workOffbTime,
      };
}
