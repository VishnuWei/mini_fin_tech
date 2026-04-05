import '../models/expense.dart';
import '../models/insight.dart';
import '../models/recommendation.dart';
import '../models/user_profile.dart';

class RecommendationEngine {
  Recommendation buildRecommendation({
    required UserProfile profile,
    required List<Expense> expenses,
    required DateTime now,
  }) {
    final monthExpenses = expenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).toList();
    final weeklyExpenses = expenses.where((expense) {
      return now.difference(expense.date).inDays >= 0 &&
          now.difference(expense.date).inDays < 7;
    }).toList();
    final priorWeekExpenses = expenses.where((expense) {
      final days = now.difference(expense.date).inDays;
      return days >= 7 && days < 14;
    }).toList();

    final monthSpend = monthExpenses.fold<double>(0, (sum, item) => sum + item.amount);
    final weeklySpend = weeklyExpenses.fold<double>(0, (sum, item) => sum + item.amount);
    final priorWeekSpend =
        priorWeekExpenses.fold<double>(0, (sum, item) => sum + item.amount);
    final remainingToGoal =
        (profile.goal.targetAmount - _estimatedSaved(profile, monthSpend)).clamp(0, double.infinity);
    final remainingDays = _daysRemainingInMonth(now).clamp(1, 31);
    final weeksRemaining = (remainingDays / 7).ceil().clamp(1, 5);
    final base = profile.monthlyIncome * 0.08;
    final expectedSpendPace =
        profile.monthlyIncome * (now.day / _daysInMonth(now)).clamp(0.1, 1.0);
    final spendPaceDelta = monthSpend - expectedSpendPace;
    final discretionarySpend = monthExpenses
        .where((e) => _discretionaryCategories.contains(e.category))
        .fold<double>(0, (sum, item) => sum + item.amount);
    final discretionaryRatio =
        profile.monthlyIncome == 0 ? 0 : discretionarySpend / profile.monthlyIncome;
    final spikeRatio =
        priorWeekSpend <= 0 ? 0 : ((weeklySpend - priorWeekSpend) / priorWeekSpend);

    var recommendation = base;
    final reasons = <String>[];

    if (spendPaceDelta > profile.monthlyIncome * 0.05) {
      recommendation -= profile.monthlyIncome * 0.02;
      reasons.add('Spend pace is running ahead of where it should be this month.');
    } else {
      recommendation += profile.monthlyIncome * 0.015;
      reasons.add('Monthly spend is under control, so you can push savings a bit more.');
    }

    if (discretionaryRatio > 0.35) {
      recommendation *= 0.75;
      reasons.add('Discretionary categories are elevated, so the rule softens this week.');
    }

    if (spikeRatio > 0.25) {
      recommendation *= 0.8;
      reasons.add('Recent transactions show an unusual weekly spike.');
    }

    if (remainingToGoal > 0) {
      final catchUp = remainingToGoal / weeksRemaining;
      recommendation =
          (recommendation + catchUp * 0.35).clamp(200, profile.monthlyIncome * 0.2);
      reasons.add('The goal gap influences a catch-up contribution.');
    }

    final confidence = spikeRatio > 0.25 || discretionaryRatio > 0.35
        ? 'Moderate confidence'
        : 'High confidence';

    return Recommendation(
      weeklyAmount: recommendation.roundToDouble(),
      reasons: reasons,
      confidenceLabel: confidence,
    );
  }

  List<Insight> buildInsights({
    required UserProfile profile,
    required List<Expense> expenses,
    required Recommendation recommendation,
    required DateTime now,
  }) {
    final weeklyExpenses = expenses.where((expense) {
      final days = now.difference(expense.date).inDays;
      return days >= 0 && days < 7;
    }).toList();
    final priorWeekExpenses = expenses.where((expense) {
      final days = now.difference(expense.date).inDays;
      return days >= 7 && days < 14;
    }).toList();
    final monthExpenses = expenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).toList();

    final weeklyFood = weeklyExpenses
        .where((expense) => expense.category == 'Food')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final priorWeeklyFood = priorWeekExpenses
        .where((expense) => expense.category == 'Food')
        .fold<double>(0, (sum, item) => sum + item.amount);

    final monthSpend = monthExpenses.fold<double>(0, (sum, item) => sum + item.amount);
    final remainingMonthlyBudget =
        (profile.monthlyIncome - monthSpend).clamp(0, double.infinity);
    final discretionarySpend = monthExpenses
        .where((e) => _discretionaryCategories.contains(e.category))
        .fold<double>(0, (sum, item) => sum + item.amount);

    final insights = <Insight>[
      Insight(
        title: 'Food trend',
        body: priorWeeklyFood > 0
            ? 'Food spend is ${(((weeklyFood - priorWeeklyFood) / priorWeeklyFood) * 100).round()}% versus last week.'
            : 'Food spend started this week, but there is no prior-week baseline yet.',
        severity: weeklyFood > priorWeeklyFood ? InsightSeverity.warning : InsightSeverity.info,
      ),
      Insight(
        title: 'Savings runway',
        body:
            'You can still direct about ${_formatCurrency((remainingMonthlyBudget * 0.35).roundToDouble())} toward savings this month if discretionary spend stays controlled.',
        severity: remainingMonthlyBudget > 0 ? InsightSeverity.success : InsightSeverity.warning,
      ),
      Insight(
        title: 'Auto-save recommendation',
        body:
            'Recommended auto-save this week: ${_formatCurrency(recommendation.weeklyAmount)}.',
        severity: InsightSeverity.info,
      ),
    ];

    if (discretionarySpend > profile.monthlyIncome * 0.3) {
      insights.add(
        Insight(
          title: 'Discretionary alert',
          body: 'Discretionary categories have crossed 30% of income, which is dragging down the save recommendation.',
          severity: InsightSeverity.warning,
        ),
      );
    }

    return insights;
  }

  static const Set<String> _discretionaryCategories = <String>{
    'Food',
    'Shopping',
    'Entertainment',
    'Travel',
  };

  double _estimatedSaved(UserProfile profile, double monthSpend) {
    return (profile.monthlyIncome - monthSpend).clamp(0, double.infinity) * 0.2;
  }

  int _daysInMonth(DateTime date) => DateTime(date.year, date.month + 1, 0).day;

  int _daysRemainingInMonth(DateTime date) => _daysInMonth(date) - date.day;

  String _formatCurrency(double value) => '\u20B9${value.toStringAsFixed(0)}';
}
