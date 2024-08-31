
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';
import '../onboarding_screen/login_page.dart';

class OTRecord {
  final String empNo;
  final DateTime attDate;
  final String deptNo;
  final String deptName;
  final String workName;
  final double hrPermittedHours;
  final double empOtHrs;
  final double empOtWithoutPermission;

  OTRecord({
    required this.empNo,
    required this.attDate,
    required this.deptNo,
    required this.deptName,
    required this.workName,
    required this.hrPermittedHours,
    required this.empOtHrs,
    required this.empOtWithoutPermission,
  });

  factory OTRecord.fromJson(Map<String, dynamic> json) {
    return OTRecord(
      empNo: json['empNo'] ?? '',
      attDate: DateTime.parse(json['attDate']),
      deptNo: json['deptNo'] ?? '',
      deptName: json['deptName'] ?? '',
      workName: json['workName'] ?? '',
      hrPermittedHours: (json['hrPermittedHours']?.toDouble() ?? 0.0),
      empOtHrs: (json['empOtHrs']?.toDouble() ?? 0.0),
      empOtWithoutPermission:
          (json['empOtWithoutPermission']?.toDouble() ?? 0.0),
    );
  }
}

class ChartsScreen extends StatefulWidget {
  final LoginModelApi userData;

  const ChartsScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _ChartsScreenState createState() => _ChartsScreenState();
}

class _ChartsScreenState extends State<ChartsScreen> {
  DateTimeRange? _selectedDateRange;
  List<OTRecord> _attendanceRecords = [];
  List<OTRecord> _filteredRecords = [];
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAllData();
  }

  Future<void> _fetchAllData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final String empNo = widget.userData.empNo;
    final String? fromDateStr = _selectedDateRange?.start.toIso8601String();
    final String? toDateStr = _selectedDateRange?.end.toIso8601String();

    final url = Uri.parse(
      'http://10.3.0.70:9042/api/HR/GetOTRecords?empNo=$empNo'
      '${fromDateStr != null ? '&fromDate=$fromDateStr' : ''}'
      '${toDateStr != null ? '&toDate=$toDateStr' : ''}',
    );

    print('URL: $url'); // Debug print

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('Response Data: $data'); // Debug print

        if (data['success']) {
          final List<dynamic> recordsJson = data['data'];
          print('Fetched Records: $recordsJson'); // Debug print

          setState(() {
            _attendanceRecords = recordsJson
                .map((json) => OTRecord.fromJson(json))
                .toList(); // Include all records without filtering
            print('Attendance Records: $_attendanceRecords'); // Debug print
            _applyDateFilter(); // Apply date filter after fetching data
          });
        } else {
          setState(() {
            _errorMessage = data['message'] ?? 'Unknown error';
          });
        }
      } else {
        setState(() {
          _errorMessage = 'Failed to load data: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error during data fetch: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyDateFilter() {
    setState(() {
      if (_selectedDateRange != null) {
        _filteredRecords = _attendanceRecords.where((record) {
          return record.attDate.isAfter(_selectedDateRange!.start.subtract(Duration(days: 1))) &&
              record.attDate.isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
        }).toList();
        print('Filtered Records: $_filteredRecords'); // Debug print
      } else {
        _filteredRecords = _attendanceRecords; // Show all records if no date filter is applied
      }
    });
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      initialDateRange: _selectedDateRange,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDateRange) {
      setState(() {
        _selectedDateRange = picked;
      });
      _applyDateFilter(); // Apply date filter locally
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'OT Data',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.lightGreen,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_today),
            onPressed: () => _selectDateRange(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isLoading)
              Center(child: CircularProgressIndicator())
            else if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: TextStyle(color: Colors.red, fontSize: 16),
              )
            else if (_filteredRecords.isNotEmpty)
              Expanded(
                child: Column(
                  children: [
                    Expanded(
                      child: SfCartesianChart(
                        primaryXAxis: CategoryAxis(),
                        title: ChartTitle(text: 'OT Hours by Date'),
                        series: <CartesianSeries>[
                          BarSeries<OTRecord, String>(
                            dataSource: _filteredRecords,
                            xValueMapper: (OTRecord record, _) =>
                                record.attDate.toLocal().toString().split(' ')[0],
                            yValueMapper: (OTRecord record, _) => record.empOtHrs,
                            dataLabelSettings: DataLabelSettings(isVisible: true),
                            color: Colors.blue,
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: SfCircularChart(
                        title: ChartTitle(text: 'OT Hours by Department'),
                        series: <CircularSeries>[
                          PieSeries<OTRecord, String>(
                            dataSource: _filteredRecords,
                            xValueMapper: (OTRecord record, _) => record.deptName,
                            yValueMapper: (OTRecord record, _) => record.empOtHrs,
                            dataLabelSettings: DataLabelSettings(isVisible: true),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              Center(child: Text('No records found.')),
          ],
        ),
      ),
    );
  }
}
