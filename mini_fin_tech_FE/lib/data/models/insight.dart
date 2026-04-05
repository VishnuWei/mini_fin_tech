class Insight {
  Insight({
    required this.title,
    required this.body,
    required this.severity,
  });

  final String title;
  final String body;
  final InsightSeverity severity;
}

enum InsightSeverity { info, warning, success }
