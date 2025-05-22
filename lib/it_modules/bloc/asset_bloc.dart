import 'package:flutter_bloc/flutter_bloc.dart';
import 'asset_event.dart';
import 'asset_state.dart';

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  AssetBloc() : super(AssetState(selectedDate: DateTime.now())) {
    on<DateChanged>((event, emit) {
      emit(state.copyWith(selectedDate: event.date));
    });

    on<AssetIdChanged>((event, emit) {
      emit(state.copyWith(selectedAssetId: event.assetId));
    });

    on<DescriptionChanged>((event, emit) {
      emit(state.copyWith(description: event.description));
    });

    on<SubmitAsset>((event, emit) {
      print("Asset ID: ${state.selectedAssetId}");
      print("Date: ${state.selectedDate}");
      print("Description: ${state.description}");
    });
  }
}
