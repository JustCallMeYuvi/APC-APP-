// import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
// import 'package:dropdown_button2/dropdown_button2.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';

// class AssetManagementScreen extends StatefulWidget {
//   final LoginModelApi userData;
//   const AssetManagementScreen({Key? key, required this.userData})
//       : super(key: key);

//   @override
//   _AssetManagementScreenState createState() => _AssetManagementScreenState();
// }

// class _AssetManagementScreenState extends State<AssetManagementScreen> {
//   late DateTime selectedDate;
//   String? selectedAssetId;
//   List<String> assetIds = ['A001', 'A002', 'A003', 'A004'];
//   TextEditingController descriptionController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     selectedDate = DateTime.now();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime.now(),
//     );

//     if (picked != null) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final formattedDate = DateFormat('yyyy-MM-dd').format(selectedDate);

//     return Scaffold(
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Card(
//           elevation: 4,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: Padding(
//             padding: const EdgeInsets.all(20),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 // Date Picker Row
//                 Text(
//                   'Selected Date',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   children: [
//                     Expanded(
//                       child: Text(
//                         formattedDate,
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ),
//                     IconButton(
//                       icon: const Icon(Icons.calendar_today),
//                       color: Colors.lightGreen,
//                       onPressed: () => _selectDate(context),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 20),

//                 // Asset Dropdown
//                 Text(
//                   'Asset ID',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 const SizedBox(height: 6),
//                 DropdownButtonHideUnderline(
//                   child: DropdownButton2<String>(
//                     isExpanded: true,
//                     hint: const Text('Select Asset ID'),
//                     value: selectedAssetId,
//                     items: assetIds.map((String item) {
//                       return DropdownMenuItem<String>(
//                         value: item,
//                         child: Text(item),
//                       );
//                     }).toList(),
//                     onChanged: (String? value) {
//                       setState(() {
//                         selectedAssetId = value;
//                       });
//                     },
//                     buttonStyleData: ButtonStyleData(
//                       padding: const EdgeInsets.symmetric(horizontal: 14),
//                       height: 50,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                         border: Border.all(color: Colors.grey),
//                       ),
//                     ),
//                     dropdownStyleData: DropdownStyleData(
//                       width: MediaQuery.of(context).size.width - 70,
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),

//                 // Description TextField
//                 Text(
//                   'Description',
//                   style: Theme.of(context).textTheme.titleMedium,
//                 ),
//                 const SizedBox(height: 6),
//                 TextField(
//                   controller: descriptionController,
//                   decoration: InputDecoration(
//                     hintText: 'Enter description...',
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(10),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         horizontal: 14, vertical: 12),
//                   ),
//                   maxLines: 3,
//                 ),
//                 const SizedBox(height: 30),

//                 // Submit Button
//                 Center(
//                   child: MaterialButton(
//                     onPressed: () {
//                       // String assetId = selectedAssetId ?? 'None';
//                       // String description = descriptionController.text;

//                       // // Debug log
//                       // print('Asset ID: $assetId');
//                       // print('Description: $description');
//                     },
//                     color: Colors.blueAccent,
//                     textColor: Colors.white,
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 40, vertical: 16),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12),
//                     ),
//                     child: const Text(
//                       'Submit',
//                       style:
//                           TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//                     ),
//                   ),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:animated_movies_app/it_modules/bloc/asset_bloc.dart';
import 'package:animated_movies_app/it_modules/bloc/asset_event.dart';
import 'package:animated_movies_app/it_modules/bloc/asset_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class AssetManagementScreen extends StatefulWidget {
  final LoginModelApi userData;

  AssetManagementScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<AssetManagementScreen> createState() => _AssetManagementScreenState();
}

class _AssetManagementScreenState extends State<AssetManagementScreen> {
  final List<String> assetIds = ['A001', 'A002', 'A003', 'A004'];

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AssetBloc(),
      child: Scaffold(
        body: BlocBuilder<AssetBloc, AssetState>(
          builder: (context, state) {
            final formattedDate =
                DateFormat('yyyy-MM-dd').format(state.selectedDate);
            return SingleChildScrollView(
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
                      const SizedBox(
                        height: 10,
                      ),
                      Text('Selected Date',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(formattedDate,
                                style: const TextStyle(fontSize: 16)),
                          ),
                          IconButton(
                            icon: const Icon(Icons.calendar_today),
                            color: Colors.lightGreen,
                            onPressed: () async {
                              final pickedDate = await showDatePicker(
                                context: context,
                                initialDate: state.selectedDate,
                                firstDate: DateTime(2000),
                                lastDate: DateTime.now(),
                              );
                              if (pickedDate != null) {
                                context
                                    .read<AssetBloc>()
                                    .add(DateChanged(pickedDate));
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text('Asset ID',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      DropdownButtonHideUnderline(
                        child: DropdownButton2<String>(
                          isExpanded: true,
                          hint: const Text('Select Asset ID'),
                          value: state.selectedAssetId,
                          items: assetIds.map((String item) {
                            return DropdownMenuItem<String>(
                              value: item,
                              child: Text(item),
                            );
                          }).toList(),
                          onChanged: (String? value) {
                            if (value != null) {
                              context
                                  .read<AssetBloc>()
                                  .add(AssetIdChanged(value));
                            }
                          },
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
                      Text('Description',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 6),
                      TextField(
                        onChanged: (value) {
                          context
                              .read<AssetBloc>()
                              .add(DescriptionChanged(value));
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter description...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 12),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),
                      Center(
                        child: MaterialButton(
                          onPressed: () {
                            context.read<AssetBloc>().add(SubmitAsset());
                          },
                          color: Colors.blueAccent,
                          textColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text('Submit',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
