import 'dart:convert';
import 'package:animated_movies_app/constants/ui_constant.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class LeavesDetails extends StatefulWidget {
  final LoginModelApi userData;
  LeavesDetails({Key? key, required this.userData}) : super(key: key);

  @override
  _LeavesDetailsState createState() => _LeavesDetailsState();
}

class _LeavesDetailsState extends State<LeavesDetails> {
  List<Datum> leavesData = []; // Use the Datum model directly
  DateTimeRange? dateRange;

  @override
  void initState() {
    super.initState();
    fetchDataLeaves();
  }

  Future<void> fetchDataLeaves() async {
    final url = Uri.parse('http://10.3.0.70:9040/api/Flutter/GetLeavesData');
    final queryParams = {
      'employeeNumber': widget.userData.empNo,
      'startDateParam': dateRange != null
          ? DateFormat('yyyy-MM-dd').format(dateRange!.start)
          : '',
      'endDateParam': dateRange != null
          ? DateFormat('yyyy-MM-dd').format(dateRange!.end)
          : '',
    };

    final uri = Uri.parse(url.toString()).replace(queryParameters: queryParams);

    print('Leave URL: $uri');
    try {
      final response =
          await http.get(uri, headers: {'Content-Type': 'application/json'});

      if (response.statusCode == 200) {
        final leavesDataResponse = leavesDataFromJson(response.body);

        setState(() {
          leavesData = leavesDataResponse.data;

          // Debug: Print the list of leavesData
          leavesData.forEach((detail) {
            print(
                'Emp Detail: ${detail.empNo}, ${detail.orgId}, ${detail.startDate}, ${detail.endDate}');
          });
        });
      } else {
        print('Request failed with status: ${response.statusCode}');
        // Handle error case, show error message or retry logic
      }
    } catch (e) {
      print('Error fetching data: $e');
      // Handle error case, show error message or retry logic
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
      });
      fetchDataLeaves(); // Fetch data again with the new date range
    }
  }

  String formatDateRange(DateTime startDate, DateTime endDate) {
    // Create date formatters
    final dayFormatter = DateFormat('dd');
    final monthFormatter = DateFormat('MMM');
    final yearFormatter = DateFormat('yyyy');

    // Format dates
    final startDay = dayFormatter.format(startDate);
    final startMonth = monthFormatter.format(startDate);
    final startYear = yearFormatter.format(startDate);

    final endDay = dayFormatter.format(endDate);
    final endMonth = monthFormatter.format(endDate);
    final endYear = yearFormatter.format(endDate);

    // Return formatted date range
    return '$startDay $startMonth $startYear - $endDay $endMonth $endYear';
  }

  @override
  Widget build(BuildContext context) {
    final filteredLeaves = dateRange == null
        ? leavesData
        : leavesData.where((leave) {
            return (leave.startDate.isAfter(
                        dateRange!.start.subtract(const Duration(days: 1))) &&
                    leave.startDate.isBefore(
                        dateRange!.end.add(const Duration(days: 1)))) ||
                (leave.endDate.isAfter(
                        dateRange!.start.subtract(const Duration(days: 1))) &&
                    leave.endDate
                        .isBefore(dateRange!.end.add(const Duration(days: 1))));
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaves Details'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient:
              UiConstants.backgroundGradient.gradient, // Add your gradient here
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      dateRange == null
                          ? 'Select Date Range'
                          : '${DateFormat('yyyy-MM-dd').format(dateRange!.start)} - ${DateFormat('yyyy-MM-dd').format(dateRange!.end)}',
                      style: const TextStyle(fontSize: 16, color: Colors.white),
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
                child:
                filteredLeaves.isEmpty
                        ? Center(
                            child: Text(
                              'No data available',
                              style: TextStyle(fontSize: 18, color: Colors.white),
                            ),
                          ):
                 ListView.builder(
                  itemCount: filteredLeaves.length,
                  itemBuilder: (context, index) {
                    final leave = filteredLeaves[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        // child: Column(
                        //   crossAxisAlignment: CrossAxisAlignment.start,
                        child: ExpansionTile(
                          minTileHeight: 02,
                          // title: Text(leave.empNo), // Title for ExpansionTile
                          title: Text(
                            formatDateRange(leave.startDate,
                                leave.endDate), // Title with formatted dates
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          children: [
                            _buildDetailRow('Barcode No', leave.empNo),
                            _buildDetailRow('Name', leave.name),
                            _buildDetailRow('Department', leave.department),
                            // _buildDetailRow('Org Id', leave.orgId.toString()), // Adjust to match model
                            _buildDetailRow(
                                'Start Date',
                                DateFormat('yyyy-MM-dd')
                                    .format(leave.startDate)),
                            _buildDetailRow('End Date',
                                DateFormat('yyyy-MM-dd').format(leave.endDate)),
                            // _buildDetailRow('Holiday Kind', leave.holidayKind),
                            _buildDetailRow('Holiday Type', leave.holidayType),
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

LeavesData leavesDataFromJson(String str) =>
    LeavesData.fromJson(json.decode(str));

String leavesDataToJson(LeavesData data) => json.encode(data.toJson());

class LeavesData {
  bool status;
  String message;
  int httpCode;
  List<Datum> data;
  int statusCode;

  LeavesData({
    required this.status,
    required this.message,
    required this.httpCode,
    required this.data,
    required this.statusCode,
  });

  factory LeavesData.fromJson(Map<String, dynamic> json) => LeavesData(
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
  int orgId;
  String empNo;
  DateTime startDate;
  DateTime endDate;
  String holidayKind;
  String holidayType;
  String name;
  String department;

  Datum({
    required this.orgId,
    required this.empNo,
    required this.startDate,
    required this.endDate,
    required this.holidayKind,
    required this.holidayType,
    required this.name,
    required this.department,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        orgId: json["OrgId"],
        empNo: json["EmpNo"],
        startDate: DateTime.parse(json["StartDate"]),
        endDate: DateTime.parse(json["EndDate"]),
        holidayKind: json["HolidayKind"],
        holidayType: json["holidayType"],
        name: json["Name"],
        department: json["Department"],
      );

  Map<String, dynamic> toJson() => {
        "OrgId": orgId,
        "EmpNo": empNo,
        "StartDate": startDate.toIso8601String(),
        "EndDate": endDate.toIso8601String(),
        "HolidayKind": holidayKind,
        "holidayType": holidayType,
        "Name": name,
        "Department": department,
      };
}
