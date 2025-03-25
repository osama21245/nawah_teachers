// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
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

  UserModel copyWith({
    String? id,
    String? email,
    String? givenName,
    String? familyName,
    String? picture,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      givenName: givenName ?? this.givenName,
      familyName: familyName ?? this.familyName,
      picture: picture ?? this.picture,
      createdAt: createdAt ?? this.createdAt,
    );
  }

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

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, givenName: $givenName, familyName: $familyName, picture: $picture, createdAt: $createdAt)';
  }

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.email == email &&
        other.givenName == givenName &&
        other.familyName == familyName &&
        other.picture == picture &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        email.hashCode ^
        givenName.hashCode ^
        familyName.hashCode ^
        picture.hashCode ^
        createdAt.hashCode;
  }
}
