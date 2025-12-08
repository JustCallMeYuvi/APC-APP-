import 'package:animated_movies_app/model/emp_count_model.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_charts/charts.dart';

class EmpCountScreen extends StatefulWidget {
  final LoginModelApi userData;

  const EmpCountScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<EmpCountScreen> createState() => _EmpCountScreenState();
}

class _EmpCountScreenState extends State<EmpCountScreen> {
  int _totalActive = 0;
  // TYPE dropdown
  final TextEditingController _typeController = TextEditingController();
  final List<String> _typeOptions = [
    'All Years',
    'All Months of Year',
    'Month Wise',
  ];

  // UI selected value (label)
  String _selectedType = 'All Years';

  // Map UI label -> API value
  final Map<String, String> _typeApiMap = {
    'All Years': 'allyears',
    'All Months of Year': 'allmonthsofyear',
    'Month Wise': 'monthwise',
  };

  // YEAR dropdown
  final TextEditingController _yearController = TextEditingController();
  late List<String> _yearOptions;
  String? _selectedYear;

  // MONTH dropdown
  final TextEditingController _monthController = TextEditingController();
  final List<String> _monthOptions = [
    '1',
    '2',
    '3',
    '4',
    '5',
    '6',
    '7',
    '8',
    '9',
    '10',
    '11',
    '12',
  ];
  String? _selectedMonth;

  // Chart data
  // List<EmpCount> _chartData = [];
  // Chart data
  List<Datum> _chartData = [];

  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();

    // Default values
    _selectedType = 'All Years';
    _typeController.text = _selectedType;

    _yearOptions = List.generate(10, (i) => (2020 + i).toString());
    _selectedYear = DateTime.now().year.toString();
    _yearController.text = _selectedYear!;

    _selectedMonth = DateTime.now().month.toString();
    _monthController.text = _selectedMonth!;

