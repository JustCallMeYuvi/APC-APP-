import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';

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

  Map<String, dynamic>? data;
  List repairs = [];

  bool isLoading = false;

  final String baseUrl = "http://10.3.0.70:9042/api/MNT_/";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      final response = await http.get(Uri.parse("$baseUrl$id"));

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
      final response = await http.post(
        Uri.parse("${baseUrl}addrepair"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "loginBarcode": widget.userData.empNo,
          "powerPanelId": data!["powerPanelId"],
          "issue": issueController.text,
          "replacedItems": replacedController.text,
          "remark": remarkController.text,
        }),
      );

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
                                  _colorCard(
                                      "Last Repair",
                                      data!["lastRepairDate"]
                                          .toString()
                                          .substring(0, 10),
                                      Colors.cyan,
                                      fullWidth: true),
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
