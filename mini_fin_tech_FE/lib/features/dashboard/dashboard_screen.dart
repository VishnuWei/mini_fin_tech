import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/formatters.dart';
import '../../data/models/expense.dart';
import '../../data/services/recommendation_engine.dart';
import '../app_shell/app_controller.dart';
import '../shared/metric_tile.dart';
import '../shared/section_card.dart';

final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  return RecommendationEngine();
});

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final profile = state.profile!;
    final expenses = state.expenses;
    final now = DateTime.now();
    final monthExpenses = expenses.where((expense) {
      return expense.date.year == now.year && expense.date.month == now.month;
    }).toList();
    final weekExpenses = expenses.where((expense) {
      final days = now.difference(expense.date).inDays;
      return days >= 0 && days < 7;
    }).toList();
    final monthSpend = monthExpenses.fold<double>(0, (sum, item) => sum + item.amount);
    final weekSpend = weekExpenses.fold<double>(0, (sum, item) => sum + item.amount);
    final remainingBudget = profile.monthlyIncome - monthSpend;
    final savedEstimate = (profile.monthlyIncome - monthSpend).clamp(0, double.infinity) * 0.2;
    final goalProgress = (savedEstimate / profile.goal.targetAmount).clamp(0.0, 1.0);
    final recommendation = ref.read(recommendationEngineProvider).buildRecommendation(
          profile: profile,
          expenses: expenses,
          now: now,
        );
    final categories = _groupByCategory(monthExpenses);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        if (state.lastSyncMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: MaterialBanner(
              content: Text(state.lastSyncMessage!),
              actions: [
                TextButton(
                  onPressed: state.isSyncing
                      ? null
                      : () => ref.read(appControllerProvider.notifier).syncPendingExpenses(),
                  child: Text(state.isSyncing ? 'Syncing...' : 'Retry sync'),
                ),
              ],
            ),
          ),
        Row(
          children: [
            Expanded(
              child: MetricTile(
                label: 'Spent this week',
                value: Formatters.currency.format(weekSpend),
                hint: '${weekExpenses.length} transactions',
                color: const Color(0xFF0F766E),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: MetricTile(
                label: 'Spent this month',
                value: Formatters.currency.format(monthSpend),
                hint: 'Budget ${Formatters.currency.format(profile.monthlyIncome)}',
                color: const Color(0xFFB45309),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Savings goal',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(profile.goal.name, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: goalProgress,
                minHeight: 12,
                borderRadius: BorderRadius.circular(24),
              ),
              const SizedBox(height: 12),
              Text(
                '${Formatters.currency.format(savedEstimate)} of ${Formatters.currency.format(profile.goal.targetAmount)}',
              ),
              const SizedBox(height: 4),
              Text('Target date: ${Formatters.shortDate.format(profile.goal.targetDate)}'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Weekly auto-save recommendation',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                Formatters.currency.format(recommendation.weeklyAmount),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 8),
              Text(recommendation.confidenceLabel),
              const SizedBox(height: 12),
              ...recommendation.reasons.map(
                (reason) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 5),
                        child: Icon(Icons.circle, size: 8),
                      ),
                      const SizedBox(width: 8),
                      Expanded(child: Text(reason)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Category breakdown',
          child: categories.isEmpty
              ? const Text('Add expenses to see category trends.')
              : SizedBox(
                  height: 220,
                  child: PieChart(
                    PieChartData(
                      sectionsSpace: 3,
                      centerSpaceRadius: 42,
                      sections: categories.entries.map((entry) {
                        final index = categories.keys.toList().indexOf(entry.key);
                        final colors = [
                          const Color(0xFF0F766E),
                          const Color(0xFFE9A23B),
                          const Color(0xFF2563EB),
                          const Color(0xFFDC2626),
                          const Color(0xFF7C3AED),
                          const Color(0xFF059669),
                        ];
                        return PieChartSectionData(
                          value: entry.value,
                          title: entry.key,
                          color: colors[index % colors.length],
                          radius: 68,
                          titleStyle: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Recent transactions',
          child: expenses.isEmpty
              ? const Text('No expenses logged yet.')
              : Column(
                  children: expenses.take(5).map((expense) {
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(expense.merchant),
                      subtitle: Text(
                        '${expense.category} • ${Formatters.shortDate.format(expense.date)} • ${expense.paymentMode}',
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(Formatters.currency.format(expense.amount)),
                          Text(
                            expense.syncStatus.name,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
        const SizedBox(height: 8),
        Text(
          'Remaining monthly budget: ${Formatters.currency.format(remainingBudget.clamp(0, double.infinity))}',
        ),
      ],
    );
  }

  Map<String, double> _groupByCategory(List<Expense> expenses) {
    final map = <String, double>{};
    for (final expense in expenses) {
      map.update(expense.category, (value) => value + expense.amount,
          ifAbsent: () => expense.amount);
    }
    return map;
  }
}
