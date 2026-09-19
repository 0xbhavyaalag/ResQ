/// A validated system state snapshot that can be restored when issues arise.
class RecoveryPoint {
  final String id;
  final String title;
  final DateTime timestamp;
  final bool isApplicationHealthy;
  final bool isDatabaseConnected;
  final bool hasRecentErrors;
  final String versionLabel;
  final String actionSource;
  final Map<String, dynamic>? metadata;

  const RecoveryPoint({
    required this.id,
    required this.title,
    required this.timestamp,
    this.isApplicationHealthy = true,
    this.isDatabaseConnected = true,
    this.hasRecentErrors = false,
    required this.versionLabel,
    required this.actionSource,
    this.metadata,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'timestamp': timestamp.toIso8601String(),
        'isApplicationHealthy': isApplicationHealthy,
        'isDatabaseConnected': isDatabaseConnected,
        'hasRecentErrors': hasRecentErrors,
        'versionLabel': versionLabel,
        'actionSource': actionSource,
        'metadata': metadata,
      };

  factory RecoveryPoint.fromMap(Map<String, dynamic> map) => RecoveryPoint(
        id: map['id'] as String,
        title: map['title'] as String,
        timestamp: DateTime.parse(map['timestamp'] as String),
        isApplicationHealthy: map['isApplicationHealthy'] as bool? ?? true,
        isDatabaseConnected: map['isDatabaseConnected'] as bool? ?? true,
        hasRecentErrors: map['hasRecentErrors'] as bool? ?? false,
        versionLabel: map['versionLabel'] as String,
        actionSource: map['actionSource'] as String,
        metadata: map['metadata'] as Map<String, dynamic>?,
      );
}
