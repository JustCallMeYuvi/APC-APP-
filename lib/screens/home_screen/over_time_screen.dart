import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class OverTimeScreen extends StatefulWidget {
  final LoginModelApi userData;

  const OverTimeScreen({Key? key, required this.userData}) : super(key: key);

  @override
  State<OverTimeScreen> createState() => _OverTimeScreenState();
}

enum OtType { overall, weekwise, datewise }

class _OverTimeScreenState extends State<OverTimeScreen> {
  OtType _selectedType = OtType.overall;

  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 7));
  DateTime _toDate = DateTime.now();

  bool _isLoading = false;
  String? _error;

  OverallModel? _overall;
  List<WeekwiseModel>? _weekwise;
  List<DatewiseModel>? _datewise;

  final DateFormat _apiFormat = DateFormat("yyyy-MM-dd");
  final DateFormat _viewFormat = DateFormat("dd MMM yyyy");

  /// Convert ToDate → Add +1 day for API
  String getToDateApi(DateTime date) =>
      _apiFormat.format(date.add(const Duration(days: 1)));

  String getFromDateApi(DateTime date) => _apiFormat.format(date);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => fetchData());
  }

  Future<void> pickFromDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _fromDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // If from-date is greater than current to-date → reset to-date also
      if (_toDate.isBefore(picked)) {
        await _showAlert("From Date cannot be greater than To Date");
        return;
      }

      setState(() => _fromDate = picked);
    }
  }

  Future<void> pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      // Validation ↓
      if (picked.isBefore(_fromDate)) {
        await _showAlert("To Date cannot be earlier than From Date");
        return;
      }

      setState(() => _toDate = picked);
    }
  }

