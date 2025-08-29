import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../../../data/models/car_model.dart';

class ExportService {
  Future<bool> exportCars(List<CarModel> cars) async {
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
      final fileName = 'boitodex_export_$timestamp.json';
      final file = File('${directory.path}/$fileName');

      await file.writeAsString(jsonString);

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