import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resq/main.dart';
import 'package:resq/services/storage_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().init();
  });

  testWidgets('ResQ App smoke test and splash screen rendering', (WidgetTester tester) async {
    await tester.pumpWidget(const ResqApp());
    await tester.pump();

    // Verify splash screen branding
    expect(find.text('ResQ'), findsOneWidget);
    expect(find.text('“Your Digital Safety Guardian”'), findsOneWidget);

    // Advance timer past splash duration (1.4s)
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    // Verify Onboarding renders
    expect(find.text('Spot Risk Before It Becomes Damage.'), findsOneWidget);
    expect(find.text('SKIP'), findsOneWidget);
  });
}
