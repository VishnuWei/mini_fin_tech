import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:smart_spend_auto_save/app/smart_spend_app.dart';

void main() {
  testWidgets('renders onboarding before profile exists', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: SmartSpendApp()));

    expect(find.text('Set up your profile'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
  });
}
