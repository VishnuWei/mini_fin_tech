import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/app_state.dart';
import '../../data/models/expense.dart';
import '../../data/models/savings_goal.dart';
import '../../data/models/user_profile.dart';
import '../../data/services/local_storage_service.dart';

final localStorageProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

final appControllerProvider =
    StateNotifierProvider<AppController, AppState>((ref) {
  return AppController(ref.read(localStorageProvider))..initialize();
});

class AppController extends StateNotifier<AppState> {
  AppController(this._storage) : super(AppState.initial());

  final LocalStorageService _storage;
  final _uuid = const Uuid();
  final Set<String> _pendingFingerprints = <String>{};

  Future<void> initialize() async {
    state = await _storage.load();
  }

  Future<String?> saveProfile({
    required double income,
    required String goalName,
    required double targetAmount,
    required DateTime targetDate,
  }) async {
    if (income <= 0) return 'Monthly income must be greater than zero.';
    if (targetAmount <= 0) return 'Target amount must be greater than zero.';
    if (!targetDate.isAfter(DateTime.now())) return 'Goal date must be in the future.';

    final profile = UserProfile(
      monthlyIncome: income,
      goal: SavingsGoal(
        name: goalName.trim(),
        targetAmount: targetAmount,
        targetDate: targetDate,
      ),
    );
    await _storage.saveProfile(profile);
    state = state.copyWith(profile: profile, lastSyncMessage: 'Profile saved.');
    return null;
  }

  Future<String?> addExpense({
    required double amount,
    required String category,
    required String merchant,
    required DateTime date,
    required String paymentMode,
    String? notes,
  }) async {
    if (amount <= 0) return 'Amount must be greater than zero.';
    if (merchant.trim().isEmpty) return 'Merchant or description is required.';
    final today = DateTime.now();
    if (date.isAfter(DateTime(today.year, today.month, today.day, 23, 59, 59))) {
      return 'Future-dated expenses are not allowed.';
    }

    final expense = Expense(
      id: _uuid.v4(),
      amount: amount,
      category: category,
      merchant: merchant.trim(),
      date: date,
      paymentMode: paymentMode,
      notes: notes?.trim().isEmpty ?? true ? null : notes?.trim(),
      createdAt: DateTime.now(),
      syncStatus: ExpenseSyncStatus.pending,
    );

    if (_pendingFingerprints.contains(expense.fingerprint) ||
        state.expenses.any((item) => item.fingerprint == expense.fingerprint)) {
      return 'This expense looks like a duplicate submission.';
    }

    _pendingFingerprints.add(expense.fingerprint);
    final updated = <Expense>[expense, ...state.expenses];
    await _storage.saveExpenses(updated);
    state = state.copyWith(
      expenses: updated,
      lastSyncMessage: state.offlineMode
          ? 'Saved locally. Sync pending until you go online.'
          : 'Saved locally and queued for sync.',
    );
    _pendingFingerprints.remove(expense.fingerprint);

    if (!state.offlineMode) {
      await syncPendingExpenses();
    }
    return null;
  }

  Future<void> syncPendingExpenses() async {
    if (state.offlineMode) {
      debugPrint('Offline mode is on. Pending items stay local.');
      state = state.copyWith(lastSyncMessage: 'Offline mode is on. Pending items stay local.');
      return;
    }

    final pending = state.expenses
        .where((expense) => expense.syncStatus != ExpenseSyncStatus.synced)
        .toList();

    debugPrint('Pending expenses to sync: ${pending.length}');    
    if (pending.isEmpty) {
      state = state.copyWith(lastSyncMessage: 'Everything is already in sync.');
      return;
    }

    state = state.copyWith(isSyncing: true, clearMessage: true);
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final updated = state.expenses.map((expense) {
      if (expense.syncStatus == ExpenseSyncStatus.synced) {
        return expense;
      }
      return expense.copyWith(syncStatus: ExpenseSyncStatus.synced);
    }).toList();
    await _storage.saveExpenses(updated);
    state = state.copyWith(
      expenses: updated,
      isSyncing: false,
      lastSyncMessage: 'Pending expenses synced successfully.',
    );
  }

  Future<void> toggleOfflineMode(bool value) async {
    await _storage.saveOfflineMode(value);
    state = state.copyWith(
      offlineMode: value,
      lastSyncMessage: value
          ? 'Offline mode enabled. New expenses will queue locally.'
          : 'Offline mode disabled. You can sync pending expenses now.',
    );
  }
}
