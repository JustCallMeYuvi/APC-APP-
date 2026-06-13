import 'package:flutter/material.dart';

class CarFilterBar extends StatelessWidget {
  final String fromLabel, toLabel;
  final VoidCallback onFromTap, onToTap, onClear;
  final int resultCount;
  final bool isLoading;
  final List<String> carOptions;
  final String? selectedCar;
  final ValueChanged<String?> onCarChanged;
  final String statusFilter;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onSearch;

  const CarFilterBar({
    super.key,
    required this.fromLabel,
    required this.toLabel,
    required this.onFromTap,
    required this.onToTap,
    required this.onClear,
    required this.resultCount,
    required this.isLoading,
    required this.carOptions,
    required this.selectedCar,
    required this.onCarChanged,
    required this.statusFilter,
    required this.onStatusChanged,
    required this.onSearch,
  });

  Widget _dateChip(
      String label, String value, VoidCallback onTap, IconData icon) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                  color: const Color(0xFF1A1F36).withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF5B5FEF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 16, color: const Color(0xFF5B5FEF)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          fontSize: 10.5,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5)),
                  Text(
                    value.isEmpty ? 'Select' : value,
                    style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: value.isEmpty
                            ? Colors.grey[400]
                            : const Color(0xFF1E2139)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statusChip(String label, IconData icon, Color color) {
    final selected = statusFilter == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => onStatusChanged(label),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 10),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.12) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: selected ? color : const Color(0xFFE7E9F3), width: 1.4),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16, color: selected ? color : const Color(0xFF9AA0BD)),
              const SizedBox(width: 6),
              Text(label,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? color : const Color(0xFF9AA0BD),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
      child: Column(
        children: [
          Row(
            children: [
              _dateChip('FROM DATE', fromLabel, onFromTap,
                  Icons.calendar_today_rounded),
              const SizedBox(width: 10),
              _dateChip(
                  'TO DATE', toLabel, onToTap, Icons.event_available_rounded),
              const SizedBox(width: 10),
              InkWell(
                onTap: onSearch,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF1A1F36).withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
                  ),
                  child: const Icon(
                    Icons.search_rounded,
                    size: 22,
                    color: Color(0xFF5B5FEF),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                    color: const Color(0xFF1A1F36).withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E6FF7).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.local_taxi_rounded,
                      size: 16, color: Color(0xFF8E6FF7)),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedCar ?? 'All',
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded,
                          color: Color(0xFF9AA0BD)),
                      style: const TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E2139)),
                      items: carOptions
                          .map((c) => DropdownMenuItem(
                              value: c,
                              child: Text(c == 'All' ? 'All Cars' : c)))
                          .toList(),
                      onChanged: onCarChanged,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _statusChip('All', Icons.apps_rounded, const Color(0xFF5B5FEF)),
              _statusChip('Pending', Icons.hourglass_top_rounded,
                  const Color(0xFFF59E0B)),
              _statusChip(
                  'Done', Icons.check_circle_rounded, const Color(0xFF16A34A)),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Row(
              children: [
                if (isLoading)
                  const SizedBox(
                      width: 13,
                      height: 13,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Color(0xFF5B5FEF)))
                else
                  Icon(Icons.fact_check_rounded,
                      size: 15, color: Colors.grey[400]),
                const SizedBox(width: 6),
                Text(
                  isLoading
                      ? 'Loading...'
                      : '$resultCount booking${resultCount == 1 ? '' : 's'} found',
                  style: TextStyle(
                      fontSize: 12.5,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
