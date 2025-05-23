import 'package:animated_movies_app/it_modules/bloc/repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'asset_event.dart';
import 'asset_state.dart';

// late final AssetRepository repository; ❌ BAD
final AssetRepository repository = AssetRepository();

class AssetBloc extends Bloc<AssetEvent, AssetState> {
  AssetBloc() : super(AssetState(selectedDate: DateTime.now())) {
    on<FetchAssetIds>((event, emit) async {
      try {
        final assetIds = await repository.fetchAssetIds();
        emit(state.classDetails(assetIds: assetIds));
      } catch (e) {
        // Handle error accordingly
        print('Error fetching asset IDs: $e');
      }
    });
    on<DateChanged>((event, emit) {
      emit(state.classDetails(selectedDate: event.date));
    });

    on<AssetIdChanged>((event, emit) {
      emit(state.classDetails(selectedAssetId: event.assetId));
    });

    on<DescriptionChanged>((event, emit) {
      emit(state.classDetails(description: event.description));
    });
    on<PlantChanged>((event, emit) {
      // print("Plant changed to: ${event.plant}");
      emit(state.classDetails(selectedPlants: event.plant));
    });

    on<AssetTypeChanged>((event, emit) {
      emit(state.classDetails(
          assetType: event.assetType, issueType: null)); // Reset issueType
    });

    on<IssueTypeChanged>((event, emit) {
      emit(state.classDetails(issueType: event.issueType));
    });
    on<EmailChanged>((event, emit) {
      emit(state.classDetails(email: event.email));
    });

    on<PhoneChanged>((event, emit) {
      emit(state.classDetails(phone: event.phone));
    });

    on<SubmitAsset>((event, emit) {
      print("Asset ID: ${state.selectedAssetId}");
      print("Date: ${state.selectedDate}");
      print("Description: ${state.description}");
      print("Plant: ${state.selectedPlants}");
      print("Asste type: ${state.assetType}");
      print('Issue Type:${state.issueType}');
    });
  }
}
