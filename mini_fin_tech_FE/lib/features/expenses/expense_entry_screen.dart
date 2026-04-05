import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_shell/app_controller.dart';
import '../shared/section_card.dart';

class ExpenseEntryScreen extends ConsumerStatefulWidget {
  const ExpenseEntryScreen({super.key});

  @override
  ConsumerState<ExpenseEntryScreen> createState() => _ExpenseEntryScreenState();
}

class _ExpenseEntryScreenState extends ConsumerState<ExpenseEntryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();
  String _category = _categories.first;
  String _paymentMode = _paymentModes.first;
  DateTime _selectedDate = DateTime.now();
  bool _submitting = false;

  static const List<String> _categories = [
    'Food',
    'Transport',
    'Bills',
    'Shopping',
    'Entertainment',
    'Health',
    'Travel',
    'Other',
  ];

  static const List<String> _paymentModes = ['UPI', 'Card', 'Cash', 'Net banking'];

  @override
  void initState() {
    super.initState();
    _dateController.text = _formatDate(_selectedDate);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appControllerProvider);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SectionCard(
          title: 'Add an expense',
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _amountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    prefixText: '\u20B9 ',
                  ),
                  validator: (value) {
                    final parsed = double.tryParse(value ?? '');
                    if (parsed == null || parsed <= 0) {
                      return 'Enter an amount greater than zero';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: _categories
                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => _category = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _merchantController,
                  decoration: const InputDecoration(labelText: 'Merchant / description'),
                  validator: (value) =>
                      value == null || value.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Date',
                    suffixIcon: Icon(Icons.event_outlined),
                  ),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: _paymentMode,
                  decoration: const InputDecoration(labelText: 'Payment mode'),
                  items: _paymentModes
                      .map((item) => DropdownMenuItem(value: item, child: Text(item)))
                      .toList(),
                  onChanged: (value) => setState(() => _paymentMode = value!),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(labelText: 'Notes (optional)'),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _submitting ? null : _submit,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: Text(_submitting ? 'Submitting...' : 'Save expense'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Sync state',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.offlineMode
                  ? 'Offline mode is active. New items stay queued locally.'
                  : 'Online mode is active. New items sync after local save.'),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text('Pending ${state.expenses.where((e) => e.syncStatus.name == "pending").length}')),
                  Chip(label: Text('Synced ${state.expenses.where((e) => e.syncStatus.name == "synced").length}')),
                  Chip(label: Text('Failed ${state.expenses.where((e) => e.syncStatus.name == "failed").length}')),
                ],
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: state.isSyncing
                    ? null
                    : () => ref.read(appControllerProvider.notifier).syncPendingExpenses(),
                child: Text(state.isSyncing ? 'Syncing...' : 'Retry pending sync'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _selectedDate = picked;
      _dateController.text = _formatDate(picked);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    final message = await ref.read(appControllerProvider.notifier).addExpense(
          amount: double.parse(_amountController.text),
          category: _category,
          merchant: _merchantController.text,
          date: _selectedDate,
          paymentMode: _paymentMode,
          notes: _notesController.text,
        );
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? 'Expense added successfully.'),
      ),
    );
    if (message == null) {
      _amountController.clear();
      _merchantController.clear();
      _notesController.clear();
      setState(() {
        _category = _categories.first;
        _paymentMode = _paymentModes.first;
        _selectedDate = DateTime.now();
        _dateController.text = _formatDate(_selectedDate);
      });
    }
  }

  String _formatDate(DateTime value) {
    final day = value.day.toString().padLeft(2, '0');
    final month = value.month.toString().padLeft(2, '0');
    return '$day/$month/${value.year}';
  }
}
