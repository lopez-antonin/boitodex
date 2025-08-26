import 'dart:typed_data';
import 'package:uuid/uuid.dart';

class CarModel {
  final int? id;
  final String uuid;
  final String brand;
  final String shape;
  final String name;
  final bool isPiggyBank;
  final bool playsMusic;
  final Uint8List? photo;
  final DateTime createdAt;
  final DateTime updatedAt;

  CarModel({
    this.id,
    String? uuid,
    required this.brand,
    required this.shape,
    required this.name,
    required this.isPiggyBank,
    required this.playsMusic,
    this.photo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) : uuid = uuid ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  CarModel copyWith({
    int? id,
    String? uuid,
    String? brand,
    String? shape,
    String? name,
    bool? isPiggyBank,
    bool? playsMusic,
    Uint8List? photo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CarModel(
      id: id ?? this.id,
      uuid: uuid ?? this.uuid,
      brand: brand ?? this.brand,
      shape: shape ?? this.shape,
      name: name ?? this.name,
      isPiggyBank: isPiggyBank ?? this.isPiggyBank,
      playsMusic: playsMusic ?? this.playsMusic,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'uuid': uuid,
      'brand': brand,
      'shape': shape,
      'name': name,
      'is_piggy_bank': isPiggyBank ? 1 : 0,
      'plays_music': playsMusic ? 1 : 0,
      'photo': photo,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
    };
  }

  factory CarModel.fromMap(Map<String, Object?> map) {
    return CarModel(
      id: map['id'] as int?,
      uuid: map['uuid'] as String? ?? const Uuid().v4(),
      brand: map['brand'] as String? ?? '',
      shape: map['shape'] as String? ?? '',
      name: map['name'] as String? ?? '',
      isPiggyBank: (map['is_piggy_bank'] as int? ?? 0) == 1,
      playsMusic: (map['plays_music'] as int? ?? 0) == 1,
      photo: map['photo'] as Uint8List?,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
          map['created_at'] as int? ?? DateTime.now().millisecondsSinceEpoch
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
          map['updated_at'] as int? ?? DateTime.now().millisecondsSinceEpoch
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'brand': brand,
      'shape': shape,
      'name': name,
      'isPiggyBank': isPiggyBank,
      'playsMusic': playsMusic,
      'hasPhoto': photo != null,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}