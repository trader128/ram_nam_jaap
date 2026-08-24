class JapStatistics {
  const JapStatistics({
    required this.todayCount,
    required this.lifetimeCount,
    required this.currentStreak,
    required this.longestStreak,
    required this.todayDate,
  });

  final int todayCount;
  final int lifetimeCount;
  final int currentStreak;
  final int longestStreak;
  final DateTime todayDate;

  static JapStatistics initial() {
    return JapStatistics(
      todayCount: 0,
      lifetimeCount: 0,
      currentStreak: 0,
      longestStreak: 0,
      todayDate: DateTime.now(),
    );
  }

  JapStatistics copyWith({
    int? todayCount,
    int? lifetimeCount,
    int? currentStreak,
    int? longestStreak,
    DateTime? todayDate,
  }) {
    return JapStatistics(
      todayCount: todayCount ?? this.todayCount,
      lifetimeCount: lifetimeCount ?? this.lifetimeCount,
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      todayDate: todayDate ?? this.todayDate,
    );
  }
}
