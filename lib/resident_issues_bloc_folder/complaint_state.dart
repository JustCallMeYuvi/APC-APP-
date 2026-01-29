import 'package:animated_movies_app/resident_issues_bloc_folder/complaint_fetch_api_model.dart';

class ComplaintResidentState {
  final bool isLoading;
  final List<ComplaintFetchAPIModel> complaints;
  final String? error;

  ComplaintResidentState({
    this.isLoading = false,
    this.complaints = const [],
    this.error,
  });

  ComplaintResidentState copyWith({
    bool? isLoading,
    List<ComplaintFetchAPIModel>? complaints,
    String? error,
  }) {
    return ComplaintResidentState(
      isLoading: isLoading ?? this.isLoading,
      complaints: complaints ?? this.complaints,
      error: error,
    );
  }
}
