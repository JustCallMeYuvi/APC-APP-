import 'package:flutter/material.dart';

class FireGateExitManifestWidget extends StatefulWidget {
  FireGateExitManifestWidget({Key? key}) : super(key: key);

  @override
  State<FireGateExitManifestWidget> createState() =>
      _FireGateExitManifestWidgetState();
}

class _FireGateExitManifestWidgetState
    extends State<FireGateExitManifestWidget> {
  final Map<String, TextEditingController> controllers = {
    'Invoice_Packing': TextEditingController(),
    'Buyers_Po': TextEditingController(),
    'Consignee': TextEditingController(),
    'Description': TextEditingController(),
    'Piece_Count': TextEditingController(),
    'Carton_boxes': TextEditingController(),
    'Gross_Weight': TextEditingController(),
    'Forwarder_details': TextEditingController(),
    'Engine_No': TextEditingController(),
    'Chassis_No': TextEditingController(),
    'Destination': TextEditingController(),
    'Seal_No_report': TextEditingController(),
    'LoadingLocations': TextEditingController(),
    'Security_Gaurd': TextEditingController(),
    'Logistics_Manager': TextEditingController(),
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ExpansionTile(
        title: const Text(
          "Fire Gate Exit",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        children: controllers.entries.map((entry) {
          return Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: TextField(
              controller: entry.value,
              decoration: InputDecoration(
                labelText: entry.key.replaceAll('_', ' '),
                border: const OutlineInputBorder(),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
