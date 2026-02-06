import 'dart:convert';

import 'package:animated_movies_app/MNT_Modules/qr_scan_bloc.dart';
import 'package:animated_movies_app/MNT_Modules/qr_scan_event.dart';
import 'package:animated_movies_app/MNT_Modules/qr_scan_state.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class MaintenanceQrCodeScannerScreen extends StatefulWidget {
  final LoginModelApi userData;
  const MaintenanceQrCodeScannerScreen({super.key, required this.userData});

  @override
  State<MaintenanceQrCodeScannerScreen> createState() =>
      _MaintenanceQrCodeScannerScreenState();
}

class _MaintenanceQrCodeScannerScreenState
    extends State<MaintenanceQrCodeScannerScreen> {
  String panelCondition = 'Good';
  String switchCondition = 'Good';
  String cableCondition = 'OK';
  String overallCondition = 'Good';

  // ✅ ADD THIS
  int _mapCondition(String value) {
    return (value == 'Good' || value == 'OK') ? 1 : 0;
  }

  Future<void> insertQrRecord({
    required String powerPanelId,
    required LoginModelApi userData,
  }) async {
    final url = Uri.parse('http://10.3.0.70:9042/api/MNT_/insert-qr-record');

    final body = {
      "powerPanelId": powerPanelId,
      "panelCondition": _mapCondition(panelCondition),
      "switchCondition": _mapCondition(switchCondition),
      "cableFasteningCondition": _mapCondition(cableCondition),
      "overallCondition": _mapCondition(overallCondition),
      "createdBy": userData.username,
    };

    try {
      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record inserted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Insert failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> updateQrRecord({
    required int lastRecordId,
    required LoginModelApi userData,
  }) async {
    final url = Uri.parse('http://10.3.0.70:9042/api/MNT_/update-qr-record');

    final body = {
      "id": lastRecordId, // ✅ VERY IMPORTANT
      "panelCondition": _mapCondition(panelCondition),
      "switchCondition": _mapCondition(switchCondition),
      "cableFasteningCondition": _mapCondition(cableCondition),
      "overallCondition": _mapCondition(overallCondition),
      "updatedBy": userData.username,
    };

    try {
      final response = await http.put(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Record updated successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  String formatDate(String? dateTime) {
    if (dateTime == null || dateTime.isEmpty) return '-';

    try {
      final dt = DateTime.parse(dateTime);
      return '${dt.day.toString().padLeft(2, '0')}-'
          '${dt.month.toString().padLeft(2, '0')}-'
          '${dt.year}';
    } catch (e) {
      return '-';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => QrScanBloc(),
      child: Scaffold(
        body: BlocConsumer<QrScanBloc, QrScanState>(
          listener: (context, state) {
            if (state.error != null) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text(state.error!)));
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),

                  /// QR SCAN BUTTON (CENTERED & IMPROVED)
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.qr_code_scanner, size: 26),
                      label: const Text(
                        'SCAN QR CODE',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFff512f),
                        foregroundColor: Colors.white,
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: state.isLoading
                          ? null
                          : () => context.read<QrScanBloc>().add(StartQrScan()),
                    ),
                  ),

                  const SizedBox(height: 20),
                  if (state.isLoading) const CircularProgressIndicator(),
                  if (state.panel != null) _panelDetails(state.panel!),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _panelDetails(panel) {
    return Card(
      elevation: 5,
      margin: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // ✅ ONE ALIGNMENT
          children: [
            // 🔹 HEADER (Centered only here)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.electrical_services,
                    color: Colors.orange, size: 22),
                const SizedBox(width: 8),
                Text(
                  panel.panelName ?? 'Power Panel',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
            const Divider(),

            // 🔹 INFO SECTION (LEFT ALIGNED, EVEN)
            _infoRow(
                Icons.confirmation_number, 'Panel Number', panel.powerPanelId),
            _infoRow(Icons.location_on, 'Location', panel.location),
            _infoRow(Icons.dashboard, 'Panel Type',
                panel.panelType ?? 'Incoming Panel'),
            _infoRow(Icons.bolt, 'Capacity', panel.capacity),
            _infoRow(
              Icons.history,
              'Last Service',
              formatDate(panel.lastServiceDate),
            ),

            _infoRow(
              Icons.history,
              'Next Service',
              formatDate(panel.nextDueDate),
            ),

            const SizedBox(height: 22),

            // 🔹 CONDITIONS (UNIFORM SPACING)
            _choiceSection(
              title: 'Panel Condition',
              value: panelCondition,
              options: const ['Good', 'Not Good'],
              onChanged: (v) => setState(() => panelCondition = v),
            ),

            _choiceSection(
              title: 'Switches Condition',
              value: switchCondition,
              options: const ['Good', 'Not Good'],
              onChanged: (v) => setState(() => switchCondition = v),
            ),

            _choiceSection(
              title: 'Cable Fastening',
              value: cableCondition,
              options: const ['OK', 'Not OK'],
              onChanged: (v) => setState(() => cableCondition = v),
            ),

            _choiceSection(
              title: 'Overall Condition',
              value: overallCondition,
              options: const ['Good', 'Not Good'],
              onChanged: (v) => setState(() => overallCondition = v),
            ),

            const SizedBox(height: 26),

            // 🔹 ACTION BUTTON (FULL WIDTH, CONSISTENT)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  backgroundColor:
                      panel.action == 'Insert' ? Colors.green : Colors.blue,
                ),
                onPressed: () {
                  if (panel.action == 'Insert') {
                    insertQrRecord(
                      powerPanelId: panel.powerPanelId,
                      userData: widget.userData,
                    );
                  } else if (panel.action == 'Update') {
                    updateQrRecord(
                      lastRecordId: panel.lastRecordId!,
                      userData: widget.userData,
                    );
                  }
                },
                child: Text(
                  panel.action == 'Insert'
                      ? 'INSERT DETAILS'
                      : 'UPDATE DETAILS',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String title, String? value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 🔹 ICON WITH BACKGROUND (STYLE BOOST)
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: Colors.grey.shade700,
          ),
        ),

        const SizedBox(width: 12),

        // 🔹 TITLE
        SizedBox(
          width: 150,
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),
        ),

        const SizedBox(width: 6),

        // 🔹 VALUE
        Expanded(
          child: Text(
            value ?? '-',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade900,
              height: 1.4, // line spacing
            ),
          ),
        ),
      ],
    );
  }

  Widget _choiceSection({
    required String title,
    required String value,
    required List<String> options,
    required Function(String) onChanged,
  }) {
    const double chipWidth = 150; // 👈 adjust if needed

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🔹 TITLE COLUMN
          SizedBox(
            width: 180,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),

          // 🔹 SAME-WIDTH CHOICE BUTTONS
          ...options.map((opt) {
            final selected = value == opt;
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: SizedBox(
                width: chipWidth,
                child: ChoiceChip(
                  label: Center(child: Text(opt)),
                  selected: selected,
                  selectedColor: Colors.orange.shade200,
                  labelStyle: TextStyle(
                    fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  onSelected: (_) => onChanged(opt),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
