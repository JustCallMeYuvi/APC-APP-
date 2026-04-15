import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddApiScreen extends StatefulWidget {
  final String server; // RealTime or Test

  const AddApiScreen({Key? key, required this.server}) : super(key: key);

  @override
  State<AddApiScreen> createState() => _AddApiScreenState();
}

class _AddApiScreenState extends State<AddApiScreen> {
  final _formKey = GlobalKey<FormState>();

  final _projectNameController = TextEditingController();
  final _publicApiController = TextEditingController();
  final _localApiController = TextEditingController();

  bool _isActive = false;
  bool _isLoading = false;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final body = {
      "id": 0,
      "server": widget.server,
      "projectName": _projectNameController.text.trim(),
      "publicApiUrl": _publicApiController.text.trim(),
      "localApiUrl": _localApiController.text.trim(),
      "isActive": _isActive,
      "createdAt": DateTime.now().toIso8601String(),
      "updatedAt": DateTime.now().toIso8601String(),
    };

    try {
      // 🔹 Detect Local / Global network
      // await ApiHelper.updateUrlsBasedOnNetwork();

      final response = await http.post(
        // Uri.parse("http://10.3.0.70:9042/api/HR"),
        Uri.parse("${ApiHelper.baseUrl}Endpoints"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Navigator.pop(context, true);
      } else {}
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isRealtime = widget.server == "RealTime";

    return Scaffold(
      // 🎨 STYLED APPBAR
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        backgroundColor: isRealtime ? Colors.green : Colors.blue,
        title: Text(
          "Add ${widget.server} API",
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ),

      backgroundColor: Colors.grey.shade100,

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // 📌 Project Name
                  TextFormField(
                    controller: _projectNameController,
                    decoration: const InputDecoration(
                      labelText: "Project Name",
                      prefixIcon: Icon(Icons.work_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 14),

                  // 🌐 Public API
                  TextFormField(
                    controller: _publicApiController,
                    decoration: const InputDecoration(
                      labelText: "Public API URL",
                      prefixIcon: Icon(Icons.public),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 14),

                  // 🖥️ Local API
                  TextFormField(
                    controller: _localApiController,
                    decoration: const InputDecoration(
                      labelText: "Local API URL",
                      prefixIcon: Icon(Icons.lan),
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? "Required" : null,
                  ),
                  const SizedBox(height: 20),

                  // ✅ ACTIVE TOGGLE CARD
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _isActive ? Icons.check_circle : Icons.cancel,
                              color: _isActive ? Colors.green : Colors.grey,
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              "Active Status",
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Switch(
                          value: _isActive,
                          activeColor: Colors.green,
                          onChanged: (value) {
                            setState(() => _isActive = value);
                          },
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 🚀 SUBMIT BUTTON
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      icon: _isLoading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: const Text(
                        "ADD API",
                        style: TextStyle(fontSize: 16),
                      ),
                      onPressed: _isLoading ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isRealtime ? Colors.green : Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
