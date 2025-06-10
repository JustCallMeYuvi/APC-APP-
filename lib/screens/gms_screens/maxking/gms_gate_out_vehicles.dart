import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/model/gate_out_vehicles_model.dart';
import 'package:animated_movies_app/screens/gms_screens/gms_files_page.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class GMSGateOutVehiclesPage extends StatefulWidget {
  final LoginModelApi userData;

  const GMSGateOutVehiclesPage({Key? key, required this.userData})
      : super(key: key);

  @override
  State<GMSGateOutVehiclesPage> createState() => _GMSGateOutVehiclesPageState();
}

class _GMSGateOutVehiclesPageState extends State<GMSGateOutVehiclesPage> {
  DateTime? _fromDate;
  DateTime? _toDate;
  bool _isLoading = false;
  List<GateOutVehiclesModel> _vehicles = [];

  @override
  void initState() {
    super.initState();
    final today = DateTime.now();
    _toDate = today;
    _fromDate = today.subtract(const Duration(days: 2));
    _fetchGateOutVehicles();
  }

  Future<void> _fetchGateOutVehicles() async {
    if (_fromDate == null || _toDate == null) return;

    setState(() => _isLoading = true);

    final fromDateStr = DateFormat('yyyy-MM-dd').format(_fromDate!);
    final toDateStr = DateFormat('yyyy-MM-dd').format(_toDate!);

    final url =
        "${ApiHelper.gmsUrl}getoutvehicles?fromdate=$fromDateStr&todate=$toDateStr";
    print('Gate Out Vehicles URL ${url}');
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _vehicles = gateOutVehiclesModelFromJson(response.body);
        });
      } else {
        _showError("Failed to load vehicles");
      }
    } catch (e) {
      _showError("Something went wrong: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
    setState(() {
      _vehicles = [];
    });
  }

  Future<void> _pickFromDate() async {
    final initialDate =
        _fromDate ?? DateTime.now().subtract(const Duration(days: 2));
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().subtract(const Duration(days: 2)),
    );

    if (picked != null) {
      setState(() => _fromDate = picked);
      _fetchGateOutVehicles();
    }
  }

  Future<void> _pickToDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() => _toDate = picked);
      _fetchGateOutVehicles();
    }
  }

  String _formatDate(DateTime? date) {
    return date != null ? DateFormat('yyyy-MM-dd').format(date) : "Select Date";
  }

  Widget _buildDateSelector(String label, DateTime? date, VoidCallback onTap) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: label,
            border: const OutlineInputBorder(),
          ),
          child: Text(_formatDate(date)),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(GateOutVehiclesModel vehicle) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => GmsFilesPage(vehicleId: vehicle.vehicleId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoRow("Vehicle Number:", vehicle.vehicleNumber),
              const SizedBox(height: 8),
              _buildInfoRow("Vehicle ID:", vehicle.vehicleId),
              const SizedBox(height: 8),
              _buildInfoRow(
                  "Main Gate Entry:", vehicle.mainGateEntry.toString()),
              const SizedBox(height: 8),
              _buildInfoRow("Main Gate Exit:", vehicle.mainGateExit.toString()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: const TextStyle(color: Colors.black54),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                _buildDateSelector("From Date", _fromDate, _pickFromDate),
                const SizedBox(width: 10),
                _buildDateSelector("To Date", _toDate, _pickToDate),
              ],
            ),
            const SizedBox(height: 20),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_vehicles.isEmpty)
              const Center(child: Text("No vehicles found"))
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _vehicles.length,
                  itemBuilder: (context, index) =>
                      _buildVehicleCard(_vehicles[index]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
