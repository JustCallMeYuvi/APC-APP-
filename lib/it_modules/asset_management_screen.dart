import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AssetManagementScreen extends StatefulWidget {
  final LoginModelApi userData;

  const AssetManagementScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  List<Map<String, String>> assetItems = [];

  List<String> assetIds = [];
  String? selectedAssetId;

  // final List<String> assetIds = ['A001', 'A002', 'A003', 'A004'];
  List<String> plantNames = [];
  String? selectedPlant;
  // final List<String> plantNames = [
  //   'Admin',
  //   'HR Buillding',
  //   'Plant1',
  //   'Plant2',
  //   'Plant3',
  //   'Plant4',
  //   'Plant5',
  // ];
  final List<String> networkIssues = [
    'No Internet',
    'Slow Speed',
    'Disconnected'
  ];
  final List<String> desktopIssues = [
    'Not Booting',
    'Blue Screen',
    'Keyboard Issue'
  ];
  @override
  void initState() {
    super.initState();
    fetchAssetDropdown();
    fetchPlantDropdown(); // fetch plants
  }

  Future<void> fetchAssetDropdown() async {
    const String url = 'http://10.3.0.70:9093/api/Login/GetAssetDropdown';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          assetItems = data.map<Map<String, String>>((item) {
            return {
              'id': item['asseT_ID'],
              'name': item['asseT_NAME'],
            };
          }).toList();
        });
      } else {
        print('Failed to load asset IDs. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching asset IDs: $e');
    }
  }

  DateTime selectedDate = DateTime.now();

  String selectedType = 'Network';
  String? selectedIssue;
  String? description;

  Future<void> fetchPlantDropdown() async {
    try {
      final response = await http.get(Uri.parse(
          'http://10.3.0.70:9093/api/Login/GetAssetLocationDropdown'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        // Combine plant and line names, then make them unique
        plantNames = data
            .map<String>(
                (item) => "${item['asseT_PLANT']} - ${item['asseT_LINE']}")
            .toSet()
            .toList();
        setState(() {});
      } else {
        throw Exception('Failed to load plant names');
      }
    } catch (e) {
      print('Error fetching plant dropdown: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

    return Scaffold(
      // appBar: AppBar(title: const Text("Asset Management")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    widget.userData.empNo,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 20),

                /// Date Picker
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
                        }
                      },
                    )
                  ],
                ),

                const SizedBox(height: 20),

                /// Asset ID Dropdown
                Text('Asset ID',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                DropdownButtonHideUnderline(
                    child: DropdownButton2<String>(
                  isExpanded: true,
                  hint: const Text('Select Asset ID'),
                  value: selectedAssetId,
                  items: assetItems.map((item) {
                    return DropdownMenuItem<String>(
                      value: item['id'],
                      child: Text('${item['name']} (${item['id']})'),
                    );
                  }).toList(),
                  onChanged: (value) => setState(() => selectedAssetId = value),
                  buttonStyleData: ButtonStyleData(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  dropdownStyleData: DropdownStyleData(
                    width: MediaQuery.of(context).size.width - 70,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                )),

                const SizedBox(height: 20),

                /// Plant Dropdown
                Text('Select Plant:',
                    style: Theme.of(context).textTheme.titleMedium),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: const Text('Select Plant'),
                    value: selectedPlant,
                    // items: plantNames.map((plant) {
                    //   return DropdownMenuItem(value: plant, child: Text(plant));
                    // }).toList(),
                    // onChanged: (value) => setState(() => selectedPlant = value),
                    items: plantNames.map((plant) {
                      return DropdownMenuItem(value: plant, child: Text(plant));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedPlant = value),
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      width: MediaQuery.of(context).size.width - 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                /// Type (Radio)
                Text('Select Type:',
                    style: Theme.of(context).textTheme.titleMedium),
                Row(
                  children: ['Network', 'Desktop'].map((type) {
                    return Row(
                      children: [
                        Radio<String>(
                          value: type,
                          groupValue: selectedType,
                          onChanged: (value) {
                            setState(() {
                              selectedType = value!;
                              selectedIssue = null;
                            });
                          },
                        ),
                        Text(type),
                      ],
                    );
                  }).toList(),
                ),

                const SizedBox(height: 10),

                /// Issue Dropdown
                Text('Issue', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 6),
                DropdownButtonHideUnderline(
                  child: DropdownButton2<String>(
                    isExpanded: true,
                    hint: const Text('Select an Issue'),
                    value: selectedIssue,
                    items: (selectedType == 'Network'
                            ? networkIssues
                            : desktopIssues)
                        .map((issue) {
                      return DropdownMenuItem(value: issue, child: Text(issue));
                    }).toList(),
                    onChanged: (value) => setState(() => selectedIssue = value),
                    buttonStyleData: ButtonStyleData(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      height: 50,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                      ),
                    ),
                    dropdownStyleData: DropdownStyleData(
                      width: MediaQuery.of(context).size.width - 70,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),

                /// Description
                if (selectedIssue != null) ...[
                  const SizedBox(height: 20),
                  Text('Description',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 6),
                  TextField(
                    onChanged: (value) => setState(() => description = value),
                    decoration: InputDecoration(
                      hintText: 'Describe the issue...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                    ),
                    maxLines: 3,
                  ),
                ],
                SizedBox(
                  height: 10,
                ),
                Center(
                  child: MaterialButton(
                    onPressed: () {
                      // Your logic here
                    },
                    color: Colors.blueAccent,
                    elevation: 6,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


// import 'package:animated_movies_app/it_modules/bloc/asset_bloc.dart';
// import 'package:animated_movies_app/it_modules/bloc/asset_event.dart';
// import 'package:animated_movies_app/it_modules/bloc/asset_state.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:intl/intl.dart';

// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';

// class AssetManagementScreen extends StatefulWidget {
//   final LoginModelApi userData;

//   const AssetManagementScreen({Key? key, required this.userData})
//       : super(key: key);

//   @override
//   State<AssetManagementScreen> createState() => _AssetManagementScreenState();
// }

// class _AssetManagementScreenState extends State<AssetManagementScreen> {
//   // final List<String> assetIds = ['A001', 'A002', 'A003', 'A004'];

//   final List<String> plantNames = [
//     'Admin',
//     'HR Buillding',
//     'Plant1',
//     'Plant2',
//     'Plant3',
//     'Plant4',
//     'Plant5',
//   ];
//   final List<String> networkIssues = [
//     'No Internet',
//     'Slow Speed',
//     'Disconnected'
//   ];
//   final List<String> desktopIssues = [
//     'Not Booting',
//     'Blue Screen',
//     'Keyboard Issue'
//   ];

//   String selectedType = 'Network';
//   String? selectedIssue;
//   String? selectedPlants;
//   late final String? email;
//   late final String? phone;
// @override
// void initState() {
//   super.initState();
//   context.read<AssetBloc>().add(FetchAssetIds());
// }
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => AssetBloc(),
//       child: Scaffold(
//         body: BlocBuilder<AssetBloc, AssetState>(
//           builder: (context, state) {
//             final formattedDate =
//                 DateFormat('yyyy-MM-dd').format(state.selectedDate);
//             return SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Card(
//                 elevation: 6,
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(20),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Center(
//                         child: Text(
//                           widget.userData.empNo,
//                           style: const TextStyle(
//                               fontSize: 20, fontWeight: FontWeight.bold),
//                         ),
//                       ),
//                       const SizedBox(
//                         height: 10,
//                       ),

//                       Text('Selected Date',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 6),
//                       Row(
//                         children: [
//                           Expanded(
//                             child: Text(formattedDate,
//                                 style: const TextStyle(fontSize: 16)),
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.calendar_today),
//                             color: Colors.lightGreen,
//                             onPressed: () async {
//                               final pickedDate = await showDatePicker(
//                                 context: context,
//                                 initialDate: state.selectedDate,
//                                 firstDate: DateTime(2000),
//                                 lastDate: DateTime.now(),
//                               );
//                               if (pickedDate != null) {
//                                 context
//                                     .read<AssetBloc>()
//                                     .add(DateChanged(pickedDate));
//                               }
//                             },
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 20),
//                       Text('Asset ID',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 6),
//                       state.assetIds.isEmpty
//                           ? const Center(child: CircularProgressIndicator())
//                           : 
//                           DropdownButtonHideUnderline(
//                               child: DropdownButton2<String>(
//                                 isExpanded: true,
//                                 hint: const Text('Select Asset ID'),
//                                 value: state.selectedAssetId,
//                                 // items: assetIds.map((String item) {
//                                 items: state.assetIds.map((String item) {
//                                   return DropdownMenuItem<String>(
//                                     value: item,
//                                     child: Text(item),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? value) {
//                                   if (value != null) {
//                                     context
//                                         .read<AssetBloc>()
//                                         .add(AssetIdChanged(value));
//                                   }
//                                 },
//                                 buttonStyleData: ButtonStyleData(
//                                   padding: const EdgeInsets.symmetric(
//                                       horizontal: 14),
//                                   height: 50,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                     border: Border.all(color: Colors.grey),
//                                   ),
//                                 ),
//                                 dropdownStyleData: DropdownStyleData(
//                                   width: MediaQuery.of(context).size.width - 70,
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.circular(10),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                       const SizedBox(height: 20),
//                       Text('Select Plant:',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       DropdownButtonHideUnderline(
//                         child: DropdownButton2<String>(
//                           isExpanded: true,
//                           hint: const Text('Select Plant'),
//                           value: selectedPlants,
//                           items: plantNames
//                               .map((plant) => DropdownMenuItem(
//                                     value: plant,
//                                     child: Text(plant),
//                                   ))
//                               .toList(),
//                           // onChanged: (value) {
//                           //   setState(() {
//                           //     selectedIssue = value;
//                           //   });
//                           // },
//                           onChanged: (value) {
//                             setState(() {
//                               selectedPlants = value;
//                             });
//                             if (value != null) {
//                               context
//                                   .read<AssetBloc>()
//                                   .add(PlantChanged(value));
//                             }
//                           },
//                           buttonStyleData: ButtonStyleData(
//                             padding: const EdgeInsets.symmetric(horizontal: 14),
//                             height: 50,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.grey),
//                             ),
//                           ),
//                           dropdownStyleData: DropdownStyleData(
//                             width: MediaQuery.of(context).size.width - 70,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       ),
//                       const SizedBox(height: 20),

//                       /// 1. Select Type (Radio buttons)
//                       Text('Select Type:',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       Row(
//                         children: ['Network', 'Desktop'].map((type) {
//                           return Row(
//                             children: [
//                               Radio<String>(
//                                 value: type,
//                                 groupValue: selectedType,
//                                 // onChanged: (value) {
//                                 //   setState(() {
//                                 //     selectedType = value!;
//                                 //     selectedIssue = null;
//                                 //   });
//                                 // },
//                                 onChanged: (value) {
//                                   setState(() {
//                                     selectedType = value!;
//                                     selectedIssue = null;
//                                   });
//                                   context
//                                       .read<AssetBloc>()
//                                       .add(AssetTypeChanged(value!));
//                                 },
//                               ),
//                               Text(type),
//                             ],
//                           );
//                         }).toList(),
//                       ),

//                       /// 2. Issue Dropdown
//                       const SizedBox(height: 10),
//                       Text('Issue',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 6),
//                       DropdownButtonHideUnderline(
//                         child: DropdownButton2<String>(
//                           isExpanded: true,
//                           hint: const Text('Select an Issue'),
//                           value: selectedIssue,
//                           items: (selectedType == 'Network'
//                                   ? networkIssues
//                                   : desktopIssues)
//                               .map((issue) => DropdownMenuItem(
//                                     value: issue,
//                                     child: Text(issue),
//                                   ))
//                               .toList(),
//                           // onChanged: (value) {
//                           //   setState(() {
//                           //     selectedIssue = value;
//                           //   });
//                           // },
//                           onChanged: (value) {
//                             setState(() {
//                               selectedIssue = value;
//                             });
//                             if (value != null) {
//                               context
//                                   .read<AssetBloc>()
//                                   .add(IssueTypeChanged(value));
//                             }
//                           },
//                           buttonStyleData: ButtonStyleData(
//                             padding: const EdgeInsets.symmetric(horizontal: 14),
//                             height: 50,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                               border: Border.all(color: Colors.grey),
//                             ),
//                           ),
//                           dropdownStyleData: DropdownStyleData(
//                             width: MediaQuery.of(context).size.width - 70,
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                           ),
//                         ),
//                       ),

//                       /// 3. Show Description only if issue is selected
//                       if (selectedIssue != null) ...[
//                         const SizedBox(height: 20),
//                         Text('Description',
//                             style: Theme.of(context).textTheme.titleMedium),
//                         const SizedBox(height: 6),
//                         TextField(
//                           onChanged: (value) {
//                             context
//                                 .read<AssetBloc>()
//                                 .add(DescriptionChanged(value));
//                           },
//                           decoration: InputDecoration(
//                             hintText: 'Describe the issue...',
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(10),
//                             ),
//                             contentPadding: const EdgeInsets.symmetric(
//                                 horizontal: 14, vertical: 12),
//                           ),
//                           maxLines: 3,
//                         ),
//                       ],
//                       // Text('Description',
//                       //     style: Theme.of(context).textTheme.titleMedium),
//                       // const SizedBox(height: 6),
//                       // TextField(
//                       //   onChanged: (value) {
//                       //     context
//                       //         .read<AssetBloc>()
//                       //         .add(DescriptionChanged(value));
//                       //   },
//                       //   decoration: InputDecoration(
//                       //     hintText: 'Enter description...',
//                       //     border: OutlineInputBorder(
//                       //       borderRadius: BorderRadius.circular(10),
//                       //     ),
//                       //     contentPadding: const EdgeInsets.symmetric(
//                       //         horizontal: 14, vertical: 12),
//                       //   ),
//                       //   maxLines: 3,
//                       // ),

//                       const SizedBox(height: 20),
//                       Text('Gmail',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 6),
//                       TextField(
//                         keyboardType: TextInputType.emailAddress,
//                         onChanged: (value) {
//                           context.read<AssetBloc>().add(EmailChanged(value));
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Enter Gmail address',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 14, vertical: 12),
//                         ),
//                       ),

//                       const SizedBox(height: 20),
//                       Text('Phone Number',
//                           style: Theme.of(context).textTheme.titleMedium),
//                       const SizedBox(height: 6),
//                       TextField(
//                         keyboardType: TextInputType.phone,
//                         onChanged: (value) {
//                           context.read<AssetBloc>().add(PhoneChanged(value));
//                         },
//                         decoration: InputDecoration(
//                           hintText: 'Enter Phone Number',
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               horizontal: 14, vertical: 12),
//                         ),
//                       ),

//                       const SizedBox(height: 30),
//                       Center(
//                         child: MaterialButton(
//                           onPressed: () {
//                             context.read<AssetBloc>().add(SubmitAsset());
//                           },
//                           color: Colors.blueAccent,
//                           textColor: Colors.white,
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 40, vertical: 16),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: const Text('Submit',
//                               style: TextStyle(
//                                   fontSize: 16, fontWeight: FontWeight.w600)),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     );
//   }
// }
