import 'savings_goal.dart';

class UserProfile {
  UserProfile({
    required this.monthlyIncome,
    required this.goal,
  });

  final double monthlyIncome;
  final SavingsGoal goal;

  Map<String, dynamic> toJson() => <String, dynamic>{
        'monthlyIncome': monthlyIncome,
        'goal': goal.toJson(),
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
        monthlyIncome: (json['monthlyIncome'] as num).toDouble(),
        goal: SavingsGoal.fromJson(json['goal'] as Map<String, dynamic>),
      );
}
