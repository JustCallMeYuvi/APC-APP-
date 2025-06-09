import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/model/line_wise_production_data_model.dart';
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
  // final TextEditingController _apcMxkSearchController = TextEditingController();
  List<Map<String, String>> deptNames = [];
  List<Map<String, String>> companyLists = [];
  String? selectedApcMxk;
  String? selectedDeptId;
  List<Map<String, dynamic>> departmentData = [];
  List<Map<String, dynamic>> filteredDepartmentData = [];
  DateTime selectedDate = DateTime.now();
  bool isLoading = false;
  List<Department> summaryList = [];
  List<LineWiseDataModel> lineWiseDataList = [];
  // Add these variables inside your widget's State class:
  Map<int, bool> expandedItems = {};
  Map<int, List<LineWiseDataModel>> fetchedLineWiseData = {};
  Map<int, bool> loadingItems = {}; // index -> isLoading

  @override
  void initState() {
    super.initState();
    fetchProductionData();
    // fetchLineWiseData('AP1');
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

  // Future<void> fetchLineWiseData(String line, int index) async {
  //   // setState(() {
  //   //   isLoading = true;
  //   // });

  //   final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
  //   final apiUrl =
  //       '${ApiHelper.productionUrl}get-production-linedata?inputDate=$formattedDate&line=$line';

  //   try {
  //     final response = await http.get(Uri.parse(apiUrl));
  //     if (response.statusCode == 200) {
  //       final jsonData = response.body;
  //       final List<LineWiseDataModel> lineWiseData =
  //           lineWiseDataModelFromJson(jsonData);
  //       print('Line Wise Data: ${response.body}');
  //       setState(() {
  //         fetchedLineWiseData[index] = lineWiseData; // store per index
  //         expandedItems[index] = true; // mark as expanded
  //       });
  //     } else {
  //       print(
  //           "Failed to load line-wise data. Status code: ${response.statusCode}");
  //     }
  //   } catch (e) {
  //     print("Error fetching line-wise data: $e");
  //   } finally {
  //     // setState(() {
  //     //   isLoading = false;
  //     // });
  //   }
  // }

  Future<void> fetchLineWiseData(String line, int index) async {
    setState(() {
      loadingItems[index] = true;
    });

    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);
    final apiUrl =
        '${ApiHelper.productionUrl}get-production-linedata?inputDate=$formattedDate&line=$line';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = response.body;
        final List<LineWiseDataModel> lineWiseData =
            lineWiseDataModelFromJson(jsonData);

        setState(() {
          fetchedLineWiseData[index] = lineWiseData;
          expandedItems[index] = true;
        });
      } else {
        print("Failed to load line-wise data.");
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        loadingItems[index] = false;
      });
    }
  }

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
      // Reset expansion and fetched data when new filter applied
      expandedItems.clear();
      fetchedLineWiseData.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
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
                    const Center(
                      child: Text(
                        'APC Assembly Output Daily Tracking Report',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
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
                          final isExpanded = expandedItems[index] ?? false;
                          final lineWiseData = fetchedLineWiseData[index] ?? [];

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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                            // SizedBox(
                                            //   width: MediaQuery.of(context)
                                            //           .size
                                            //           .width *
                                            //       0.2, // 20% of screen width
                                            // ),
                                            SizedBox(
                                              width: screenWidth < 600
                                                  ? screenWidth * 0.2 // mobile
                                                  : screenWidth *
                                                      0.3, // tablet or larger
                                            ),
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
                                        color: Colors.red,
                                        icon: Icon(
                                          isExpanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                        ),
                                        onPressed: () {
                                          if (isExpanded) {
                                            // Collapse: update in outer setState
                                            setState(() {
                                              expandedItems[index] = false;
                                            });
                                          } else {
                                            // Expand and fetch data
                                            fetchLineWiseData(
                                                dept['udf05'].toString(),
                                                index);
                                          }
                                        },
                                      ),
                                    ],
                                  ),

                                  const Divider(
                                      color: Colors.grey, thickness: 1),
                                  const SizedBox(height: 12),
                                  _customPlantInfoText(
                                      '🎯 Target', dept['target']),
                                  _customPlantInfoText(
                                      '✅ Achieved Output', dept['output']),
                                  _customPlantInfoText(
                                    '📊 Balance',
                                    dept['achievement'],
                                    valueColor: int.tryParse(dept['achievement']
                                                    .toString()) !=
                                                null &&
                                            int.parse(dept['achievement']
                                                    .toString()) >=
                                                0
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  _customPlantInfoText(
                                    '🏆 Achievement %',
                                    dept['achievementPercent'],
                                    valueColor: _parseAchievementPercent(
                                                dept['achievementPercent']) >=
                                            100
                                        ? Colors.green
                                        : Colors.red,
                                  ),

                                  if (isExpanded) ...[
                                    const SizedBox(height: 16),
                                    const Text(
                                      'Line Wise Details:',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16),
                                    ),
                                    const SizedBox(height: 8),
                                    // isLoading
                                    //     ? const Center(
                                    //         child: CircularProgressIndicator())
                                    //     : lineWiseData.isEmpty
                                    //         ? const Text('No data available.')
                                    //         :

                                    if (loadingItems[index] == true)
                                      const Center(
                                          child: CircularProgressIndicator())
                                    else if (lineWiseData.isEmpty)
                                      const Text('No data available.')
                                    else
                                      ListView.builder(
                                        itemCount: lineWiseData.length,
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemBuilder: (context, i) {
                                          final data = lineWiseData[i];
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.grey
                                                          .withOpacity(0.15),
                                                      blurRadius: 8,
                                                      offset:
                                                          const Offset(0, 4),
                                                    ),
                                                  ],
                                                ),
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    _customLineWiseData(
                                                        '🏭 Line',
                                                        data.department,
                                                        valueColor:
                                                            Colors.blue),
                                                    const Divider(height: 20),
                                                    _customLineWiseData(
                                                        '📅 Date', data.date),
                                                    const Divider(height: 20),
                                                    _customLineWiseData(
                                                        '🎯 Target',
                                                        data.target.toString()),
                                                    const Divider(height: 20),
                                                    _customLineWiseData(
                                                        '📦 Output',
                                                        data.output.toString()),
                                                    const Divider(height: 20),
                                                    _customLineWiseData(
                                                      '📈 Achievement',
                                                      data.achievement
                                                          .toString(),
                                                      valueColor: int.tryParse(data
                                                                      .achievement
                                                                      .toString()) !=
                                                                  null &&
                                                              int.parse(data
                                                                      .achievement
                                                                      .toString()) >=
                                                                  0
                                                          ? Colors.green
                                                          : Colors.red,
                                                    ),
                                                    const Divider(height: 20),
                                                    _customLineWiseData(
                                                      '✅ Achievement %',
                                                      data.achievementPercent,
                                                      valueColor:
                                                          _parseAchievementPercent(
                                                                      data.achievementPercent) >=
                                                                  100
                                                              ? Colors.green
                                                              : Colors.red,
                                                    ),
                                                    const Divider(height: 20),
                                                    _customLineWiseData(
                                                        '👷‍♂️ Manpower',
                                                        data.manPower),
                                                  ],
                                                ),
                                              ),
                                              if (i != lineWiseData.length - 1)
                                                const Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      vertical: 8),
                                                  child: Divider(
                                                      color: Colors.grey),
                                                ),
                                            ],
                                          );
                                        },
                                      )
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
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
                                  _customSummaryLabel(
                                      "Target", item.target.toString()),
                                  _customSummaryLabel(
                                      "Output", item.output.toString()),
                                  _customSummaryLabel(
                                    "Achievement",
                                    item.achievement.toString(),
                                    valueColor: achievementColor,
                                  ),
                                  _customSummaryLabel(
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

  Widget _customLineWiseData(String label, dynamic value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 5,
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

  int _parseAchievementPercent(String percentStr) {
    return int.tryParse(percentStr.replaceAll('%', '').trim()) ?? 0;
  }
}

Widget _customPlantInfoText(String label, dynamic value, {Color? valueColor}) {
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

Widget _customSummaryLabel(String label, String value, {Color? valueColor}) {
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
