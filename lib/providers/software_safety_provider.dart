import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/risk_model.dart';
import '../models/recovery_point.dart';
import '../models/security_event.dart';
import '../services/risk_service.dart';
import '../services/recovery_service.dart';
import 'app_state_provider.dart';

class SoftwareSafetyProvider extends ChangeNotifier {
  final RiskService _riskService = RiskService();
  final RecoveryService _recoveryService = RecoveryService();

  String _selectedAction = AppConstants.actionDbConfig;
  bool _isAnalyzingRisk = false;
  RiskResult? _currentRiskResult;

  // Protection state
  bool _isCreatingRecoveryPoint = false;
  bool _hasCreatedRecoveryPoint = false;
  bool _hasProceededWithoutSnapshot = false;

  // Failure Simulation state
  bool _isSimulatingFailure = false;
  bool _hasFailureOccurred = false;
  List<FailureInvestigationStep> _failureSteps = [];

  // Recovery Execution state
  bool _isRestoring = false;
  bool _isRecoveryVerified = false;
  List<RecoveryExecutionStep> _recoverySteps = [];

  // Getters
  String get selectedAction => _selectedAction;
  bool get isAnalyzingRisk => _isAnalyzingRisk;
  RiskResult? get currentRiskResult => _currentRiskResult;
  bool get isCreatingRecoveryPoint => _isCreatingRecoveryPoint;
  bool get hasCreatedRecoveryPoint => _hasCreatedRecoveryPoint;
  bool get hasProceededWithoutSnapshot => _hasProceededWithoutSnapshot;
  bool get isSimulatingFailure => _isSimulatingFailure;
  bool get hasFailureOccurred => _hasFailureOccurred;
  List<FailureInvestigationStep> get failureSteps => _failureSteps;
  bool get isRestoring => _isRestoring;
  bool get isRecoveryVerified => _isRecoveryVerified;
  List<RecoveryExecutionStep> get recoverySteps => _recoverySteps;

  SoftwareSafetyProvider() {
    _failureSteps = List<FailureInvestigationStep>.from(_recoveryService.getInitialFailureSteps());
    _recoverySteps = List<RecoveryExecutionStep>.from(_recoveryService.getInitialRecoverySteps());
  }

  void selectAction(String action, [AppStateProvider? appState]) {
    _selectedAction = action;
    _currentRiskResult = null;
    _hasCreatedRecoveryPoint = false;
    _hasProceededWithoutSnapshot = false;
    _hasFailureOccurred = false;
    _isRecoveryVerified = false;
    _failureSteps = List<FailureInvestigationStep>.from(_recoveryService.getInitialFailureSteps());
    _recoverySteps = List<RecoveryExecutionStep>.from(_recoveryService.getInitialRecoverySteps());
    appState?.onActionSelected(action);
    notifyListeners();
  }

  Future<void> proceedWithoutProtection(AppStateProvider appState) async {
    _hasProceededWithoutSnapshot = true;
    _hasCreatedRecoveryPoint = false;
    await appState.logSecurityEvent(
      SecurityEvent(
        id: 'evt_warn_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Proceeded Without Recovery Snapshot',
        subtitle: 'Applied "$_selectedAction" despite high risk score (${_currentRiskResult?.score ?? 82}/100)',
        timestamp: DateTime.now(),
        category: SecurityCategory.software,
        riskLevel: RiskLevel.high,
      ),
    );
    notifyListeners();
  }

  Future<void> analyzeSelectedAction(AppStateProvider appState) async {
    _isAnalyzingRisk = true;
    _currentRiskResult = null;
    _hasCreatedRecoveryPoint = false;
    notifyListeners();

    final result = await _riskService.analyzeAction(
      actionType: _selectedAction,
    );

    _currentRiskResult = result;
    _isAnalyzingRisk = false;
    appState.onRiskPredicted(result);

    // Log event
    await appState.logSecurityEvent(
      SecurityEvent(
        id: 'evt_risk_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Configuration Risk Evaluated',
        subtitle: '$_selectedAction scored ${result.score}/100 (${result.level.shortLabel}, ${result.confidence}% confidence)',
        timestamp: DateTime.now(),
        category: SecurityCategory.software,
        riskLevel: result.level,
      ),
    );

    notifyListeners();
  }

  Future<void> protectMySystem(AppStateProvider appState) async {
    _isCreatingRecoveryPoint = true;
    notifyListeners();

    await Future.delayed(const Duration(milliseconds: 700));

    final newPoint = RecoveryPoint(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      title: 'Safe Snapshot ($_selectedAction)',
      timestamp: DateTime.now(),
      isApplicationHealthy: true,
      isDatabaseConnected: true,
      hasRecentErrors: false,
      versionLabel: 'v2.4.2-verified',
      actionSource: _selectedAction,
    );

    await appState.onProtected(newPoint);
    await appState.logSecurityEvent(
      SecurityEvent(
        id: 'evt_rec_${DateTime.now().millisecondsSinceEpoch}',
        title: 'Recovery Point Created',
        subtitle: 'Pre-change safe snapshot saved: ${newPoint.versionLabel}',
        timestamp: DateTime.now(),
        category: SecurityCategory.recovery,
        riskLevel: RiskLevel.low,
      ),
    );

    _isCreatingRecoveryPoint = false;
    _hasCreatedRecoveryPoint = true;
    notifyListeners();
  }

