import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final int? annualGoal;
  final int? currentStreak;

  const ProfileEntity({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.annualGoal,
    this.currentStreak,
  });

  @override
  List<Object?> get props => [
    id,
    fullName,
    avatarUrl,
    annualGoal,
    currentStreak,
  ];
}
