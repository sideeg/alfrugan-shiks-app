// Path: lib/data/models/auth/sheikh_model.dart
import '../../../domain/entities/auth/sheikh_entity.dart';

class SheikhModel extends SheikhEntity {
  const SheikhModel({
    required int id,
    required String name,
    required String email,
    required String phone,
    required String nationalId,
    required String qiraat,
    String? profileImage,
    required String role,
    required bool isActive,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          name: name,
          email: email,
          phone: phone,
          nationalId: nationalId,
          qiraat: qiraat,
          profileImage: profileImage,
          role: role,
          isActive: isActive,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory SheikhModel.fromJson(Map<String, dynamic> json) {
    return SheikhModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      nationalId: json['national_id'] ?? '',
      qiraat: json['qiraat'] ?? '',
      profileImage: json['profile_image'],
      role: json['role'] ?? '',
      isActive: json['is_active'] ?? false,
      createdAt: DateTime.parse(
          json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'national_id': nationalId,
      'qiraat': qiraat,
      'profile_image': profileImage,
      'role': role,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
