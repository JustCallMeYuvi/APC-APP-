import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  int? selectedCompanyId;
  String? selectedYear;
  String? selectedSeason;
  String? selectedMonth;
  String _dateSelectionMode = 'Season'; // or 'Month'
  late Map<String, int> monthNameToNumber;
  late List<String> months;

  final List<Map<String, dynamic>> companies = [
    {'name': 'APC', 'id': 5000},
    {'name': 'Maxking', 'id': 5001},
  ];

  final List<String> seasons = [
    'All',
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
      for (var i = 1; i <= 12; i++) DateFormat.MMM().format(DateTime(0, i)): i,
    };

    months = monthNameToNumber.keys.toList();
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

              /// Year DropdownSearch
              // DropDownSearchField(
              //   textFieldConfiguration: TextFieldConfiguration(
              //     controller: _yearController,
              //     decoration: const InputDecoration(
              //       labelText: "Select Year",
              //       border: OutlineInputBorder(),
              //       suffixIcon: Icon(Icons.calendar_today),
              //     ),
              //   ),
              //   suggestionsCallback: (pattern) async {
              //     return years
              //         .where((y) =>
              //             y.toLowerCase().contains(pattern.toLowerCase()))
              //         .toList();
              //   },
              //   itemBuilder: (context, suggestion) {
              //     return ListTile(title: Text(suggestion));
              //   },
              //   onSuggestionSelected: (suggestion) {
              //     setState(() {
              //       selectedYear = suggestion;
              //       _yearController.text = suggestion;
              //     });
              //   },
              //   displayAllSuggestionWhenTap: true,
              //   isMultiSelectDropdown: false,
              // ),
              /// Year Dropdown using dropdown_search
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

              /// Season DropdownSearch
              // DropDownSearchField(
              //   textFieldConfiguration: TextFieldConfiguration(
              //     controller: _seasonController,
              //     decoration: const InputDecoration(
              //       labelText: "Select Season",
              //       border: OutlineInputBorder(),
              //       suffixIcon: Icon(Icons.wb_sunny),
              //     ),
              //   ),
              //   suggestionsCallback: (pattern) async {
              //     return seasons
              //         .where((s) =>
              //             s.toLowerCase().contains(pattern.toLowerCase()))
              //         .toList();
              //   },
              //   itemBuilder: (context, suggestion) {
              //     return ListTile(title: Text(suggestion));
              //   },
              //   onSuggestionSelected: (suggestion) {
              //     setState(() {
              //       selectedSeason = suggestion;
              //       _seasonController.text = suggestion;
              //     });
              //   },
              //   displayAllSuggestionWhenTap: true,
              //   isMultiSelectDropdown: false,
              // ),

              // const SizedBox(height: 16),

              // /// Month DropdownSearch
              // DropDownSearchField(
              //   textFieldConfiguration: TextFieldConfiguration(
              //     controller: _monthController,
              //     decoration: const InputDecoration(
              //       labelText: "Select Month",
              //       border: OutlineInputBorder(),
              //       suffixIcon: Icon(Icons.calendar_month),
              //     ),
              //   ),
              //   suggestionsCallback: (pattern) async {
              //     return months
              //         .where((m) =>
              //             m.toLowerCase().contains(pattern.toLowerCase()))
              //         .toList();
              //   },
              //   itemBuilder: (context, suggestion) {
              //     return ListTile(title: Text(suggestion));
              //   },
              //   onSuggestionSelected: (suggestion) {
              //     setState(() {
              //       selectedMonth = suggestion;
              //       _monthController.text = suggestion;
              //     });
              //   },
              //   displayAllSuggestionWhenTap: true,
              //   isMultiSelectDropdown: false,
              // ),
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
            ],
          ),
        ),
      ),
    );
  }
}
