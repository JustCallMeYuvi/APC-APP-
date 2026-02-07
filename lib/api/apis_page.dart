import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class ApiHelper {
  // static const String _baseUrl = 'http://10.3.0.208:8084/api/HR/'; // 208 local url

  // static String _baseUrl = 'http://203.153.32.85:54329/api/HR/'; //global url

  static String _baseUrl = 'http://10.3.0.70:9042/api/HR/'; // 70 local url

  // static String _baseUrl =
  //     'http://apc-gms.apachefootwear.com:8084/api/HR/'; // using new link local url

  //  static const String _gmsUrl = 'http://10.3.0.208:8084/api/GMS/'; // 208 local url

  // static String _gmsUrl = 'http://203.153.32.85:54329/api/GMS/'; //global url

  static String _gmsUrl = 'http://10.3.0.70:9042/api/GMS/'; // 70 local url

  // static String _gmsUrl =
  //     'http://apc-gms.apachefootwear.com:8084/api/GMS/'; // using new link local url

  // static String _maxkingGMSUrl =
  //     'http://203.153.32.85:54329/api/Maxking_GMS_/'; // Global maxking URL

  static String _maxkingGMSUrl =
      'http://10.3.0.70:9042/api/Maxking_GMS_/'; // 70 maxking URL

  // static String _maxkingGMSUrl =
  //     'http://apc-gms.apachefootwear.com:8084/api/Maxking_GMS_/'; // using new link maxking URL

  // static String _productionUrl =
  //     'http://203.153.32.85:54329/api/Production/'; //global url

  // Production base URL
  static String _productionUrl = 'http://10.3.0.70:9042/api/Production/';

// Production base URL
  // static String _productionUrl =
  //     'http://apc-gms.apachefootwear.com:8084/api/Production/'; // using new link

  static String _carConveynanceUrl =
      'http://10.3.0.70:9042/api/Car_Conveyance_/';

  static String _dormitoryURL = 'http://10.3.0.70:9042/api/Dormitory_/';

  static String _mntURL = 'http://10.3.0.70:9042/api/MNT_/';

// Car Conevynance base URL
  // static String _carConveynanceUrl =
  //     'http://apc-gms.apachefootwear.com:8084/api/Car_Conveyance_/'; // using new link

  // Getter for Production URL (optional)
  static String get productionUrl => _productionUrl;

  static String get baseUrl => _baseUrl; // Public getter

  static String get gmsUrl => _gmsUrl;

  static String get maxkingGMSUrl => _maxkingGMSUrl; // Maxking URL

  static String get carConveynanceUrl => _carConveynanceUrl;
  static String get dormitoryURL => _dormitoryURL;

  static String get mntURL => _mntURL;

  static String urlGlobalOrLocalCheck = '';

  // Method to update URLs based on the current Wi-Fi network
  static Future<void> updateUrlsBasedOnNetwork() async {
    String? ipAddress = await _getWifiIPAddress();
    print('👉 Detected IP: $ipAddress');
    if (ipAddress != null) {
      if (ipAddress.startsWith('10.3.') ||
          ipAddress.startsWith('10.4.') ||
          ipAddress.startsWith('10.5.') ||
          ipAddress.startsWith('10.0.')) {
        // If the IP address starts with 10.3.x.x or 10.4.x.x, use local URLs
        // _baseUrl = 'http://10.3.0.208:8084/api/HR/';
        _baseUrl = 'http://10.3.0.70:9042/api/HR/';
        _gmsUrl = 'http://10.3.0.208:8084/api/GMS/';
        _maxkingGMSUrl = 'http://10.3.0.208:8084/api/Maxking_GMS_/';
        // _productionUrl = 'http://10.3.0.208:8084/api/Production/';

        _productionUrl = 'http://10.3.0.70:9042/api/Production/';
        _carConveynanceUrl = 'http://10.3.0.208:8084/api/Car_Conveyance_/';

// // for test url apk
//         _baseUrl = 'http://10.3.0.70:9042/api/HR/';
//         _gmsUrl = 'http://10.3.0.70:9042/api/GMS/';
//         _maxkingGMSUrl = 'http://10.3.0.70:9042/api/Maxking_GMS_/';
//         _productionUrl = 'http://10.3.0.70:9042/api/Production/';
//         _carConveynanceUrl = 'http://10.3.0.70:9042/api/Car_Conveyance_/';

        // urlGlobalOrLocalCheck = '10.3.0.208';
        urlGlobalOrLocalCheck = '10.3.0.70';
      } else {
        // If the IP address does not match, use the public URLs
        // _baseUrl = 'http://203.153.32.85:54329/api/HR/';
        // _gmsUrl = 'http://203.153.32.85:54329/api/GMS/';
        // _maxkingGMSUrl = 'http://203.153.32.85:54329/api/Maxking_GMS_/';
        // _productionUrl = 'http://203.153.32.85:54329/api/Production/';
        // _carConveynanceUrl = 'http://10.3.0.70:9042/api/Car_Conveyance_/';

// this global domain based url
        // _baseUrl = 'http://apc-gms.apachefootwear.com:8084/api/HR/';
        // _baseUrl = 'http://115.244.47.101:9042/api/HR/';

        // _gmsUrl = 'http://apc-gms.apachefootwear.com:8084/api/GMS/';
        // _maxkingGMSUrl =
        //     'http://apc-gms.apachefootwear.com:8084/api/Maxking_GMS_/';
        // // _productionUrl =
        // //     'http://apc-gms.apachefootwear.com:8084/api/Production/';
        // _productionUrl = 'http://115.244.47.101:9042/api/Production/';
        // _carConveynanceUrl =
        //     'http://apc-gms.apachefootwear.com:8084/api/Car_Conveyance_/';
        // urlGlobalOrLocalCheck = '203.153.32.85';

// this below is 70 public links
        _baseUrl = 'http://115.244.47.101:9042/api/HR/';
        _gmsUrl = 'http://115.244.47.101:9042/api/GMS/';
        _maxkingGMSUrl = 'http://115.244.47.101:9042/api/Maxking_GMS_/';
        _productionUrl = 'http://115.244.47.101:9042/api/Production/';
        _carConveynanceUrl = 'http://115.244.47.101:9042/api/Car_Conveyance_/';
        _dormitoryURL = 'http://115.244.47.101:9042/api/Dormitory_/';
        _mntURL = 'http://115.244.47.101:9042/api/MNT_/';

        urlGlobalOrLocalCheck = '115.244.47.101';
      }
      print('Base URL set to: $_baseUrl');
      print('GMS URL set to: $_gmsUrl');
    }
  }

  // Helper method to fetch the Wi-Fi IP address
  static Future<String?> _getWifiIPAddress() async {
    try {
      final info = NetworkInfo();
      String? wifiIp = await info.getWifiIP();
      return wifiIp;
    } catch (e) {
      print('Error getting Wi-Fi IP address: $e');
      return null;
    }
  }

  // static String get gmsUrlExportApproval => _gmsUrlExportApproval;
  // static String get gmsUrlVehicleApproval => _gmsvehicleApproval;
  // static String get gmsUrlExportVehicles => _gmsUrlExportVehicles;

  // Login Page
  // static String login(String empNo, String password) =>
  //     '${_baseUrl}LoginApi?empNo=$empNo&password=$password';

  // Login Page
  static String login(String username, String password) =>
      '${_baseUrl}LoginApi?username=$username&password=$password';

  // Employee Details Page in Accoun Screen
  static String getEmpDetails(String empNo) =>
      '${_baseUrl}GetEmpDetails?empNo=$empNo';
// username base
  static String getEmpDetailsUserNameBased(String username) =>
      '${_baseUrl}GetEmpDetails?empNo=$username';

  // Method for generating the URL for UpdatePassword API
  static String updatePasswordApi(
      String empNo, String oldPassword, String newPassword) {
    return '${_baseUrl}UpdatePassword?empNo=$empNo&oldPassword=$oldPassword&newPassword=$newPassword';
  }

  // // Get Notifications Page
  // static String getNotifications(String empNo) =>
  //     '${_baseUrl}get-notifications/$empNo';

  static String getNotifications(String username) =>
      '${_baseUrl}get-notifications/$username';

// Method for generating the URL for GetUserDetails API inside Contacts Page
  static String getUserDetailsApi(String empNo) {
    return '${_baseUrl}GetUserDetails?empNo=$empNo';
  }

  // Method for generating the URL for the Check-Update API inside home content page
  // static Uri checkUpdateApi(String currentVersion) {
  //   // return Uri.parse('${_baseUrl}check-update?appVersion=$currentVersion');
  //   return Uri.parse('${_baseUrl}check-update?clientVersion=$currentVersion');
  // }

  static Uri checkUpdateApi(String currentVersion) {
    // return Uri.parse('${_baseUrl}check-update?appVersion=$currentVersion');
    return Uri.parse('${_baseUrl}check-version?clientVersion=$currentVersion');
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

  static String getMaxkingVehicleTacking() {
    return '${maxkingGMSUrl}status-report'; // This is the correct way to form the URL
  }
}
