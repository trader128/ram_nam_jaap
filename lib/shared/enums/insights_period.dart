enum InsightsPeriod {
  sevenDays(7, '7 दिन'),
  thirtyDays(30, '30 दिन'),
  ninetyDays(90, '90 दिन'),
  oneYear(365, '1 वर्ष'),
  all(-1, 'सभी');

  const InsightsPeriod(this.days, this.label);

  final int days;
  final String label;
}