// --- Alert Dialog Function ---
  Future<void> _showAlert(String message) async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Invalid Date"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  Future<void> fetchData() async {
    setState(() {
      _isLoading = true;
      _error = null;
      _overall = null;
      _weekwise = null;
      _datewise = null;
    });

    final type = _selectedType == OtType.overall
        ? "overall"
        : _selectedType == OtType.weekwise
            ? "weekwise"
            : "datewise";

    final from = getFromDateApi(_fromDate);
    final to = getToDateApi(_toDate);

    final baseUrl =
        '${ApiHelper.baseUrl}OtCount?type=$type&fromdate=$from&todate=$to';
    // final url =
    //     "http://10.3.0.70:9042/api/HR/OtCount?type=$type&fromdate=$from&todate=$to";

    try {
      final res = await http.get(Uri.parse(baseUrl));

      if (res.statusCode != 200) {
        throw Exception("Server Error: ${res.statusCode}");
      }

      final data = json.decode(res.body);

      if (_selectedType == OtType.overall) {
        if (data is List && data.isNotEmpty) {
          _overall = OverallModel.fromJson(data[0]);
        }
      } else if (_selectedType == OtType.weekwise) {
        _weekwise =
            (data as List).map((e) => WeekwiseModel.fromJson(e)).toList();
      } else {
        _datewise =
            (data as List).map((e) => DatewiseModel.fromJson(e)).toList();
      }

      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            buildTypeDropdown(),
            const SizedBox(width: 12),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: pickFromDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: "From Date"),
                      child: Text(_viewFormat.format(_fromDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: InkWell(
                    onTap: pickToDate,
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: "To Date"),
                      child: Text(_viewFormat.format(_toDate)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isLoading) const CircularProgressIndicator(),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
            Expanded(child: buildResults()),
            SizedBox(
              width: double.infinity, // FULL WIDTH
              child: ElevatedButton.icon(
                onPressed: fetchData,
                icon: const Icon(Icons.search),
                label: const Text("Search"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16), // height
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10), // rounded corners
                  ),
                  backgroundColor: Colors.blue, // button color
                  foregroundColor: Colors.white, // text + icon color
                  elevation: 3,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildTypeDropdown() {
    return DropdownButtonFormField<OtType>(
      value: _selectedType,
      decoration: const InputDecoration(labelText: "Type"),
      items: const [
        DropdownMenuItem(value: OtType.overall, child: Text("Overall")),
        DropdownMenuItem(value: OtType.weekwise, child: Text("Weekwise")),
        DropdownMenuItem(value: OtType.datewise, child: Text("Datewise")),
      ],
      onChanged: (v) => setState(() => _selectedType = v!),
    );
  }

  Widget buildResults() {
    if (_isLoading) return const SizedBox();

    // Unified container UI used for overall, weekwise items and datewise items.
    if (_selectedType == OtType.overall) {
      if (_overall == null) return const Center(child: Text("No Data"));

      final items = {
        'Total OT Employees':
            _overall!.totalOtEmployees?.toStringAsFixed(0) ?? '-',
        'HR Permitted Hours':
            _overall!.totalHrPermittedHours?.toString() ?? '-',
        'Emp OT Hours': _overall!.totalEmpOtHours?.toString() ?? '-',
        // 'OT Without Permission':
        //     _overall!.totalOtWithoutPermission?.toString() ?? '-',

        if (_overall!.totalOtWithoutPermission != null &&
            _overall!.totalOtWithoutPermission! >= 0)
          'OT Without Permission':
              _overall!.totalOtWithoutPermission.toString(),
        'OT Mandays': _overall!.totalOtMandays?.toString() ?? '-',
      };

      return ListView(
        padding: const EdgeInsets.only(bottom: 12),
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child:
                _buildDataContainer(title: 'Overall OT Summary', values: items),
          ),
        ],
      );
    }

    if (_selectedType == OtType.weekwise) {
      if (_weekwise == null || _weekwise!.isEmpty) {
        return const Center(child: Text("No Data"));
      }

      return ListView.separated(
        itemCount: _weekwise!.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, i) {
          final w = _weekwise![i];
          final title =
              "${_viewFormat.format(w.weekStartDate)} → ${_viewFormat.format(w.weekEndDate)}";
          final items = {
            'Total OT Employees': w.totalOtEmployees?.toStringAsFixed(0) ?? '-',
            'HR Permitted Hours': w.totalHrPermittedHours?.toString() ?? '-',
            'Emp OT Hours': w.totalEmpOtHours?.toString() ?? '-',
            // 'OT Without Permission':
            //     w.totalOtWithoutPermission?.toString() ?? '-',
            // ⭐ Hide this row completely if value is negative
            if (w.totalOtWithoutPermission != null &&
                w.totalOtWithoutPermission! >= 0)
              'OT Without Permission': w.totalOtWithoutPermission.toString(),

            'OT Mandays': w.totalOtMandays?.toString() ?? '-',
          };
          return _buildDataContainer(title: title, values: items);
        },
      );
    }

    // datewise
    if (_datewise == null || _datewise!.isEmpty) {
      return const Center(child: Text("No Data"));
    }

    return ListView.separated(
      itemCount: _datewise!.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) {
        final d = _datewise![i];
        final title = _viewFormat.format(d.attDate);
        final items = {
          'HR Permitted Hours': d.totalHrPermittedHours?.toString() ?? '-',
          'Emp OT Hours': d.totalEmpOtHours?.toString() ?? '-',
          // 'OT Without Permission':
          //     d.totalOtWithoutPermission?.toString() ?? '-',

          // ⭐ Hide this row completely when value is negative
          if (d.totalOtWithoutPermission != null &&
              d.totalOtWithoutPermission! >= 0)
            'OT Without Permission': d.totalOtWithoutPermission.toString(),

          'OT Mandays': d.totalOtMandays?.toString() ?? '-',
        };
        return _buildDataContainer(title: title, values: items);
      },
    );
  }

  Widget _buildDataContainer(
      {required String title, required Map<String, String> values}) {
    // A visually-rich container: gradient header + card body + rows
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header with gradient and title
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).primaryColor,
                  Theme.of(context).primaryColor.withOpacity(0.9)
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              children: [
                const Icon(Icons.timer, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(title,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.w600)),
                ),
                Text(
                    _selectedType == OtType.datewise
                        ? 'Date'
                        : _selectedType == OtType.weekwise
                            ? 'Week'
                            : '',
                    style: const TextStyle(color: Colors.white70)),
              ],
            ),
          ),

          // Body
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              children: values.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: Text(e.key,
                              style: const TextStyle(fontSize: 14))),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.04),
                                blurRadius: 6,
                                offset: const Offset(0, 2)),
                          ],
                        ),
                        child: Text(e.value,
                            style:
                                const TextStyle(fontWeight: FontWeight.w700)),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),

          // Footer: small hint
          if (_selectedType != OtType.overall)
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      size: 16, color: Colors.black54),
                  const SizedBox(width: 8),
                  Expanded(
                      child: Text(
                          'Displayed values are for the selected ${_selectedType == OtType.weekwise ? 'week' : 'date'}.',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54))),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget metric(String label, double? value) {
    return Card(
      child: ListTile(
        title: Text(label),
        trailing: Text(
          value?.toStringAsFixed(2) ?? "-",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

//
// ===== MODELS =====
//

class OverallModel {
  final double? totalOtEmployees;
  final double? totalHrPermittedHours;
  final double? totalEmpOtHours;
  final double? totalOtWithoutPermission;
  final double? totalOtMandays;

  OverallModel({
    this.totalOtEmployees,
    this.totalHrPermittedHours,
    this.totalEmpOtHours,
    this.totalOtWithoutPermission,
    this.totalOtMandays,
  });

  factory OverallModel.fromJson(Map<String, dynamic> json) => OverallModel(
        totalOtEmployees: (json["TOTAL_OT_EMPLOYEES"] as num?)?.toDouble(),
        totalHrPermittedHours:
            (json["TOTAL_HR_PERMITTED_HOURS"] as num?)?.toDouble(),
        totalEmpOtHours: (json["TOTAL_EMP_OT_HOURS"] as num?)?.toDouble(),
        totalOtWithoutPermission:
            (json["TOTAL_OT_WITHOUT_PERMISSION"] as num?)?.toDouble(),
        totalOtMandays: (json["TOTAL_OT_MANDAYS"] as num?)?.toDouble(),
      );
}

class WeekwiseModel {
  final DateTime weekStartDate;
  final DateTime weekEndDate;
  final double? totalOtEmployees;
  final double? totalHrPermittedHours;
  final double? totalEmpOtHours;
  final double? totalOtWithoutPermission;
  final double? totalOtMandays;

  WeekwiseModel({
    required this.weekStartDate,
    required this.weekEndDate,
    this.totalOtEmployees,
    this.totalHrPermittedHours,
    this.totalEmpOtHours,
    this.totalOtWithoutPermission,
    this.totalOtMandays,
  });

  factory WeekwiseModel.fromJson(Map<String, dynamic> json) => WeekwiseModel(
        weekStartDate: DateTime.parse(json["WEEK_START_DATE"]),
        weekEndDate: DateTime.parse(json["WEEK_END_DATE"]),
        totalOtEmployees: (json["TOTAL_OT_EMPLOYEES"] as num?)?.toDouble(),
        totalHrPermittedHours:
            (json["TOTAL_HR_PERMITTED_HOURS"] as num?)?.toDouble(),
        totalEmpOtHours: (json["TOTAL_EMP_OT_HOURS"] as num?)?.toDouble(),
        totalOtWithoutPermission:
            (json["TOTAL_OT_WITHOUT_PERMISSION"] as num?)?.toDouble(),
        totalOtMandays: (json["TOTAL_OT_MANDAYS"] as num?)?.toDouble(),
      );
}

class DatewiseModel {
  final DateTime attDate;
  final double? totalHrPermittedHours;
  final double? totalEmpOtHours;
  final double? totalOtWithoutPermission;
  final double? totalOtMandays;

  DatewiseModel({
    required this.attDate,
    this.totalHrPermittedHours,
    this.totalEmpOtHours,
    this.totalOtWithoutPermission,
    this.totalOtMandays,
  });

  factory DatewiseModel.fromJson(Map<String, dynamic> json) => DatewiseModel(
        attDate: DateTime.parse(json["ATT_DATE"]),
        totalHrPermittedHours:
            (json["TOTAL_HR_PERMITTED_HOURS"] as num?)?.toDouble(),
        totalEmpOtHours: (json["TOTAL_EMP_OT_HOURS"] as num?)?.toDouble(),
        totalOtWithoutPermission:
            (json["TOTAL_OT_WITHOUT_PERMISSION"] as num?)?.toDouble(),
        totalOtMandays: (json["TOTAL_OT_MANDAYS"] as num?)?.toDouble(),
      );
}
