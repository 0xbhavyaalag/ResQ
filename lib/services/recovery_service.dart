enum FailureStepStatus { pending, inProgress, success, failure }

class FailureInvestigationStep {
  final int stepNumber;
  final String title;
  final FailureStepStatus status;
  final String? failureMessage;

  const FailureInvestigationStep({
    required this.stepNumber,
    required this.title,
    required this.status,
    this.failureMessage,
  });

  FailureInvestigationStep copyWith({
    FailureStepStatus? status,
    String? failureMessage,
  }) {
    return FailureInvestigationStep(
      stepNumber: stepNumber,
      title: title,
      status: status ?? this.status,
      failureMessage: failureMessage ?? this.failureMessage,
    );
  }
}

enum RecoveryStepStatus { pending, inProgress, success }

class RecoveryExecutionStep {
  final int stepNumber;
  final String title;
  final RecoveryStepStatus status;

  const RecoveryExecutionStep({
    required this.stepNumber,
    required this.title,
    required this.status,
  });

  RecoveryExecutionStep copyWith({
    RecoveryStepStatus? status,
  }) {
    return RecoveryExecutionStep(
      stepNumber: stepNumber,
      title: title,
      status: status ?? this.status,
    );
  }
}

class RecoveryService {
  static final RecoveryService _instance = RecoveryService._internal();
  factory RecoveryService() => _instance;
  RecoveryService._internal();

  /// Initial step definitions for failure diagnosis simulation
  List<FailureInvestigationStep> getInitialFailureSteps() {
    return [
      const FailureInvestigationStep(
        stepNumber: 1,
        title: 'Checking application...',
        status: FailureStepStatus.pending,
      ),
      const FailureInvestigationStep(
        stepNumber: 2,
        title: 'Checking system health...',
        status: FailureStepStatus.pending,
      ),
      const FailureInvestigationStep(
        stepNumber: 3,
        title: 'Analyzing recent changes...',
        status: FailureStepStatus.pending,
      ),
      const FailureInvestigationStep(
        stepNumber: 4,
        title: 'Analyzing error logs...',
        status: FailureStepStatus.pending,
      ),
    ];
  }

  /// Initial step definitions for verified recovery sequence
  List<RecoveryExecutionStep> getInitialRecoverySteps() {
    return [
      const RecoveryExecutionStep(
        stepNumber: 1,
        title: 'Creating backup...',
        status: RecoveryStepStatus.pending,
      ),
      const RecoveryExecutionStep(
        stepNumber: 2,
        title: 'Restoring safe configuration...',
        status: RecoveryStepStatus.pending,
      ),
      const RecoveryExecutionStep(
        stepNumber: 3,
        title: 'Restarting application...',
        status: RecoveryStepStatus.pending,
      ),
      const RecoveryExecutionStep(
        stepNumber: 4,
        title: 'Running health checks...',
        status: RecoveryStepStatus.pending,
      ),
    ];
  }
}
