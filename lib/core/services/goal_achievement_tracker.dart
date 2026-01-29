import 'package:shared_preferences/shared_preferences.dart';

class GoalAchievementTracker {
  static const String _keyPrefix = 'goal_celebrated_';
  static const String _globalKey = 'goal_celebrated_ever';

  /// Check if goal achievement has been celebrated this year
  static Future<bool> hasCelebratedThisYear() async {
    final prefs = await SharedPreferences.getInstance();
    // Check global flag first (show only once ever)
    final hasCelebratedEver = prefs.getBool(_globalKey) ?? false;
    if (hasCelebratedEver) return true;
    
    // Fallback to per-year check for backward compatibility
    final currentYear = DateTime.now().year;
    final key = '$_keyPrefix$currentYear';
    return prefs.getBool(key) ?? false;
  }

  /// Mark goal achievement as celebrated for this year
  static Future<void> markAsCelebrated() async {
    final prefs = await SharedPreferences.getInstance();
    // Mark globally (show only once ever)
    await prefs.setBool(_globalKey, true);
    
    // Also mark for current year for backward compatibility
    final currentYear = DateTime.now().year;
    final key = '$_keyPrefix$currentYear';
    await prefs.setBool(key, true);
  }

  /// Reset celebration status (useful for testing or if user wants to see it again)
  static Future<void> resetCelebration() async {
    final prefs = await SharedPreferences.getInstance();
    // Reset both global and per-year flags
    await prefs.remove(_globalKey);
    final currentYear = DateTime.now().year;
    final key = '$_keyPrefix$currentYear';
    await prefs.remove(key);
  }

  /// Check if goal is achieved
  static bool isGoalAchieved(int completedBooks, int? annualGoal) {
    if (annualGoal == null || annualGoal <= 0) return false;
    return completedBooks >= annualGoal;
  }
}

