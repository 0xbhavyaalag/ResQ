import 'package:flutter_test/flutter_test.dart';
import 'package:resq/core/constants/app_constants.dart';
import 'package:resq/models/risk_model.dart';
import 'package:resq/services/risk_service.dart';

void main() {
  group('RiskService Tests', () {
    final riskService = RiskService();

    test('Database configuration action yields HIGH risk result', () async {
      final result = await riskService.analyzeAction(
        actionType: AppConstants.actionDbConfig,
      );

      expect(result.level, RiskLevel.high);
      expect(result.score, 82);
      expect(result.reasons, isNotEmpty);
      expect(result.potentialImpact, contains('database'));
      expect(result.recommendedAction, contains('recovery point'));
    });

    test('App update action yields LOW risk result', () async {
      final result = await riskService.analyzeAction(
        actionType: AppConstants.actionAppUpdate,
      );

      expect(result.level, RiskLevel.low);
      expect(result.score, 35);
    });

    test('Permission change yields HIGH risk result', () async {
      final result = await riskService.analyzeAction(
        actionType: AppConstants.actionPermissionChange,
      );

      expect(result.level, RiskLevel.high);
      expect(result.score, 76);
    });
  });
}
