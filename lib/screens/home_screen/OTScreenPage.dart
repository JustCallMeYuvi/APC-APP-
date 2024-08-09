import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

class OTScreenPage extends StatefulWidget {
  final LoginModelApi userData;

  const OTScreenPage({Key? key, required this.userData}) : super(key: key);

  @override
  _OTScreenPageState createState() => _OTScreenPageState();
}

class _OTScreenPageState extends State<OTScreenPage> {
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
            _errorMessage = data['message'];
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
          return record.attDate.isAfter(
                  _selectedDateRange!.start.subtract(Duration(days: 1))) &&
              record.attDate
                  .isBefore(_selectedDateRange!.end.add(Duration(days: 1)));
        }).toList();
        print('Filtered Records: $_filteredRecords'); // Debug print
      } else {
        _filteredRecords =
            _attendanceRecords; // Show all records if no date filter is applied
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

  void _showRecordDetails(OTRecord record) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('OT Hours'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                  'Date: ${record.attDate.toLocal().toString().split(' ')[0]}'),
              Text('Permitted Hours: ${record.hrPermittedHours}'),
              Text('OT Hours: ${record.empOtHrs}'),
              if (record.empOtWithoutPermission > 0)
                Text('OT Without Permission: ${record.empOtWithoutPermission}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
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
                child: ListView.builder(
                  itemCount: _filteredRecords.length,
                  itemBuilder: (context, index) {
                    final record = _filteredRecords[index];

                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8.0),
                      title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${record.attDate.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            'OT Hours: ${record.empOtHrs}',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                      onTap: () => _showRecordDetails(record),
                    );
                  },
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
