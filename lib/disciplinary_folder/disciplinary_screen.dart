import 'dart:convert';

import 'package:animated_movies_app/disciplinary_folder/disciplinary_model.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'disciplinary_card_widget.dart';

// ─── Main Screen ──────────────────────────────────────────────────────────────

class DisciplinaryListScreen extends StatefulWidget {
  final LoginModelApi userData;
  const DisciplinaryListScreen({Key? key, required this.userData})
      : super(key: key);

  @override
  State<DisciplinaryListScreen> createState() => _DisciplinaryListScreenState();
}

class _DisciplinaryListScreenState extends State<DisciplinaryListScreen>
    with SingleTickerProviderStateMixin {
  bool _showFilter = false;
  DateTime? _fromDate;
  DateTime? _toDate;
  List<DisciplinaryDto> _filtered = [];

  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    fetchDisciplinaryData(); // 🔥 API CALL

    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, -0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() => _showFilter = !_showFilter);
    if (_showFilter) {
      _animCtrl.forward();
    } else {
      _animCtrl.reverse();
    }
  }

  // void _applyFilter() {
  //   fetchDisciplinaryData(); // 🔥 API FILTER CALL
  // }
  void _applyFilter() {
    final now = DateTime.now();

    // ❌ Case 1: No dates selected
    if (_fromDate == null && _toDate == null) {
      _showError("Please select From Date and To Date");
      return;
    }

    // ❌ Case 2: Only one date selected
    if (_fromDate == null || _toDate == null) {
      _showError("Please select both From Date and To Date");
      return;
    }

    // ❌ Case 3: To date > today
    if (_toDate!.isAfter(now)) {
      _showError("To Date should not be greater than today");
      return;
    }

    // ❌ Case 4: From > To
    if (_fromDate!.isAfter(_toDate!)) {
      _showError("From Date should be before To Date");
      return;
    }

    // ❌ Case 5: Max 9 months
    final diffDays = _toDate!.difference(_fromDate!).inDays;
    if (diffDays > 270) {
      _showError("Date range should not exceed 9 months");
      return;
    }

    // ✅ Valid → call API
    fetchDisciplinaryData();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearFilter() {
    setState(() {
      _fromDate = null;
      _toDate = null;
    });

    fetchDisciplinaryData(); // reload API
  }

  Future<void> fetchDisciplinaryData() async {
  try {
    final url =
        Uri.parse("http://10.3.0.70:9042/api/HR/Get_Disciplinary_Data");

    final now = DateTime.now();

    // 🔥 If user didn't select dates → default last 9 months
    final fromDate = _fromDate ??
        DateTime(now.year, now.month - 9, now.day);

    final toDate = _toDate ?? now;

    final requestBody = {
      "empNo": widget.userData.empNo,
      "fromDate": fromDate.toString().split(' ')[0],
      "toDate": toDate.toString().split(' ')[0],
    };

    // 🔥 PRINT REQUEST
    print("👉 URL: $url");
    print("👉 BODY: ${jsonEncode(requestBody)}");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(requestBody),
    );

    // 🔥 PRINT RESPONSE
    print("✅ STATUS CODE: ${response.statusCode}");
    print("✅ RESPONSE BODY: ${response.body}");

    if (response.statusCode == 200 && response.body.isNotEmpty) {
      final data = jsonDecode(response.body);

      final List list = data['data'] ?? [];

      setState(() {
        _filtered = list
            .map((e) => DisciplinaryDto(
                  empNo: e['empNo'] ?? '',
                  empName: e['empName'] ?? '',
                  deptName: e['deptName'] ?? '',
                  disciplinaryDate: e['disciplinaryDate'] ?? '',
                  rewardCode: e['rewardCode'] ?? '',
                  rewardName: e['rewardName'] ?? '',
                  rewardQuantity: e['rewardQuantity'] ?? '',
                  rewardAmount: e['rewardAmount'] ?? '',
                  reason: e['reason'] ?? '',
                ))
            .toList();
      });
    } else {
      print("❌ API Error: ${response.body}");
    }
  } catch (e) {
    print("🚨 ERROR: $e");
  }
}

  Future<void> _pickDate(bool isFrom) async {
    final now = DateTime.now();
    final initial =
        isFrom ? (_fromDate ?? DateTime(now.year, 1, 1)) : (_toDate ?? now);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppColors.primary,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: AppColors.textPrimary,
          ),
          dialogBackgroundColor: Colors.white,
        ),
        child: child!,
      ),
    );

    if (picked != null) {
      setState(() {
        if (isFrom)
          _fromDate = picked;
        else
          _toDate = picked;
      });
    }
  }

  String _fmt(DateTime? d) {
    if (d == null) return 'Select Date';
    return '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';
  }

  bool get _isFiltered => _fromDate != null || _toDate != null;

  @override
  Widget build(BuildContext context) {
    final emp = _filtered.isNotEmpty ? _filtered.first : null;
    return Scaffold(
      backgroundColor: AppColors.background,
      // appBar: _buildAppBar(),
      body: Stack(
        children: [
          // ── Main Content ──
          Column(
            children: [
              _buildHeader(), // ✅ THIS IS YOUR UI (blue one)

              if (emp != null) _buildEmployeeHeader(emp),
              _buildRecordsLabel(),
              Expanded(
                child: _filtered.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                        itemCount: _filtered.length,
                        itemBuilder: (ctx, i) =>
                            DisciplinaryCard(data: _filtered[i]),
                      ),
              ),
            ],
          ),

          // ── Filter Panel Overlay ──
          if (_showFilter)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: _buildFilterPanel(),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          /// 🔹 Title Section
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Disciplinary Records',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
             
              ],
            ),
          ),

          /// 🔹 Filter Button
          GestureDetector(
            onTap: _toggleFilter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: _showFilter || _isFiltered
                    ? Colors.white
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _isFiltered
                      ? const Color(0xFF0EA271)
                      : Colors.transparent,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _isFiltered
                        ? Icons.filter_alt_rounded
                        : Icons.filter_list_rounded,
                    size: 15,
                    color: _showFilter || _isFiltered
                        ? AppColors.primary
                        : Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _isFiltered ? 'Filtered' : 'Filter',
                    style: TextStyle(
                      color: _showFilter || _isFiltered
                          ? AppColors.primary
                          : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  /// ❌ Clear Button
                  if (_isFiltered) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _clearFilter,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: AppColors.primary,
                      ),
                    ),
                  ]
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }


  // ── Filter Panel ────────────────────────────────────────────────────────────
  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title row
          Row(
            children: [
              const Icon(Icons.date_range_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: 7),
              const Text(
                'Filter by Date Range',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: _toggleFilter,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.tagBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Icon(Icons.close_rounded,
                      size: 16, color: AppColors.textSecond),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Date selectors row
          Row(
            children: [
              // From Date
              Expanded(child: _datePicker(label: 'FROM DATE', isFrom: true)),
              const SizedBox(width: 10),
              // Arrow
              const Icon(Icons.arrow_forward_rounded,
                  size: 18, color: AppColors.textSecond),
              const SizedBox(width: 10),
              // To Date
              Expanded(child: _datePicker(label: 'TO DATE', isFrom: false)),
            ],
          ),

          const SizedBox(height: 14),

          // Buttons row
          Row(
            children: [
              // Clear button
              Expanded(
                child: GestureDetector(
                  onTap: _clearFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.tagBg,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.divider),
                    ),
                    child: const Center(
                      child: Text(
                        'Clear',
                        style: TextStyle(
                          color: AppColors.textSecond,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              // Search button
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _applyFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded,
                            size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Search',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _datePicker({required String label, required bool isFrom}) {
    final date = isFrom ? _fromDate : _toDate;
    final hasValue = date != null;

    return GestureDetector(
      onTap: () => _pickDate(isFrom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: hasValue ? const Color(0xFFEEF4FF) : AppColors.background,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: hasValue ? AppColors.primary : AppColors.divider,
            width: hasValue ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: hasValue ? AppColors.primary : AppColors.textSecond,
                fontSize: 9,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 12,
                  color: hasValue ? AppColors.primary : AppColors.textSecond,
                ),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    _fmt(date),
                    style: TextStyle(
                      color: hasValue
                          ? AppColors.textPrimary
                          : AppColors.textSecond,
                      fontSize: 12,
                      fontWeight: hasValue ? FontWeight.w700 : FontWeight.w400,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Employee Header ─────────────────────────────────────────────────────────
  Widget _buildEmployeeHeader(DisciplinaryDto emp) {
    final initials = _initials(emp.empName);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: Center(
              child: Text(initials,
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 18)),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(emp.empName,
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 16),
                    overflow: TextOverflow.ellipsis),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _headerChip(Icons.business_rounded, emp.deptName),
                    const SizedBox(width: 10),
                    _headerChip(Icons.badge_outlined, '#${emp.empNo}'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _headerChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF8FA8CC)),
        const SizedBox(width: 4),
        Text(label,
            style: const TextStyle(
                color: Color(0xFFB8CCE8),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  // ── Records Label ───────────────────────────────────────────────────────────
  Widget _buildRecordsLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Row(
        children: [
          const Icon(Icons.history_rounded,
              size: 14, color: AppColors.textSecond),
          const SizedBox(width: 6),
          const Text('DISCIPLINARY HISTORY',
              style: TextStyle(
                  color: AppColors.textSecond,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${_filtered.length} Records',
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.search_off_rounded,
              size: 56, color: AppColors.textSecond.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text('No records found for selected dates',
              style: TextStyle(color: AppColors.textSecond, fontSize: 14)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _clearFilter,
            child: const Text('Clear Filter',
                style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }
}
