import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;

class InspectedBarcodesWidget extends StatefulWidget {
    final Function(String) onBarcodeSelected; // Callback to pass selected barcode
   InspectedBarcodesWidget({required this.onBarcodeSelected});
  @override
  _InspectedBarcodesWidgetState createState() =>
      _InspectedBarcodesWidgetState();
}

class _InspectedBarcodesWidgetState extends State<InspectedBarcodesWidget> {
  final TextEditingController _barcodeController = TextEditingController();
  String _selectedBarcode = '';
  List<String> _allBarcodes = [];
  bool _isLoading = false;

  // Fetching barcodes from the API
  Future<void> _fetchInspectedBarcodes() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      // final url = 'http://10.3.0.208:8084/api/GMS/getinspectedbarcodes';
      final url = '${ApiHelper.gmsUrl}getinspectedbarcodes';

      print(
          'Requesting data from URL: $url'); // Print the URL in the debug console

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        print(
            'Response body: ${response.body}'); // Print the response body to debug

        // Try to decode the response body
        final dynamic data = json.decode(response.body);

        // Extract the 'inspectedBarcodes' key, which contains the list of barcodes
        if (data is Map<String, dynamic> &&
            data.containsKey('inspectedBarcodes')) {
          final barcodes = data['inspectedBarcodes'] as List<dynamic>;

          // Convert the barcode list into a list of strings (barcode values)
          setState(() {
            _allBarcodes = barcodes
                .map((item) => item['barcode']
                    .toString()) // Extract barcode and convert to string
                .toList();
          });
        } else {
          print('Error: Expected a Map with "inspectedBarcodes" key');
          throw Exception('Expected a Map with "inspectedBarcodes" key');
        }
      } else {
        print('Error: Request failed with status: ${response.statusCode}');
        throw Exception(
            'Failed to load barcodes, status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error: $e'); // Print the error to the console
      throw Exception('Failed to load barcodes: $e');
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false
      });
    }
  }

  // Filter the barcodes based on the search pattern
  List<String> _getSuggestionsBarcodes(String pattern) {
    return _allBarcodes
        .where(
            (barcode) => barcode.toLowerCase().contains(pattern.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return TypeAheadField<String>(
      suggestionsCallback: (pattern) async {
        // Fetch the barcodes if the list is empty and not already loading
        if (_allBarcodes.isEmpty && !_isLoading) {
          await _fetchInspectedBarcodes(); // Wait until data is fetched
        }
        // Return filtered suggestions
        return _getSuggestionsBarcodes(pattern);
      },
      hideOnSelect: true,
      constraints: BoxConstraints(maxHeight: 300),
      builder: (context, controller, focusNode) {
        controller.text = _selectedBarcode; // Set initial text if any
        return TextField(
          controller: controller,
          focusNode: focusNode,
          decoration: InputDecoration(
            labelText: "Search Barcode",
            border: OutlineInputBorder(),
            suffixIcon: Icon(Icons.search),
          ),
        );
      },
      itemBuilder: (context, suggestion) {
        return ListTile(
          title: Text(suggestion), // Display suggestion in dropdown
        );
      },
      onSelected: (suggestion) {
        setState(() {
          _selectedBarcode = suggestion; // Update selected barcode
          _barcodeController.text = suggestion; // Update controller text
        });
            widget.onBarcodeSelected(suggestion); // Notify parent
        FocusScope.of(context).unfocus(); // Optionally unfocus the text field
      },
    );
  }
}
