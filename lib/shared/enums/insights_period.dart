enum InsightsPeriod {
  sevenDays(7, '7D'),
  thirtyDays(30, '30D'),
  ninetyDays(90, '90D'),
  oneYear(365, '1Y'),
  all(-1, 'All');

  const InsightsPeriod(this.days, this.label);

  final int days;
  final String label;
}
