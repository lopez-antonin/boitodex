import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/utils/result.dart';
import '../data/models/car_model.dart';
import '../core/constants/app_constants.dart';
import '../core/errors/exceptions.dart';

abstract class ExportService {
  Future<Result<String>> exportToJson(List<CarModel> cars);
  Future<Result<bool>> shareExport(String filePath);
}

class ExportServiceImpl implements ExportService {
  @override
  Future<Result<String>> exportToJson(List<CarModel> cars) async {
    try {
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalCars': cars.length,
        'cars': cars.map((car) => car.toJson()).toList(),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${AppConstants.exportFileName}_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);

      return Success(file.path);
    } catch (e) {
      return Failure('Erreur lors de l\'export: ${e.toString()}');
    }
  }

  @override
  Future<Result<bool>> shareExport(String filePath) async {
    try {
      await Share.shareXFiles(
        [XFile(filePath)],
        text: 'Export de ma collection Boitodex',
        subject: 'Collection Boitodex',
      );

      return const Success(true);
    } catch (e) {
      return Failure('Erreur lors du partage: ${e.toString()}');
    }
  }
}