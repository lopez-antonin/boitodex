import 'dart:typed_data';

class Car {
  final int? id;
  final String brand;
  final String shape;
  final String name;
  final bool isPiggyBank;
  final bool playsMusic;
  final Uint8List? photo; // stored as bytes (BLOB in SQLite)

  Car({
    this.id,
    required this.brand,
    required this.shape,
    required this.name,
    required this.isPiggyBank,
    required this.playsMusic,
    this.photo,
  });

  Car copyWith({
    int? id,
    String? brand,
    String? shape,
    String? name,
    bool? isPiggyBank,
    bool? playsMusic,
    Uint8List? photo,
  }) {
    return Car(
      id: id ?? this.id,
      brand: brand ?? this.brand,
      shape: shape ?? this.shape,
      name: name ?? this.name,
      isPiggyBank: isPiggyBank ?? this.isPiggyBank,
      playsMusic: playsMusic ?? this.playsMusic,
      photo: photo ?? this.photo,
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'brand': brand,
      'shape': shape,
      'name': name,
      // store booleans as integers 0/1
      'is_piggy_bank': isPiggyBank ? 1 : 0,
      'plays_music': playsMusic ? 1 : 0,
      'photo': photo,
    };
  }

  factory Car.fromMap(Map<String, Object?> map) {
    return Car(
      id: map['id'] as int?,
      brand: map['brand'] as String? ?? '',
      shape: map['shape'] as String? ?? '',
      name: map['name'] as String? ?? '',
      isPiggyBank: (map['is_piggy_bank'] as int? ?? 0) == 1,
      playsMusic: (map['plays_music'] as int? ?? 0) == 1,
      photo: map['photo'] as Uint8List?,
    );
  }
}
