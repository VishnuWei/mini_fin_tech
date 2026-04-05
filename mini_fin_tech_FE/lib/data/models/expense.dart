import 'dart:convert';

enum ExpenseSyncStatus { pending, synced, failed }

class Expense {
  Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.merchant,
    required this.date,
    required this.paymentMode,
    required this.notes,
    required this.createdAt,
    required this.syncStatus,
  });

  final String id;
  final double amount;
  final String category;
  final String merchant;
  final DateTime date;
  final String paymentMode;
  final String? notes;
  final DateTime createdAt;
  final ExpenseSyncStatus syncStatus;

  String get fingerprint => jsonEncode(<String, dynamic>{
        'amount': amount.toStringAsFixed(2),
        'category': category.trim().toLowerCase(),
        'merchant': merchant.trim().toLowerCase(),
        'date': date.toIso8601String().substring(0, 10),
      });

  Expense copyWith({
    String? id,
    double? amount,
    String? category,
    String? merchant,
    DateTime? date,
    String? paymentMode,
    String? notes,
    DateTime? createdAt,
    ExpenseSyncStatus? syncStatus,
  }) {
    return Expense(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      merchant: merchant ?? this.merchant,
      date: date ?? this.date,
      paymentMode: paymentMode ?? this.paymentMode,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'amount': amount,
        'category': category,
        'merchant': merchant,
        'date': date.toIso8601String(),
        'paymentMode': paymentMode,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'syncStatus': syncStatus.name,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        merchant: json['merchant'] as String,
        date: DateTime.parse(json['date'] as String),
        paymentMode: json['paymentMode'] as String,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
        syncStatus: ExpenseSyncStatus.values.firstWhere(
          (status) => status.name == json['syncStatus'],
          orElse: () => ExpenseSyncStatus.pending,
        ),
      );
}
