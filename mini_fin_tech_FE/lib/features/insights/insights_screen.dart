import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/expense.dart';
import '../../data/models/insight.dart';
import '../app_shell/app_controller.dart';
import '../dashboard/dashboard_screen.dart';
import '../shared/section_card.dart';

class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(appControllerProvider);
    final profile = state.profile!;
    final engine = ref.read(recommendationEngineProvider);
    final recommendation = engine.buildRecommendation(
      profile: profile,
      expenses: state.expenses,
      now: DateTime.now(),
    );
    final insights = engine.buildInsights(
      profile: profile,
      expenses: state.expenses,
      recommendation: recommendation,
      now: DateTime.now(),
    );
    final alerts = _buildRuleAlerts(profile.monthlyIncome, state.expenses);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Insights',
          child: Column(
            children: insights
                .map((insight) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InsightRow(insight: insight),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Budget rules',
          child: Column(
            children: alerts
                .map((alert) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _InsightRow(insight: alert),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }

  List<Insight> _buildRuleAlerts(double monthlyIncome, List<Expense> expenses) {
    final shoppingSpend = expenses
        .where((item) => item.category == 'Shopping')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final foodSpend = expenses
        .where((item) => item.category == 'Food')
        .fold<double>(0, (sum, item) => sum + item.amount);
    final shoppingBudget = monthlyIncome * 0.15;
    final foodBudget = monthlyIncome * 0.12;

    return [
      Insight(
        title: 'Category threshold',
        body: shoppingSpend >= shoppingBudget * 0.8
            ? 'Shopping has crossed 80% of its notional category budget.'
            : 'Shopping is still below the 80% threshold.',
        severity: shoppingSpend >= shoppingBudget * 0.8
            ? InsightSeverity.warning
            : InsightSeverity.success,
      ),
      Insight(
        title: 'Food budget pace',
        body: foodSpend >= foodBudget * 0.8
            ? 'Food spend is nearing its budget cap and may trim savings flexibility.'
            : 'Food spend is pacing comfortably against budget.',
        severity:
            foodSpend >= foodBudget * 0.8 ? InsightSeverity.warning : InsightSeverity.info,
      ),
    ];
  }
}

class _InsightRow extends StatelessWidget {
  const _InsightRow({required this.insight});

  final Insight insight;

  @override
  Widget build(BuildContext context) {
    final color = switch (insight.severity) {
      InsightSeverity.warning => const Color(0xFFB45309),
      InsightSeverity.success => const Color(0xFF15803D),
      InsightSeverity.info => const Color(0xFF1D4ED8),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            insight.title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color),
          ),
          const SizedBox(height: 8),
          Text(insight.body),
        ],
      ),
    );
  }
}
