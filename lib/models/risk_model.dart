import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

enum RiskLevel {
  low,
  medium,
  high,
  critical;

  String get label {
    switch (this) {
      case RiskLevel.low:
        return 'LOW RISK';
      case RiskLevel.medium:
        return 'POTENTIALLY SUSPICIOUS';
      case RiskLevel.high:
        return 'HIGH RISK';
      case RiskLevel.critical:
        return 'CRITICAL RISK';
    }
  }

  String get shortLabel {
    switch (this) {
      case RiskLevel.low:
        return 'LOW';
      case RiskLevel.medium:
        return 'MEDIUM';
      case RiskLevel.high:
        return 'HIGH';
      case RiskLevel.critical:
        return 'CRITICAL';
    }
  }

  Color get color {
    switch (this) {
      case RiskLevel.low:
        return AppTheme.mintDark;
      case RiskLevel.medium:
        return AppTheme.amberDark;
      case RiskLevel.high:
        return AppTheme.coralDark;
      case RiskLevel.critical:
        return AppTheme.coralDark;
    }
  }

  Color get pastelBg {
    switch (this) {
      case RiskLevel.low:
        return AppTheme.pastelMint;
      case RiskLevel.medium:
        return AppTheme.pastelAmber;
      case RiskLevel.high:
        return AppTheme.pastelCoral;
      case RiskLevel.critical:
        return AppTheme.pastelRose;
    }
  }

  IconData get icon {
    switch (this) {
      case RiskLevel.low:
        return Icons.check_circle_outline_rounded;
      case RiskLevel.medium:
        return Icons.warning_amber_rounded;
      case RiskLevel.high:
        return Icons.error_outline_rounded;
      case RiskLevel.critical:
        return Icons.gpp_bad_rounded;
    }
  }
}

class RiskSignal {
  final String label;
  final bool isTriggered;
  final String description;
  final RiskLevel severity;

  const RiskSignal({
    required this.label,
    required this.isTriggered,
    required this.description,
    this.severity = RiskLevel.medium,
  });

  Map<String, dynamic> toMap() => {
        'label': label,
        'isTriggered': isTriggered,
        'description': description,
        'severity': severity.name,
      };

  factory RiskSignal.fromMap(Map<String, dynamic> map) => RiskSignal(
        label: map['label'] as String,
        isTriggered: map['isTriggered'] as bool,
        description: map['description'] as String,
        severity: RiskLevel.values.firstWhere(
          (e) => e.name == map['severity'],
          orElse: () => RiskLevel.medium,
        ),
      );
}

class RiskResult {
  final int score; // 0 to 100
  final int confidence; // 0 to 100 AI Confidence
  final RiskLevel level;
  final String summary;
  final List<String> reasons;
  final String potentialImpact;
  final String recommendedAction;
  final List<RiskSignal> signals;

  const RiskResult({
    required this.score,
    this.confidence = 91,
    required this.level,
    required this.summary,
    required this.reasons,
    required this.potentialImpact,
    required this.recommendedAction,
    this.signals = const [],
  });

  Map<String, dynamic> toMap() => {
        'score': score,
        'confidence': confidence,
        'level': level.name,
        'summary': summary,
        'reasons': reasons,
        'potentialImpact': potentialImpact,
        'recommendedAction': recommendedAction,
        'signals': signals.map((s) => s.toMap()).toList(),
      };

  factory RiskResult.fromMap(Map<String, dynamic> map) => RiskResult(
        score: map['score'] as int,
        confidence: (map['confidence'] as int?) ?? 91,
        level: RiskLevel.values.firstWhere(
          (e) => e.name == map['level'],
          orElse: () => RiskLevel.low,
        ),
        summary: map['summary'] as String,
        reasons: List<String>.from(map['reasons'] as List),
        potentialImpact: map['potentialImpact'] as String,
        recommendedAction: map['recommendedAction'] as String,
        signals: (map['signals'] as List?)
                ?.map((s) => RiskSignal.fromMap(s as Map<String, dynamic>))
                .toList() ??
            [],
      );
}

/// Unified 7-Step ResQ Flow State
enum ResqFlowState {
  healthy, // Normal baseline
  actionSelected, // Step 1: User action chosen
  riskPredicted, // Step 2: Risk analyzed (Score + Confidence + Why)
  warningActive, // Step 3: Warning presented
  protected, // Protection snapshot created
  failureDetected, // Step 4: Controlled failure simulated
  diagnosed, // Step 5: Root cause diagnosed with evidence
  recovering, // Step 6: Rollback in progress
  verified, // Step 7: Post-recovery verification passed
}

