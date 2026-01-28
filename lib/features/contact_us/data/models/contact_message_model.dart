import 'package:equatable/equatable.dart';

class ContactMessageModel extends Equatable {
  final String? id;
  final String category;
  final String message;
  final String? userId;
  final String? userEmail;
  final String? userName;
  final DateTime createdAt;
  final String status; // 'pending', 'read', 'responded'

  const ContactMessageModel({
    this.id,
    required this.category,
    required this.message,
    this.userId,
    this.userEmail,
    this.userName,
    required this.createdAt,
    this.status = 'pending',
  });

  factory ContactMessageModel.fromSupabase(Map<String, dynamic> json) {
    return ContactMessageModel(
      id: json['id'] as String?,
      category: json['category'] as String,
      message: json['message'] as String,
      userId: json['user_id'] as String?,
      userEmail: json['user_email'] as String?,
      userName: json['user_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      status: json['status'] as String? ?? 'pending',
    );
  }

  Map<String, dynamic> toSupabase() {
    return {
      if (id != null) 'id': id,
      'category': category,
      'message': message,
      if (userId != null) 'user_id': userId,
      if (userEmail != null) 'user_email': userEmail,
      if (userName != null) 'user_name': userName,
      'created_at': createdAt.toIso8601String(),
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        id,
        category,
        message,
        userId,
        userEmail,
        userName,
        createdAt,
        status,
      ];
}

