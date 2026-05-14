import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../screens/onboarding_screen/login_page.dart';
import 'leave_model_employee_data_model.dart';
import 'package:http/http.dart' as http;

// ─────────────────────── Colors ───────────────────────────────
class AppColors {
  static const bg = Color(0xFF0D0F1A);
  static const surface = Color(0xFF161829);
  static const card = Color(0xFF1E2138);
  static const accent = Color(0xFF6C63FF);
  static const accentGlow = Color(0xFF8B85FF);
  static const teal = Color(0xFF00D4AA);
  static const textPrimary = Color(0xFFEEF0FF);
  static const textSecondary = Color(0xFF8A8FAD);
  static const border = Color(0xFF2A2D45);
  static const inputBg = Color(0xFF13152A);
}

// ─────────────────────── Model ────────────────────────────────

// ─────────────────────── Screen ───────────────────────────────
class LeaveRequestScreen extends StatefulWidget {
  final LoginModelApi userData;
  const LeaveRequestScreen({super.key, required this.userData});

  @override
  State<LeaveRequestScreen> createState() => _LeaveRequestScreenState();
}

class _LeaveRequestScreenState extends State<LeaveRequestScreen> {
  // Controllers
  final _reasonCtrl = TextEditingController();
  final _approverCtrl = TextEditingController();

  // State
  String _leaveType = 'Casual Leave';
  String? _hrApprover;
  DateTime? _fromDate;
  TimeOfDay? _fromTime;
  DateTime? _toDate;
  TimeOfDay? _toTime;
  bool _isSubmitting = false;
  bool _submitted = false;

  final _leaveTypes = [
    {'label': 'Casual Leave', 'icon': '🏖️'},
    {'label': 'Sick Leave', 'icon': '🏥'},
    {'label': 'Annual Leave', 'icon': '⭐'},
    {'label': 'Emergency Annual Leave', 'icon': '⭐'},

    // {'label': 'Maternity Leave', 'icon': '❤️'},
    {'label': 'Personal Leave', 'icon': '👶'},
    // {'label': 'Loss of Pay', 'icon': '💸'},
    // {'label': 'Compensatory Off', 'icon': '🔄'},
  ];

  // final _hrApprovers = ['Priya Sharma', 'Ravi Kumar', 'Meena Nair'];

  final TextEditingController _barcodeCtrl = TextEditingController();

  @override
  void dispose() {
    _reasonCtrl.dispose();
    _approverCtrl.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    fetchEmployeeData(); // 🔥 call here
    fetchHrApprovers();
  }

  String get _duration {
    if (_fromDate == null || _toDate == null) return '—';
    final from = DateTime(
      _fromDate!.year,
      _fromDate!.month,
      _fromDate!.day,
      _fromTime?.hour ?? 0,
      _fromTime?.minute ?? 0,
    );
    final to = DateTime(
      _toDate!.year,
      _toDate!.month,
      _toDate!.day,
      _toTime?.hour ?? 0,
      _toTime?.minute ?? 0,
    );
    final diff = to.difference(from);
    if (diff.isNegative) return 'Invalid';
    return '${diff.inDays}d ${diff.inHours % 24}h ${diff.inMinutes % 60}m';
  }

  // Future<void> _pickDate(bool isFrom) async {
  //   final picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     firstDate: DateTime(2020),
  //     lastDate: DateTime(2030),
  //     builder: (ctx, child) => _themedPicker(ctx, child),
  //   );
  //   if (picked == null || !mounted) return;
  //   final time = await showTimePicker(
  //     context: context,
  //     initialTime: TimeOfDay.now(),
  //     builder: (ctx, child) => _themedPicker(ctx, child),
  //   );
  //   if (!mounted) return;
  //   setState(() {
  //     if (isFrom) {
  //       _fromDate = picked;
  //       _fromTime = time;
  //     } else {
  //       _toDate = picked;
  //       _toTime = time;
  //     }
  //   });
  // }
  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();

    // 🔥 normalize date
    final today = DateTime(now.year, now.month, now.day);

    DateTime firstDate = DateTime(2020);
    DateTime initialDate = today;

    // 🔥 ANNUAL LEAVE
    if (_leaveType == "Annual Leave") {
      firstDate = today.add(const Duration(days: 15));
      initialDate = firstDate;
    }

    // 🔥 EMERGENCY ANNUAL LEAVE
    else if (_leaveType == "Emergency Annual Leave") {
      firstDate = today;
    }

    // 🔥 PERSONAL LEAVE
    else if (_leaveType == "Personal Leave") {
      firstDate = today.subtract(const Duration(days: 1));
    }

    // 🔥 SICK LEAVE
    else if (_leaveType == "Sick Leave") {
      firstDate = today.subtract(const Duration(days: 1));
    }

    // 🔥 CASUAL LEAVE
    else if (_leaveType == "Casual Leave") {
      firstDate = today.subtract(const Duration(days: 1));
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2030),

