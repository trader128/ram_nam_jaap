class DailyJapRecord {
  const DailyJapRecord({
    required this.date,
    required this.count,
    required this.dailyGoal,
  });

  final DateTime date;
  final int count;
  final int dailyGoal;

  bool get goalMet => count >= dailyGoal;

  double get goalProgress {
    if (dailyGoal <= 0) {
      return 0;
    }
    return (count / dailyGoal).clamp(0, 1);
  }

  DailyJapRecord copyWith({DateTime? date, int? count, int? dailyGoal}) {
    return DailyJapRecord(
      date: date ?? this.date,
      count: count ?? this.count,
      dailyGoal: dailyGoal ?? this.dailyGoal,
    );
  }
}
