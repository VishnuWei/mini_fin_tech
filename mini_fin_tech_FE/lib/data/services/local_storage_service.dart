import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_state.dart';
import '../models/expense.dart';
import '../models/user_profile.dart';

class LocalStorageService {
  static const _profileKey = 'profile';
  static const _expensesKey = 'expenses';
  static const _offlineModeKey = 'offline_mode';

  Future<AppState> load() async {
    final prefs = await SharedPreferences.getInstance();
    final profileRaw = prefs.getString(_profileKey);
    final expensesRaw = prefs.getString(_expensesKey);
    final offlineMode = prefs.getBool(_offlineModeKey) ?? false;

    final profile = profileRaw == null
        ? null
        : UserProfile.fromJson(jsonDecode(profileRaw) as Map<String, dynamic>);

    final expenses = expensesRaw == null
        ? <Expense>[]
        : (jsonDecode(expensesRaw) as List<dynamic>)
            .map((item) => Expense.fromJson(item as Map<String, dynamic>))
            .toList();

    return AppState.initial().copyWith(
      profile: profile,
      expenses: expenses,
      offlineMode: offlineMode,
    );
  }

  Future<void> saveProfile(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> saveExpenses(List<Expense> expenses) async {
    final prefs = await SharedPreferences.getInstance();
    final payload = expenses.map((expense) => expense.toJson()).toList();
    await prefs.setString(_expensesKey, jsonEncode(payload));
  }

  Future<void> saveOfflineMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_offlineModeKey, value);
  }
}
