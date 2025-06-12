import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';

class ProductionReportsModule extends StatefulWidget {
  final LoginModelApi userData;
  const ProductionReportsModule({Key? key, required this.userData})
      : super(key: key);

  @override
  _ProductionReportsModuleState createState() =>
      _ProductionReportsModuleState();
}

class _ProductionReportsModuleState extends State<ProductionReportsModule> {
  final List<String> reportOptions = ['RFT Report', 'IE Efficiency', 'B-Grade'];
  final List<String> plants = ['AP1', 'AP2', 'AP3'];
  final List<String> processsType = ['ALL', 'Stiching', 'Assembly', 'Cutting'];

  String? selectedReport;
  String? selectedPlants;
  String? selectedProcess;

  final TextEditingController _reportSearchController = TextEditingController();
  final TextEditingController _plantController = TextEditingController();
  final TextEditingController _processTypeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _reportSearchController,
                autofocus: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelText: "Search Report",
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (text) {
                  setState(() {
                    if (text.isEmpty) selectedReport = null;
                  });
                },
              ),
              suggestionsCallback: (pattern) async {
                if (pattern.isEmpty) return reportOptions;
                return reportOptions
                    .where((option) =>
                        option.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  selectedReport = suggestion;
                  _reportSearchController.text = suggestion;
                });
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),
            const SizedBox(
              height: 20,
            ),
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _plantController,
                autofocus: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelText: "Search Plant",
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (text) {
                  setState(() {
                    if (text.isEmpty) selectedPlants = null;
                  });
                },
              ),
              suggestionsCallback: (pattern) async {
                if (pattern.isEmpty) return plants;
                return plants
                    .where((option) =>
                        option.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  selectedPlants = suggestion;
                  _plantController.text = suggestion;
                });
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),
            const SizedBox(
              height: 20,
            ),
            DropDownSearchField(
              textFieldConfiguration: TextFieldConfiguration(
                controller: _processTypeController,
                autofocus: false,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                  ),
                  labelText: "Search Process",
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (text) {
                  setState(() {
                    if (text.isEmpty) selectedProcess = null;
                  });
                },
              ),
              suggestionsCallback: (pattern) async {
                if (pattern.isEmpty) return processsType;
                return processsType
                    .where((option) =>
                        option.toLowerCase().contains(pattern.toLowerCase()))
                    .toList();
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: const Icon(Icons.assignment_outlined),
                  title: Text(suggestion),
                );
              },
              onSuggestionSelected: (suggestion) {
                setState(() {
                  selectedProcess = suggestion;
                  _processTypeController.text = suggestion;
                });
              },
              displayAllSuggestionWhenTap: true,
              isMultiSelectDropdown: false,
            ),
          ],
        ),
      ),
    );
  }
}
