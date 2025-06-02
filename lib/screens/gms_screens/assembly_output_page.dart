import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/gms_screens/production_data_model.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AssemblyOutputPage extends StatefulWidget {
  final LoginModelApi userData;
  const AssemblyOutputPage({Key? key, required this.userData})
      : super(key: key);

  @override
  _AssemblyOutputPageState createState() => _AssemblyOutputPageState();
}

class _AssemblyOutputPageState extends State<AssemblyOutputPage> {
  final TextEditingController _deptSearchController = TextEditingController();
  final TextEditingController _apcMxkSearchController = TextEditingController();
  List<Map<String, String>> deptNames = [];
  List<Map<String, String>> companyLists = [];
  String? selectedApcMxk;
  String? selectedDeptId;
  List<Map<String, dynamic>> departmentData = [];
  List<Map<String, dynamic>> filteredDepartmentData = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  List<Department> summaryList = [];
  @override
  void initState() {
    super.initState();
    fetchProductionData();
  }

  Future<void> fetchProductionData() async {
    setState(() {
      isLoading = true;
    });
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    // final url = Uri.parse(
    //     'http://10.3.0.70:9042/api/Production/get-production?date=$formattedDate');

    var apiUrl = '${ApiHelper.productionUrl}get-production?date=$formattedDate';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        // print('Production Data ${response.body}');
        // final departments = jsonData['departmentList'] as List<dynamic>;
        // final companies = jsonData['companyList'] as List<dynamic>;
        // final departmentsApiData =
        //     jsonData['departments'] as List<dynamic>; // <-- updated key

        print('Production Data: $jsonData');

        // Store full response in one object
        // final productionData = ProductionResponse.fromJson(jsonData);
        final productionData = ProductionDataModel.fromJson(jsonData);

        setState(() {
          deptNames = productionData.departmentList
              .map<Map<String, String>>(
                  (e) => {'id': e.toString(), 'name': e.toString()})
              .toList();

          companyLists = productionData.companyList
              .map<Map<String, String>>(
                  (e) => {'id': e.toString(), 'name': e.toString()})
              .toList();
          // departmentData = departmentsApiData.cast<Map<String, dynamic>>();

          // departmentData = productionData.departments;
          departmentData =
              productionData.departments.map((e) => e.toJson()).toList();
          filteredDepartmentData = departmentData; // initialize with full data
          summaryList = productionData.summary;
        });
      } else {
        print("Failed to load data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  // void filterDepartmentData() {
  //   setState(() {
  //     filteredDepartmentData = departmentData.where((dept) {
  //       final matchesDept = selectedDeptId == null ||
  //           dept['udf05'].toString() == selectedDeptId;
  //       // final matchesCompany = selectedApcMxk == null ||
  //       //     dept['companyList'].toString() == selectedApcMxk;
  //       return matchesDept ;
  //     }).toList();
  //   });
  // }
  // void filterDepartmentData() {
  //   setState(() {
  //     if (selectedDeptId == null || selectedDeptId == "ALL") {
  //       // Show all departments
  //       filteredDepartmentData = departmentData;
  //     } else {
  //       // Filter by selected department
  //       filteredDepartmentData = departmentData.where((dept) {
  //         return dept['udf05'].toString() == selectedDeptId;
  //       }).toList();
  //     }
  //   });
  // }

  void filterDepartmentData() {
    setState(() {
      final selectedDateString = DateFormat('yyyy/MM/dd').format(selectedDate);

      filteredDepartmentData = departmentData.where((dept) {
        final matchesDept = selectedDeptId == null ||
            selectedDeptId == "ALL" ||
            dept['udf05'].toString() == selectedDeptId;

        final matchesDate = dept['scanDate'].toString() == selectedDateString;

        return matchesDept && matchesDate;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    return Scaffold(
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : // Your normal UI here
            SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// Heading
                    const Text(
                      'APC Assembly Output Daily Tracking Report',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Text('Selected Date',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(child: Text(formattedDate)),
                        IconButton(
                          icon: const Icon(Icons.calendar_today,
                              color: Colors.lightGreen),
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2000),
                              lastDate: DateTime.now(),
                            );
                            if (picked != null) {
                              setState(() => selectedDate = picked);
                              fetchProductionData();
                              filterDepartmentData(); // Then apply filters
                            }
                          },
                        )
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// DropDownSearchField: Bases / Departments
                    const Text('Select Plant'),
                    const SizedBox(
                      height: 20,
                    ),
                    DropDownSearchField(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _deptSearchController,
                        autofocus: false,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          labelText: "Search Plant",
                          suffixIcon: Icon(Icons.search),
                        ),
                        onChanged: (text) {
                          setState(() {
                            if (text.isEmpty) selectedDeptId = null;
                          });
                        },
                      ),
                      suggestionsCallback: (pattern) async {
                        if (pattern.isEmpty) return deptNames;
                        return deptNames.where((item) {
                          final combined =
                              '${item['name']} (${item['id']})'.toLowerCase();
                          return combined.contains(pattern.toLowerCase());
                        }).toList();
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          leading: const Icon(Icons.place_outlined),
                          title: Text('${suggestion['name']}'),
                        );
                      },
                      onSuggestionSelected: (suggestion) {
                        setState(() {
                          selectedDeptId = suggestion['id'];
                          _deptSearchController.text = '${suggestion['name']}';
                        });
                        filterDepartmentData();
                      },
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                    ),
                    const SizedBox(height: 10),

                    /// Dropdown for APC / MXK
                    // const Text('Select Company'),
                    // const SizedBox(
                    //   height: 20,
                    // ),
                    // DropDownSearchField(
                    //   textFieldConfiguration: TextFieldConfiguration(
                    //     controller: _apcMxkSearchController,
                    //     decoration: const InputDecoration(
                    //       border: OutlineInputBorder(
                    //           borderRadius: BorderRadius.all(Radius.circular(10))),
                    //       labelText: "Search APC / MXK",
                    //       suffixIcon: Icon(Icons.search),
                    //     ),
                    //   ),
                    //   suggestionsCallback: (pattern) async {
                    //     if (pattern.isEmpty) return companyLists;
                    //     return companyLists.where((item) {
                    //       return item['name']!
                    //           .toLowerCase()
                    //           .contains(pattern.toLowerCase());
                    //     }).toList();
                    //   },
                    //   itemBuilder: (context, suggestion) {
                    //     return ListTile(
                    //       leading: const Icon(Icons.list),
                    //       title: Text(suggestion['name']!),
                    //     );
                    //   },
                    //   onSuggestionSelected: (suggestion) {
                    //     setState(() {
                    //       selectedApcMxk = suggestion['id'];
                    //       _apcMxkSearchController.text = suggestion['name']!;
                    //     });
                    //     filterDepartmentData();
                    //   },
                    //   displayAllSuggestionWhenTap: true,
                    //   isMultiSelectDropdown: false,
                    // ),

                    // if (departmentData.isNotEmpty) ...[
                    //   const SizedBox(height: 20),
                    //   const Text(
                    //     'Department Production Table',
                    //     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    //   ),
                    //   SingleChildScrollView(
                    //     scrollDirection: Axis.horizontal,
                    //     child: DataTable(
                    //       columns: const [
                    //         DataColumn(label: Text('Scan Date')),
                    //         DataColumn(label: Text('Department')),
                    //         DataColumn(label: Text('Target')),
                    //         DataColumn(label: Text('Achieved Output')),
                    //         DataColumn(label: Text('Balance')),
                    //         DataColumn(label: Text('Achievement %')),
                    //       ],
                    //       // rows: departmentData.map((dept) {
                    //       rows: filteredDepartmentData.map((dept) {
                    //         return DataRow(cells: [
                    //           DataCell(Text(dept['scanDate'].toString())),
                    //           DataCell(Text(dept['udf05'].toString())),
                    //           DataCell(Text(dept['target'].toString())),
                    //           DataCell(Text(dept['output'].toString())),
                    //           DataCell(Text(dept['achievement'].toString())),
                    //           DataCell(Text(dept['achievementPercent'].toString())),
                    //         ]);
                    //       }).toList(),
                    //     ),
                    //   ),
                    // ]

                    if (filteredDepartmentData.isNotEmpty) ...[
                      // const SizedBox(height: 20),
                      // Text(
                      //   'Department Production Summary',
                      //   style: Theme.of(context).textTheme.headlineSmall,
                      // ),
                      // ListView.builder(
                      //   shrinkWrap: true,
                      //   physics: const NeverScrollableScrollPhysics(),
                      //   itemCount: filteredDepartmentData.length,
                      //   itemBuilder: (context, index) {
                      //     final dept = filteredDepartmentData[index];
                      //     return Card(
                      //       elevation: 4,
                      //       margin: const EdgeInsets.symmetric(
                      //         vertical: 8,
                      //       ),
                      //       shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12),
                      //       ),
                      //       child: Padding(
                      //         padding: const EdgeInsets.symmetric(
                      //             vertical: 16, horizontal: 20),
                      //         child: Column(
                      //           crossAxisAlignment: CrossAxisAlignment.center,
                      //           children: [
                      //             Row(
                      //               mainAxisAlignment:
                      //                   MainAxisAlignment.spaceBetween,
                      //               children: [
                      //                 Text(
                      //                   dept['udf05'].toString(),
                      //                   style: const TextStyle(
                      //                     fontWeight: FontWeight.w700,
                      //                     fontSize: 18,
                      //                     color: Colors.blueAccent,
                      //                   ),
                      //                 ),
                      //                 IconButton(
                      //                     onPressed: () {},
                      //                     icon: Icon(Icons.expand_more))
                      //               ],
                      //             ),
                      //             const SizedBox(height: 8),
                      //             const Divider(
                      //               color: Colors.grey,
                      //               thickness: 1,
                      //             ),
                      //             const SizedBox(height: 12),
                      //             _buildInfoText('Target', dept['target']),
                      //             _buildInfoText(
                      //                 'Achieved Output', dept['output']),
                      //             _buildInfoText(
                      //               'Balance',
                      //               dept['achievement'],
                      //               valueColor: int.tryParse(dept['achievement']
                      //                               .toString()) !=
                      //                           null &&
                      //                       int.parse(dept['achievement']
                      //                               .toString()) >=
                      //                           0
                      //                   ? Colors.green
                      //                   : Colors.red,
                      //             ),
                      //             _buildInfoText(
                      //               'Achievement %',
                      //               dept['achievementPercent'],
                      //               valueColor: _parseAchievementPercent(
                      //                           dept['achievementPercent']) >=
                      //                       100
                      //                   ? Colors.green
                      //                   : Colors.red,
                      //             ),
                      //           ],
                      //         ),
                      //       ),
                      //     );
                      //   },
                      // ),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: filteredDepartmentData.length,
                        itemBuilder: (context, index) {
                          final dept = filteredDepartmentData[index];
                          bool isExpanded = false;

                          return StatefulBuilder(
                            builder: (context, setState) {
                              return Card(
                                elevation: 4,
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 16, horizontal: 20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Header Row with toggle button
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                Text(
                                                  dept['udf05'].toString(),
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 18,
                                                    color: Colors.blueAccent,
                                                  ),
                                                ),
                                                const SizedBox(
                                                    width:
                                                        60), // spacing between the two texts
                                                const Text(
                                                  'Line Wise Info',
                                                  style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                    color: Colors.black87,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(
                                              isExpanded
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                            ),
                                            onPressed: () {
                                              setState(() {
                                                isExpanded = !isExpanded;
                                              });
                                            },
                                          ),
                                        ],
                                      ),

                                      const Divider(
                                          color: Colors.grey, thickness: 1),
                                      const SizedBox(height: 12),
                                      _buildInfoText('Target', dept['target']),
                                      _buildInfoText(
                                          'Achieved Output', dept['output']),
                                      _buildInfoText(
                                        'Balance',
                                        dept['achievement'],
                                        valueColor: int.tryParse(
                                                        dept['achievement']
                                                            .toString()) !=
                                                    null &&
                                                int.parse(dept['achievement']
                                                        .toString()) >=
                                                    0
                                            ? Colors.green
                                            : Colors.red,
                                      ),
                                      _buildInfoText(
                                        'Achievement %',
                                        dept['achievementPercent'],
                                        valueColor: _parseAchievementPercent(
                                                    dept[
                                                        'achievementPercent']) >=
                                                100
                                            ? Colors.green
                                            : Colors.red,
                                      ),

                                      // Expandable Section
                                      if (isExpanded) ...[
                                        const SizedBox(height: 16),
                                        const Text(
                                          'Team Members:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text('- Yuvi'),
                                        const Text('- Yuva'),
                                        const Text('- Vijay'),
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      )
                    ],
                    const SizedBox(
                      height: 10,
                    ),
                    ...summaryList.map((item) {
                      final achievementColor =
                          item.achievement >= 0 ? Colors.green : Colors.red;

                      final achievementPercentValue =
                          _parseAchievementPercent(item.achievementPercent);
                      final percentColor = achievementPercentValue >= 100
                          ? Colors.green
                          : Colors.red;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        elevation: 3,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.udf05,
                                style: const TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              const Divider(
                                color: Colors.grey,
                                thickness: 1,
                              ),
                              const SizedBox(height: 18),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildSummaryLabel(
                                      "Target", item.target.toString()),
                                  _buildSummaryLabel(
                                      "Output", item.output.toString()),
                                  _buildSummaryLabel(
                                    "Achievement",
                                    item.achievement.toString(),
                                    valueColor: achievementColor,
                                  ),
                                  _buildSummaryLabel(
                                    "%",
                                    item.achievementPercent,
                                    valueColor: percentColor,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
      ),
    );
  }

  int _parseAchievementPercent(String percentStr) {
    return int.tryParse(percentStr.replaceAll('%', '').trim()) ?? 0;
  }
}

Widget _buildInfoText(String label, dynamic value, {Color? valueColor}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 4),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160, // Fixed width for labels (adjust as needed)
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value.toString(),
            style: TextStyle(
              fontWeight: FontWeight.normal,
              color: valueColor ?? Colors.black87,
              fontSize: 16,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _buildSummaryLabel(String label, String value, {Color? valueColor}) {
  return Column(
    children: [
      Text(label,
          style: const TextStyle(
              color: Colors.black, fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          color: valueColor ?? Colors.black87,
        ),
      ),
    ],
  );
}
