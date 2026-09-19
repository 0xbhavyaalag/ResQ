import 'risk_model.dart';

class QrScanData {
  final String merchantName;
  final String recipientName;
  final String vpa;
  final double amount;
  final bool isMismatch;
  final RiskLevel riskLevel;
  final DateTime timestamp;
  final String rawPayload;
  final String notes;

  const QrScanData({
    required this.merchantName,
    required this.recipientName,
    required this.vpa,
    required this.amount,
    required this.isMismatch,
    required this.riskLevel,
    required this.timestamp,
    required this.rawPayload,
    required this.notes,
  });

  Map<String, dynamic> toMap() => {
        'merchantName': merchantName,
        'recipientName': recipientName,
        'vpa': vpa,
        'amount': amount,
        'isMismatch': isMismatch,
        'riskLevel': riskLevel.name,
        'timestamp': timestamp.toIso8601String(),
        'rawPayload': rawPayload,
        'notes': notes,
      };

  factory QrScanData.fromMap(Map<String, dynamic> map) => QrScanData(
        merchantName: map['merchantName'] as String,
        recipientName: map['recipientName'] as String,
        vpa: map['vpa'] as String,
        amount: (map['amount'] as num).toDouble(),
        isMismatch: map['isMismatch'] as bool,
        riskLevel: RiskLevel.values.firstWhere(
          (r) => r.name == map['riskLevel'],
          orElse: () => RiskLevel.low,
        ),
        timestamp: DateTime.parse(map['timestamp'] as String),
        rawPayload: map['rawPayload'] as String,
        notes: map['notes'] as String,
      );
}
