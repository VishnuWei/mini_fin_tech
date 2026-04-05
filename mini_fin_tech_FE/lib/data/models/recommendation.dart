class Recommendation {
  Recommendation({
    required this.weeklyAmount,
    required this.reasons,
    required this.confidenceLabel,
  });

  final double weeklyAmount;
  final List<String> reasons;
  final String confidenceLabel;
}
