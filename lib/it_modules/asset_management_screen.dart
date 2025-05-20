import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AssetManagementScreen extends StatefulWidget {
  final LoginModelApi userData;
  const AssetManagementScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  _AssetManagementScreenState createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  late DateTime selectedDate; // use 'late' since we assign it in initState
  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now(); // default is today
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime today = DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(2000), // or any past date
      lastDate: today, // restrict future dates
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate!);
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    // String formattedDate = selectedDate != null
    //     ? DateFormat('yyyy-MM-dd').format(selectedDate!)
    //     : 'No date selected';
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Center(child: Text('Selected Date: $formattedDate')),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _selectDate(context),
              child: const Text('Pick Date'),
            ),
          ],
        ),
      ),
    );
  }
}
