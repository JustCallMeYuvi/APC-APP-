import 'package:flutter/material.dart';

class TokenScreen extends StatefulWidget {
  const TokenScreen({Key? key}) : super(key: key);

  @override
  _TokenScreenState createState() => _TokenScreenState();
}

class _TokenScreenState extends State<TokenScreen> {
  final TextEditingController _textFieldController = TextEditingController();
  String? _selectedBarcode;
  final List<String> _barcodes = ['70068', '71202', '67757','70643'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Token Screen'),
        backgroundColor: Colors.lightGreen,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _textFieldController,
              decoration: InputDecoration(
                labelText: 'Enter Text',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Barcode',
                border: OutlineInputBorder(),
              ),
              value: _selectedBarcode,
              items: _barcodes.map((String barcode) {
                return DropdownMenuItem<String>(
                  value: barcode,
                  child: Text(barcode),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedBarcode = newValue;
                });
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle the submit action
                String token = _textFieldController.text;
                String barcode = _selectedBarcode ?? 'No barcode selected';
                print('Token: $token, Barcode: $barcode');
                // Perform further actions with the token and barcode
              },
              child: Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
