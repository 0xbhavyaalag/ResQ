import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resq/services/storage_service.dart';
import 'package:resq/services/ai_assistant_service.dart';
import 'package:resq/providers/settings_provider.dart';
import 'package:resq/providers/app_state_provider.dart';
import 'package:resq/providers/software_safety_provider.dart';
import 'package:resq/providers/fraud_safety_provider.dart';
import 'package:resq/screens/guide/guide_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late StorageService storage;
  late AppStateProvider appState;
  late SoftwareSafetyProvider softwareProvider;
  late FraudSafetyProvider fraudProvider;
  late AiAssistantService aiService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    storage = StorageService();
    await storage.init();
    appState = AppStateProvider();
    softwareProvider = SoftwareSafetyProvider();
    fraudProvider = FraudSafetyProvider();
    aiService = AiAssistantService();
  });

  group('AiAssistantService Data Analysis Tests', () {
    test('Reflects selected device context in answers', () async {
      await appState.setSelectedDevice('Samsung', 'Galaxy S25');

      final resp = aiService.processQuery(
        query: '🔍 What problem has ResQ detected?',
        appState: appState,
        softwareProvider: softwareProvider,
        fraudProvider: fraudProvider,
      );

      expect(resp.text.contains('Samsung Galaxy S25'), isTrue);
      expect(resp.text.contains('Good news! ResQ has not detected any active problem'), isTrue);
    });

    test('Reports failure correctly when failure has occurred', () async {
      await appState.setSelectedDevice('Samsung', 'Galaxy S24');
      await appState.onFailureSimulated(action: 'Database Configuration');

      final resp = aiService.processQuery(
        query: '🔍 What problem has ResQ detected?',
        appState: appState,
        softwareProvider: softwareProvider,
        fraudProvider: fraudProvider,
      );

      expect(resp.text.contains('Samsung Galaxy S24'), isTrue);
      expect(resp.text.contains('unexpected application failure was detected'), isTrue);
      expect(resp.actions.any((a) => a.type == AiActionType.startRecovery), isTrue);
      expect(resp.followUps.contains('⚠️ Why did this problem happen?'), isTrue);
    });

    test('Answers all 12 FAQs with appropriate structure and actions', () async {
      await appState.setSelectedDevice('Apple', 'iPhone 16');

      for (final faq in AiAssistantService.faqList) {
        final resp = aiService.processQuery(
          query: faq,
          appState: appState,
          softwareProvider: softwareProvider,
          fraudProvider: fraudProvider,
        );

        expect(resp.text.isNotEmpty, isTrue, reason: 'Failed on FAQ: $faq');
        expect(resp.followUps.isNotEmpty, isTrue, reason: 'Empty follow-ups on FAQ: $faq');
      }
    });

    test('Handles Hindi and Hinglish queries accurately', () async {
      await appState.setSelectedDevice('Samsung', 'Galaxy S24');

      final resp1 = aiService.processQuery(
        query: 'Mere phone mein kya problem hai?',
        appState: appState,
        softwareProvider: softwareProvider,
        fraudProvider: fraudProvider,
      );
      expect(resp1.text.contains('Samsung Galaxy S24'), isTrue);

      final resp2 = aiService.processQuery(
        query: 'Ye issue kaise solve hoga?',
        appState: appState,
        softwareProvider: softwareProvider,
        fraudProvider: fraudProvider,
      );
      expect(resp2.text.contains('How to fix it'), isTrue);

      final resp3 = aiService.processQuery(
        query: 'ResQ ne isko suspicious kyu bola?',
        appState: appState,
        softwareProvider: softwareProvider,
        fraudProvider: fraudProvider,
      );
      expect(resp3.text.contains('Message Suspicion'), isTrue);
    });

    test('Maintains conversation context for follow-up questions', () async {
      await appState.setSelectedDevice('OnePlus', 'OnePlus 12');
      await appState.onFailureSimulated(action: 'Database Configuration');

      final resp1 = aiService.processQuery(
        query: '🔍 What problem has ResQ detected?',
        appState: appState,
        softwareProvider: softwareProvider,
        fraudProvider: fraudProvider,
      );
      expect(resp1.topic, 'failure');

      // Follow up with pronoun "when did it happen?"
      final resp2 = aiService.processQuery(
        query: 'When did it happen?',
        appState: appState,
        softwareProvider: softwareProvider,
        fraudProvider: fraudProvider,
        previousTopic: resp1.topic,
      );
      expect(resp2.text.contains('Incident Timeline for OnePlus OnePlus 12'), isTrue);
    });
  });

  group('GuideScreen AI Assistant Widget Tests', () {
    testWidgets('Renders ResQ AI Assistant, 12 FAQs, and executes chat query', (WidgetTester tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await appState.setSelectedDevice('Samsung', 'Galaxy S24');

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => SettingsProvider()),
            ChangeNotifierProvider.value(value: appState),
            ChangeNotifierProvider.value(value: softwareProvider),
            ChangeNotifierProvider.value(value: fraudProvider),
          ],
          child: const MaterialApp(
            home: GuideScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Verify Header & Greeting
      expect(find.text('🤖 ResQ AI Assistant'), findsWidgets);
      expect(find.text('Samsung Galaxy S24'), findsOneWidget);
      expect(find.text('FREQUENTLY ASKED QUESTIONS'), findsWidgets);

      // 2. Verify all 12 FAQs are present
      for (final faq in AiAssistantService.faqList) {
        expect(find.text(faq), findsOneWidget);
      }

      // 3. Tap FAQ 1: "🔍 What problem has ResQ detected?"
      await tester.tap(find.text('🔍 What problem has ResQ detected?'));
      await tester.pumpAndSettle();

      // Verify user query added to chat
      expect(find.text('🔍 What problem has ResQ detected?'), findsAtLeastNWidgets(1));

      // Advance delay for AI answer
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify AI response contains device name and healthy message
      expect(find.textContaining('Samsung Galaxy S24'), findsWidgets);
      expect(find.textContaining('Good news! ResQ has not detected any active problem'), findsOneWidget);

      // Verify suggested follow-ups are rendered
      expect(find.text('SUGGESTED FOLLOW-UPS'), findsWidgets);
      expect(find.text('• 📱 How can I check my device status?'), findsWidgets);

      // 4. Tap the follow-up chip
      await tester.tap(find.text('• 📱 How can I check my device status?').last);
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pumpAndSettle();

      // Verify follow-up answer appears
      expect(find.textContaining('Device Status for Samsung Galaxy S24'), findsWidgets);
    });
  });
}