      // 🔥 disable unwanted dates
      selectableDayPredicate: (date) {
        final d = DateTime(date.year, date.month, date.day);

        // ✅ Annual Leave → only after 15 days
        if (_leaveType == "Annual Leave") {
          return !d.isBefore(today.add(const Duration(days: 15)));
        }

        // ✅ Emergency AL → today + future
        if (_leaveType == "Emergency Annual Leave") {
          return !d.isBefore(today);
        }

        // ✅ PL & SL → yesterday/today/future
        if (_leaveType == "Personal Leave" || _leaveType == "Sick Leave") {
          return !d.isBefore(today.subtract(const Duration(days: 1)));
        }

        // ✅ Casual Leave → yesterday + today only
        if (_leaveType == "Casual Leave") {
          return d == today || d == today.subtract(const Duration(days: 1));
        }

        return true;
      },

      builder: (ctx, child) => _themedPicker(ctx, child),
    );

    if (picked == null || !mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (ctx, child) => _themedPicker(ctx, child),
    );

    if (time == null || !mounted) return;

    final selectedDateTime = combineDateTime(picked, time);

    // ✅ CHECK TO DATE/TIME
    if (!isFrom) {
      final fromDateTime = combineDateTime(_fromDate, _fromTime);

      if (fromDateTime != null &&
          selectedDateTime != null &&
          selectedDateTime.isBefore(fromDateTime)) {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                ),
                SizedBox(width: 8),
                Text(
                  "Invalid Time",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: const Text(
              "To Date & Time must be greater than From Date & Time.",
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        );

        return;
      }
    }

    // ✅ SAVE
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        _fromTime = time;
      } else {
        _toDate = picked;
        _toTime = time;
      }
    });
  }

  Widget _themedPicker(BuildContext ctx, Widget? child) => Theme(
        data: ThemeData.dark().copyWith(
          colorScheme: const ColorScheme.dark(
            primary: AppColors.accent,
            onPrimary: Colors.white,
            surface: AppColors.card,
            onSurface: AppColors.textPrimary,
          ),
          dialogBackgroundColor: AppColors.surface,
        ),
        child: child!,
      );

  bool validateForm() {
    // ✅ Reason
    if (_reasonCtrl.text.trim().isEmpty) {
      showValidationAlert(
        "Reason Required",
        "Please enter the reason for leave.",
      );
      return false;
    }

    // ✅ HR Approver
    if (_hrApprover == null || _hrApprover!.isEmpty) {
      showValidationAlert(
        "HR Approval Required",
        "Please select HR department approval.",
      );
      return false;
    }

    // ✅ From Date
    if (_fromDate == null || _fromTime == null) {
      showValidationAlert(
        "From Date Required",
        "Please select From Date & Time.",
      );
      return false;
    }

    // ✅ To Date
    if (_toDate == null || _toTime == null) {
      showValidationAlert(
        "To Date Required",
        "Please select To Date & Time.",
      );
      return false;
    }

    return true;
  }

  void showValidationAlert(
    String title,
    String message,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: const TextStyle(
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "OK",
              style: TextStyle(
                color: AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _fmt(DateTime? d, TimeOfDay? t) {
    if (d == null || t == null) return 'Tap to select';

    final dt = combineDateTime(d, t);

    // 🔥 12-hour format with AM/PM
    return DateFormat("dd/MM/yyyy hh:mm a").format(dt!);
  }

  List<HrApprover> hrApproverList = [];

  Future<void> fetchHrApprovers() async {
    final url = Uri.parse(
      'http://10.3.0.70:9197/api/LEAVE_APPROVAL/HRform/getall',
    );

    try {
      final response = await http.get(url);

      print("HR API STATUS: ${response.statusCode}");
      print("HR API BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List) {
          setState(() {
            hrApproverList =
                decoded.map((e) => HrApprover.fromJson(e)).toList();
          });
        }
      }
    } catch (e) {
      print("❌ HR API Exception: $e");
    }
  }

  EmployeeData? empData;
  bool isLoadingEmp = false;

  Future<void> fetchEmployeeData() async {
    setState(() => isLoadingEmp = true);

    final url = Uri.parse(
        'http://10.3.0.70:9197/api/LEAVE_APPROVAL/GetDataList/${widget.userData.empNo}/5000');

    try {
      final response = await http.post(url);

      print("====== EMPLOYEE API ======");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List && decoded.isNotEmpty) {
          final emp = EmployeeData.fromJson(decoded[0]);

          print("✅ FINAL deptNo: ${emp.deptNo}");

          setState(() {
            empData = emp;
          });

          // 🔥 Call Approver API
          if (emp.deptNo.isNotEmpty) {
            await fetchApprover(emp.deptNo);
          } else {
            print("❌ deptNo is EMPTY — check API response");
          }
        } else {
          print("⚠️ Employee response empty");
        }
      } else {
        print("❌ Employee API error: ${response.body}");
      }
    } catch (e) {
      print("❌ Employee Exception: $e");
    }

    setState(() => isLoadingEmp = false);
  }

