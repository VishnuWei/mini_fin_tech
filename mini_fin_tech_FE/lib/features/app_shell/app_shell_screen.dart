import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../dashboard/dashboard_screen.dart';
import '../expenses/expense_entry_screen.dart';
import '../home/home_screen.dart';
import '../insights/insights_screen.dart';
import 'app_controller.dart';

class AppShellScreen extends ConsumerStatefulWidget {
  const AppShellScreen({super.key});

  @override
  ConsumerState<AppShellScreen> createState() => _AppShellScreenState();
}

class _AppShellScreenState extends ConsumerState<AppShellScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);
    final controller = ref.read(appControllerProvider.notifier);

    if (state.profile == null) {
      return HomeScreen(
        onSaveProfile: ({
          required income,
          required goalName,
          required targetAmount,
          required targetDate,
        }) {
          return controller.saveProfile(
            income: income,
            goalName: goalName,
            targetAmount: targetAmount,
            targetDate: targetDate,
          );
        },
      );
    }

    final screens = <Widget>[
      const DashboardScreen(),
      const ExpenseEntryScreen(),
      const InsightsScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Text('Smart Spend & Auto-Save'),
        actions: [
          Switch(
            value: state.offlineMode,
            onChanged: controller.toggleOfflineMode,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(state.offlineMode ? 'Offline' : 'Online'),
            ),
          ),
        ],
      ),
      body: SafeArea(child: screens[_index]),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) => setState(() => _index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.dashboard_outlined), label: 'Dashboard'),
          NavigationDestination(icon: Icon(Icons.add_card_outlined), label: 'Expense'),
          NavigationDestination(icon: Icon(Icons.insights_outlined), label: 'Insights'),
        ],
      ),
    );
  }
}
