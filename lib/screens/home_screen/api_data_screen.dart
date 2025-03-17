// // api_data_screen.dart

// import 'package:flutter/material.dart';

// class ApiDataScreen extends StatelessWidget {
//   final String pageName;

//   const ApiDataScreen({Key? key, required this.pageName}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(pageName),
//         backgroundColor: Colors.lightGreen,
//       ),
//       body: Center(
//         child: Container(
//           padding: const EdgeInsets.all(16.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(10),
//             boxShadow: [
//               BoxShadow(
//                   color: Colors.grey.withOpacity(0.5),
//                   blurRadius: 10,
//                   offset: Offset(0, 3)),
//             ],
//           ),
//           child: Text(
//             'Data for $pageName goes here.',
//             style: TextStyle(fontSize: 20),
//           ),
//         ),
//       ),
//     );
//   }
// }

// api_data_screen.dart

import 'package:animated_movies_app/screens/api_data_screens/production_request_page.dart';
import 'package:animated_movies_app/screens/api_data_screens/user_approval_page.dart';
import 'package:animated_movies_app/screens/gms_screens/export_tracking.dart';
import 'package:animated_movies_app/screens/gms_screens/gms_charts.dart';
import 'package:animated_movies_app/screens/gms_screens/gms_export_page.dart';
import 'package:animated_movies_app/screens/gms_screens/gms_tracking_page.dart';
import 'package:animated_movies_app/screens/gms_screens/maxking_gms_page.dart';

import 'package:animated_movies_app/screens/home_screen/efficiency_report_page.dart';
import 'package:animated_movies_app/screens/home_screen/employee_feedback_screen.dart';
import 'package:animated_movies_app/screens/home_screen/patrolling_screen.dart';
import 'package:animated_movies_app/screens/home_screen/po_completion_page.dart';
import 'package:animated_movies_app/screens/home_screen/rft_report_page.dart';
import 'package:animated_movies_app/screens/home_screen/target_output_report_page.dart';
import 'package:animated_movies_app/screens/home_screen/token_screen.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';

import 'package:flutter/material.dart';

class ApiDataScreen extends StatefulWidget {
  final String pageName;
  final String pageRoute;

  //  final String pageName;
  // final String userCode;
  // final String userName;
  final LoginModelApi userData; // Use userData directly

  const ApiDataScreen({
    Key? key,
    required this.pageName,
    // required this.userCode,
    required this.userData,
    required this.pageRoute,
    // required this.userName
  }) : super(key: key);

  @override
  State<ApiDataScreen> createState() => _ApiDataScreenState();
}

class _ApiDataScreenState extends State<ApiDataScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.pageName),
        backgroundColor: Colors.lightGreen,
      ),
      body: Center(
        child: Container(
            //     width: double.infinity,
            // decoration: BoxDecoration(
            //   gradient:
            //       UiConstants.backgroundGradient.gradient, // Add your gradient here
            // ),
            padding: const EdgeInsets.all(0.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  blurRadius: 10,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: widget.pageRoute == 'SkillMappingRequest'
                ? SkillMappingRequestPage(
                    // userCode: widget.userCode,
                    userData: widget.userData,

                    // userName: widget.userName,
                  )
                : widget.pageRoute == 'SkillMappingApproval'
                    ? SkillMappingApprovalPage(
                        userData: widget.userData,
                      )
                    : widget.pageRoute == 'Patrolling'
                        ? PatrollingScreen(
                            userData: widget.userData,
                          )
                        : widget.pageRoute == 'GmsExportPage'
                            ? GmsExportPage(
                                userData: widget.userData,
                              )
                            : widget.pageRoute == 'GMSTrackingPage'
                                ? GMSTrackingPage(
                                    // userData: widget.userData,
                                    )
                                : widget.pageRoute == 'GmsCharts'
                                    ? GmsCharts(
                                        // userData: widget.userData,
                                        )
                                    : widget.pageRoute == 'ExportTracking'
                                        ? ExportTracking(
                                            title: widget.pageName,
                                            // userData: widget.userData,
                                          )
                                        : widget.pageRoute ==
                                                'TargetOutputReport'
                                            ? TargetOutputReportPage()
                                            : widget.pageRoute ==
                                                    'EfficiencyReport'
                                                ? EfficiencyReportPage()
                                                : widget.pageRoute ==
                                                        'RftReport'
                                                    ? RftReportPage()
                                                    : widget.pageRoute ==
                                                            'PoCompletionReport'
                                                        ? PoCompletionReport()
                                                        : widget.pageRoute ==
                                                                'Token Screen'
                                                            ? TokenScreen(
                                                                userData: widget
                                                                    .userData,
                                                                empDetailsList: [],
                                                              )
                                                            : widget.pageRoute ==
                                                                    'EmployeeFeedbackScreen'
                                                                ? EmployeeFeedbackScreen()
                                                                : widget.pageRoute ==
                                                                        'MaxkingGmsPage'
                                                                    ? MaxkingGMSPage(
                                                                        userData:
                                                                            widget.userData,
                                                                      )
                                                                    : Text(
                                                                        'Data for ${widget.pageName} goes here.',
                                                                        style: const TextStyle(
                                                                            fontSize:
                                                                                20),
                                                                      )

            // : SignApprovalPage(
            //     userData: widget.userData,
            //   )
            // Text(
            //     'Data for ${widget.pageName} goes here.',
            //     style: TextStyle(fontSize: 20),
            //   ),
            ),
      ),
    );
  }
}
