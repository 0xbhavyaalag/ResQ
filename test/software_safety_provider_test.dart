import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resq/services/storage_service.dart';
import 'package:resq/services/recovery_service.dart';
import 'package:resq/providers/app_state_provider.dart';
import 'package:resq/providers/software_safety_provider.dart';
import 'package:resq/models/recovery_point.dart';
import 'package:resq/screens/recovery/recovery_center_screen.dart';
import 'package:resq/screens/software/software_safety_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late AppStateProvider appState;
  late SoftwareSafetyProvider software;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
    appState = AppStateProvider();
    software = SoftwareSafetyProvider();
  });

  test('simulateFailure runs step by step without throwing unmodifiable error', () async {
    expect(software.isSimulatingFailure, isFalse);
    expect(software.hasFailureOccurred, isFalse);

    final future = software.simulateFailure(appState);
    expect(software.isSimulatingFailure, isTrue);

    await future;

    expect(software.isSimulatingFailure, isFalse);
    expect(software.hasFailureOccurred, isTrue);
    expect(software.failureSteps[0].status, FailureStepStatus.success);
    expect(software.failureSteps[1].status, FailureStepStatus.failure);
    expect(software.failureSteps[2].status, FailureStepStatus.success);
    expect(software.failureSteps[3].status, FailureStepStatus.success);
  });

  test('restoreSafeVersion runs step by step without throwing unmodifiable error', () async {
    final pt = RecoveryPoint(
      id: 'test_pt',
      title: 'Safe Checkpoint',
      timestamp: DateTime.now(),
      versionLabel: 'v1.0.0',
      actionSource: 'Database Config',
    );

    expect(software.isRestoring, isFalse);
    expect(software.isRecoveryVerified, isFalse);

    final future = software.restoreSafeVersion(pt, appState);
    expect(software.isRestoring, isTrue);

    await future;

    expect(software.isRestoring, isFalse);
    expect(software.isRecoveryVerified, isTrue);
    for (final step in software.recoverySteps) {
      expect(step.status, RecoveryStepStatus.success);
    }
  });

  testWidgets('SoftwareSafetyScreen: Simulate Failure progresses through steps to failure outcome', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider.value(value: software),
        ],
        child: const MaterialApp(
          home: SoftwareSafetyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap ANALYZE RISK first to reach Step 4 (Controlled Demo Environment)
    final analyzeBtn = find.text('ANALYZE RISK');
    expect(analyzeBtn, findsOneWidget);
    await tester.tap(analyzeBtn);
    await tester.pumpAndSettle();

    // Verify SIMULATE FAILURE button now exists
    final simulateBtn = find.text('SIMULATE FAILURE');
    expect(simulateBtn, findsOneWidget);

    // Tap SIMULATE FAILURE
    await tester.tap(simulateBtn);
    await tester.pump();

    // Verify DETECTING TELEMETRY... appears
    expect(find.text('DETECTING TELEMETRY...'), findsOneWidget);

    // Pump through the animated steps (550ms + 650ms + 550ms + 550ms)
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    // Verify failure completed and announced
    expect(find.text('APPLICATION FAILURE DETECTED'), findsOneWidget);
    expect(software.hasFailureOccurred, isTrue);
  });

  testWidgets('RecoveryCenterScreen: Restore safely progresses through all 4 steps to verified', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider.value(value: software),
        ],
        child: const MaterialApp(
          home: RecoveryCenterScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify RESTORE button exists
    final restoreBtn = find.text('RESTORE').first;
    await tester.tap(restoreBtn);
    await tester.pumpAndSettle();

    // Confirm dialog appears
    expect(find.text('Restore this safe version?'), findsOneWidget);
    await tester.tap(find.text('RESTORE SAFELY'));
    await tester.pump();

    // Verify RESTORATION IN PROGRESS is shown
    expect(find.text('RESTORATION IN PROGRESS'), findsOneWidget);

    // Pump through the 4 animated steps (600ms + 650ms + 650ms + 700ms)
    await tester.pump(const Duration(milliseconds: 650));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 750));
    await tester.pumpAndSettle();

    // Verify recovery verified
    expect(find.text('✓ RECOVERY VERIFIED'), findsOneWidget);
    expect(find.text('RECOVERY VERIFIED — SYSTEM HEALTHY'), findsOneWidget);
    expect(software.isRecoveryVerified, isTrue);
  });

  testWidgets('SoftwareSafetyScreen: CONTINUE ANYWAY shows warning dialog and advances to unprotected mode', (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: appState),
          ChangeNotifierProvider.value(value: software),
        ],
        child: const MaterialApp(
          home: SoftwareSafetyScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Analyze risk first
    await tester.tap(find.text('ANALYZE RISK'));
    await tester.pumpAndSettle();

    // 2. Tap CONTINUE ANYWAY
    final continueAnywayBtn = find.text('CONTINUE ANYWAY');
    expect(continueAnywayBtn, findsOneWidget);
    await tester.tap(continueAnywayBtn);
    await tester.pumpAndSettle();

    // 3. Verify confirmation dialog appears
    expect(find.text('Proceed Without Protection?'), findsOneWidget);
    expect(find.text('PROCEED ANYWAY'), findsOneWidget);

    // 4. Confirm PROCEED ANYWAY
    await tester.tap(find.text('PROCEED ANYWAY'));
    await tester.pumpAndSettle();

    // 5. Verify Unprotected Execution Card appears
    expect(find.text('⚠️ UNPROTECTED EXECUTION'), findsOneWidget);
    expect(find.text('CREATE RECOVERY POINT NOW'), findsOneWidget);
    expect(software.hasProceededWithoutSnapshot, isTrue);

    // 6. Verify pipeline advanced to Step 4
    expect(find.text('STEP 4 OF 7'), findsOneWidget);
  });
}
