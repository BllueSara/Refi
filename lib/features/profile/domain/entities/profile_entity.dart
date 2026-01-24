import 'package:equatable/equatable.dart';

class ProfileEntity extends Equatable {
  final String id;
  final String? fullName;
  final String? avatarUrl;
  final int? annualGoal;
  final int? currentStreak;
  final int finishedBooksCount;
  final int totalQuotesCount;

  const ProfileEntity({
    required this.id,
    this.fullName,
    this.avatarUrl,
    this.annualGoal,
    this.currentStreak,
    this.finishedBooksCount = 0,
    this.totalQuotesCount = 0,
  });

  @override
  List<Object?> get props => [
        id,
        fullName,
        avatarUrl,
        annualGoal,
        currentStreak,
        finishedBooksCount,
        totalQuotesCount,
      ];
}
