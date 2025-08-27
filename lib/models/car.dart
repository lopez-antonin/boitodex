import 'dart:typed_data';

/// Car model representing a collectible car
class Car {
  final int? id;
  final String brand;
  final String shape;
  final String name;
  final String? informations;
  final bool isPiggyBank;
  final bool playsMusic;
  final Uint8List? photo;
  final DateTime createdAt;
  final DateTime updatedAt;

  Car({
    this.id,
    required this.brand,
    required this.shape,
    required this.name,
    this.informations,
    this.isPiggyBank = false,
    this.playsMusic = false,
    this.photo,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  /// Create a copy of the car with updated fields
  Car copyWith({
    int? id,
    String? brand,
    String? shape,
    String? name,
    String? informations,
    bool? isPiggyBank,
    bool? playsMusic,
    Uint8List? photo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      shape: shape ?? this.shape,
      name: name ?? this.name,
      informations: informations ?? this.informations,
      isPiggyBank: isPiggyBank ?? this.isPiggyBank,
      playsMusic: playsMusic ?? this.playsMusic,
      photo: photo ?? this.photo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  /// Convert car to database map
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

  /// Create car from database map
  factory Car.fromMap(Map<String, dynamic> map) {
    return Car(
      id: map['id'] as int?,
      brand: map['brand'] as String? ?? '',
      shape: map['shape'] as String? ?? '',
      name: map['name'] as String? ?? '',
      informations: map['informations'] as String?,
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

  /// Convert car to JSON for export
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