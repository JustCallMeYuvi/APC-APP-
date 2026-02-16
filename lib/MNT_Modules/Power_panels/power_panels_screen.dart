import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_bloc.dart';
import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_event.dart';
import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_names_model.dart';
import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_repository.dart';
import 'package:animated_movies_app/MNT_Modules/Power_panels/power_panel_state.dart';
import 'package:animated_movies_app/screens/onboarding_screen/login_page.dart';
import 'package:drop_down_search_field/drop_down_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PowerPanelsScreen extends StatefulWidget {
  final LoginModelApi userData;
  const PowerPanelsScreen({Key? key, required this.userData}) : super(key: key);

  @override
  _PowerPanelsScreenState createState() => _PowerPanelsScreenState();
}

class _PowerPanelsScreenState extends State<PowerPanelsScreen>
    with SingleTickerProviderStateMixin {
  late PowerPanelBloc bloc;
  late AnimationController controller;
  final ScrollController _scrollController = ScrollController();

  DateTime? fromDate;
  DateTime? toDate;
  String? selectedPanelId;

  final TextEditingController _panelController = TextEditingController();
  List<PowerPanelNamesModel> panelList = [];

  @override
  void initState() {
    super.initState();
    bloc = PowerPanelBloc(PowerPanelRepository());
    bloc.add(FetchPowerPanels());

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  Future<void> pickDate(bool isFrom) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      setState(() {
        if (isFrom) {
          fromDate = date;
        } else {
          toDate = date;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => bloc,
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _scrollController.animateTo(
              0,
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            );
          },
          child: const Icon(Icons.arrow_upward),
        ),
        backgroundColor: const Color(0xffEEF2F7),
        body: BlocBuilder<PowerPanelBloc, PowerPanelState>(
          builder: (context, state) {
            if (state is PowerPanelLoaded) {
              panelList = state.panels;
            }

            return SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// DROPDOWN
                  if (panelList.isNotEmpty)
                    DropDownSearchField<PowerPanelNamesModel>(
                      textFieldConfiguration: TextFieldConfiguration(
                        controller: _panelController,
                        decoration: const InputDecoration(
                          labelText: "Select Power Panel",
                          border: OutlineInputBorder(),
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                      suggestionsCallback: (pattern) async {
                        return panelList.where((panel) => panel.displayName
                            .toLowerCase()
                            .contains(pattern.toLowerCase()));
                      },
                      itemBuilder: (context, suggestion) =>
                          ListTile(title: Text(suggestion.displayName)),
                      onSuggestionSelected: (suggestion) {
                        selectedPanelId = suggestion.powerPanelId;
                        _panelController.text = suggestion.displayName;
                      },
                      displayAllSuggestionWhenTap: true,
                      isMultiSelectDropdown: false,
                    ),

                  const SizedBox(height: 15),

                  /// FROM DATE
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "From Date",
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text: fromDate != null
                          ? fromDate.toString().split(' ')[0]
                          : '',
                    ),
                    onTap: () => pickDate(true),
                  ),

                  const SizedBox(height: 15),

                  /// TO DATE
                  TextField(
                    readOnly: true,
                    decoration: const InputDecoration(
                      labelText: "To Date",
                      border: OutlineInputBorder(),
                    ),
                    controller: TextEditingController(
                      text:
                          toDate != null ? toDate.toString().split(' ')[0] : '',
                    ),
                    onTap: () => pickDate(false),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xff1B8E3E), Color(0xff2ECC71)],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          if (selectedPanelId != null &&
                              fromDate != null &&
                              toDate != null) {
                            context.read<PowerPanelBloc>().add(
                                  FetchPanelHistory(
                                    powerPanelId: selectedPanelId!,
                                    fromDate:
                                        fromDate!.toString().split(' ')[0],
                                    toDate: toDate!.toString().split(' ')[0],
                                  ),
                                );
                          }
                        },
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, color: Colors.white),
                            SizedBox(width: 8),
                            Text(
                              "Search",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// LOADING
                  if (state is PowerPanelHistoryLoading)
                    const Center(child: CircularProgressIndicator()),

                  /// EMPTY
                  if (state is PowerPanelHistoryEmpty)
                    const Center(
                      child: Text(
                        "No Data Found",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),

                  /// DASHBOARD
                  if (state is PowerPanelHistoryLoaded)
                    FadeTransition(
                      opacity: controller..forward(),
                      child: buildDashboard(state.history),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /// DASHBOARD
  Widget buildDashboard(history) {
    final panel = history.panelDetails;
    final summary = history.summary;
    final records = history.records;

    int total = summary.totalCount;
    int overallGood = summary.overallGood;
    double percent = total == 0 ? 0 : overallGood / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(panel.powerPanelId,
        //     style: const TextStyle(
        //         fontSize: 18,
        //         fontWeight: FontWeight.w600)),

        // const SizedBox(height: 25),

        buildOverallCard(percent, panel.dB_NAME, panel.powerPanelId),

        const SizedBox(height: 25),

        buildPlantCard(panel),

        const SizedBox(height: 30),

        const Text("Inspection Breakdown",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),

        const SizedBox(height: 15),

        buildSummaryRow("Panel", summary.panelGood, summary.panelNotGood),
        buildSummaryRow("Switch", summary.switchGood, summary.switchNotGood),
        buildSummaryRow("Cable", summary.cableGood, summary.cableNotGood),

        const SizedBox(height: 30),

        const Text("Inspection Records",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600)),

        const SizedBox(height: 15),

        ...records.map((r) => buildRecordCard(r)).toList(),
      ],
    );
  }

  /// OVERALL CARD
  Widget buildOverallCard(
    double percent,
    String name,
    String panelId,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF4F6F8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  value: percent,
                  strokeWidth: 10,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: const AlwaysStoppedAnimation(Color(0xff1B8E3E)),
                ),
              ),
              Text(
                "${(percent * 100).toInt()}%",
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              )
            ],
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  panelId,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 6),
                Text(
                  name,
                  style: const TextStyle(color: Colors.black54),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget buildPlantCard(panel) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xffF4F6F8),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          buildPlantRow("Plant", panel.plant),
          const SizedBox(height: 12),
          buildPlantRow("Location", panel.location),
          const SizedBox(height: 12),
          buildPlantRow("Capacity", panel.capacity),
        ],
      ),
    );
  }

  Widget buildPlantRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  Widget buildSummaryRow(String title, int good, int bad) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Row(
            children: [
              statusChip("Good", good, Colors.green),
              const SizedBox(width: 10),
              statusChip("Not Good", bad, Colors.redAccent),
            ],
          )
        ],
      ),
    );
  }

  Widget statusChip(String label, int value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        "$label: $value",
        style:
            TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12),
      ),
    );
  }

  Widget buildRecordCard(record) {
    bool overallBad = record.overallCondition == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xffF4F6F8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Inspection By: ${record.createdBy}",
              style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(record.createdDate,
              style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 12),
          Row(
            children: [
              conditionIcon(record.panelCondition),
              conditionIcon(record.switchCondition),
              conditionIcon(record.cableCondition),
              const Spacer(),
              Icon(
                overallBad ? Icons.cancel : Icons.check_circle,
                color: overallBad ? Colors.red : Colors.green,
              )
            ],
          )
        ],
      ),
    );
  }

  Widget conditionIcon(int value) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Icon(
        value == 1 ? Icons.check_circle : Icons.cancel,
        color: value == 1 ? Colors.green : Colors.red,
      ),
    );
  }
}
