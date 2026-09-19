import 'package:flutter_test/flutter_test.dart';
import 'package:resq/core/constants/app_constants.dart';
import 'package:resq/models/risk_model.dart';
import 'package:resq/services/fraud_service.dart';

void main() {
  group('FraudService Tests', () {
    final fraudService = FraudService.instance;

    test('Suspicious phishing message detected as HIGH risk', () async {
      final result = await fraudService.analyzeMessage(AppConstants.demoSuspiciousMessage);
      expect(result.level, RiskLevel.high);
      expect(result.score, greaterThanOrEqualTo(70));
      expect(result.signals.any((s) => s.label == 'Urgent Tone'), isTrue);
      expect(result.signals.any((s) => s.label == 'Credential Request'), isTrue);
    });

    test('Deceptive typosquatting URL flagged as HIGH risk', () async {
      final result = await fraudService.analyzeUrl(AppConstants.demoSuspiciousUrl);
      expect(result.level, RiskLevel.high);
      expect(result.score, greaterThanOrEqualTo(70));
      expect(result.signals.any((s) => s.label.contains('Typosquatting')), isTrue);
    });

    test('Bank phishing SMS triggers KYC suspension warnings', () async {
      final result = await fraudService.analyzeBankMessage(AppConstants.demoSuspiciousBankMessage);
      expect(result.level, RiskLevel.high);
      expect(result.signals.any((s) => s.label.contains('KYC')), isTrue);
    });

    test('Safe benign message classified as LOW risk', () async {
      final result = await fraudService.analyzeMessage('Hey, can we catch up for coffee tomorrow?');
      expect(result.level, RiskLevel.low);
      expect(result.score, lessThan(40));
    });
  });
}
