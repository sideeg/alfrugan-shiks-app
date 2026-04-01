// Path:   entities/profile_update_request.dart

import 'dart:io';
import 'package:equatable/equatable.dart';

class ProfileUpdateRequest extends Equatable {
  final String name;
  final String email;
  final String? phone;
  final String? nationalId;
  final String? qiraat;
  final File? profileImageFile;

  const ProfileUpdateRequest({
    required this.name,
    required this.email,
    this.phone,
    this.nationalId,
    this.qiraat,
    this.profileImageFile,
  });

  @override
  List<Object?> get props => [
        name,
        email,
        phone,
        nationalId,
        qiraat,
        profileImageFile,
      ];
}
