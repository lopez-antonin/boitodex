import 'package:get_it/get_it.dart';
import '../../data/datasources/local/car_local_datasource.dart';
import '../../data/repositories/car_repository_impl.dart';
import '../../data/services/database_service.dart';
import '../../domain/repositories/car_repository.dart';
import '../../domain/usecases/cars/add_car.dart';
import '../../domain/usecases/cars/delete_car.dart';
import '../../domain/usecases/cars/get_cars.dart';
import '../../domain/usecases/cars/update_car.dart';
import '../../domain/usecases/export/export_cars.dart';
import '../../domain/usecases/media/pick_image.dart';
import '../../features/car_form/data/services/image_service.dart';
import '../../features/car_form/data/services/export_service.dart';
import '../../features/car_form/presentation/viewmodel/car_form_viewmodel.dart';
import '../../features/home/presentation/viewmodel/home_viewmodel.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Services
  locator.registerLazySingleton<DatabaseService>(() => DatabaseService());
  locator.registerLazySingleton<ImageService>(() => ImageService());
  locator.registerLazySingleton<ExportService>(() => ExportService());

  // Data sources
  locator.registerLazySingleton<CarLocalDataSource>(
        () => CarLocalDataSourceImpl(locator()),
  );

  // Repositories
  locator.registerLazySingleton<CarRepository>(
        () => CarRepositoryImpl(locator()),
  );

  // Use cases
  locator.registerLazySingleton(() => AddCar(locator()));
  locator.registerLazySingleton(() => DeleteCar(locator()));
  locator.registerLazySingleton(() => GetCars(locator()));
  locator.registerLazySingleton(() => UpdateCar(locator()));
  locator.registerLazySingleton(() => ExportCars(locator(), locator()));
  locator.registerLazySingleton(() => PickImage(locator()));

  // ViewModels
  locator.registerFactory(() => HomeViewModel(
    getCars: locator(),
    deleteCar: locator(),
    exportCars: locator(),
  ));

  locator.registerFactory(() => CarFormViewModel(
    addCar: locator(),
    updateCar: locator(),
    deleteCar: locator(),
    pickImage: locator(),
  ));
}