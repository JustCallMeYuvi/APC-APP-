// production_bloc.dart
import 'dart:convert';

import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/it_modules/bloc/production_event.dart';
import 'package:animated_movies_app/it_modules/bloc/production_state.dart';
import 'package:animated_movies_app/screens/gms_screens/production_data_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class ProductionBloc extends Bloc<ProductionEvent, ProductionState> {
  ProductionBloc() : super(ProductionInitial()) {
    on<FetchProductionData>(_onFetchProductionData);
    on<FilterDepartmentData>(_onFilterDepartmentData);
  }

  ProductionDataModel? _cachedData;
  List<Map<String, dynamic>> _departmentData = [];

  Future<void> _onFetchProductionData(
      FetchProductionData event, Emitter<ProductionState> emit) async {
    emit(ProductionLoading());
    final formattedDate = DateFormat('yyyy-MM-dd').format(event.date);
    final apiUrl = '${ApiHelper.productionUrl}get-production?date=$formattedDate';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        final data = ProductionDataModel.fromJson(jsonData);
        _cachedData = data;
        _departmentData = data.departments.map((e) => e.toJson()).toList();

        emit(ProductionLoaded(
          deptNames: data.departmentList
              .map((e) => {'id': e, 'name': e})
              .toList(),
          companyLists: data.companyList
              .map((e) => {'id': e, 'name': e})
              .toList(),
          departmentData: _departmentData,
          filteredDepartmentData: _departmentData,
          summaryList: data.summary,
        ));
      } else {
        emit(ProductionError("Failed to load data. Status: ${response.statusCode}"));
      }
    } catch (e) {
      emit(ProductionError("Error fetching data: $e"));
    }
  }

  void _onFilterDepartmentData(
      FilterDepartmentData event, Emitter<ProductionState> emit) {
    if (_cachedData == null) return;

    final formattedDate = DateFormat('yyyy/MM/dd').format(event.selectedDate);
    final filtered = _departmentData.where((dept) {
      final matchesDept = event.selectedDeptId == null ||
          event.selectedDeptId == "ALL" ||
          dept['udf05'].toString() == event.selectedDeptId;

      final matchesDate = dept['scanDate'].toString() == formattedDate;

      return matchesDept && matchesDate;
    }).toList();

    emit(ProductionLoaded(
      deptNames: _cachedData!.departmentList
          .map((e) => {'id': e, 'name': e})
          .toList(),
      companyLists: _cachedData!.companyList
          .map((e) => {'id': e, 'name': e})
          .toList(),
      departmentData: _departmentData,
      filteredDepartmentData: filtered,
      summaryList: _cachedData!.summary,
    ));
  }
}
