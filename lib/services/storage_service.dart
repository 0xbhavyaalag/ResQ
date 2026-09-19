import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../models/recovery_point.dart';
import '../models/security_event.dart';
import '../models/risk_model.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  SharedPreferences? _prefs;

  Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    await _seedInitialDataIfNeeded();
  }

  SharedPreferences get prefs {
    if (_prefs == null) {
      throw StateError('StorageService must be initialized before use.');
    }
    return _prefs!;
  }

  Future<void> _seedInitialDataIfNeeded() async {
    final hasLaunched = prefs.getBool(AppConstants.keyFirstLaunch) ?? false;
    if (!hasLaunched) {
      // Seed default safety score 94%
      await prefs.setInt(AppConstants.keySystemSafetyScore, 94);

      // Seed initial recovery points
      final initialPoints = [
        RecoveryPoint(
          id: 'rec_init_1',
          title: 'Safe Configuration Snapshot',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          isApplicationHealthy: true,
          isDatabaseConnected: true,
          hasRecentErrors: false,
          versionLabel: 'v2.4.1-stable',
          actionSource: 'Scheduled Guard',
        ),
        RecoveryPoint(
          id: 'rec_init_2',
          title: 'Pre-Deployment Backup',
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isApplicationHealthy: true,
          isDatabaseConnected: true,
          hasRecentErrors: false,
          versionLabel: 'v2.4.0-release',
          actionSource: 'Manual Snapshot',
        ),
      ];
      await saveRecoveryPoints(initialPoints);

      // Seed initial history events
      final initialHistory = [
        SecurityEvent(
          id: 'evt_init_1',
          title: 'Recovery Point Created',
          subtitle: 'Scheduled snapshot v2.4.1-stable saved safely',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          category: SecurityCategory.recovery,
          riskLevel: RiskLevel.low,
        ),
        SecurityEvent(
          id: 'evt_init_2',
          title: 'Suspicious Link Evaluated',
          subtitle: 'Phishing domain detected: paypa1-update.info',
          timestamp: DateTime.now().subtract(const Duration(hours: 5)),
          category: SecurityCategory.fraud,
          riskLevel: RiskLevel.high,
        ),
        SecurityEvent(
          id: 'evt_init_3',
          title: 'System Health Check Passed',
          subtitle: 'Database connection latencies normal (<12ms)',
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          category: SecurityCategory.software,
          riskLevel: RiskLevel.low,
        ),
      ];
      await saveHistoryEvents(initialHistory);

      await prefs.setBool(AppConstants.keyFirstLaunch, true);
    }
  }

  // Safety Score
  int getSafetyScore() {
    return prefs.getInt(AppConstants.keySystemSafetyScore) ?? 94;
  }

  Future<void> setSafetyScore(int score) async {
    await prefs.setInt(AppConstants.keySystemSafetyScore, score);
  }

  // Recovery Points
  List<RecoveryPoint> getRecoveryPoints() {
    final raw = prefs.getString(AppConstants.keyRecoveryPoints);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => RecoveryPoint.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveRecoveryPoints(List<RecoveryPoint> points) async {
    final encoded = jsonEncode(points.map((p) => p.toMap()).toList());
    await prefs.setString(AppConstants.keyRecoveryPoints, encoded);
  }

  Future<void> addRecoveryPoint(RecoveryPoint point) async {
    final current = getRecoveryPoints();
    current.insert(0, point);
    await saveRecoveryPoints(current);
  }

  // Security History
  List<SecurityEvent> getHistoryEvents() {
    final raw = prefs.getString(AppConstants.keyHistoryEvents);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => SecurityEvent.fromMap(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistoryEvents(List<SecurityEvent> events) async {
    final encoded = jsonEncode(events.map((e) => e.toMap()).toList());
    await prefs.setString(AppConstants.keyHistoryEvents, encoded);
  }

  Future<void> addHistoryEvent(SecurityEvent event) async {
    final current = getHistoryEvents();
    current.insert(0, event);
    await saveHistoryEvents(current);
  }

  Future<void> clearHistory() async {
    await prefs.remove(AppConstants.keyHistoryEvents);
  }

  // Preferences
  bool isPresentationMode() => prefs.getBool(AppConstants.keyPresentationMode) ?? false;
  Future<void> setPresentationMode(bool value) =>
      prefs.setBool(AppConstants.keyPresentationMode, value);

  bool isDemoMode() => prefs.getBool(AppConstants.keyDemoMode) ?? true;
  Future<void> setDemoMode(bool value) => prefs.setBool(AppConstants.keyDemoMode, value);

  // Selected Device
  String? getSelectedBrand() => prefs.getString(AppConstants.keySelectedBrand);
  String? getSelectedModel() => prefs.getString(AppConstants.keySelectedModel);
  Future<void> saveSelectedDevice(String brand, String model) async {
    await prefs.setString(AppConstants.keySelectedBrand, brand);
    await prefs.setString(AppConstants.keySelectedModel, model);
  }
  Future<void> clearSelectedDevice() async {
    await prefs.remove(AppConstants.keySelectedBrand);
    await prefs.remove(AppConstants.keySelectedModel);
  }

  Future<void> resetToDefaults() async {
    await prefs.clear();
    await _seedInitialDataIfNeeded();
  }
}
