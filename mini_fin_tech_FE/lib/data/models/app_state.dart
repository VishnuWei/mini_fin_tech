import 'expense.dart';
import 'user_profile.dart';

class AppState {
  AppState({
    required this.profile,
    required this.expenses,
    required this.offlineMode,
    required this.isSyncing,
    required this.lastSyncMessage,
  });

  final UserProfile? profile;
  final List<Expense> expenses;
  final bool offlineMode;
  final bool isSyncing;
  final String? lastSyncMessage;

  factory AppState.initial() => AppState(
        profile: null,
        expenses: const [],
        offlineMode: false,
        isSyncing: false,
        lastSyncMessage: null,
      );

  AppState copyWith({
    UserProfile? profile,
    List<Expense>? expenses,
    bool? offlineMode,
    bool? isSyncing,
    String? lastSyncMessage,
    bool clearMessage = false,
  }) {
    return AppState(
      profile: profile ?? this.profile,
      expenses: expenses ?? this.expenses,
      offlineMode: offlineMode ?? this.offlineMode,
      isSyncing: isSyncing ?? this.isSyncing,
      lastSyncMessage: clearMessage ? null : (lastSyncMessage ?? this.lastSyncMessage),
    );
  }
}
