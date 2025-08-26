import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/datasources/car_database.dart';
import '../../data/repositories/car_repository.dart';
import '../../services/image_service.dart';
import '../../services/export_service.dart';
import 'car_notifier.dart';

// Database
final carDatabaseProvider = Provider<CarDatabase>((ref) {
  return CarDatabase();
});

// Repository
final carRepositoryProvider = Provider<CarRepository>((ref) {
  final database = ref.watch(carDatabaseProvider);
  return CarRepositoryImpl(database);
});

// Services
final imagePickerProvider = Provider<ImagePicker>((ref) {
  return ImagePicker();
});

final imageServiceProvider = Provider<ImageService>((ref) {
  final picker = ref.watch(imagePickerProvider);
  return ImageServiceImpl(picker);
});

final exportServiceProvider = Provider<ExportService>((ref) {
  return ExportServiceImpl();
});

// Car State Management
final carNotifierProvider = StateNotifierProvider<CarNotifier, CarState>((ref) {
  final repository = ref.watch(carRepositoryProvider);
  return CarNotifier(repository);
});

// Export State Management
final exportNotifierProvider = StateNotifierProvider<ExportNotifier, ExportState>((ref) {
  final repository = ref.watch(carRepositoryProvider);
  final exportService = ref.watch(exportServiceProvider);
  return ExportNotifier(repository, exportService);
});

class ExportState {
  final bool isExporting;
  final String? error;
  final String? successMessage;

  const ExportState({
    this.isExporting = false,
    this.error,
    this.successMessage,
  });

  ExportState copyWith({
    bool? isExporting,
    String? error,
    String? successMessage,
  }) {
    return ExportState(
      isExporting: isExporting ?? this.isExporting,
      error: error,
      successMessage: successMessage,
    );
  }
}

class ExportNotifier extends StateNotifier<ExportState> {
  final CarRepository _repository;
  final ExportService _exportService;

  ExportNotifier(this._repository, this._exportService) : super(const ExportState());

  Future<void> exportCollection() async {
    state = state.copyWith(isExporting: true, error: null, successMessage: null);

    final carsResult = await _repository.getAllCarsForExport();

    if (carsResult.isFailure) {
      state = state.copyWith(
        isExporting: false,
        error: carsResult.error,
      );
      return;
    }

    final exportResult = await _exportService.exportToJson(carsResult.data!);

    if (exportResult.isFailure) {
      state = state.copyWith(
        isExporting: false,
        error: exportResult.error,
      );
      return;
    }

    final shareResult = await _exportService.shareExport(exportResult.data!);

    if (shareResult.isFailure) {
      state = state.copyWith(
        isExporting: false,
        error: shareResult.error,
      );
      return;
    }

    state = state.copyWith(
      isExporting: false,
      successMessage: 'Collection exportée avec succès!',
    );
  }

  void clearMessages() {
    state = state.copyWith(error: null, successMessage: null);
  }
}