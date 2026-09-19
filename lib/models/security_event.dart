import 'risk_model.dart';

enum SecurityCategory {
  software,
  fraud,
  recovery;

  String get label {
    switch (this) {
      case SecurityCategory.software:
        return 'SOFTWARE';
      case SecurityCategory.fraud:
        return 'FRAUD';
      case SecurityCategory.recovery:
        return 'RECOVERY';
    }
  }
}

/// Represents an item in the Security Timeline
class SecurityEvent {
  final String id;
  final String title;
  final String subtitle;
  final DateTime timestamp;
  final SecurityCategory category;
  final RiskLevel riskLevel;
  final String? iconType;
  final Map<String, dynamic>? details;

  const SecurityEvent({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.category,
    required this.riskLevel,
    this.iconType,
    this.details,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'subtitle': subtitle,
        'timestamp': timestamp.toIso8601String(),
        'category': category.name,
        'riskLevel': riskLevel.name,
        'iconType': iconType,
        'details': details,
      };

  factory SecurityEvent.fromMap(Map<String, dynamic> map) => SecurityEvent(
        id: map['id'] as String,
        title: map['title'] as String,
        subtitle: map['subtitle'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        category: SecurityCategory.values.firstWhere(
          (c) => c.name == map['category'],
          orElse: () => SecurityCategory.software,
        ),
        riskLevel: RiskLevel.values.firstWhere(
          (r) => r.name == map['riskLevel'],
          orElse: () => RiskLevel.low,
        ),
        iconType: map['iconType'] as String?,
        details: map['details'] as Map<String, dynamic>?,
      );
}
