import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LoadingPointSearch extends StatefulWidget {
  final TextEditingController controller;
  final String selectedLoadingPoint;

  LoadingPointSearch({
    required this.controller,
    required this.selectedLoadingPoint,
  });

  @override
  _LoadingPointSearchState createState() => _LoadingPointSearchState();
}

class _LoadingPointSearchState extends State<LoadingPointSearch> {
  List<String> _allLoadingPoints = [];
  bool _isLoading = false;
  String _selectedLoadingPoint = '';

  @override
  void initState() {
    super.initState();
    _selectedLoadingPoint = widget.selectedLoadingPoint;
    _fetchLoadingPoints();  // Fetch loading points when widget is initialized
  }

  // Fetch loading points from the API
  Future<void> _fetchLoadingPoints() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      final url = 'http://10.3.0.208:8084/api/GMS/getloadingpoints';
      print('Requesting data from URL: $url');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data is Map && data.containsKey('loadingPoints')) {
          final List<dynamic> loadingPoints = data['loadingPoints'];

          setState(() {
            _allLoadingPoints = loadingPoints
                .map((item) => item['loadingPoint'].toString())
                .toList();
          });
        } else {
          print('Error: Expected a map with key "loadingPoints", but got: $data');
          throw Exception('Failed to load loading points');
        }
      } else {
        print('Error: Request failed with status: ${response.statusCode}');
        throw Exception('Failed to load loading points');
      }
    } catch (e) {
      print('Error: $e');
      throw Exception('Failed to load loading points: $e');
    } finally {
      setState(() {
        _isLoading = false; // Set loading state to false
      });
    }
  }

  // Filter loading points based on query
  List<String> _getSuggestionsLoadingPoints(
      String query, List<String> allLoadingPoints) {
    return allLoadingPoints
        .where((loadingPoint) =>
            loadingPoint.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TypeAheadField<String>(
        suggestionsCallback: (pattern) async {
          if (_allLoadingPoints.isEmpty && !_isLoading) {
            await _fetchLoadingPoints();  // Fetch data if not already fetched
          }
          return _getSuggestionsLoadingPoints(pattern, _allLoadingPoints);
        },
        hideOnSelect: true,
        constraints: BoxConstraints(maxHeight: 300),
        builder: (context, controller, focusNode) {
          controller.text = widget.selectedLoadingPoint;
          return TextField(
            controller: controller,
            focusNode: focusNode,
            decoration: InputDecoration(
              labelText: "Search Loading Point",
              border: OutlineInputBorder(),
              suffixIcon: Icon(Icons.search),
            ),
          );
        },
        itemBuilder: (context, suggestion) {
          return ListTile(
            title: Text(suggestion),
          );
        },
        onSelected: (suggestion) {
          setState(() {
            _selectedLoadingPoint = suggestion;
            widget.controller.text = suggestion;
          });
          FocusScope.of(context).unfocus();
        },
      ),
    );
  }
}
