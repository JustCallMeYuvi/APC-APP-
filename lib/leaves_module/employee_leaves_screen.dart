import 'dart:convert';

import 'package:animated_movies_app/leaves_module/employee_leaves_model.dart';
import 'package:animated_movies_app/leaves_module/leaves_card_widget.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../api/apis_page.dart';

// ─── Main Screen ──────────────────────────────────────────────────────────────

class EmployeeLeaveScreen extends StatefulWidget {
  final LoginModelApi userData;
  const EmployeeLeaveScreen({Key? key, required this.userData})
      : super(key: key);
  @override
  State<EmployeeLeaveScreen> createState() => _EmployeeLeaveScreenState();
}

class _EmployeeLeaveScreenState extends State<EmployeeLeaveScreen>
    with SingleTickerProviderStateMixin {
  List<LeaveDto> _filtered = [];
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _showFilter = false;

  bool _isLoading = false;

  late AnimationController _anim;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    fetchLeaveData(); // 🔥 ADD THIS
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 260));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, -0.1), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  void _toggleFilter() {
    setState(() => _showFilter = !_showFilter);
    _showFilter ? _anim.forward() : _anim.reverse();
  }

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

    // ✅ No 9-month restriction ❌ removed

    // ✅ Call API with selected dates
    fetchLeaveData(
      fromDate: _fromDate,
      toDate: _toDate,
    );

    // ✅ CLOSE FILTER UI 🔥
    setState(() {
      _showFilter = false;
    });
    _anim.reverse();
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
      _filtered = _filtered;
      _showFilter = false;
      _anim.reverse();
    });
  }

  // Future<void> fetchLeaveData({DateTime? fromDate, DateTime? toDate}) async {
  //   setState(() => _isLoading = true);

  //   try {
  //     final url = Uri.parse("http://10.3.0.70:9042/api/HR/get-employee-leaves");

  //     final now = DateTime.now();

  //     final start = fromDate ??
  //         DateTime(now.year, now.month, now.day)
  //             .subtract(const Duration(days: 270));

  //     final end = toDate ?? now;

  //     final body = {
  //       "empNo": widget.userData.empNo,
  //       "startDate": start.toIso8601String(),
  //       "endDate": end.toIso8601String(),
  //     };

  //     print("👉 BODY: ${jsonEncode(body)}");

  //     final response = await http.post(
  //       url,
  //       headers: {"Content-Type": "application/json"},
  //       body: jsonEncode(body),
  //     );

  //     if (response.statusCode == 200 && response.body.isNotEmpty) {
  //       final List data = jsonDecode(response.body);

  //       setState(() {
  //         _filtered = data
  //             .map((e) => LeaveDto(
  //                   empNo: e['empNo'] ?? '',
  //                   holidayCode: e['holidayCode'] ?? '',
  //                   holidayName: e['holidayName'] ?? '',
  //                   startDate: DateTime.parse(e['startDate']),
  //                   endDate: DateTime.parse(e['endDate']),
  //                   holidayQty: (e['holidayQty'] ?? 0).toDouble(),
  //                 ))
  //             .toList();
  //       });
  //     }
  //   } catch (e) {
  //     print("❌ ERROR: $e");
  //   } finally {
  //     setState(() => _isLoading = false);
  //   }
  // }

  Future<void> fetchLeaveData({DateTime? fromDate, DateTime? toDate}) async {
    setState(() => _isLoading = true);

    try {
      // final url = Uri.parse("http://10.3.0.70:9042/api/HR/get-employee-leaves");

      final url = Uri.parse('${ApiHelper.baseUrl}get-employee-leaves');

      final now = DateTime.now();

      DateTime start;
      DateTime end;

      if (fromDate != null && toDate != null) {
        // ✅ User filter
        start = fromDate;
        end = toDate;
      } else {
        // ✅ Default initState logic

        if (now.day == 1) {
          // 🔹 Example: April 1 → fetch March full
          final prevMonth = DateTime(now.year, now.month - 1, 1);
          start = prevMonth;
          end = DateTime(now.year, now.month, 0); // last day of prev month
        } else {
          // 🔹 Example: April 20 → fetch March + April till today
          final prevMonth = DateTime(now.year, now.month - 1, 1);
          start = prevMonth;
          end = now;
        }
      }

      final body = {
        "empNo": widget.userData.empNo,
        "startDate": start.toIso8601String(),
        "endDate": end.toIso8601String(),
      };

      print("👉 BODY: ${jsonEncode(body)}");

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 && response.body.isNotEmpty) {
        final List data = jsonDecode(response.body);

        setState(() {
          _filtered = data
              .map((e) => LeaveDto(
                    empNo: e['empNo'] ?? '',
                    holidayCode: e['holidayCode'] ?? '',
                    holidayName: e['holidayName'] ?? '',
                    startDate: DateTime.parse(e['startDate']),
                    endDate: DateTime.parse(e['endDate']),
                    holidayQty: (e['holidayQty'] ?? 0).toDouble(),
                  ))
              .toList();
        });
      }
    } catch (e) {
      print("❌ ERROR: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_fromDate ?? DateTime(2026, 1, 1))
          : (_toDate ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
      builder: (ctx, child) => Theme(
        data: ThemeData.light().copyWith(
          colorScheme: const ColorScheme.light(
            primary: C.navy,
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: C.text,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null)
      setState(() => isFrom ? _fromDate = picked : _toDate = picked);
  }

  // ── Summary totals ──────────────────────────────────────────────────────────
  Map<String, double> get _totals {
    final map = <String, double>{};
    for (final l in _filtered) {
      map[l.holidayName] = (map[l.holidayName] ?? 0) + l.holidayQty;
    }
    return map;
  }

  double get _totalHours => _filtered.fold(0, (s, l) => s + l.holidayQty);

  bool get _isFiltered => _fromDate != null || _toDate != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: C.bg,
      body: Stack(
        children: [
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(), // ✅ NEW HEADER

                _buildEmpHeader(),
                _buildSummarySection(),
                _buildListLabel(),
                _filtered.isEmpty
                    ? _buildEmpty()
                    : Column(
                        children:
                            _filtered.map((l) => LeaveCard(leave: l)).toList(),
                      ),
                const SizedBox(height: 30),
              ],
            ),
          ),

          // 🔥 LOADING OVERLAY (FULL SCREEN FIX)
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            ),

          // ── Filter Panel ──
          if (_showFilter)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _fade,
                child: SlideTransition(
                  position: _slide,
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
        color: C.navy,
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
          /// 🔹 Title
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Leave Records',
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
                    color: _showFilter || _isFiltered ? C.navy : Colors.white,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    _isFiltered ? 'Filtered' : 'Filter',
                    style: TextStyle(
                      color: _showFilter || _isFiltered ? C.navy : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (_isFiltered) ...[
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: _clearFilter,
                      child: const Icon(
                        Icons.close_rounded,
                        size: 14,
                        color: C.navy,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Employee Header ─────────────────────────────────────────────────────────
  Widget _buildEmpHeader() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [C.navy, Color(0xFF2E4A7A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
              color: C.navy.withOpacity(0.3),
              blurRadius: 18,
              offset: const Offset(0, 7)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border:
                  Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
            child: const Center(
              child: Icon(Icons.person_rounded, color: Colors.white, size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Employee #${widget.userData.empNo}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    _hdrChip(Icons.access_time_rounded,
                        // '${_totalHours.toStringAsFixed(0)} hrs total'),
                        '${_totalHours.toStringAsFixed(2)} hrs total'),
                    const SizedBox(width: 12),
                    _hdrChip(Icons.event_note_rounded,
                        '${_filtered.length} records'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _hdrChip(IconData icon, String label) => Row(
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

  // ── Summary Section ─────────────────────────────────────────────────────────
  Widget _buildSummarySection() {
    final totals = _totals;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(Icons.donut_small_rounded, size: 14, color: C.sub),
              SizedBox(width: 6),
              Text('LEAVE SUMMARY',
                  style: TextStyle(
                      color: C.sub,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0)),
            ],
          ),
        ),
        SizedBox(
          height: 108,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: totals.entries.map((entry) {
                final name = entry.key;
                final hours = entry.value;
                final code = _filtered
                    .firstWhere((l) => l.holidayName == name)
                    .holidayCode;
                final style = getLeaveStyle(code);
                return _summaryCard(name: name, hours: hours, style: style);
              }).toList(),
            ),
          ),
        ),
        // ── Total bar ──
        Container(
          margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: C.navy,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Icon(Icons.summarize_rounded,
                  size: 16, color: Colors.white),
              const SizedBox(width: 10),
              const Text('Total Leave Hours',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600)),
              const Spacer(),
              Text(
                '${_totalHours.toStringAsFixed(0)} hrs  •  ${(_totalHours / 8).toStringAsFixed(1)} days',
                style: const TextStyle(
                    color: Color(0xFFB8CCE8),
                    fontSize: 12,
                    fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _summaryCard(
      {required String name,
      required double hours,
      required LeaveTypeStyle style}) {
    return Container(
      width: 140,
      margin: const EdgeInsets.only(right: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: C.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: style.borderColor),
        boxShadow: [
          BoxShadow(
              color: style.color.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                    color: style.bgColor,
                    borderRadius: BorderRadius.circular(8)),
                child: Icon(style.icon, size: 14, color: style.color),
              ),
              Text(hrsLabel(hours),
                  style: TextStyle(
                      color: style.color,
                      fontSize: 18,
                      fontWeight: FontWeight.w800)),
            ],
          ),
          Text(name,
              style: const TextStyle(
                  color: C.text, fontSize: 11, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis),
          // mini progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: (hours / _totalHours).clamp(0.0, 1.0),
              minHeight: 4,
              backgroundColor: style.bgColor,
              valueColor: AlwaysStoppedAnimation<Color>(style.color),
            ),
          ),
        ],
      ),
    );
  }

  // ── List Label ──────────────────────────────────────────────────────────────
  Widget _buildListLabel() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 6),
      child: Row(
        children: [
          const Icon(Icons.list_alt_rounded, size: 14, color: C.sub),
          const SizedBox(width: 6),
          const Text('LEAVE DETAILS',
              style: TextStyle(
                  color: C.sub,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 1.0)),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
                color: C.navy, borderRadius: BorderRadius.circular(10)),
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

  // ── Filter Panel ────────────────────────────────────────────────────────────
  Widget _buildFilterPanel() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: C.divider),
        boxShadow: [
          BoxShadow(
              color: C.navy.withOpacity(0.12),
              blurRadius: 20,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.date_range_rounded, size: 16, color: C.navy),
              const SizedBox(width: 7),
              const Text('Filter by Date Range',
                  style: TextStyle(
                      color: C.text,
                      fontWeight: FontWeight.w700,
                      fontSize: 14)),
              const Spacer(),
              GestureDetector(
                onTap: _toggleFilter,
                child: Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      color: C.tag, borderRadius: BorderRadius.circular(6)),
                  child:
                      const Icon(Icons.close_rounded, size: 15, color: C.sub),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: _dateTile(label: 'FROM', isFrom: true)),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child:
                    Icon(Icons.arrow_forward_rounded, size: 18, color: C.sub),
              ),
              Expanded(child: _dateTile(label: 'TO', isFrom: false)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: _clearFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: C.tag,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: C.divider),
                    ),
                    child: const Center(
                        child: Text('Clear',
                            style: TextStyle(
                                color: C.sub,
                                fontWeight: FontWeight.w600,
                                fontSize: 13))),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _applyFilter,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: C.navy,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                            color: C.navy.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 3))
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.search_rounded,
                            size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Search',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 13)),
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

  Widget _dateTile({required String label, required bool isFrom}) {
    final date = isFrom ? _fromDate : _toDate;
    final has = date != null;
    return GestureDetector(
      onTap: () => _pickDate(isFrom),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: has ? const Color(0xFFEEF4FF) : C.bg,
          borderRadius: BorderRadius.circular(10),
          border:
              Border.all(color: has ? C.navy : C.divider, width: has ? 1.5 : 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    color: has ? C.navy : C.sub,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8)),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 12, color: has ? C.navy : C.sub),
                const SizedBox(width: 5),
                Expanded(
                  child: Text(
                    has ? fmtShort(date!) : 'Select Date',
                    style: TextStyle(
                      color: has ? C.text : C.sub,
                      fontSize: 12,
                      fontWeight: has ? FontWeight.w700 : FontWeight.w400,
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

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.event_busy_rounded,
              size: 56, color: C.sub.withOpacity(0.3)),
          const SizedBox(height: 12),
          const Text('No leave records found',
              style: TextStyle(color: C.sub, fontSize: 14)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _clearFilter,
            child: const Text('Clear Filter',
                style: TextStyle(
                    color: C.navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    decoration: TextDecoration.underline)),
          ),
        ],
      ),
    );
  }
}
