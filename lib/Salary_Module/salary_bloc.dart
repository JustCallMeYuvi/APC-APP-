import 'package:flutter_bloc/flutter_bloc.dart';
import 'salary_event.dart';
import 'salary_state.dart';
import 'salary_repository.dart';
import 'salary_model.dart';

class SalaryBloc extends Bloc<SalaryEvent, SalaryState> {
  final SalaryRepository repository;

  SalaryBloc(this.repository) : super(SalaryInitial()) {

    on<FetchSalary>((event, emit) async {

      emit(SalaryLoading());

      try {

        final List<SalaryModel>? salaries =
            await repository.fetchSalary(
          barcode: event.barcode,
          fromDate: event.fromDate,
          toDate: event.toDate,
        );

        /// ✅ No Data
        if (salaries == null || salaries.isEmpty) {
          emit(SalaryNoData());
        }
        /// ✅ Success
        else {
          emit(SalaryLoaded(salaries));
        }

      } catch (e) {

        emit(
          SalaryError(
            e.toString(),
          ),
        );
      }
    });
  }
}
