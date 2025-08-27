import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../core/constants/app_constants.dart';
import '../models/car.dart';

/// Service for exporting car collection data
class ExportService {

  /// Export cars to JSON file and share it
  Future<bool> exportCars(List<Car> cars) async {
    try {
      // Create export data structure
      final exportData = {
        'version': '1.0',
        'exportDate': DateTime.now().toIso8601String(),
        'totalCars': cars.length,
        'cars': cars.map((car) => car.toJson()).toList(),
      };

      // Convert to JSON string
      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);

      // Get temporary directory and create file
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final fileName = '${AppConstants.exportFileName}_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      // Write JSON to file
      await file.writeAsString(jsonString);

      // Share the file
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Export de ma collection Boitodex',
        subject: 'Collection Boitodex',
      );

      return true;
    } catch (e) {
      return false;
    }
  }
}