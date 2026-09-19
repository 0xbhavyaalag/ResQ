import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resq/services/storage_service.dart';
import 'package:resq/providers/settings_provider.dart';
import 'package:resq/providers/app_state_provider.dart';
import 'package:resq/providers/software_safety_provider.dart';
import 'package:resq/providers/fraud_safety_provider.dart';
import 'package:resq/screens/home/home_screen.dart';
import 'package:resq/screens/onboarding/onboarding_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await StorageService().init();
  });

  testWidgets('Full Brand -> Model selection user flow on HomeScreen', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
        ],
        child: const MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify initial unselected device state on HomeScreen
    expect(find.text('Select Device'), findsAtLeastNWidgets(1));
    expect(find.text('DEVICE SELECTION'), findsOneWidget);

    // 2. Click "Select Device"
    await tester.tap(find.text('Select Device').first);
    await tester.pumpAndSettle();

    // 3. Verify Brand Popup opens with brands
    expect(find.text('Select Brand'), findsOneWidget);
    expect(find.text('Samsung'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);
    expect(find.text('OnePlus'), findsOneWidget);
    expect(find.text('Google Pixel'), findsOneWidget);

    // 4. Tap "Samsung" brand
    await tester.tap(find.text('Samsung'));
    await tester.pumpAndSettle();

    // 5. Verify Samsung models are shown with "Back to Brands"
    expect(find.text('Back to Brands'), findsOneWidget);
    expect(find.text('Galaxy S25'), findsOneWidget);
    expect(find.text('Galaxy S24'), findsOneWidget);

    // 6. Test "Back to Brands" navigation
    await tester.tap(find.text('Back to Brands'));
    await tester.pumpAndSettle();

    // Verify returned to Brand list
    expect(find.text('Select Brand'), findsOneWidget);
    expect(find.text('Samsung'), findsOneWidget);

    // 7. Select Samsung again, then select Galaxy S25
    await tester.tap(find.text('Samsung'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Galaxy S25'));
    await tester.pumpAndSettle();

    // 8. Verify modal is closed and HomeScreen now shows "Samsung Galaxy S25" and "Change Device"
    expect(find.text('Samsung Galaxy S25'), findsOneWidget);
    expect(find.text('MONITORED DEVICE'), findsOneWidget);
    expect(find.text('Change Device'), findsOneWidget);

    // 9. Click "Change Device" to verify it reopens the modal
    await tester.tap(find.text('Change Device'));
    await tester.pumpAndSettle();

    expect(find.text('Select Brand'), findsOneWidget);
    expect(find.text('Apple'), findsOneWidget);

    // Select Apple -> iPhone 16
    await tester.tap(find.text('Apple'));
    await tester.pumpAndSettle();

    expect(find.text('Back to Brands'), findsOneWidget);
    expect(find.text('iPhone 16'), findsOneWidget);

    await tester.tap(find.text('iPhone 16'));
    await tester.pumpAndSettle();

    // Verify HomeScreen now shows "Apple iPhone 16"
    expect(find.text('Apple iPhone 16'), findsOneWidget);
  });

  testWidgets('Onboarding Screen -> GET STARTED -> Device Selector -> Main Page flow', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => SettingsProvider()),
          ChangeNotifierProvider(create: (_) => AppStateProvider()),
          ChangeNotifierProvider(create: (_) => SoftwareSafetyProvider()),
          ChangeNotifierProvider(create: (_) => FraudSafetyProvider()),
        ],
        child: const MaterialApp(
          home: OnboardingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Advance to slide 3 of onboarding (Picture 2: "Recover Safely. Verify Everything.")
    expect(find.text('CONTINUE'), findsOneWidget);
    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CONTINUE'));
    await tester.pumpAndSettle();

    // Verify slide 3 (Picture 2) is visible
    expect(find.text('Recover Safely. Verify Everything.'), findsOneWidget);
    expect(find.text('GET STARTED'), findsOneWidget);

    // 2. Click "GET STARTED"
    await tester.tap(find.text('GET STARTED'));
    await tester.pumpAndSettle();

    // 3. Verify Device Selector popup appears!
    expect(find.text('Select Brand'), findsOneWidget);
    expect(find.text('Samsung'), findsOneWidget);

    // 4. Select Samsung -> Galaxy S24
    await tester.tap(find.text('Samsung'));
    await tester.pumpAndSettle();

    expect(find.text('Back to Brands'), findsOneWidget);
    expect(find.text('Galaxy S24'), findsOneWidget);

    await tester.tap(find.text('Galaxy S24'));
    await tester.pumpAndSettle();

    // 5. Verify it navigated to Main Page and displays Picture 1 card: "Samsung Galaxy S24"
    expect(find.text('Samsung Galaxy S24'), findsOneWidget);
    expect(find.text('MONITORED DEVICE'), findsOneWidget);
    expect(find.text('Change Device'), findsOneWidget);
  });
}