    _fetchEmpCount(); // initial load
  }

  @override
  void dispose() {
    _typeController.dispose();
    _yearController.dispose();
    _monthController.dispose();
    super.dispose();
  }

  Future<void> _fetchEmpCount() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    const baseUrl = 'http://10.3.0.70:9042/api/HR/EmpCount';
    late Uri uri;

    // Convert UI text -> API type
    final apiType = _typeApiMap[_selectedType] ?? 'allyears';

    if (apiType == 'allyears') {
      uri = Uri.parse('$baseUrl?type=allyears');
    } else if (apiType == 'allmonthsofyear') {
      if (_selectedYear == null) {
        setState(() {
          _isLoading = false;
          _error = 'Please select a year';
        });
        return;
      }
      uri = Uri.parse('$baseUrl?type=allmonthsofyear&year=$_selectedYear');
    } else {
      // monthwise
      if (_selectedYear == null || _selectedMonth == null) {
        setState(() {
          _isLoading = false;
          _error = 'Please select year and month';
        });
        return;
      }
      uri = Uri.parse(
        '$baseUrl?type=monthwise&year=$_selectedYear&month=$_selectedMonth',
      );
    }

    try {
      print("==========================================");
      print("📡 API CALL -> $uri");
      final response = await http.get(uri);
      print("📥 STATUS CODE: ${response.statusCode}");
      print("📥 RAW RESPONSE:");
      print(response.body);
      print("==========================================");

      if (response.statusCode == 200) {
        // ✅ Use your model parser
        // final List<EmpCount> list = empCountFromJson(response.body);
        final EmpCount empCount = empCountFromJson(response.body);

        // setState(() {
        //   _chartData = list;
        //   _isLoading = false;
        // });
        setState(() {
          _chartData = empCount.data; // 👈 this is List<Datum>
          _totalActive = empCount.totalActive; // 👈 Save total active
          _isLoading = false;
        });

        print("✅ Chart data length: ${_chartData.length}");
      } else {
        setState(() {
          _isLoading = false;
          _error = 'Server error: ${response.statusCode}';
        });
      }
    } catch (e) {
      print("❌ ERROR OCCURRED: $e");

      setState(() {
        _isLoading = false;
        _error = 'Failed to load data: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Use apiType here also for visibility
    final apiType = _typeApiMap[_selectedType] ?? 'allyears';

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // TYPE DROPDOWN (search)
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _typeController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Select Type",
                  suffixIcon: Icon(Icons.arrow_drop_down),
                ),
              ),
              suggestionsCallback: (pattern) async {
                return _typeOptions
                    .where((option) =>
                        option.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(title: Text(suggestion));
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  _selectedType = suggestion; // UI label
                  _typeController.text = suggestion;
                });
                _fetchEmpCount();
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),

            const SizedBox(height: 12),

            // YEAR DROPDOWN (visible for allmonthsofyear & monthwise)
            if (apiType == 'allmonthsofyear' || apiType == 'monthwise') ...[
              DropDownSearchField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _yearController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Year",
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return _yearOptions
                      .where((option) =>
                          option.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _selectedYear = suggestion;
                    _yearController.text = suggestion;
                  });
                  _fetchEmpCount();
                },
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: false,
              ),
              const SizedBox(height: 12),
            ],

            // MONTH DROPDOWN (only for monthwise)
            if (apiType == 'monthwise') ...[
              DropDownSearchField(
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _monthController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Select Month",
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                ),
                suggestionsCallback: (pattern) async {
                  return _monthOptions
                      .where((option) =>
                          option.toLowerCase().contains(pattern.toLowerCase()))
                      .toList();
                },
                itemBuilder: (context, suggestion) {
                  return ListTile(title: Text(suggestion));
                },
                onSuggestionSelected: (suggestion) {
                  setState(() {
                    _selectedMonth = suggestion;
                    _monthController.text = suggestion;
                  });
                  _fetchEmpCount();
                },
                displayAllSuggestionWhenTap: true,
                isMultiSelectDropdown: false,
              ),
              const SizedBox(height: 12),
            ],

            // SEARCH / LOAD BUTTON
            // ElevatedButton(
            //   style: ElevatedButton.styleFrom(
            //     padding:
            //         const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     backgroundColor: Colors.transparent,
            //     shadowColor: Colors.black.withOpacity(0.3),
            //   ).copyWith(
            //     backgroundColor: WidgetStateProperty.resolveWith(
            //       (states) => null, // Removes default color
            //     ),
            //   ),
            //   onPressed: _fetchEmpCount,
            //   child: Ink(
            //     decoration: BoxDecoration(
            //       gradient: const LinearGradient(
            //         colors: [Color(0xFF6A5AE0), Color(0xFF8A7DFF)],
            //       ),
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Container(
            //       padding:
            //           const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            //       child: const Row(
            //         mainAxisSize: MainAxisSize.min,
            //         children: [
            //           Icon(Icons.search, color: Colors.white),
            //           SizedBox(width: 8),
            //           Text(
            //             "Search",
            //             style: TextStyle(color: Colors.white, fontSize: 16),
            //           ),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),

            const SizedBox(height: 8),
            Container(
              height: 50, // passport-size look
              width: double.infinity, // same width → makes it a square
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.shade300,
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Active Employees",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(width: 25),
                  Text(
                    _totalActive.toString(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 08,
            ),
            // RANGE COLUMN CHART SECTION
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_error != null)
              Expanded(
                child: Center(
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              )
            else
              Expanded(
                child: _chartData.isEmpty
                    ? const Center(child: Text('No data'))
                    : SfCartesianChart(
                        primaryXAxis: const CategoryAxis(),
                        primaryYAxis: const NumericAxis(),
                        title: const ChartTitle(text: 'Employee Count'),
                        tooltipBehavior: TooltipBehavior(enable: true),
                        // series: <CartesianSeries<EmpCount, String>>[
                        //   // 🔹 totalJoined as RangeColumn (0 -> totalJoined)
                        //   RangeColumnSeries<EmpCount, String>(
                        //     dataSource: _chartData,
                        //     xValueMapper: (EmpCount data, _) =>
                        //         data.year.toString(),
                        //     lowValueMapper: (EmpCount data, _) => 0,
                        //     highValueMapper: (EmpCount data, _) =>
                        //         data.totalJoined.toDouble(),
                        //     dataLabelSettings:
                        //         const DataLabelSettings(isVisible: true),
                        //   ),
                        // ],
                        series: <CartesianSeries<Datum, String>>[
                          RangeColumnSeries<Datum, String>(
                            dataSource: _chartData,
                            xValueMapper: (Datum data, _) =>
                                data.year.toString(),
                            lowValueMapper: (Datum data, _) => 0,
                            highValueMapper: (Datum data, _) =>
                                data.totalJoined.toDouble(),
                            dataLabelSettings:
                                const DataLabelSettings(isVisible: true),
                          ),
                        ],
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
