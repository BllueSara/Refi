import '../../domain/entities/profile_entity.dart';

class ProfileModel extends ProfileEntity {
  const ProfileModel({
    required super.id,
    super.fullName,
    super.avatarUrl,
    super.annualGoal,
    super.currentStreak,
    super.finishedBooksCount,
    super.totalQuotesCount,
  });

  factory ProfileModel.fromSupabase(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      fullName: json['full_name'],
      avatarUrl: json['avatar_url'],
      annualGoal: json['annual_goal'],
      currentStreak: json['current_streak'] ?? 0,
      finishedBooksCount: json['finished_books_count'] ?? 0,
      totalQuotesCount: json['total_quotes_count'] ?? 0,
    );
  }
}
