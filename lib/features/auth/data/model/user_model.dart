import 'package:kinde_flutter_sdk/kinde_flutter_sdk.dart';

class UserModel {
  final String id;
  final String email;
  final String? givenName;
  final String? familyName;
  final String? picture;
  final DateTime createdAt;

  UserModel({
    required this.id,
    required this.email,
    this.givenName,
    this.familyName,
    this.picture,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'given_name': givenName,
      'family_name': familyName,
      'picture': picture,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      givenName: map['given_name'],
      familyName: map['family_name'],
      picture: map['picture'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  factory UserModel.fromKindeProfile(UserProfileV2 profile) {
    return UserModel(
      id: profile.id ?? '',
      email: profile.email ?? '',
      givenName: profile.givenName,
      familyName: profile.familyName,
      picture: profile.picture,
      createdAt: DateTime.now(),
    );
  }
}