// approval api fetch
  ApproverData? deptApprover;
  bool isLoadingApprover = false;
  Future<void> fetchApprover(String deptNo) async {
    if (deptNo.isEmpty) {
      print("❌ DeptNo empty, skipping approver API");
      return;
    }

    setState(() => isLoadingApprover = true);

    final url = Uri.parse(
        'http://10.3.0.70:9197/api/LEAVE_APPROVAL/api/approver/$deptNo/5000/${widget.userData.empNo}');

    try {
      final response = await http.get(url);

      print("====== APPROVER API ======");
      print("URL: $url");
      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List && decoded.isNotEmpty) {
          setState(() {
            deptApprover = ApproverData.fromJson(decoded[0]);
          });
        } else if (decoded is Map<String, dynamic>) {
          setState(() {
            deptApprover = ApproverData.fromJson(decoded);
          });
        } else {
          print("⚠️ Approver empty");
        }
      } else {
        print("❌ Approver API error: ${response.body}");
      }
    } catch (e) {
      print("❌ Approver Exception: $e");
    }

    setState(() => isLoadingApprover = false);
  }

  EmployeeData? specialEmp;
  Timer? _debounce; // 🔥 debounce
  Future<void> fetchByBarcode() async {
    final barcode = _barcodeCtrl.text.trim();

    if (barcode.isEmpty) return;

    print("🔥 API CALL: $barcode");

    final url = Uri.parse(
        'http://10.3.0.70:9197/api/LEAVE_APPROVAL/GetDataList/$barcode/5000');

    try {
      final response = await http.post(url);

      print("STATUS: ${response.statusCode}");
      print("BODY: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is List && decoded.isNotEmpty) {
          setState(() {
            specialEmp = EmployeeData.fromJson(decoded[0]);
          });
        } else {
          setState(() {
            specialEmp = null;
          });
        }
      }
    } catch (e) {
      print("❌ Exception: $e");
    }
  }

  // ── Build ───────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      // body: _submitted ? _buildSuccess() : _buildSingleScreen(),
      body: isLoadingEmp
          ? const Center(child: CircularProgressIndicator()) // ✅ HERE
          : (_submitted ? _buildSuccess() : _buildSingleScreen()),
    );
  }

  // ── Success ─────────────────────────────────────────────────
  Widget _buildSuccess() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                    colors: [AppColors.teal, AppColors.accent]),
                boxShadow: [
                  BoxShadow(
                      color: AppColors.teal.withOpacity(0.3), blurRadius: 28)
                ],
              ),
              child: const Icon(Icons.check_rounded,
                  color: Colors.white, size: 48),
            ),
            const SizedBox(height: 24),
            const Text('Request Submitted!',
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            const SizedBox(height: 8),
            const Text('Your leave request has been sent\nfor approval.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: AppColors.textSecondary, height: 1.6)),
            const SizedBox(height: 32),
            _gradientBtn('Back to Home',
                onTap: () => setState(() => _submitted = false)),
          ],
        ),
      ),
    );
  }

  PlatformFile? selectedFile;
  Future<void> pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      withData: true, // 🔥 IMPORTANT (loads bytes)
    );

    if (result != null && result.files.isNotEmpty) {
      setState(() {
        selectedFile = result.files.first;
      });

      print("Selected file: ${selectedFile!.name}");
      print("Has bytes: ${selectedFile!.bytes != null}");
    }
  }

  DateTime? combineDateTime(DateTime? date, TimeOfDay? time) {
    if (date == null || time == null) return null;

    return DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
  }

  // double calculateLeaveHours() {
  //   if (_fromDate == null ||
  //       _toDate == null ||
  //       _fromTime == null ||
  //       _toTime == null) {
  //     return 0;
  //   }

  //   final from = combineDateTime(_fromDate, _fromTime);
  //   final to = combineDateTime(_toDate, _toTime);

  //   if (from == null || to == null) return 0;

  //   final diff = to.difference(from);

  //   // Convert to hours (including decimals)
  //   return diff.inMinutes / 60.0;
  // }

  double calculateLeaveHours() {
    if (_fromDate == null ||
        _toDate == null ||
        _fromTime == null ||
        _toTime == null) {
      return 0;
    }

    final from = combineDateTime(_fromDate, _fromTime);
    final to = combineDateTime(_toDate, _toTime);

    if (from == null || to == null) return 0;

    double totalHours = to.difference(from).inMinutes / 60;

    // REMOVE LUNCH BREAK
    if (totalHours >= 5) {
      totalHours -= 0.75; // 45 mins
    }

    return totalHours;
  }

  String format12Hour(DateTime? dt) {
    if (dt == null) return "";
    return DateFormat("yyyy-MM-dd hh:mm a").format(dt);
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    // ✅ Validate form
    if (!validateForm()) {
      setState(() => _isSubmitting = false);
      return;
    }

    final fromDateTime = combineDateTime(_fromDate, _fromTime);

    final toDateTime = combineDateTime(_toDate, _toTime);

    try {
      String getBtType(String? type) {
        switch (type) {
          case "Casual Leave":
            return "CL";

          case "Sick Leave":
            return "SL";

          case "Personal Leave": // ✅ your custom UI
            return "PL";

          case "Annual Leave":
            return "AL";

          case "Emergency Annual Leave":
            return "EAL";

          default:
            return "";
        }
      }

      String getHolidayKind(String? type) {
        switch (type) {
          case "Casual Leave":
            return "02";

          case "Sick Leave":
            return "03";

          case "Personal Leave": // ✅ maps to PL
            return "15";

          case "Annual Leave":
          case "Emergency Annual Leave":
            return "05";

          default:
            return "";
        }
      }

      final btType = getBtType(_leaveType);
      final holidayKind = getHolidayKind(_leaveType);

      final totalHours = calculateLeaveHours();

// ✅ Casual Leave max 8 hours
      if (btType == "CL" && totalHours > 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              "Casual Leave cannot exceed 8 hours",
            ),
          ),
        );

        setState(() => _isSubmitting = false);
        return;
      }

      print("BT TYPE: $btType");
      print("HOLIDAY KIND: $holidayKind");

      if (btType.isEmpty || holidayKind.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid Leave Type")),
        );
        return;
      }

      // 🔥 STEP 2: CHECK LEAVE API
      final checkUrl = Uri.parse(
        'http://10.3.0.70:9197/api/LEAVE_APPROVAL/check-leave',
      );
      // final checkUrl = Uri.parse(
      //   'http://10.3.5.248:45455/api/LEAVE_APPROVAL/check-leave',
      // );

      final checkBody = {
        "Barcode": widget.userData.empNo,
        // "LeaveType": mappedType, // ✅ USE CODE
        "LeaveType": holidayKind,
        "UserOrgId": 100,
        // "StartDate": _fromDate?.toIso8601String().split("T")[0],
        // "EndDate": _toDate?.toIso8601String().split("T")[0],

        // ✅ SEND FULL DATETIME
        "StartDate": fromDateTime?.toIso8601String(),
        "EndDate": toDateTime?.toIso8601String(),
      };

      final checkResponse = await http.post(
        checkUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(checkBody),
      );

      final checkData = jsonDecode(checkResponse.body);

      print('CHECK API STATUS: ${checkResponse.statusCode}');
      print('CHECK API BODY: $checkData');

      // if (checkData["Status"] != true) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text(checkData["Message"] ?? "Leave not allowed")),
      //   );
      //   return;
      // }

      if (checkData["Status"] != true) {
        String errMsg = checkData["Message"] ?? "Leave not allowed";

        // ✅ Remove ORA error
        errMsg = errMsg.replaceAll(
          RegExp(r'ORA-\d+:\s*'),
          '',
        );

        // ✅ Custom message for CL limit
        // if (errMsg.contains("already entered")) {
        //   errMsg =
        //       "You have already reached the Casual Leave limit for this time period.";
        // }

        if (errMsg.contains("already entered")) {
          switch (btType) {
            case "CL":
              errMsg =
                  "You have already reached the Casual Leave limit for this time period.";
              break;

            case "SL":
              errMsg =
                  "You have already reached the Sick Leave limit for this time period.";
              break;

            case "PL":
              errMsg =
                  "You have already reached the Personal Leave limit for this time period.";
              break;

            case "AL":
              errMsg =
                  "You have already reached the Annual Leave limit for this time period.";
              break;

            case "EAL":
              errMsg =
                  "You have already reached the Emergency Annual Leave limit for this time period.";
              break;

            default:
              errMsg = "Leave limit already reached.";
          }
        }

        // ✅ STOP BUTTON LOADING
        setState(() => _isSubmitting = false);

        // ✅ SHOW ALERT
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            backgroundColor: AppColors.card,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  "Leave Alert",
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            content: Text(
              errMsg,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  "OK",
                  style: TextStyle(
                    color: AppColors.accent,
                  ),
                ),
              ),
            ],
          ),
        );

        return;
      }
      /*  public string Barcode { get; set; }
        public string Name { get; set; }
        public string Department { get; set; }
        public string Position { get; set; }
        public string DeptNo { get; set; }
        public string WorkNO { get; set; } */
      // 🔥 STEP 3: PREPARE PAYLOAD (MATCH WEB)
      final payload = {
        "Employees": [
          {
            "Barcode": widget.userData.empNo,
            "Name": empData?.username ?? widget.userData.username,
            "Department": empData?.deptName ?? '',
            "Position": empData?.position ?? '',
            "DeptNo": empData?.deptNo ?? '',
            "WorkNO": empData?.workNo ?? '',
          }
        ],
        // "SplEmployees": [],

        "SplEmployees": [
          {
            "Barcode": specialEmp?.empNo ?? '',
            "Name": specialEmp?.username ?? '',
            "Department": specialEmp?.deptName ?? '',
            "Position": specialEmp?.position ?? '',
            "DeptNo": specialEmp?.deptNo ?? '',
            "WorkNO": specialEmp?.workNo ?? '',
          }
        ],

// 🔥 FILE DETAILS
        "FileName": selectedFile?.name ?? "",
        "FileType": selectedFile?.extension ?? "",
        "Reason": _reasonCtrl.text,
        // "BtType": mappedType,
        "BtType": btType, // ✅ FIXED
        // "FromDateTime": fromDateTime?.toIso8601String(),
        // "ToDateTime": toDateTime?.toIso8601String(),
        // // "FromDateTime": format12Hour(fromDateTime),
        // // "ToDateTime": format12Hour(toDateTime),
        // "TotalHours": calculateLeaveHours().toString(),
        // "TotalDays": "1",
        // "TotalMintues": (calculateLeaveHours() * 60).toInt().toString(),

        "FromDateTime": fromDateTime?.toIso8601String(),
        "ToDateTime": toDateTime?.toIso8601String(),

        "TotalHours": calculateLeaveHours(),
        "TotalDays": 1,
        "TotalMintues": (calculateLeaveHours() * 60).toInt(),
        "UserBarcode": widget.userData.empNo,
        "Factory": 5000,
        "OrgId": 100,
        "HRBarcode": _hrApprover,
        // "HolidayKind": mappedType,
        "HolidayKind": holidayKind, // ✅ FIXED
      };

      print("FINAL PAYLOAD: $payload");

      // 🔥 STEP 4: MULTIPART REQUEST
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          'http://10.3.0.70:9197/api/LEAVE_APPROVAL/BusinessTrip/Submit',
        ),
      );
      // var request = http.MultipartRequest(
      //   'POST',
      //   Uri.parse(
      //     'http://10.3.5.248:45455/api/LEAVE_APPROVAL/BusinessTrip/Submit',
      //   ),
      // );
      // ✅ IMPORTANT: send JSON inside "request"
      request.fields['request'] = jsonEncode(payload);

      // 🔥 FILE ATTACH
      if (selectedFile != null) {
        Uint8List? bytes = selectedFile!.bytes;

        if (bytes == null && selectedFile!.path != null) {
          final file = File(selectedFile!.path!);
          bytes = await file.readAsBytes();
        }

        if (bytes != null) {
          // 🔥 SEND FILE NAME
          request.fields['fileNames'] = selectedFile!.name;

          // 🔥 SEND FILE TYPE
          request.fields['fileTypes'] = selectedFile!.extension ?? '';

          // 🔥 OPTIONAL INDEX
          request.fields['fileEmpIndex'] = "0";

          // 🔥 SEND FILE
          request.files.add(
            http.MultipartFile.fromBytes(
              'files',
              bytes,
              filename: selectedFile!.name,
            ),
          );

          print("FILE NAME: ${selectedFile!.name}");
          print("FILE TYPE: ${selectedFile!.extension}");
        }
      }

      // 🔥 STEP 5: SEND
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("STATUS: ${response.statusCode}");
      print("BODY: $responseBody");

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Successfully submitted!")),
        );

        // 🔥 RESET FORM
        setState(() {
          _reasonCtrl.clear();
          _barcodeCtrl.clear();
          selectedFile = null;
          _hrApprover = null;
          specialEmp = null;
          _fromDate = null;
          _toDate = null;
          _submitted = true;
        });
      }
      // else {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(content: Text(responseBody)),
      //   );
      // }

      else {
        String errMsg = "Something went wrong";

        try {
          final decoded = jsonDecode(responseBody);

          if (decoded["Message"] != null) {
            errMsg = decoded["Message"].toString();
          } else {
            errMsg = responseBody;
          }
        } catch (e) {
          errMsg = responseBody;
        }

        // ✅ Remove ORA error codes
        errMsg = errMsg.replaceAll(
          RegExp(r'ORA-\d+:\s*'),
          '',
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errMsg)),
        );
      }
    } catch (e) {
      print("❌ Exception: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }

    setState(() => _isSubmitting = false);
  }

  // ── Single Screen ───────────────────────────────────────────
  Widget _buildSingleScreen() {
    return SafeArea(
      child: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Employee Info'),
                  const SizedBox(height: 10),

                  Row(children: [
                    Expanded(
                      child: _readField(
                        'Employee ID',
                        empData?.empNo ?? widget.userData.empNo,
                        Icons.badge_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _readField(
                        'Department',
                        empData?.deptName ?? widget.userData.deptName ?? '—',
                        Icons.business_rounded,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 12),

                  Row(children: [
                    Expanded(
                      child: _readField(
                        'Full Name',
                        empData?.username ?? widget.userData.username,
                        Icons.person_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _readField(
                        'Position',
                        empData?.position ?? widget.userData.position ?? '—',
                        Icons.work_rounded,
                      ),
                    ),
                  ]),

                  const SizedBox(height: 20),

                  _sectionLabel('Attachments'),
                  const SizedBox(height: 10),

                  // GestureDetector(
                  //   onTap: selectedFile == null
                  //       ? pickFile
                  //       : null, // 🔥 disable tap after select
                  //   child: Container(
                  //     height: 60,
                  //     decoration: BoxDecoration(
                  //       color: AppColors.inputBg,
                  //       borderRadius: BorderRadius.circular(12),
                  //       border: Border.all(color: AppColors.border),
                  //     ),
                  //     padding: const EdgeInsets.symmetric(horizontal: 12),
                  //     child: Row(
                  //       children: [
                  //         // 🔥 Left icon (change based on state)
                  //         Container(
                  //           width: 36,
                  //           height: 36,
                  //           decoration: BoxDecoration(
                  //             color: AppColors.accent.withOpacity(0.1),
                  //             borderRadius: BorderRadius.circular(8),
                  //           ),
                  //           child: Icon(
                  //             selectedFile == null
                  //                 ? Icons.attach_file
                  //                 : Icons.insert_drive_file, // 🔥 change icon
                  //             color: AppColors.accent,
                  //             size: 18,
                  //           ),
                  //         ),

                  //         const SizedBox(width: 10),

                  //         // 🔥 File name
                  //         Expanded(
                  //           child: Text(
                  //             selectedFile?.name ?? 'Upload file (Image / PDF)',
                  //             overflow: TextOverflow.ellipsis,
                  //             style: TextStyle(
                  //               fontSize: 13,
                  //               color: selectedFile != null
                  //                   ? AppColors.textPrimary
                  //                   : AppColors.textSecondary,
                  //             ),
                  //           ),
                  //         ),

                  //         // 🔥 Right side action
                  //         if (selectedFile == null)
                  //           const Icon(Icons.upload_file,
                  //               color: AppColors.textSecondary)
                  //         else
                  //           GestureDetector(
                  //             onTap: () {
                  //               setState(() {
                  //                 selectedFile = null; // 🔥 remove file
                  //               });
                  //             },
                  //             child: const Icon(Icons.close,
                  //                 color: Colors.red, size: 20),
                  //           ),
                  //       ],
                  //     ),
                  //   ),
                  // ),

                  GestureDetector(
                    onTap: selectedFile == null ? pickFile : null,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.inputBg,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          // FILE ICON
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              selectedFile == null
                                  ? Icons.attach_file
                                  : _getFileIcon(selectedFile!.extension),
                              color: AppColors.accent,
                              size: 20,
                            ),
                          ),

                          const SizedBox(width: 12),

                          // FILE DETAILS
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  selectedFile?.name ?? 'Upload file',
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: selectedFile != null
                                        ? AppColors.textPrimary
                                        : AppColors.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  selectedFile != null
                                      ? "${selectedFile!.extension?.toUpperCase()} • ${(selectedFile!.size / 1024).toStringAsFixed(1)} KB"
                                      : 'Image / PDF supported',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // ACTION ICON
                          if (selectedFile == null)
                            const Icon(
                              Icons.upload_file,
                              color: AppColors.textSecondary,
                            )
                          else
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedFile = null;
                                });
                              },
                              child: const Icon(
                                Icons.close,
                                color: Colors.red,
                                size: 20,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _sectionLabel('Leave Type'),
                  const SizedBox(height: 10),
                  _leaveTypeGrid(),
                  const SizedBox(height: 24),

                  _sectionLabel('Reason for Leave'),
                  const SizedBox(height: 10),
                  _reasonField(),
                  const SizedBox(height: 24),

                  _sectionLabel('Approvers'),
                  const SizedBox(height: 10),
                  // _approvalCard(
                  //   label: 'Dept Approval',
                  //   name: 'Yuvi',
                  //   id: '70068',
                  //   color: AppColors.teal,
                  //   icon: Icons.supervisor_account_rounded,
                  // ),

                  _approvalCard(
                    label: 'Dept Approval',
                    name: deptApprover?.name ?? '—',
                    id: deptApprover?.id ?? '—',
                    color: AppColors.teal,
                    icon: Icons.supervisor_account_rounded,
                  ),
                  const SizedBox(height: 10),
                  // _approvalCard(
                  //   label: 'Applicant',
                  //   name: widget.userData.username,
                  //   id: widget.userData.empNo,
                  //   color: AppColors.accent,
                  //   icon: Icons.person_rounded,
                  // ),

                  _approvalCard(
                    label: 'Applicant',
                    name: widget.userData.username,
                    id: widget.userData.empNo,
                    color: AppColors.accent,
                    icon: Icons.person_rounded,
                  ),
                  const SizedBox(height: 12),
                  _hrDropdown(),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _inputField(
                          ctrl: _barcodeCtrl,
                          label: 'Barcode',
                          hint: 'Enter',
                          icon: Icons.qr_code,
                          onChanged: (value) {
                            if (_debounce?.isActive ?? false) {
                              _debounce!.cancel();
                            }

                            _debounce =
                                Timer(const Duration(milliseconds: 500), () {
                              fetchByBarcode();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _readField(
                          'Department',
                          specialEmp?.deptName ?? '—',
                          Icons.business_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      Expanded(
                        child: _readField(
                          'Full Name',
                          specialEmp?.username ?? '—',
                          Icons.person_rounded,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _readField(
                          'Position',
                          specialEmp?.position ?? '—',
                          Icons.work_rounded,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  _sectionLabel('Date & Time'),
                  const SizedBox(height: 10),
                  Row(children: [
                    Expanded(
                        child: _dtCard(
                      label: 'FROM',
                      icon: Icons.flight_takeoff_rounded,
                      color: AppColors.accent,
                      value: _fmt(_fromDate, _fromTime),
                      hasValue: _fromDate != null,
                      onTap: () => _pickDate(true),
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: _dtCard(
                      label: 'TO',
                      icon: Icons.flight_land_rounded,
                      color: AppColors.teal,
                      value: _fmt(_toDate, _toTime),
                      hasValue: _toDate != null,
                      onTap: () => _pickDate(false),
                    )),
                  ]),
                  // time duratiion bar (🔥 NEW)
                  // const SizedBox(height: 12),
                  // _durationBar(),
                  const SizedBox(height: 16),
                  _infoTip(
                      'Employee fields are auto-populated from your profile. Tap date cards to set your leave period.'),
                  const SizedBox(height: 24),
                  // _gradientBtn('Submit Request',
                  //     icon: Icons.send_rounded,
                  //     isLoading: _isSubmitting,
                  //     onTap: _submit),
                  _gradientBtn(
                    _isSubmitting
                        ? 'Submitting...'
                        : 'Submit Request', // 🔥 HERE
                    icon: Icons.send_rounded,
                    isLoading: _isSubmitting,
                    onTap: _submit,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentGlow]),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: AppColors.accent.withOpacity(0.4), blurRadius: 10)
            ],
          ),
          child: const Icon(Icons.event_available_rounded,
              color: Colors.white, size: 20),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Leave Request',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary)),
            Text('Fill in all details and submit',
                style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
      ]),
    );
  }

  // ── Section Label ────────────────────────────────────────────
  Widget _sectionLabel(String text) {
    return Row(children: [
      Container(
        width: 3,
        height: 15,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.accent, AppColors.teal],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 8),
      Text(text,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              letterSpacing: 0.4)),
    ]);
  }

  IconData _getFileIcon(String? ext) {
    switch (ext?.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;

      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;

      case 'doc':
      case 'docx':
        return Icons.description;

      case 'xls':
      case 'xlsx':
        return Icons.table_chart;

      default:
        return Icons.insert_drive_file;
    }
  }

  // ── Read-only Field ──────────────────────────────────────────
  Widget _readField(String label, String value, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3)),
        const SizedBox(height: 5),
        Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Row(children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(7),
              ),
              child: Icon(icon, size: 14, color: AppColors.accent),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(value,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500)),
            ),
          ]),
        ),
      ],
    );
  }

  // ── Input Field ──────────────────────────────────────────────
  Widget _inputField({
    required TextEditingController ctrl,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    Function(String)? onSubmitted, // 🔥 NEW
    Function(String)? onChanged, // 🔥 OPTIONAL
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(label,
              style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3)),
          const SizedBox(height: 5),
        ],
        TextFormField(
          controller: ctrl,
          maxLines: maxLines,
          onFieldSubmitted: onSubmitted, // 🔥 trigger on enter
          onChanged: onChanged, // 🔥 optional live typing
          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF4A4F6A)),
            prefixIcon: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, size: 15, color: AppColors.accent),
            ),
            filled: true,
            fillColor: AppColors.inputBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    BorderSide(color: AppColors.border.withOpacity(0.8))),
            focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide:
                    const BorderSide(color: AppColors.accent, width: 1.5)),
          ),
        ),
      ],
    );
  }

  // ── Leave Type Grid ──────────────────────────────────────────
  Widget _leaveTypeGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 3.2,
      ),
      itemCount: _leaveTypes.length,
      itemBuilder: (_, i) {
        final lt = _leaveTypes[i];
        final selected = _leaveType == lt['label'];
        return GestureDetector(
          onTap: () => setState(() => _leaveType = lt['label']!),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            decoration: BoxDecoration(
              color: selected
                  ? AppColors.accent.withOpacity(0.12)
                  : AppColors.card,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: selected ? AppColors.accent : AppColors.border,
                width: selected ? 1.5 : 1,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                          color: AppColors.accent.withOpacity(0.2),
                          blurRadius: 10)
                    ]
                  : [],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(children: [
              Text(lt['icon']!, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 7),
              Expanded(
                child: Text(lt['label']!,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                      color: selected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                    )),
              ),
              if (selected)
                Container(
                  width: 14,
                  height: 14,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                        colors: [AppColors.accent, AppColors.accentGlow]),
                  ),
                  child: const Icon(Icons.check_rounded,
                      size: 9, color: Colors.white),
                ),
            ]),
          ),
        );
      },
    );
  }

  // ── Reason Field ─────────────────────────────────────────────
  Widget _reasonField() {
    return TextFormField(
      controller: _reasonCtrl,
      maxLines: 4,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: 'Briefly describe your reason...',
        hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF4A4F6A)),
        prefixIcon: Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 0, 0),
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.notes_rounded,
                size: 15, color: AppColors.accent),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        filled: true,
        fillColor: AppColors.inputBg,
        contentPadding: const EdgeInsets.fromLTRB(12, 14, 14, 14),
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.border.withOpacity(0.8))),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.accent, width: 1.5)),
      ),
    );
  }

  // ── Approval Card ────────────────────────────────────────────
  Widget _approvalCard({
    required String label,
    required String name,
    required String id,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 2),
          Text(name,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary)),
          Text('ID: $id',
              style: const TextStyle(
                  fontSize: 10, color: AppColors.textSecondary)),
        ]),
        const Spacer(),
        Icon(Icons.lock_rounded, size: 14, color: color.withOpacity(0.5)),
      ]),
    );
  }

  // ── HR Dropdown ──────────────────────────────────────────────
  Widget _hrDropdown() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('HR Dept Approval',
          style: TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3)),
      const SizedBox(height: 5),
      DropdownButtonFormField<String>(
        value: _hrApprover,
        onChanged: (v) => setState(() => _hrApprover = v),
        dropdownColor: AppColors.card,
        style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: 'Select HR Approver',
          hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF4A4F6A)),
          prefixIcon: Container(
            margin: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.accent.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.how_to_reg_rounded,
                size: 15, color: AppColors.accent),
          ),
          filled: true,
          fillColor: AppColors.inputBg,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withOpacity(0.8))),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.accent, width: 1.5)),
        ),
        items: hrApproverList.map((e) {
          return DropdownMenuItem<String>(
            value: e.id.toString(), // ✅ THIS IS FIX
            child: Text(e.name), // display name
          );
        }).toList(),
      ),
    ]);
  }

  // ── Date-Time Card ───────────────────────────────────────────
  Widget _dtCard({
    required String label,
    required IconData icon,
    required Color color,
    required String value,
    required bool hasValue,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
              color: hasValue ? color.withOpacity(0.4) : AppColors.border),
          boxShadow: hasValue
              ? [BoxShadow(color: color.withOpacity(0.15), blurRadius: 12)]
              : [],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: color.withOpacity(0.15),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 12, color: color),
            ),
            const SizedBox(width: 6),
            Text(label,
                style: TextStyle(
                    fontSize: 10,
                    color: color,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.4)),
          ]),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                color:
                    hasValue ? AppColors.textPrimary : AppColors.textSecondary,
              )),
        ]),
      ),
    );
  }

  // ── Duration Bar ─────────────────────────────────────────────
  Widget _durationBar() {
    final has = _fromDate != null && _toDate != null;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: has ? const Color(0xFF1A2A38) : AppColors.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: has ? AppColors.teal.withOpacity(0.4) : AppColors.border),
        boxShadow: has
            ? [
                BoxShadow(
                    color: AppColors.teal.withOpacity(0.1), blurRadius: 14)
              ]
            : [],
      ),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.teal.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.timelapse_rounded,
              color: AppColors.teal, size: 20),
        ),
        const SizedBox(width: 12),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('TOTAL DURATION',
              style: TextStyle(
                  fontSize: 10,
                  color: AppColors.teal,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5)),
          const SizedBox(height: 3),
          Text(_duration,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.4,
                color: has ? AppColors.textPrimary : AppColors.textSecondary,
              )),
        ]),
      ]),
    );
  }

  // ── Info Tip ─────────────────────────────────────────────────
  Widget _infoTip(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline_rounded,
            size: 15, color: AppColors.accentGlow),
        const SizedBox(width: 8),
        Expanded(
          child: Text(text,
              style: const TextStyle(
                  fontSize: 11, color: AppColors.textSecondary, height: 1.5)),
        ),
      ]),
    );
  }

  // ── Gradient Button ──────────────────────────────────────────
  Widget _gradientBtn(
    String label, {
    required VoidCallback onTap,
    IconData? icon,
    bool isLoading = false,
  }) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        height: 52,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF5B52F5), Color(0xFF8B85FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: AppColors.accent.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2.5, color: Colors.white))
              : Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(label,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.3)),
                  if (icon != null) ...[
                    const SizedBox(width: 8),
                    Icon(icon, size: 17, color: Colors.white),
                  ],
                ]),
        ),
      ),
    );
  }
}

// ── Usage Example ────────────────────────────────────────────────
// Navigate to this screen like:
//
// Navigator.push(context, MaterialPageRoute(
//   builder: (_) => LeaveRequestScreen(
//     userData: LoginModelApi(
//       empNo: 'EMP-00123',
//       username: 'Imran Khan',
//       deptName: 'Production',
//       position: 'Floor Supervisor',
//     ),
//   ),
// ));
