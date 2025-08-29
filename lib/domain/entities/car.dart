import 'dart:typed_data';
import 'package:equatable/equatable.dart';

class Car extends Equatable {
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

  const Car({
    this.id,
    required this.brand,
    required this.shape,
    required this.name,
    this.informations,
    this.isPiggyBank = false,
    this.playsMusic = false,
    this.photo,
    required this.createdAt,
    required this.updatedAt,
  });

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

  @override
  List<Object?> get props => [
    id,
    brand,
    shape,
    name,
    informations,
    isPiggyBank,
    playsMusic,
    photo,
    createdAt,
    updatedAt,
  ];
}