  /// Step-by-step animated failure diagnosis
  Future<void> simulateFailure(AppStateProvider appState) async {
    _isSimulatingFailure = true;
    _hasFailureOccurred = false;
    _isRecoveryVerified = false;
    _failureSteps = List<FailureInvestigationStep>.from(_recoveryService.getInitialFailureSteps());
    notifyListeners();

    try {
      // Step 1: Checking application...
      _failureSteps[0] = _failureSteps[0].copyWith(status: FailureStepStatus.inProgress);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 550));
      _failureSteps[0] = _failureSteps[0].copyWith(status: FailureStepStatus.success);
      notifyListeners();

      // Step 2: Checking system health...
      _failureSteps[1] = _failureSteps[1].copyWith(status: FailureStepStatus.inProgress);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 650));
      _failureSteps[1] = _failureSteps[1].copyWith(
        status: FailureStepStatus.failure,
        failureMessage: 'Health check failed (HTTP 500)',
      );
      notifyListeners();

      // Step 3: Analyzing recent changes...
      _failureSteps[2] = _failureSteps[2].copyWith(status: FailureStepStatus.inProgress);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 550));
      _failureSteps[2] = _failureSteps[2].copyWith(status: FailureStepStatus.success);
      notifyListeners();

      // Step 4: Analyzing error logs...
      _failureSteps[3] = _failureSteps[3].copyWith(status: FailureStepStatus.inProgress);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 550));
      _failureSteps[3] = _failureSteps[3].copyWith(status: FailureStepStatus.success);
      notifyListeners();

      // Final outcome
      _hasFailureOccurred = true;

      // Mutate controlled ResQ demo application environment state
      await appState.onFailureSimulated(action: _selectedAction);
      await appState.logSecurityEvent(
        SecurityEvent(
          id: 'evt_fail_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Application Failure Detected',
          subtitle: 'Database connection failed following configuration change',
          timestamp: DateTime.now(),
          category: SecurityCategory.software,
          riskLevel: RiskLevel.critical,
        ),
      );
    } catch (e, stack) {
      debugPrint('Error in simulateFailure: $e\n$stack');
    } finally {
      _isSimulatingFailure = false;
      notifyListeners();
    }
  }

  /// 4-step animated recovery verification
  Future<void> restoreSafeVersion(RecoveryPoint point, AppStateProvider appState) async {
    _isRestoring = true;
    _isRecoveryVerified = false;
    _recoverySteps = List<RecoveryExecutionStep>.from(_recoveryService.getInitialRecoverySteps());
    appState.onRecovering();
    notifyListeners();

    try {
      // Step 1: Creating backup...
      _recoverySteps[0] = _recoverySteps[0].copyWith(status: RecoveryStepStatus.inProgress);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 600));
      _recoverySteps[0] = _recoverySteps[0].copyWith(status: RecoveryStepStatus.success);
      notifyListeners();

      // Step 2: Restoring safe configuration...
      _recoverySteps[1] = _recoverySteps[1].copyWith(status: RecoveryStepStatus.inProgress);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 650));
      _recoverySteps[1] = _recoverySteps[1].copyWith(status: RecoveryStepStatus.success);
      notifyListeners();

      // Step 3: Restarting application...
      _recoverySteps[2] = _recoverySteps[2].copyWith(status: RecoveryStepStatus.inProgress);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 650));
      _recoverySteps[2] = _recoverySteps[2].copyWith(status: RecoveryStepStatus.success);
      notifyListeners();

      // Step 4: Running health checks...
      _recoverySteps[3] = _recoverySteps[3].copyWith(status: RecoveryStepStatus.inProgress);
      notifyListeners();
      await Future.delayed(const Duration(milliseconds: 700));
      _recoverySteps[3] = _recoverySteps[3].copyWith(status: RecoveryStepStatus.success);
      notifyListeners();

      _isRecoveryVerified = true;

      // Fully restore controlled demo state and safety pulse to 100%
      await appState.onRecoveryVerified();
      await appState.logSecurityEvent(
        SecurityEvent(
          id: 'evt_rec_ver_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Recovery Verified',
          subtitle: 'All components restored: Database connected, health check passed',
          timestamp: DateTime.now(),
          category: SecurityCategory.recovery,
          riskLevel: RiskLevel.low,
        ),
      );
    } catch (e, stack) {
      debugPrint('Error in restoreSafeVersion: $e\n$stack');
    } finally {
      _isRestoring = false;
      notifyListeners();
    }
  }

  void resetSoftwareSafetyState() {
    _hasFailureOccurred = false;
    _isRecoveryVerified = false;
    _currentRiskResult = null;
    _hasCreatedRecoveryPoint = false;
    _hasProceededWithoutSnapshot = false;
    _failureSteps = List<FailureInvestigationStep>.from(_recoveryService.getInitialFailureSteps());
    _recoverySteps = List<RecoveryExecutionStep>.from(_recoveryService.getInitialRecoverySteps());
    notifyListeners();
  }
}
