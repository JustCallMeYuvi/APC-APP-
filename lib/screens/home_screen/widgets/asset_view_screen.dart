import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class AssetViewScreen extends StatefulWidget {
  final LoginModelApi userData;

  const AssetViewScreen({super.key, required this.userData});

  @override
  State<AssetViewScreen> createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<AssetViewScreen> {
  TextEditingController searchController = TextEditingController();

  List<Asset> assets = [];
  List<Asset> filteredAssets = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAssets();
  }

  Future<void> fetchAssets() async {
    // final url =
    //     Uri.parse("http://10.3.0.70:9042/api/AssetManagement/getAssets");

    final url = Uri.parse("${ApiHelper.assetUrl}getAssets");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        List data = json.decode(response.body);

        assets = data.map((e) {
          Asset a = Asset.fromJson(e);

          String formattedDate = "";
          if (a.outTime.isNotEmpty) {
            DateTime date = DateTime.parse(a.outTime);
            formattedDate = DateFormat("dd MMM yyyy").format(date);
          }

          return Asset(
            assetId: a.assetId,
            employee: a.employee,
            department: a.department,
            barcode: a.barcode,
            purpose: a.purpose,
            outTime: formattedDate,
          );
        }).toList();

        filteredAssets = assets;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  void search(String value) {
    setState(() {
      filteredAssets = assets.where((a) {
        return a.assetId.toLowerCase().contains(value.toLowerCase()) ||
            a.employee.toLowerCase().contains(value.toLowerCase()) ||
            a.barcode.contains(value);
      }).toList();
    });
  }

  Widget summaryCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.blueGrey.shade700,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Column(
            children: [
              const Text("Devices", style: TextStyle(color: Colors.white70)),
              Text(
                "${assets.length}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )
            ],
          ),
          Column(
            children: [
              const Text("Visible", style: TextStyle(color: Colors.white70)),
              Text(
                "${filteredAssets.length}",
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              )
            ],
          ),
        ],
      ),
    );
  }

  Widget assetCard(Asset a) {
    return Card(
      color: const Color(0xFF1E1E2C),
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              a.assetId,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.cyanAccent),
            ),
            const Divider(color: Colors.white24, height: 20),
            infoRow("Employee", a.employee),
            infoRow("Department", a.department),
            infoRow("Barcode", a.barcode),
            infoRow("Purpose", a.purpose),
            infoRow("Device Taken", a.outTime),
          ],
        ),
      ),
    );
  }

  Widget infoRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              title,
              style: const TextStyle(color: Colors.white54),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                  fontWeight: FontWeight.w500, color: Colors.white),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF0F2027),
              Color(0xFF203A43),
              Color(0xFF2C5364),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                summaryCard(),
                TextField(
                  controller: searchController,
                  onChanged: search,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search, color: Colors.white70),
                    hintText: "Search Asset ID / Employee / Barcode",
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: Colors.black.withOpacity(0.4),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          itemCount: filteredAssets.length,
                          itemBuilder: (context, index) {
                            return assetCard(filteredAssets[index]);
                          },
                        ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Asset {
  final String assetId;
  final String employee;
  final String department;
  final String barcode;
  final String purpose;
  final String outTime;

  Asset({
    required this.assetId,
    required this.employee,
    required this.department,
    required this.barcode,
    required this.purpose,
    required this.outTime,
  });

  factory Asset.fromJson(Map<String, dynamic> json) {
    return Asset(
      assetId: json['assetID'] ?? '',
      employee: json['employeeName'] ?? '',
      department: json['department'] ?? '',
      barcode: json['barcode'] ?? '',
      purpose: json['purpose'] ?? '',
      outTime: json['deviceOutTime'] ?? '',
    );
  }
}
