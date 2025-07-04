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

import 'package:animated_movies_app/hr_department/employee_punch_page.dart';
import 'package:animated_movies_app/it_modules/asset_management_screen.dart';
import 'package:animated_movies_app/screens/api_data_screens/production_request_page.dart';
import 'package:animated_movies_app/screens/api_data_screens/user_approval_page.dart';
import 'package:animated_movies_app/screens/gms_screens/assembly_output_page.dart';
import 'package:animated_movies_app/screens/gms_screens/export_approval_page.dart';
import 'package:animated_movies_app/screens/gms_screens/gms_charts.dart';
import 'package:animated_movies_app/screens/gms_screens/gms_delete_page.dart';
import 'package:animated_movies_app/screens/gms_screens/gms_export_page.dart';
import 'package:animated_movies_app/screens/gms_screens/gms_tracking_page.dart';
import 'package:animated_movies_app/screens/gms_screens/kpi_screen.dart';
import 'package:animated_movies_app/screens/gms_screens/maxking/gms_gate_out_vehicles.dart';
import 'package:animated_movies_app/screens/gms_screens/maxking/maxking_export_approval_page.dart';
import 'package:animated_movies_app/screens/gms_screens/maxking/maxking_gms_charts.dart';

import 'package:animated_movies_app/screens/gms_screens/maxking/maxking_gms_page.dart';
import 'package:animated_movies_app/screens/gms_screens/maxking/maxking_gms_tracking.dart';
import 'package:animated_movies_app/screens/gms_screens/production_output_module.dart';

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
                  offset: const Offset(0, 3),
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
                                ? const GMSTrackingPage(
                                    // userData: widget.userData,
                                    )
                                : widget.pageRoute == 'GmsCharts'
                                    ? const GmsCharts(
                                        // userData: widget.userData,
                                        )
                                    : widget.pageRoute == 'ExportTracking'
                                        ? ExportApprovalPage(
                                            title: widget.pageName,
                                            // userData: widget.userData,
                                          )
                                        : widget.pageRoute ==
                                                'TargetOutputReport'
                                            ? const TargetOutputReportPage()
                                            : widget.pageRoute ==
                                                    'EfficiencyReport'
                                                ? const EfficiencyReportPage()
                                                : widget.pageRoute ==
                                                        'RftReport'
                                                    ? const RftReportPage()
                                                    : widget.pageRoute ==
                                                            'PoCompletionReport'
                                                        ? const PoCompletionReport()
                                                        : widget.pageRoute ==
                                                                'Token Screen'
                                                            ? TokenScreen(
                                                                userData: widget
                                                                    .userData,
                                                                empDetailsList: [],
                                                              )
                                                            : widget.pageRoute ==
                                                                    'EmployeeFeedbackScreen'
                                                                ? const EmployeeFeedbackScreen()
                                                                : widget.pageRoute ==
                                                                        'MaxkingGmsPage'
                                                                    ? MaxkingGMSPage(
                                                                        userData:
                                                                            widget.userData,
                                                                      )
                                                                    : widget.pageRoute ==
                                                                            'MaxkingGMSTrackingPage'
                                                                        ? const MaxkingGMSTrackingPage(

                                                                            // userData:
                                                                            //     widget.userData,
                                                                            )
                                                                        : widget.pageRoute ==
                                                                                'MaxkingGmsCharts'
                                                                            ? const MaxkingGmsCharts(
                                                                                // userData:
                                                                                //     widget.userData,
                                                                                )
                                                                            : widget.pageRoute == 'RemoveGmsVehicle'
                                                                                ? const GMSDeletePage(
                                                                                    // userData:
                                                                                    //     widget.userData,
                                                                                    )
                                                                                : widget.pageRoute == 'EmpPunch'
                                                                                    ? EmpPunch(
                                                                                        userData: widget.userData,
                                                                                        // userData:
                                                                                        //     widget.userData,
                                                                                      )
                                                                                    : widget.pageRoute == 'Asset_Management'
                                                                                        ? AssetManagementScreen(
                                                                                            userData: widget.userData,
                                                                                            // userData:
                                                                                            //     widget.userData,
                                                                                          )
                                                                                        : widget.pageRoute == 'AssemblyOutputPage'
                                                                                            ? AssemblyOutputPage(
                                                                                                userData: widget.userData,
                                                                                                // userData:
                                                                                                //     widget.userData,
                                                                                              )
                                                                                            : widget.pageRoute == 'KpiOutput'
                                                                                                ? KpiScreen(
                                                                                                    userData: widget.userData,
                                                                                                    // userData:
                                                                                                    //     widget.userData,
                                                                                                  )
                                                                                                : widget.pageRoute == 'MaxKingGateOutVehicles'
                                                                                                    ? GMSGateOutVehiclesPage(
                                                                                                        userData: widget.userData,
                                                                                                        // userData:
                                                                                                        //     widget.userData,
                                                                                                      )
                                                                                                    : widget.pageRoute == 'ProductionReports'
                                                                                                        ? ProductionReportsModule(
                                                                                                            userData: widget.userData,
                                                                                                            // userData:
                                                                                                            //     widget.userData,
                                                                                                          )
                                                                                                        : widget.pageRoute == 'MaxkingExportApprovals'
                                                                                                            ? MaxkingExportApprovalPage(
                                                                                                                title: widget.pageName,
                                                                                                                // userData: widget.userData,
                                                                                                                // userData:
                                                                                                                //     widget.userData,
                                                                                                              )
                                                                                                            : Text(
                                                                                                                'Data for ${widget.pageName} goes here.',
                                                                                                                style: const TextStyle(fontSize: 20),
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
