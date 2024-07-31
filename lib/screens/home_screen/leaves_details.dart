import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LeavesDetails extends StatefulWidget {
  LeavesDetails({Key? key}) : super(key: key);

  @override
  _LeavesDetailsState createState() => _LeavesDetailsState();
}

class _LeavesDetailsState extends State<LeavesDetails> {
  // Sample data for demonstration purposes
  final List<Map<String, String>> leaves = [
    {
      "barcode": "123456",
      "name": "John Doe",
      "department": "HR",
      "fromDate": "2024-07-01",
      "endDate": "202-07-10",
      "shift": "Morning",
      "hours": "80"
    },
    {
      "barcode": "654321",
      "name": "Jane Smith",
      "department": "Finance",
      "fromDate": "2024-07-05",
      "endDate": "2024-07-12",
      "shift": "Evening",
      "hours": "72"
    },
    // Add more sample data as needed
  ];

  DateTimeRange? dateRange;

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
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredLeaves = dateRange == null
        ? leaves
        : leaves.where((leave) {
            final fromDate = DateFormat('yyyy-MM-dd').parse(leave['fromDate']!);
            final endDate = DateFormat('yyyy-MM-dd').parse(leave['endDate']!);
            return fromDate.isAfter(
                    dateRange!.start.subtract(const Duration(days: 1))) &&
                endDate.isBefore(dateRange!.end.add(const Duration(days: 1)));
          }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaves Details'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
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
                itemCount: filteredLeaves.length,
                itemBuilder: (context, index) {
                  final leave = filteredLeaves[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Barcode', leave['barcode']!),
                          _buildDetailRow('Name', leave['name']!),
                          _buildDetailRow('Department', leave['department']!),
                          _buildDetailRow('From Date', leave['fromDate']!),
                          _buildDetailRow('End Date', leave['endDate']!),
                          _buildDetailRow('Shift', leave['shift']!),
                          _buildDetailRow('Hours', leave['hours']!),
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
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
