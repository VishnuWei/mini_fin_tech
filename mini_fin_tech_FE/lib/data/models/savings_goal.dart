class SavingsGoal {
  SavingsGoal({
    required this.name,
    required this.targetAmount,
    required this.targetDate,
  });

  final String name;
  final double targetAmount;
  final DateTime targetDate;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'name': name,
        'targetAmount': targetAmount,
        'targetDate': targetDate.toIso8601String(),
      };

  factory SavingsGoal.fromJson(Map<String, dynamic> json) => SavingsGoal(
        name: json['name'] as String,
        targetAmount: (json['targetAmount'] as num).toDouble(),
        targetDate: DateTime.parse(json['targetDate'] as String),
      );
}
