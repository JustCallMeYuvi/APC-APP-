import 'dart:convert';
import 'package:animated_movies_app/MNT_Modules/qr_codes_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';

import '../api/apis_page.dart';

class MaintenanceHistoryAndRepairScreen extends StatefulWidget {
  final LoginModelApi userData;

  const MaintenanceHistoryAndRepairScreen({
    super.key,
    required this.userData,
  });

  @override
  State<MaintenanceHistoryAndRepairScreen> createState() =>
      _MaintenanceHistoryAndRepairScreenState();
}

class _MaintenanceHistoryAndRepairScreenState
    extends State<MaintenanceHistoryAndRepairScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final panelController = TextEditingController();
  final issueController = TextEditingController();
  final replacedController = TextEditingController();
  final remarkController = TextEditingController();

  List<OrgCodeModel> orgCodes = [];
  OrgCodeModel? selectedOrg;

  Future<void> fetchOrgCodes() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiHelper.mntURL}getOrgCodes'),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        setState(() {
          orgCodes = data.map((e) => OrgCodeModel.fromJson(e)).toList();

          if (orgCodes.isNotEmpty) {
            selectedOrg = orgCodes.first;
          }
        });
      }
    } catch (e) {
      print(e);
    }
  }

  Map<String, dynamic>? data;
  List repairs = [];

  bool isLoading = false;

  // final String baseUrl = "http://10.3.0.70:9042/api/MNT_/";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    fetchOrgCodes(); // ✅ LOAD DROPDOWN
  }

  @override
  void dispose() {
    panelController.dispose();
    issueController.dispose();
    replacedController.dispose();
    remarkController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// ================= BARCODE =================
  Future<void> scanBarcode() async {
    String result = await FlutterBarcodeScanner.scanBarcode(
      '#00FFFF',
      'Cancel',
      true,
      ScanMode.BARCODE,
    );

    if (result != '-1') {
      panelController.text = result;
      fetchPanel(result);
    }
  }

  /// ================= FETCH PANEL =================
  Future<void> fetchPanel(String id) async {
    if (id.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      // final response = await http.get(Uri.parse("$baseUrl$id"));
      final response = await http.get(
        Uri.parse("${ApiHelper.mntURL}$id"),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        setState(() {
          data = result;
          repairs = result["repairs"] ?? [];
        });
      } else {
        setState(() {
          data = null; // 🔥 clear old UI
          repairs.clear(); // 🔥 clear old list
        });

        _showSnack("Panel not found");
      }
    } catch (e) {
      setState(() {
        data = null; // 🔥 clear UI on error
        repairs.clear();
      });

      _showSnack("Server error");
    }

    setState(() => isLoading = false);
  }

  /// ================= ADD REPAIR =================
  Future<void> submitRepair() async {
    if (issueController.text.isEmpty ||
        replacedController.text.isEmpty ||
        remarkController.text.isEmpty ||
        data == null) {
      _showSnack("Fill all fields");
      return;
    }

    setState(() => isLoading = true);

    try {
      // final response = await http.post(
      //   Uri.parse("${baseUrl}addrepair"),
      final response = await http.post(
        Uri.parse("${ApiHelper.mntURL}addrepair"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "loginBarcode": widget.userData.empNo,
          "powerPanelId": data!["powerPanelId"],
          // "orgCode": selectedOrg?.orgCode,
          "ORG_CODE": selectedOrg!.orgCode,
          "issue": issueController.text,
          "replacedItems": replacedController.text,
          "remark": remarkController.text,
        }),
      );
      print("ORG CODE 👉 ${selectedOrg!.orgCode}");

      if (response.statusCode == 200) {
        issueController.clear();
        replacedController.clear();
        remarkController.clear();

        await fetchPanel(data!["powerPanelId"]);

        _tabController.animateTo(0);
        _showSnack("Repair Added Successfully");
      } else {
        _showSnack("Failed to Add Repair");
      }
    } catch (e) {
      _showSnack("Error adding repair");
    }

    setState(() => isLoading = false);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  /// ================= UI =================
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          resizeToAvoidBottomInset: true,
          body: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SafeArea(
              child: NestedScrollView(
                headerSliverBuilder: (context, _) {
                  return [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          /// SEARCH
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 20, vertical: 20),
                            child: Row(
                              children: [
                                Expanded(
                                  child:
                                      _input(panelController, "Enter Panel ID"),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.search,
                                      color: Colors.white),
                                  onPressed: () =>
                                      fetchPanel(panelController.text),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.qr_code_scanner,
                                      color: Colors.cyanAccent),
                                  onPressed: scanBarcode,
                                )
                              ],
                            ),
                          ),

                          if (data != null) ...[
                            const SizedBox(height: 20),

                            /// PANEL INFO
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    data!["powerPanelId"],
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    data!["panelName"],
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// SUMMARY CARDS
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                          child: _colorCard("Location",
                                              data!["location"], Colors.green)),
                                      const SizedBox(width: 14),
                                      Expanded(
                                          child: _colorCard("Capacity",
                                              data!["capacity"], Colors.blue)),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                          child: _colorCard(
                                              "Type",
                                              data!["panelType"],
                                              Colors.orange)),
                                      const SizedBox(width: 14),
                                      Expanded(
                                          child: _colorCard(
                                              "Repairs",
                                              data!["totalRepairs"].toString(),
                                              Colors.purple)),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  // _colorCard(
                                  //     "Last Repair",
                                  //     data!["lastRepairDate"]
                                  //         .toString()
                                  //         .substring(0, 10),
                                  //     Colors.cyan,
                                  //     fullWidth: true),
                                  _colorCard(
                                    "Last Repair",
                                    data!["lastRepairDate"] != null &&
                                            data!["lastRepairDate"]
                                                    .toString()
                                                    .length >=
                                                10
                                        ? data!["lastRepairDate"]
                                            .toString()
                                            .substring(0, 10)
                                        : "No Repair",
                                    Colors.cyan,
                                    fullWidth: true,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            /// TABS
                            TabBar(
                              controller: _tabController,
                              indicatorColor: Colors.cyanAccent,
                              labelColor: Colors.white,
                              unselectedLabelColor: Colors.white54,
                              tabs: const [
                                Tab(text: "HISTORY"),
                                Tab(text: "ADD REPAIR"),
                              ],
                            ),
                          ]
                        ],
                      ),
                    ),
                  ];
                },
                body: data == null
                    ? const Center(
                        child: Text(
                          "No Panel Found",
                          style: TextStyle(color: Colors.white54, fontSize: 16),
                        ),
                      )
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _historyTab(),
                          _formTab(),
                        ],
                      ),
              ),
            ),
          ),
        ),

        /// GLOBAL LOADER
        if (isLoading)
          Container(
            color: Colors.black54,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
      ],
    );
  }

  /// COLOR CARD
  Widget _colorCard(String title, String value, Color accent,
      {bool fullWidth = false}) {
    return Container(
      width: fullWidth ? double.infinity : null,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [accent.withOpacity(0.25), accent.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 6),
          Text(value,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _historyTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: repairs.length,
      itemBuilder: (context, index) {
        final item = repairs[index];
        print("FULL ITEM 👉 $item");
        print("ITEM ORG CODE 👉 ${item["ORG_CODE"]}");

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF182235),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.cyan.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  orgCodes
                      .firstWhere(
                        (e) =>
                            e.orgCode.toString() == item["ORG_CODE"].toString(),
                        orElse: () => OrgCodeModel(
                          orgCode: 0,
                          orgName: "ORG",
                        ),
                      )
                      .orgName,
                  style: const TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(item["issue"],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              Text(item["issue"],
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Text("Replaced: ${item["replacedItems"]}",
                  style: const TextStyle(color: Colors.white70)),
              Text("Created By: ${item["createdBy"]}",
                  style: const TextStyle(color: Colors.white70)),
            ],
          ),
        );
      },
    );
  }

  Widget _formTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          /// 🔹 ORGANIZATION DROPDOWN
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<OrgCodeModel>(
                dropdownColor: const Color(0xFF1E293B),
                value: selectedOrg,
                isExpanded: true,
                hint: const Text(
                  "Select Organization",
                  style: TextStyle(color: Colors.white54),
                ),
                style: const TextStyle(color: Colors.white),
                items: orgCodes.map((org) {
                  return DropdownMenuItem<OrgCodeModel>(
                    value: org,
                    child: Text(org.orgName),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedOrg = value;
                  });
                },
              ),
            ),
          ),

          const SizedBox(height: 14),
          _input(issueController, "Issue"),
          const SizedBox(height: 14),
          _input(replacedController, "Replaced Items"),
          const SizedBox(height: 14),
          _input(remarkController, "Remark"),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: submitRepair,
              child: const Text("Submit"),
            ),
          ),
        ],
      ),
    );
  }

  Widget _input(TextEditingController controller, String hint) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white54),
        filled: true,
        fillColor: const Color(0xFF1E293B),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
