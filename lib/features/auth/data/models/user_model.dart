import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({required super.id, required super.email, super.name});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['full_name'] as String?,
    );
  }

  factory UserModel.fromSupabase(User user, {String? name}) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      name: name ?? user.userMetadata?['full_name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'email': email, 'full_name': name};
  }
}
