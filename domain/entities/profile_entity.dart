import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? nationalId;
  final String? nationality;
  final String? qiraat;
  final String? profileImage;
  final String role;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileEntity({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.nationalId,
    this.nationality,
    this.qiraat,
    this.profileImage,
    required this.role,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  ProfileEntity copyWith({
    int? id,
    String? name,
    String? email,
    String? phone,
    String? nationalId,
    String? nationality,
    String? qiraat,
    String? profileImage,
    String? role,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      nationalId: nationalId ?? this.nationalId,
      nationality: nationality ?? this.nationality,
      qiraat: qiraat ?? this.qiraat,
      profileImage: profileImage ?? this.profileImage,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        email,
        phone,
        nationalId,
        nationality,
        qiraat,
        profileImage,
        role,
        isActive,
        createdAt,
        updatedAt,
      ];
}
