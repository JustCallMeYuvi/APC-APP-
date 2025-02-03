// import 'package:animated_movies_app/productionRequest.dart';
// import 'package:animated_movies_app/sign_approval_page.dart';
// import 'package:flutter/material.dart';

// class SkillMapping extends StatefulWidget {
//   const SkillMapping({Key? key}) : super(key: key);

//   @override
//   _SkillMappingState createState() => _SkillMappingState();
// }

// class _SkillMappingState extends State<SkillMapping> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Skills Mapping'),
//         actions: [],
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//               child: ElevatedButton(
//                   onPressed: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (context) => const ProductionRequestPage(
//                                 userCode: 'Admin',
//                                 userName: '70045',
//                               )),
//                     );
//                   },
//                   child: Text('Production Request'))),
//           SizedBox(
//             height: 10,
//           ),
//           ElevatedButton(
//               onPressed: () {
//                 Navigator.push(
//                   context,
//                   MaterialPageRoute(
//                       builder: (context) => const SignApprovalPage(
//                             userCode: 'Admin',
//                             userName: '70045',
//                           )),
//                 );
//               },
//               child: Text('Sign Approval Screen'))
//         ],
//       ),
//     );
//   }
// }
