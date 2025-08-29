import 'dart:typed_data';
import '../../domain/entities/car.dart';

class CarModel extends Car {
  const CarModel({
    super.id,
    required super.brand,
    required super.shape,
    required super.name,
    super.informations,
    super.isPiggyBank = false,
    super.playsMusic = false,
    super.photo,
    required super.createdAt,
    required super.updatedAt,
  });

  factory CarModel.fromMap(Map<String, dynamic> map) {
    return CarModel(
      id: map['id'] as int?,
      brand: map['brand'] as String? ?? '',
      shape: map['shape'] as String? ?? '',
      name: map['name'] as String? ?? '',
      informations: map['informations'] as String?,
      isPiggyBank: (map['is_piggy_bank'] as int? ?? 0) == 1,
      playsMusic: (map['plays_music'] as int? ?? 0) == 1,
      photo: map['photo'] as Uint8List?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        map['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        map['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'shape': shape,
      'name': name,
      'informations': informations,
      'is_piggy_bank': isPiggyBank ? 1 : 0,
      'plays_music': playsMusic ? 1 : 0,
      'photo': photo,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CarModel.fromEntity(Car car) {
    return CarModel(
      id: car.id,
      brand: car.brand,
      shape: car.shape,
      name: car.name,
      informations: car.informations,
      isPiggyBank: car.isPiggyBank,
      playsMusic: car.playsMusic,
      photo: car.photo,
      createdAt: car.createdAt,
      updatedAt: car.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'brand': brand,
      'shape': shape,
      'name': name,
      'informations': informations,
      'isPiggyBank': isPiggyBank,
      'playsMusic': playsMusic,
      'hasPhoto': photo != null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}