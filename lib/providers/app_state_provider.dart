import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/risk_model.dart';
import '../models/recovery_point.dart';
import '../models/security_event.dart';
import '../services/storage_service.dart';

class AppStateProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();

  int _currentNavIndex = 0;
  int _safetyScore = 94;
  int _activeRisks = 1;
  int _recentAlerts = 2;
  List<RecoveryPoint> _recoveryPoints = [];
  List<SecurityEvent> _historyEvents = [];

  // Unified 7-Step ResQ Flow State
  ResqFlowState _flowState = ResqFlowState.healthy;
  String _activeSoftwareAction = 'Database Configuration';
  RiskResult? _activeRiskResult;

  // Controlled ResQ Demo Application Environment State
  String _controlledAppStatus = 'Healthy (PID 4092)';
  String _controlledDbStatus = 'Connected (Port 5432, Pool 50/50)';
  String _controlledHealthCheck = '200 OK — Latency 14ms';
  List<String> _controlledLogs = [
    '[10:30:12] INFO: Service gateway initialized on port 8080',
    '[10:31:45] INFO: Database connection pool established with 50 workers',
    '[10:33:01] INFO: Health check endpoint /healthz returned 200 OK',
  ];
  String? _incidentCause;
  String? _incidentEvidence;

  // Smart Insight dynamic state
  String _insightMessage = 'A configuration change was detected recently.';
  String _insightRecommendation = 'ResQ recommends creating a recovery point.';
  String? _insightActionLabel = 'PROTECT NOW';
  bool _isInsightWarning = true;

  // Selected Device State
  String? _selectedBrand;
  String? _selectedModel;

  int get currentNavIndex => _currentNavIndex;
  int get safetyScore => _safetyScore;
  int get activeRisks => _activeRisks;
  int get recentAlerts => _recentAlerts;
  List<RecoveryPoint> get recoveryPoints => _recoveryPoints;
  List<SecurityEvent> get historyEvents => _historyEvents;

  String? get selectedBrand => _selectedBrand;
  String? get selectedModel => _selectedModel;
  String? get selectedDevice => _selectedModel != null
      ? (_selectedBrand != null ? '$_selectedBrand $_selectedModel' : _selectedModel)
      : null;

  ResqFlowState get flowState => _flowState;
  String get activeSoftwareAction => _activeSoftwareAction;
  RiskResult? get activeRiskResult => _activeRiskResult;

  String get controlledAppStatus => _controlledAppStatus;
  String get controlledDbStatus => _controlledDbStatus;
  String get controlledHealthCheck => _controlledHealthCheck;
  List<String> get controlledLogs => _controlledLogs;
  String? get incidentCause => _incidentCause;
  String? get incidentEvidence => _incidentEvidence;

  String get insightMessage => _insightMessage;
  String get insightRecommendation => _insightRecommendation;
  String? get insightActionLabel => _insightActionLabel;
  bool get isInsightWarning => _isInsightWarning;

  /// Dynamic Home Safety Pulse Status Title
  String get pulseStatusTitle {
    switch (_flowState) {
      case ResqFlowState.verified:
        return 'RECOVERY VERIFIED';
      case ResqFlowState.recovering:
        return 'RECOVERING';
      case ResqFlowState.failureDetected:
      case ResqFlowState.diagnosed:
        return 'ACTION REQUIRED';
      case ResqFlowState.riskPredicted:
      case ResqFlowState.warningActive:
        return 'ATTENTION';
      case ResqFlowState.protected:
        return 'PROTECTED';
      case ResqFlowState.actionSelected:
      case ResqFlowState.healthy:
        return 'LOOKING GOOD';
    }
  }

  /// Dynamic Home Safety Pulse Status Background
  Color get pulseStatusBgColor {
    switch (_flowState) {
      case ResqFlowState.verified:
        return AppTheme.pastelMint;
      case ResqFlowState.recovering:
        return AppTheme.pastelBlue;
      case ResqFlowState.failureDetected:
      case ResqFlowState.diagnosed:
        return AppTheme.pastelCoral;
      case ResqFlowState.riskPredicted:
      case ResqFlowState.warningActive:
        return AppTheme.pastelAmber;
      case ResqFlowState.protected:
        return AppTheme.pastelMint;
      case ResqFlowState.actionSelected:
      case ResqFlowState.healthy:
        return AppTheme.pastelMint;
    }
  }

  AppStateProvider() {
    refreshAll();
  }

  void setNavIndex(int index) {
    if (_currentNavIndex != index) {
      _currentNavIndex = index;
      notifyListeners();
    }
  }

  void refreshAll() {
    _safetyScore = _storage.getSafetyScore();
    _recoveryPoints = _storage.getRecoveryPoints();
    _historyEvents = _storage.getHistoryEvents();
    _selectedBrand = _storage.getSelectedBrand();
    _selectedModel = _storage.getSelectedModel();
    _evaluateInsight();
    notifyListeners();
  }

  void _evaluateInsight() {
    if (_flowState == ResqFlowState.verified) {
      _insightMessage = 'System verified and completely healthy.';
      _insightRecommendation = 'Safe checkpoint restored. Monitored components stable.';
      _insightActionLabel = null;
      _isInsightWarning = false;
      _activeRisks = 0;
    } else if (_flowState == ResqFlowState.failureDetected || _flowState == ResqFlowState.diagnosed) {
      _insightMessage = 'Application failure detected in active services.';
      _insightRecommendation = 'Restore a safe version immediately to resume operation.';
      _insightActionLabel = 'RESTORE NOW';
      _isInsightWarning = true;
      _activeRisks = 2;
    } else if (_flowState == ResqFlowState.protected) {
      _insightMessage = 'Safe snapshot created for $_activeSoftwareAction.';
      _insightRecommendation = 'You are ready to safely proceed or test failure simulation.';
      _insightActionLabel = 'SIMULATE FAILURE';
      _isInsightWarning = false;
      _activeRisks = 1;
    } else if (_safetyScore < 50) {
      _insightMessage = 'Application failure detected in active services.';
      _insightRecommendation = 'Restore a safe version immediately to resume operation.';
      _insightActionLabel = 'RESTORE NOW';
      _isInsightWarning = true;
      _activeRisks = 2;
    } else if (_safetyScore < 95) {
      _insightMessage = 'A configuration change was detected recently.';
      _insightRecommendation = 'ResQ recommends creating a recovery point.';
      _insightActionLabel = 'PROTECT NOW';
      _isInsightWarning = true;
      _activeRisks = 1;
    } else {
      _insightMessage = 'All monitored components are operating normally.';
      _insightRecommendation = 'Nothing needs your attention right now.';
      _insightActionLabel = null;
      _isInsightWarning = false;
      _activeRisks = 0;
    }
  }

  // --- Step 1: User Action Selected ---
  void onActionSelected(String action) {
    _activeSoftwareAction = action;
    _flowState = ResqFlowState.actionSelected;
    notifyListeners();
  }

  // --- Step 2 & 3: Risk Predicted & Warning Active ---
  void onRiskPredicted(RiskResult result) {
    _activeRiskResult = result;
    _flowState = ResqFlowState.warningActive;
    _safetyScore = 68;
    _activeRisks = 1;
    _evaluateInsight();
    notifyListeners();
  }

  // --- Protection Point Created ---
  Future<void> onProtected(RecoveryPoint point) async {
    _flowState = ResqFlowState.protected;
    await addRecoveryPoint(point);
    _evaluateInsight();
    notifyListeners();
  }

  // --- Step 4: Controlled Failure Detected ---
  Future<void> onFailureSimulated({required String action}) async {
    _flowState = ResqFlowState.failureDetected;
    _controlledAppStatus = 'Unhealthy (Exceptions Thrown)';
    _controlledDbStatus = 'Connection Failed (Pool Exhausted)';
    _controlledHealthCheck = '500 Server Error — Port 5432 Unreachable';
    _controlledLogs.addAll([
      '[10:34:10] WARN: Configuration applied: pool_size=5 (reduced from 50)',
      '[10:34:12] ERROR: could not connect to server: Connection refused',
      '[10:34:14] FATAL: connection pool exhausted, 24 queries failed',
      '[10:34:15] CRITICAL: /healthz health check probe returned HTTP 500',
    ]);
    _incidentCause = 'Recent Database Configuration Change';
    _incidentEvidence = 'Configuration altered pool parameters leading to socket exhaustion & 500 health check failure.';

    await updateSafetyScore(24);
    _activeRisks = 2;
    _evaluateInsight();
    notifyListeners();
  }

  // --- Step 5: AI Diagnosed ---
  void onDiagnosed({required String cause, required String evidence}) {
    _flowState = ResqFlowState.diagnosed;
    _incidentCause = cause;
    _incidentEvidence = evidence;
    notifyListeners();
  }

  // --- Step 6: Recovering ---
  void onRecovering() {
    _flowState = ResqFlowState.recovering;
    _safetyScore = 60;
    notifyListeners();
  }

  // --- Step 7: Recovery Verified ---
  Future<void> onRecoveryVerified() async {
    _flowState = ResqFlowState.verified;
    _controlledAppStatus = 'Healthy (PID 4118)';
    _controlledDbStatus = 'Connected (Port 5432, Pool 50/50)';
    _controlledHealthCheck = '200 OK — Latency 11ms';
    _controlledLogs.addAll([
      '[10:36:01] INFO: Restoring configuration snapshot...',
      '[10:36:03] INFO: Database connection re-established on port 5432',
      '[10:36:04] INFO: Health check passed: 200 OK (all services green)',
      '[10:36:05] SUCCESS: System recovery verified with zero drift',
    ]);
    await updateSafetyScore(100);
    _activeRisks = 0;
    _evaluateInsight();
    notifyListeners();
  }

  Future<void> updateSafetyScore(int newScore) async {
    _safetyScore = newScore;
    await _storage.setSafetyScore(newScore);
    _evaluateInsight();
    notifyListeners();
  }

  Future<void> addRecoveryPoint(RecoveryPoint point) async {
    await _storage.addRecoveryPoint(point);
    _recoveryPoints = _storage.getRecoveryPoints();
    notifyListeners();
  }

  Future<void> logSecurityEvent(SecurityEvent event) async {
    await _storage.addHistoryEvent(event);
    _historyEvents = _storage.getHistoryEvents();
    _recentAlerts = _historyEvents.length.clamp(1, 99);
    notifyListeners();
  }

  Future<void> clearHistory() async {
    await _storage.clearHistory();
    _historyEvents = [];
    _recentAlerts = 0;
    notifyListeners();
  }

  Future<void> setSelectedDevice(String brand, String model) async {
    _selectedBrand = brand;
    _selectedModel = model;
    await _storage.saveSelectedDevice(brand, model);
    notifyListeners();
  }

  Future<void> clearSelectedDevice() async {
    _selectedBrand = null;
    _selectedModel = null;
    await _storage.clearSelectedDevice();
    notifyListeners();
  }

  void resetAllDemoFlow() {
    _flowState = ResqFlowState.healthy;
    _safetyScore = 94;
    _activeRisks = 1;
    _controlledAppStatus = 'Healthy (PID 4092)';
    _controlledDbStatus = 'Connected (Port 5432, Pool 50/50)';
    _controlledHealthCheck = '200 OK — Latency 14ms';
    _controlledLogs = [
      '[10:30:12] INFO: Service gateway initialized on port 8080',
      '[10:31:45] INFO: Database connection pool established with 50 workers',
      '[10:33:01] INFO: Health check endpoint /healthz returned 200 OK',
    ];
    _incidentCause = null;
    _incidentEvidence = null;
    _selectedBrand = null;
    _selectedModel = null;
    _evaluateInsight();
    notifyListeners();
  }
}

