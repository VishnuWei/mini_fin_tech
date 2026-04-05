import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSaveProfile});

  final Future<String?> Function({
    required double income,
    required String goalName,
    required double targetAmount,
    required DateTime targetDate,
  }) onSaveProfile;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _incomeController = TextEditingController();
  final _goalNameController = TextEditingController();
  final _goalAmountController = TextEditingController();
  final _dateController = TextEditingController();
  DateTime? _targetDate;
  bool _saving = false;

  @override
  void dispose() {
    _incomeController.dispose();
    _goalNameController.dispose();
    _goalAmountController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(28),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0F766E), Color(0xFF1F2937)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Build a calmer money routine.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Track spending, shape a savings habit, and let the app suggest a realistic weekly auto-save amount.',
                      style: TextStyle(color: Colors.white70, fontSize: 16, height: 1.4),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text('Set up your profile', style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: 8),
              const Text('We only need your income and one savings goal to get started.'),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _incomeController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Monthly income',
                        prefixText: '\u20B9 ',
                      ),
                      validator: _requiredNumberValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _goalNameController,
                      decoration: const InputDecoration(labelText: 'Goal name'),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Goal name is required' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _goalAmountController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Target amount',
                        prefixText: '\u20B9 ',
                      ),
                      validator: _requiredNumberValidator,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Target date',
                        suffixIcon: Icon(Icons.calendar_month_outlined),
                      ),
                      onTap: _pickDate,
                      validator: (value) => _targetDate == null ? 'Target date is required' : null,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _saving ? null : _submit,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          child: Text(_saving ? 'Saving...' : 'Continue'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked == null) return;
    setState(() {
      _targetDate = picked;
      _dateController.text = DateFormat('dd MMM yyyy').format(picked);
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    final error = await widget.onSaveProfile(
      income: double.parse(_incomeController.text),
      goalName: _goalNameController.text,
      targetAmount: double.parse(_goalAmountController.text),
      targetDate: _targetDate!,
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  String? _requiredNumberValidator(String? value) {
    final parsed = double.tryParse(value ?? '');
    if (parsed == null || parsed <= 0) {
      return 'Enter a value greater than zero';
    }
    return null;
  }
}
