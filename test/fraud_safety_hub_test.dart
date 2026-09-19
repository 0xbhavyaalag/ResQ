import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resq/services/storage_service.dart';
import 'package:resq/providers/app_state_provider.dart';
import 'package:resq/providers/fraud_safety_provider.dart';
import 'package:resq/models/risk_model.dart';
import 'package:resq/screens/scan/scan_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late AppStateProvider appState;
  late FraudSafetyProvider fraudProvider;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
    appState = AppStateProvider();
    fraudProvider = FraudSafetyProvider();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: appState),
        ChangeNotifierProvider.value(value: fraudProvider),
      ],
      child: const MaterialApp(
        home: ScanScreen(),
      ),
    );
  }

  group('FraudSafetyHub 1-Click Safe & Harmful Scenarios', () {
    testWidgets('MESSAGE Tab: Safe Sample vs Harmful Sample', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // 1. Safe Message Test
      expect(find.text('✓ Safe Sample'), findsOneWidget);
      await tester.tap(find.text('✓ Safe Sample'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHECK WITH RESQ'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('LOW RISK'), findsOneWidget);
      expect(fraudProvider.messageResult?.level, RiskLevel.low);

      // 2. Harmful Message Test
      expect(find.text('⚠ Harmful Sample'), findsOneWidget);
      await tester.tap(find.text('⚠ Harmful Sample'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHECK WITH RESQ'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('HIGH RISK'), findsOneWidget);
      expect(fraudProvider.messageResult?.level, RiskLevel.high);
    });

    testWidgets('LINK Tab: Safe Link vs Harmful Link', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to LINK tab
      await tester.tap(find.text('LINK'));
      await tester.pumpAndSettle();

      // 1. Safe Link Test
      expect(find.text('✓ Safe Link'), findsOneWidget);
      await tester.tap(find.text('✓ Safe Link'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ANALYZE LINK'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('LOW RISK'), findsOneWidget);
      expect(fraudProvider.urlResult?.level, RiskLevel.low);

      // 2. Harmful Link Test
      expect(find.text('⚠ Harmful Link'), findsOneWidget);
      await tester.tap(find.text('⚠ Harmful Link'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('ANALYZE LINK'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('HIGH RISK'), findsOneWidget);
      expect(fraudProvider.urlResult?.level, RiskLevel.high);
    });

    testWidgets('BANK MSG Tab: Safe Bank Msg vs Harmful Bank Scam', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to BANK MSG tab
      await tester.tap(find.text('BANK MSG'));
      await tester.pumpAndSettle();

      // 1. Safe Bank Alert Test
      expect(find.text('✓ Safe Bank Msg'), findsOneWidget);
      await tester.tap(find.text('✓ Safe Bank Msg'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHECK MESSAGE'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('LOW RISK'), findsOneWidget);
      expect(fraudProvider.bankResult?.level, RiskLevel.low);

      // 2. Harmful Bank Scam Test
      expect(find.text('⚠ Harmful Bank Scam'), findsOneWidget);
      await tester.tap(find.text('⚠ Harmful Bank Scam'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('CHECK MESSAGE'));
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle();

      expect(find.text('HIGH RISK'), findsOneWidget);
      expect(fraudProvider.bankResult?.level, RiskLevel.high);
    });

    testWidgets('QR / PAY Tab: Verified Safe QR vs Harmful Mismatch QR', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Switch to QR / PAY tab
      await tester.tap(find.text('QR / PAY'));
      await tester.pumpAndSettle();

      // 1. Safe QR Test (Starbucks = Starbucks)
      expect(find.text('✓ Safe QR (Verified)'), findsOneWidget);
      await tester.tap(find.text('✓ Safe QR (Verified)'));
      await tester.pumpAndSettle();

      expect(find.text('✓ RECIPIENT VERIFIED'), findsOneWidget);
      expect(find.text('='), findsOneWidget);
      expect(fraudProvider.currentQrData?.isMismatch, isFalse);
      expect(fraudProvider.currentQrData?.riskLevel, RiskLevel.low);

      // 2. Harmful QR Test (ABC Electronics ≠ XYZ Services)
      expect(find.text('⚠ Harmful QR (Mismatch)'), findsOneWidget);
      await tester.tap(find.text('⚠ Harmful QR (Mismatch)'));
      await tester.pumpAndSettle();

      expect(find.text('⚠ POSSIBLE MISMATCH'), findsOneWidget);
      expect(find.text('≠'), findsOneWidget);
      expect(fraudProvider.currentQrData?.isMismatch, isTrue);
      expect(fraudProvider.currentQrData?.riskLevel, RiskLevel.high);
    });
  });
}
