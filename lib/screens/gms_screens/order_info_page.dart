import 'dart:convert';

import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class OrderInfoPage extends StatefulWidget {
  final LoginModelApi userData;
  const OrderInfoPage({Key? key, required this.userData}) : super(key: key);

  @override
  _OrderInfoPageState createState() => _OrderInfoPageState();
}

class _OrderInfoPageState extends State<OrderInfoPage> {
  final TextEditingController _companyController = TextEditingController();
  final TextEditingController _yearController = TextEditingController();
  final TextEditingController _seasonController = TextEditingController();
  final TextEditingController _monthController = TextEditingController();
  final TextEditingController _typeController = TextEditingController();

  String? selectedCompany;
  // int? selectedCompanyId;
  Object?
      selectedCompanyId; // or dynamic This way you can store both int and String values.
  String? selectedYear;
  String? selectedSeason;
  String? selectedMonth;
  String _dateSelectionMode = 'Season'; // or 'Month'
  late Map<String, int> monthNameToNumber;
  late List<String> months;

  List<Map<String, dynamic>> fetchedOrders = [];
  bool isLoading = false;

  final List<Map<String, dynamic>> companies = [
    {'name': 'ALL', 'id': 'ALL'},
    {'name': 'APC', 'id': '5000'},
    {'name': 'Maxking', 'id': '5010'},
  ];

  final List<String> seasons = [
    'ALL',
    'Spring Summer',
    'Following Winter',
  ];

  late final List<String> years;

  // final List<String> months = List.generate(
  //   12,
  //   (index) => DateFormat.MMMM().format(DateTime(0, index + 1)),
  // );

  @override
  void initState() {
    super.initState();
    final currentYear = DateTime.now().year;
    years = [currentYear.toString(), (currentYear - 1).toString()];
    _yearController.text = years.first;

    // Create map like {'Jan': 1, 'Feb': 2, ...}
    monthNameToNumber = {
      for (var i = 01; i <= 12; i++) DateFormat.MMM().format(DateTime(0, i)): i,
    };

    months = monthNameToNumber.keys.toList();
  }

  Future<List<Map<String, dynamic>>> fetchOrderInfo() async {
    String baseUrl = 'http://10.3.0.70:9042/api/Production/get-Order-Info';
    String company = selectedCompanyId.toString(); // handle int or string
    String year = selectedYear ?? DateTime.now().year.toString();
    String type = _typeController.text;
    String season = type == 'Season' ? selectedSeason ?? 'null' : 'null';
    String month = 'null';

    if (type == 'Month' && selectedMonth != null) {
      int? numericMonth = monthNameToNumber[selectedMonth!];
      if (numericMonth != null) {
        month = numericMonth.toString().padLeft(2, '0'); // e.g., 05
      }
    }

    final Uri uri = Uri.parse(
      '$baseUrl?company=$company&year=$year&season=$season&month=$month&type=$type',
    );

    final response = await http.get(uri);
    print('Order INfo Url $uri');
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      throw Exception('Failed to fetch order info');
    }
  }

  Widget buildOrderCard(Map<String, dynamic> order) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Model: ${order['model']}",
                style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Plant: ${order['plant']}"),
            Text("Quantity: ${order['quantity']}"),
            Text("Month: ${order['month']}"),
            Text("Article: ${order['artile']}"),
            Text("Percentage: ${order['percentage']}%"),
            Text("Total Quantity: ${order['totalQuantity']}"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              /// Company DropdownSearch
              DropDownSearchField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _companyController,
                  decoration: const InputDecoration(
                    labelText: "Select Company",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return companies
                      .map((e) => e['name'] as String)
                      .where((name) =>
                          name.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSuggestionSelected: (suggestion) {
                  final selected =
                      companies.firstWhere((e) => e['name'] == suggestion);
                  setState(() {
                    selectedCompany = suggestion;
                    selectedCompanyId = selected['id'];
                    _companyController.text = suggestion;
                  });
                },
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: false,
              ),

              const SizedBox(height: 16),

              DropdownSearch<String>(
                items: years,
                selectedItem: selectedYear,
                dropdownDecoratorProps: const DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    labelText: "Select Year",
                    border: OutlineInputBorder(),
                    // suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    selectedYear = value!;
                  });
                },
              ),

              const SizedBox(height: 16),

              DropDownSearchField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _typeController,
                  decoration: const InputDecoration(
                    labelText: "Select Type",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.category),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return ['Season', 'Month']
                      .where((type) =>
                          type.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _dateSelectionMode = suggestion;
                    _typeController.text = suggestion;
                    selectedSeason = null;
                    selectedMonth = null;
                    _seasonController.clear();
                    _monthController.clear();
                  });
                },
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: false,
              ),

              const SizedBox(height: 16),

              if (_dateSelectionMode == 'Season')
                DropDownSearchField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _seasonController,
                    decoration: const InputDecoration(
                      labelText: "Select Season",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.wb_sunny),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return seasons
                        .where((s) =>
                            s.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(title: Text(suggestion));
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedSeason = suggestion;
                      _seasonController.text = suggestion;
                    });
                  },
                  displayAllSuggestionWhenTap: true,
                  isMultiSelectDropdown: false,
                )
              else
                DropDownSearchField(
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _monthController,
                    decoration: const InputDecoration(
                      labelText: "Select Month",
                      border: OutlineInputBorder(),
                      suffixIcon: Icon(Icons.calendar_month),
                    ),
                  ),
                  suggestionsCallback: (pattern) async {
                    return months
                        .where((m) =>
                            m.toLowerCase().contains(pattern.toLowerCase()))
                        .toList();
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(title: Text(suggestion));
                  },
                  onSuggestionSelected: (suggestion) {
                    setState(() {
                      selectedMonth = suggestion;
                      _monthController.text = suggestion;
                    });
                  },
                  displayAllSuggestionWhenTap: true,
                  isMultiSelectDropdown: false,
                ),
              const SizedBox(
                height: 10,
              ),
              ElevatedButton(
                onPressed: () async {
                  setState(() {
                    isLoading = true;
                  });
                  try {
                    final data = await fetchOrderInfo();
                    setState(() {
                      fetchedOrders = data;
                      isLoading = false;
                    });
                  } catch (e) {
                    setState(() {
                      isLoading = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error fetching data: $e')),
                    );
                  }
                },
                child: const Text("Fetch Orders"),
              ),
              const SizedBox(height: 16),

              isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : fetchedOrders.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: fetchedOrders.length,
                          itemBuilder: (context, index) {
                            return buildOrderCard(fetchedOrders[index]);
                          },
                        )
                      : const Text("No data fetched yet."),
            ],
          ),
        ),
      ),
    );
  }
}
