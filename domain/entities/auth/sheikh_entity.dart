// Path: lib/domain/entities/auth/sheikh_entity.dart
import 'package:equatable/equatable.dart';

class SheikhEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String nationalId;
  final String qiraat;
  final String? profileImage;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SheikhEntity({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.nationalId,
    required this.qiraat,
    this.profileImage,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        nationalId,
        qiraat,
        profileImage,
        role,
        isActive,
        createdAt,
        updatedAt,
      ];

  static SheikhEntity fromModel(dynamic model) {
    // Replace 'dynamic' with your actual model type, e.g., SheikhModel
    // Map model fields to entity fields here
    return SheikhEntity(
      id: model.id,
      name: model.name,
      email: model.email,
      phone: model.phone,
      nationalId: model.nationalId,
      qiraat: model.qiraat,
      profileImage: model.profileImage,
      role: model.role,
      isActive: model.isActive,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }

  SheikhEntity copyWith({
    String? name,
    String? email,
    String? phone,
    String? nationalId,
    String? qiraat,
    String? profileImage,
    int? id,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SheikhEntity(
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      qiraat: qiraat ?? this.qiraat,
      profileImage: profileImage ?? this.profileImage,
      id: id ?? this.id,
      role: '',
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
