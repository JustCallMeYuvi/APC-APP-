import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/dormitory/department_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'complaint_event.dart';
import 'complaint_state.dart';

class ComplaintBloc extends Bloc<ComplaintEvent, ComplaintState> {
  ComplaintBloc() : super(ComplaintState.initial()) {
    // on<LoadComplaintTypes>(_loadTypes);
    on<LoadComplaintTypes>(_loadTypesFromApi);
    on<SelectComplaintType>(_selectType);
    on<SubmitComplaint>(_submitComplaint);
  }

  Future<void> _loadTypesFromApi(
      LoadComplaintTypes event, Emitter<ComplaintState> emit) async {
    final url = Uri.parse('${ApiHelper.dormitoryURL}department-dropdown');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);

      final departments = data.map((e) => DepartmentModel.fromJson(e)).toList();

      emit(state.copyWith(departments: departments));
    } else {
      emit(state.copyWith(error: "Failed to load departments"));
    }
  }

  void _selectType(SelectComplaintType event, Emitter<ComplaintState> emit) {
    emit(state.copyWith(selectedDept: event.department));
  }

  Future<void> _submitComplaint(
      SubmitComplaint event, Emitter<ComplaintState> emit) async {
    if (state.selectedDept == null || event.description.isEmpty) {
      emit(state.copyWith(error: "Please fill all fields"));
      return;
    }

    final body = {
      "complaint": event.description.trim(),
      "complaintRelatedDept": state.selectedDept!.dept, // ✅ IT-Hardware
      "raisedBy": event.empNo.toString(),
      "raisedDate": DateTime.now().toIso8601String().split('.').first,
      "raisedDept": event.employeeDept,
      "email": state.selectedDept!.mail, // ✅ it@dormitory.com
      "active": 0,
    };

    print("FINAL BODY => $body");

    final response = await http.post(
      Uri.parse('${ApiHelper.dormitoryURL}add-resident-complaint'),
      headers: {
        "Content-Type": "application/json",
        "Accept": "application/json",
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      emit(state.copyWith(isSuccess: true, isLoading: false));
    } else {
      print("ERROR BODY => ${response.body}");
      emit(state.copyWith(error: "Failed to submit complaint"));
    }
  }
}
