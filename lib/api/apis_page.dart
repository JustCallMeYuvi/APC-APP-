import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiHelper {
  // static const String _baseUrl = 'http://10.3.0.70:9042/api/HR/';
  // static const String _baseUrl = 'http://10.3.0.208:8084/api/HR/';
  static const String _baseUrl = 'http://203.153.32.85:54329/api/HR/';

  // static String _baseUrlInternal = 'http://10.3.0.208:8084/api/HR/';
  // static String _baseUrlExternal = 'http://203.153.32.85:54329/api/HR/';
  // static late String _baseUrl;
  // static late String _gmsUrl;

  // // Initialize the base URL by checking connectivity
  // static Future<void> initializeBaseUrl() async {
  //   final connectivityResult = await (Connectivity().checkConnectivity());

  //   if (connectivityResult == ConnectivityResult.mobile ||
  //       connectivityResult == ConnectivityResult.wifi) {
  //     try {
  //       // Try reaching the internal URL
  //       final response = await http.get(Uri.parse(_baseUrlInternal));
  //       if (response.statusCode == 200) {
  //         // If internal URL works, use it
  //         _baseUrl = _baseUrlInternal;
  //         _gmsUrl = "http://10.3.0.208:8084/api/GMS/";
  //       } else {
  //         // If internal URL fails, fallback to external URL
  //         _baseUrl = _baseUrlExternal;
  //         _gmsUrl = "http://203.153.32.85:54329/api/GMS/";
  //       }
  //     } catch (_) {
  //       // If internal URL is unreachable, fallback to external URL
  //       _baseUrl = _baseUrlExternal;
  //       _gmsUrl = "http://203.153.32.85:54329/api/GMS/";
  //     }
  //   } else {
  //     // If no connectivity, fallback to external URL
  //     _baseUrl = _baseUrlExternal;
  //     _gmsUrl = "http://203.153.32.85:54329/api/GMS/";
  //   }
  // }

  //  static const String _gmsUrl = 'http://10.3.0.208:8084/api/GMS/';
  static const String _gmsUrl = 'http://203.153.32.85:54329/api/GMS/';
  static const String _gmsUrlExportApproval = 'http://10.3.0.70:83/api/Student/ExportArrovals';
  static const String _gmsvehicleApproval='http://10.3.0.70:83/api/Student/Approve';
  static const String _gmsUrlExportVehicles = 'http://10.3.0.70:83/api/Student/';


// http://10.3.0.70:83/api/Student/GMS_ExportVehicles

// class ApiHelper {
//   // Base URLs
//   static const String _baseUrlInternal = 'http://10.3.0.208:8084/api/HR/';
//   static const String _baseUrlExternal = 'http://203.153.32.85:54329/api/HR/';
//   static late String _baseUrl;

//   static const String _gmsUrlInternal = 'http://10.3.0.208:8084/api/GMS/';
//   static const String _gmsUrlExternal = 'http://203.153.32.85:54329/api/GMS/';
//   static late String _gmsUrl;

//   // Getter for Base URLs
//   static String get baseUrl => _baseUrl;
//   static String get gmsUrl => _gmsUrl;

//   // Initialize the base URL dynamically
//   static Future<void> initializeBaseUrl() async {
//     final connectivityResult = await Connectivity().checkConnectivity();
//     print(connectivityResult);

//     if (connectivityResult == ConnectivityResult.wifi) {
//       // If connected to Wi-Fi, check for the internal network IP address
//       bool isInternalNetwork = false;

//       try {
//         for (var interface in await NetworkInterface.list()) {
//           for (var address in interface.addresses) {
//             if (address.address.startsWith('10.3.')) {
//               isInternalNetwork = true;
//               break; // Exit once a match is found
//             }
//           }
//           if (isInternalNetwork) break;
//         }
//       } catch (e) {
//         print("Error checking internal network: $e");
//       }

//       if (isInternalNetwork) {
//         _baseUrl = _baseUrlInternal;
//         _gmsUrl = _gmsUrlInternal;
//       } else {
//         _baseUrl = _baseUrlExternal;
//         _gmsUrl = _gmsUrlExternal;
//       }
//     } else if (connectivityResult == ConnectivityResult.mobile) {
//       // If on mobile network, use external URLs
//       _baseUrl = _baseUrlExternal;
//       _gmsUrl = _gmsUrlExternal;
//     } else {
//       // No connectivity, default to external URLs
//       _baseUrl = _baseUrlExternal;
//       _gmsUrl = _gmsUrlExternal;
//     }

//     print("Base URL: $_baseUrl");
//     print("GMS URL: $_gmsUrl");
//   }

  static String get baseUrl => _baseUrl; // Public getter

  static String get gmsUrl => _gmsUrl;
  static String get gmsUrlExportApproval => _gmsUrlExportApproval;
  static String get gmsUrlVehicleApproval => _gmsvehicleApproval;
  static String get gmsUrlExportVehicles=>_gmsUrlExportVehicles;




  
  // Login Page
  static String login(String empNo, String password) =>
      '${_baseUrl}LoginApi?empNo=$empNo&password=$password';

  // Employee Details Page in Accoun Screen
  static String getEmpDetails(String empNo) =>
      '${_baseUrl}GetEmpDetails?empNo=$empNo';

  // Method for generating the URL for UpdatePassword API
  static String updatePasswordApi(
      String empNo, String oldPassword, String newPassword) {
    return '${_baseUrl}UpdatePassword?empNo=$empNo&oldPassword=$oldPassword&newPassword=$newPassword';
  }

  // Get Notifications Page
  static String getNotifications(String empNo) =>
      '${_baseUrl}get-notifications/$empNo';

// Method for generating the URL for GetUserDetails API inside Contacts Page
  static String getUserDetailsApi(String empNo) {
    return '${_baseUrl}GetUserDetails?empNo=$empNo';
  }

  // Method for generating the URL for the Check-Update API inside home content page
  static Uri checkUpdateApi(String currentVersion) {
    return Uri.parse('${_baseUrl}check-update?appVersion=$currentVersion');
  }

  // Method to generate the URL for sending notifications for token screen
  static String sendNotificationApi() {
    return '${_baseUrl}send-notification';
  }

  // Get  TargetOutputReportPage
  static String getWorkTargets(String fromDate, String toDate) =>
      '${_baseUrl}GetWorkTargets?fromDate=$fromDate&toDate=$toDate';

  // Efficiency Report
  static String getEfficiencyReport(DateTimeRange? dateRange) {
    String url = '${_baseUrl}efficiency-report';
    if (dateRange != null) {
      final formattedFromDate =
          dateRange.start.toIso8601String().substring(0, 10);
      final formattedToDate = dateRange.end.toIso8601String().substring(0, 10);
      url += '?fromDate=$formattedFromDate&toDate=$formattedToDate';
    }
    return url;
  }

  // RFT Report (GetProductionData)
  static String getRftReport(DateTimeRange? dateRange) {
    String url = '${_baseUrl}GetProductionData';
    if (dateRange != null) {
      final formattedFromDate =
          dateRange.start.toIso8601String().substring(0, 10);
      final formattedToDate = dateRange.end.toIso8601String().substring(0, 10);
      url += '?startDate=$formattedFromDate&endDate=$formattedToDate';
    }
    return url;
  }

  // Method to generate the URL for GetSeOrderDetails API with date range inside PO Completion Page
  static String getSeOrderDetailsApi(DateTimeRange? dateRange) {
    String url = '${_baseUrl}GetSeOrderDetails';

    if (dateRange != null) {
      String formattedFromDate =
          dateRange.start.toIso8601String().substring(0, 10);
      String formattedToDate = dateRange.end.toIso8601String().substring(0, 10);
      url += '?fromDate=$formattedFromDate&toDate=$formattedToDate';
    }

    return url;
  }

  // Method for generating URL for Notify API based on role and plant
  static String notifyApiforLeaveRequest(String role, String plant) {
    return '${_baseUrl}Notify?Role=$role&plant=$plant';
  }

  // Method for generating URL for GetAbsentList API based on selected plant
  static String getAbsentListApi(String selectedPlant) {
    return '${_baseUrl}GetAbsentList?Plant=$selectedPlant';
  }

  // Method for generating URL for GetEmployeeList for Production Request Page API
  static String getEmployeeListApi() {
    return '${_baseUrl}GetEmployeeList';
  }

// get Plants for Production request Page
  static String getPlantsforLeaves() {
    return '${_baseUrl}GetPlants';
  }

  // get Process Types for Production request Page
  static String getProcessTypes() {
    return '${_baseUrl}GetProcessType';
  }

  // Method for generating URL for GetProductionLines API based on plant
  static String getProductionLinesApi(String plant) {
    return '${_baseUrl}GetProductionLines?plant=$plant';
  }

  // Method for generating URL for GetSkillNames API based on process type
  static String getSkillNamesApi(String process) {
    return '${_baseUrl}GetSkillNames?processType=$process';
  }

  // Method for generating URL for CheckDept API based on plant and deptCode
  static String checkDeptApi(String plant, String deptCode) {
    return '${_baseUrl}CheckDept?plant=$plant&deptCode=$deptCode';
  }

  // Method for generating URL for SubmitPlantData API
  static String submitPlantDataApi() {
    return '${_baseUrl}SubmitPlantData';
  }

  // Method for generating URL for GetHeadCount API
  static String getHeadCountApi(String plant, String departmentCode) {
    return '${_baseUrl}GetHeadCount?plant=$plant&departmentCode=$departmentCode';
  }

  // Method for generating URL for GetApprovedStatus API
  static String getApprovedStatusApi(String plant) {
    return '${_baseUrl}GetApprovedStatus?plant=$plant';
  }

  // Method for generating URL for InsertAbsentList API
  static String insertAbsentListApi() {
    return '${_baseUrl}InsertAbsentList';
  }

  // Define a method for getting the URL for the ApproveStatus endpoint
  static String getApproveStatusApi() {
    return '${_baseUrl}ApproveStatus'; // This is the correct way to form the URL
  }

  static String getVehicleTacking() {
    return '${_gmsUrl}status-report'; // This is the correct way to form the URL
  }
}
