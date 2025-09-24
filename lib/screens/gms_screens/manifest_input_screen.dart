
// class ManifestCheckReportWidget extends StatefulWidget {
//   @override
//   State<ManifestCheckReportWidget> createState() =>
//       _ManifestCheckReportWidgetState();
// }

// class _ManifestCheckReportWidgetState extends State<ManifestCheckReportWidget> {
//   // Define TextEditingControllers for each field
//   final TextEditingController _invoicePackingController =
//       TextEditingController();
//   final TextEditingController _buyersPoController = TextEditingController();
//   final TextEditingController _consigneeController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _pieceCountController = TextEditingController();
//   final TextEditingController _cartonBoxesController = TextEditingController();
//   final TextEditingController _grossWeightController = TextEditingController();
//   final TextEditingController _forwarderDetailsController =
//       TextEditingController();
//   final TextEditingController _engineNoController = TextEditingController();
//   final TextEditingController _chassisNoController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: Text(
//         "Manifest Check Report Details",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 18,
//           color: Colors.blue, // Title color
//         ),
//       ),
//       children: [
//         _customTextFieldForManifest("Invoice Packing", _invoicePackingController),
//         _customTextFieldForManifest("Buyers Po", _buyersPoController),
//         _customTextFieldForManifest("Consignee", _consigneeController),
//         _customTextFieldForManifest("Description", _descriptionController),
//         _customTextFieldForManifest("Piece Count", _pieceCountController),
//         _customTextFieldForManifest("Carton Boxes", _cartonBoxesController),
//         _customTextFieldForManifest("Gross Weight", _grossWeightController),
//         _customTextFieldForManifest("Forwarder Details", _forwarderDetailsController),
//         _customTextFieldForManifest("Engine No", _engineNoController),
//         _customTextFieldForManifest("Chassis No", _chassisNoController),
//         _customTextFieldForManifest("Destination", _destinationController),
//       ],
//     );
//   }

//   Widget _customTextFieldForManifest(String labelText, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: labelText,
//           // labelStyle: TextStyle(color: Colors.blue), // Label color
//           border: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.blue), // Border color
//           ),
//           hintText: "Enter $labelText",
//           hintStyle: TextStyle(color: Colors.grey), // Hint text color
//           fillColor: Colors.white, // Text field background color
//           filled: true,
//         ),
//       ),
//     );
//   }
// }

// class ManifestCheckReportWidget extends StatefulWidget {
//   final TextEditingController sealNoController;
//   final TextEditingController linearSealController;
//   final TextEditingController customSealController;
//   final TextEditingController otherSealController;

//   ManifestCheckReportWidget({
//     required this.sealNoController,
//     required this.linearSealController,
//     required this.customSealController,
//     required this.otherSealController,
//   });

//   @override
//   State<ManifestCheckReportWidget> createState() =>
//       _ManifestCheckReportWidgetState();
// }

// class _ManifestCheckReportWidgetState extends State<ManifestCheckReportWidget> {
//   final TextEditingController _invoicePackingController =
//       TextEditingController();
//   final TextEditingController _buyersPoController = TextEditingController();
//   final TextEditingController _consigneeController = TextEditingController();
//   final TextEditingController _descriptionController = TextEditingController();
//   final TextEditingController _pieceCountController = TextEditingController();
//   final TextEditingController _cartonBoxesController = TextEditingController();
//   final TextEditingController _grossWeightController = TextEditingController();
//   final TextEditingController _forwarderDetailsController =
//       TextEditingController();
//   final TextEditingController _engineNoController = TextEditingController();
//   final TextEditingController _chassisNoController = TextEditingController();
//   final TextEditingController _destinationController = TextEditingController();
//   final TextEditingController _combinedSealController =
//       TextEditingController(); // Combined seal text field controller

//   @override
//   void initState() {
//     super.initState();

//     // Attach listeners to update combined seal field
//     widget.sealNoController.addListener(_updateCombinedSeal);
//     widget.linearSealController.addListener(_updateCombinedSeal);
//     widget.customSealController.addListener(_updateCombinedSeal);
//     widget.otherSealController.addListener(_updateCombinedSeal);

//     // Attach listener to combined field for manual edits
//     _combinedSealController.addListener(_updateIndividualSeals);

//     // Initialize the combined seal field
//     _updateCombinedSeal();
//   }

//   @override
//   void dispose() {
//     // Remove listeners
//     widget.sealNoController.removeListener(_updateCombinedSeal);
//     widget.linearSealController.removeListener(_updateCombinedSeal);
//     widget.customSealController.removeListener(_updateCombinedSeal);
//     widget.otherSealController.removeListener(_updateCombinedSeal);

//     _combinedSealController.removeListener(_updateIndividualSeals);
//     super.dispose();
//   }

//   void _updateCombinedSeal() {
//     // Update the combined seal field based on individual fields
//     _combinedSealController.text = [
//       widget.sealNoController.text,
//       widget.linearSealController.text,
//       widget.customSealController.text,
//       widget.otherSealController.text
//     ].where((seal) => seal.isNotEmpty).join(", ");
//   }

//   void _updateIndividualSeals() {
//     // Update individual fields based on combined field value
//     if (!_combinedSealController.text.contains(", "))
//       return; // Ensure valid format

//     final seals = _combinedSealController.text.split(", ");
//     setState(() {
//       widget.sealNoController.text = seals.length > 0 ? seals[0] : '';
//       widget.linearSealController.text = seals.length > 1 ? seals[1] : '';
//       widget.customSealController.text = seals.length > 2 ? seals[2] : '';
//       widget.otherSealController.text = seals.length > 3 ? seals[3] : '';
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ExpansionTile(
//       title: Text(
//         "Manifest Check Report Details",
//         style: TextStyle(
//           fontWeight: FontWeight.bold,
//           fontSize: 18,
//           color: Colors.blue,
//         ),
//       ),
//       children: [
//         _customTextFieldForManifest(
//             "Invoice Packing", _invoicePackingController),
//         _customTextFieldForManifest("Buyers Po", _buyersPoController),
//         _customTextFieldForManifest("Consignee", _consigneeController),
//         _customTextFieldForManifest("Description", _descriptionController),
//         _customTextFieldForManifest("Piece Count", _pieceCountController),
//         _customTextFieldForManifest("Carton Boxes", _cartonBoxesController),
//         _customTextFieldForManifest("Gross Weight", _grossWeightController),
//         _customTextFieldForManifest(
//             "Forwarder Details", _forwarderDetailsController),
//         _customTextFieldForManifest("Engine No", _engineNoController),
//         _customTextFieldForManifest("Chassis No", _chassisNoController),
//         _customTextFieldForManifest("Destination", _destinationController),
//         // Combined seal text field
//         _customTextFieldForManifest("Combined Seal", _combinedSealController),
//       ],
//     );
//   }

//   Widget _customTextFieldForManifest(
//       String labelText, TextEditingController controller) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
//       child: TextField(
//         controller: controller,
//         decoration: InputDecoration(
//           labelText: labelText,
//           border: OutlineInputBorder(
//             borderSide: BorderSide(color: Colors.blue),
//           ),
//           hintText: "Enter $labelText",
//           hintStyle: TextStyle(color: Colors.grey),
//           fillColor: Colors.white,
//           filled: true,
//         ),
//       ),
//     );
//   }
// }
