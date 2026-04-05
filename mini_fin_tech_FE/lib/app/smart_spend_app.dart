import 'package:flutter/material.dart';

import '../core/theme/app_theme.dart';
import '../features/app_shell/app_shell_screen.dart';

class SmartSpendApp extends StatelessWidget {
  const SmartSpendApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Spend & Auto-Save',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const AppShellScreen(),
    );
  }
}
