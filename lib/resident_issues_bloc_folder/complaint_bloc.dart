import 'dart:convert';
import 'package:animated_movies_app/api/apis_page.dart';
import 'package:animated_movies_app/resident_issues_bloc_folder/complaint_event.dart';
import 'package:animated_movies_app/resident_issues_bloc_folder/complaint_fetch_api_model.dart';
import 'package:animated_movies_app/resident_issues_bloc_folder/complaint_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

class ComplaintResidentBloc
    extends Bloc<ComplaintResidentEvent, ComplaintResidentState> {
  ComplaintResidentBloc() : super(ComplaintResidentState()) {
    on<FetchComplaints>(_fetchResidentComplaints);
  }

  Future<void> _fetchResidentComplaints(
      FetchComplaints event, Emitter<ComplaintResidentState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));

    try {
      final url = '${ApiHelper.dormitoryURL}'
          'complaints-by-barcode/${event.empNo}';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        print('fetch compliants ${response.body}');

        final complaints =
            data.map((e) => ComplaintFetchAPIModel.fromJson(e)).toList();

        emit(state.copyWith(
          isLoading: false,
          complaints: complaints,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Failed to load complaints',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: e.toString(),
      ));
    } 
  }
}
