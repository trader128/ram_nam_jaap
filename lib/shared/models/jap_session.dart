class JapSession {
  const JapSession({
    required this.count,
    required this.isActive,
    this.startedAt,
  });

  final int count;
  final bool isActive;
  final DateTime? startedAt;

  static const JapSession empty = JapSession(count: 0, isActive: false);

  JapSession copyWith({int? count, bool? isActive, DateTime? startedAt}) {
    return JapSession(
      count: count ?? this.count,
      isActive: isActive ?? this.isActive,
      startedAt: startedAt ?? this.startedAt,
    );
  }
}
