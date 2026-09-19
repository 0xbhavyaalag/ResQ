import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../models/recovery_point.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/software_safety_provider.dart';
import '../../widgets/neo_card.dart';
import '../../widgets/step_progress_card.dart';
import '../../widgets/vector_illustrations.dart';
import '../../widgets/voice_assistant_modal.dart';
import '../../services/recovery_service.dart';
import '../recovery/recovery_center_screen.dart';

class SoftwareSafetyScreen extends StatefulWidget {
  const SoftwareSafetyScreen({super.key});

  @override
  State<SoftwareSafetyScreen> createState() => _SoftwareSafetyScreenState();
}

class _SoftwareSafetyScreenState extends State<SoftwareSafetyScreen> {

  @override
  Widget build(BuildContext context) {
    final software = context.watch<SoftwareSafetyProvider>();
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgNeutral,
      appBar: AppBar(
        title: const Text('Software Safety'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_rounded, size: 24),
            tooltip: 'Ask ResQ (Voice)',
            onPressed: () => VoiceAssistantModal.show(context),
          ),
          IconButton(
            icon: const Icon(Icons.restore_page_rounded, size: 24),
            tooltip: 'Recovery Center',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecoveryCenterScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Flow Pipeline Stepper Header
              _buildFlowPipelineHeader(appState, software),
              const SizedBox(height: 18),

              // Title & Subtitle
              const Text(
                'Protect Your Software',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Predict risks, simulate failures, diagnose causes, and recover safely.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 18),

              // ==============================================================
              // STEP 1: USER ACTION SELECTION
              // ==============================================================
              _buildStepCard(
                stepNumber: 1,
                title: 'USER ACTION',
                subtitle: 'Select an intended software operation to evaluate',
                isActive: software.currentRiskResult == null,
                isCompleted: software.currentRiskResult != null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: AppConstants.softwareActions.map((action) {
                        final isSelected = software.selectedAction == action;
                        return InkWell(
                          onTap: () => software.selectAction(action, appState),
                          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: isSelected ? AppTheme.pastelPurple : Colors.white,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              border: Border.all(
                                color: AppTheme.strokeBlack,
                                width: isSelected ? 2.0 : 1.5,
                              ),
                            ),
                            child: Text(
                              action,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),

                    // ANALYZE RISK Button
                    ElevatedButton.icon(
                      onPressed: software.isAnalyzingRisk
                          ? null
                          : () => software.analyzeSelectedAction(appState),
                      icon: const Icon(Icons.analytics_rounded, size: 20),
                      label: software.isAnalyzingRisk
                          ? const Text('ANALYZING ENVIRONMENT...')
                          : const Text('ANALYZE RISK'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.pastelBlue,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Analyzing State with 2D illustration
              if (software.isAnalyzingRisk) ...[
                NeoCard(
                  backgroundColor: AppTheme.pastelAmber,
                  child: Column(
                    children: const [
                      RiskBrainIllustration(width: 140, height: 100),
                      SizedBox(height: 10),
                      Text(
                        'Analyzing configuration, telemetry & error history...',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // ==============================================================
              // STEP 2 & 3: RISK PREDICTION & WARNING
              // ==============================================================
              if (software.currentRiskResult != null) ...[
                _buildRiskPredictionAndWarningCard(context, software, appState),
                const SizedBox(height: 18),
              ],

              // Protection Confirmation Banner or Unprotected Warning Banner
              if (software.hasCreatedRecoveryPoint) ...[
                _buildProtectionCreatedCard(context, appState),
                const SizedBox(height: 18),
              ],
              if (software.hasProceededWithoutSnapshot) ...[
                _buildUnprotectedWarningCard(context, software, appState),
                const SizedBox(height: 18),
              ],

              // ==============================================================
              // STEP 4: FAILURE DETECTION & CONTROLLED ENVIRONMENT
              // ==============================================================
              if (software.currentRiskResult != null || software.hasFailureOccurred) ...[
                _buildControlledFailureDetectionCard(context, software, appState),
                const SizedBox(height: 18),
              ],

              // ==============================================================
              // STEP 5: AI DIAGNOSIS
              // ==============================================================
              if (software.hasFailureOccurred) ...[
                _buildAiDiagnosisCard(context, software, appState),
                const SizedBox(height: 18),
              ],

              // ==============================================================
              // STEP 6: RECOVERY GUIDANCE & EXECUTION
              // ==============================================================
              if (software.hasFailureOccurred || software.isRestoring || software.isRecoveryVerified) ...[
                _buildRecoveryGuidanceCard(context, software, appState),
                const SizedBox(height: 18),
              ],

              // ==============================================================
              // STEP 7: VERIFICATION
              // ==============================================================
              if (software.isRecoveryVerified) ...[
                _buildVerificationCard(context, software, appState),
                const SizedBox(height: 24),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // --- Visual 7-Step Pipeline Header ---
  Widget _buildFlowPipelineHeader(AppStateProvider appState, SoftwareSafetyProvider software) {
    int currentStep = 1;
    if (software.isRecoveryVerified) {
      currentStep = 7;
    } else if (software.isRestoring) {
      currentStep = 6;
    } else if (software.hasFailureOccurred) {
      currentStep = 5;
    } else if (software.hasCreatedRecoveryPoint || software.hasProceededWithoutSnapshot) {
      currentStep = 4;
    } else if (software.currentRiskResult != null) {
      currentStep = 3;
    }

    final steps = ['ACTION', 'PREDICT', 'WARN', 'DETECT', 'DIAGNOSE', 'RECOVER', 'VERIFY'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RESQ SAFETY PIPELINE',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.pastelPurple,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.strokeBlack, width: 1.0),
                ),
                child: Text(
                  'STEP $currentStep OF 7',
                  style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(steps.length, (i) {
              final isDone = (i + 1) < currentStep;
              final isCurrent = (i + 1) == currentStep;
              return Expanded(
                child: Container(
                  height: 6,
                  margin: EdgeInsets.only(right: i < steps.length - 1 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: isDone
                        ? AppTheme.mintDark
                        : isCurrent
                            ? AppTheme.lilacDark
                            : AppTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(
                      color: (isDone || isCurrent) ? AppTheme.strokeBlack : Colors.transparent,
                      width: 1.0,
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  // --- Step Container Wrapper ---
  Widget _buildStepCard({
    required int stepNumber,
    required String title,
    required String subtitle,
    required bool isActive,
    required bool isCompleted,
    required Widget child,
  }) {
    return NeoCard(
      backgroundColor: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? AppTheme.pastelMint
                      : isActive
                          ? AppTheme.pastelPurple
                          : AppTheme.surfaceSecondary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check_rounded, size: 16, color: AppTheme.strokeBlack)
                      : Text(
                          '$stepNumber',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(fontSize: 11, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  // --- Step 2 & 3: Risk Prediction & Warning Card ---
  Widget _buildRiskPredictionAndWarningCard(
    BuildContext context,
    SoftwareSafetyProvider software,
    AppStateProvider appState,
  ) {
    final res = software.currentRiskResult!;
    return NeoCard(
      backgroundColor: res.level.pastelBg,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Step 2 Badge & Scores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: const [
                  Text(
                    '⚠️ POTENTIAL RISK',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.strokeBlack,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  // Risk Score
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                    ),
                    child: Text(
                      'Score: ${res.score}/100',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ),
                  const SizedBox(width: 6),
                  // AI Confidence
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppTheme.pastelPurple,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                    ),
                    child: Text(
                      'AI Confidence: ${res.confidence}%',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // WHAT WE FOUND / WHAT RESQ DETECTED
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WHAT RESQ DETECTED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  res.summary,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // WHY IT MATTERS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WHY IT MAY BE RISKY',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 6),
                ...res.reasons.map((r) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.mintDark),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              r,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // WHAT COULD HAPPEN
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'WHAT COULD HAPPEN',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  res.potentialImpact,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // WHAT THE USER CAN DO
          Text(
            'WHAT YOU CAN DO: "${res.recommendedAction}"',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 16),

          // Buttons: PROTECT MY SYSTEM, CONTINUE ANYWAY, WHY DID THIS HAPPEN?, ASK RESQ
          ElevatedButton.icon(
            onPressed: software.isCreatingRecoveryPoint
                ? null
                : () => software.protectMySystem(appState),
            icon: const Icon(Icons.shield_rounded, size: 20),
            label: software.isCreatingRecoveryPoint
                ? const Text('CREATING RECOVERY POINT...')
                : const Text('PROTECT MY SYSTEM'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.pastelMint,
            ),
          ),
          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmProceedWithoutProtection(context, software, appState),
                  child: const Text('CONTINUE ANYWAY'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showInvestigationModal(context),
                  child: const Text('WHY DID THIS HAPPEN?'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          OutlinedButton.icon(
            onPressed: () => VoiceAssistantModal.show(context),
            icon: const Icon(Icons.mic_rounded, size: 18, color: AppTheme.lilacDark),
            label: const Text('ASK RESQ 🎙️'),
          ),
        ],
      ),
    );
  }

  // --- Protection Created Confirmation Card ---
  Widget _buildProtectionCreatedCard(BuildContext context, AppStateProvider appState) {
    return NeoCard(
      backgroundColor: AppTheme.pastelMint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.check_circle_rounded, color: AppTheme.mintDark, size: 32),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '✓ RECOVERY POINT CREATED',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      'Safe Version: v2.4.2-verified (Snapshot Saved)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Safe Checklist
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: Column(
              children: [
                _buildCheckRow('Application Healthy', true),
                const SizedBox(height: 6),
                _buildCheckRow('Database Connected', true),
                const SizedBox(height: 6),
                _buildCheckRow('No Recent Errors', true),
              ],
            ),
          ),
          const SizedBox(height: 12),

          ElevatedButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const RecoveryCenterScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
            child: const Text('VIEW IN RECOVERY CENTER'),
          ),
        ],
      ),
    );
  }

  // --- Unprotected Operation Warning Card (When user taps CONTINUE ANYWAY) ---
  Widget _buildUnprotectedWarningCard(
    BuildContext context,
    SoftwareSafetyProvider software,
    AppStateProvider appState,
  ) {
    return NeoCard(
      backgroundColor: AppTheme.pastelCoral,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              Icon(Icons.warning_amber_rounded, color: AppTheme.coralDark, size: 32),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '⚠️ UNPROTECTED EXECUTION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.strokeBlack,
                      ),
                    ),
                    Text(
                      'Operating without pre-change recovery snapshot',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.coralDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'ACTIVE ENVIRONMENT NOTICE:',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.textMuted,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '• You chose to apply "${software.selectedAction}" without creating a recovery point.\n'
                  '• ResQ background guardian is actively monitoring health check endpoints and socket telemetry.\n'
                  '• Test the failure and diagnosis loop in the Controlled Environment below.',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            onPressed: software.isCreatingRecoveryPoint
                ? null
                : () => software.protectMySystem(appState),
            icon: const Icon(Icons.shield_rounded, size: 18),
            label: software.isCreatingRecoveryPoint
                ? const Text('CREATING RECOVERY POINT...')
                : const Text('CREATE RECOVERY POINT NOW'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelMint),
          ),
        ],
      ),
    );
  }

  void _confirmProceedWithoutProtection(
    BuildContext context,
    SoftwareSafetyProvider software,
    AppStateProvider appState,
  ) {
    final score = software.currentRiskResult?.score ?? 82;
    final level = software.currentRiskResult?.level.label ?? 'HIGH RISK';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppTheme.coralDark, size: 24),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Proceed Without Protection?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ResQ predicted a risk score of $score/100 ($level) for "${software.selectedAction}".',
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.pastelCoral,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: AppTheme.strokeBlack, width: 1.2),
              ),
              child: const Text(
                '⚠️ If this configuration change causes an outage, you will NOT have an immediate rollback checkpoint saved.',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.strokeBlack),
              ),
            ),
          ],
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              software.proceedWithoutProtection(appState);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelRose),
            child: const Text('PROCEED ANYWAY'),
          ),
        ],
      ),
    );
  }

  // --- Step 4: Controlled Environment & Failure Simulation Card ---
  Widget _buildControlledFailureDetectionCard(
    BuildContext context,
    SoftwareSafetyProvider software,
    AppStateProvider appState,
  ) {
    return NeoCard(
      backgroundColor: software.hasFailureOccurred ? AppTheme.pastelCoral : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'CONTROLLED DEMO ENVIRONMENT',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppTheme.lilacDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.pastelPurple,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.strokeBlack, width: 1.0),
                ),
                child: const Text(
                  'RESQ SANDBOX',
                  style: TextStyle(fontSize: 9, fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Controlled State Telemetry Rows
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.2),
            ),
            child: Column(
              children: [
                _buildTelemetryRow('App Service', appState.controlledAppStatus),
                const SizedBox(height: 4),
                _buildTelemetryRow('Database', appState.controlledDbStatus),
                const SizedBox(height: 4),
                _buildTelemetryRow('Health Check', appState.controlledHealthCheck),
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (!software.hasFailureOccurred) ...[
            const Text(
              'Simulate an unexpected database connection pool failure to test ResQ\'s detection, diagnosis, and verified recovery loop.',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: software.isSimulatingFailure
                  ? null
                  : () => software.simulateFailure(appState),
              icon: const Icon(Icons.bug_report_rounded, size: 20),
              label: software.isSimulatingFailure
                  ? const Text('DETECTING TELEMETRY...')
                  : const Text('SIMULATE FAILURE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pastelRose,
              ),
            ),
          ],

          // Step-by-step detection progress
          if (software.isSimulatingFailure || software.hasFailureOccurred) ...[
            const SizedBox(height: 12),
            ...software.failureSteps.map((step) {
              return StepProgressCard(
                title: step.title,
                isInProgress: step.status == FailureStepStatus.inProgress,
                isSuccess: step.status == FailureStepStatus.success,
                isFailure: step.status == FailureStepStatus.failure,
                failureMessage: step.failureMessage,
              );
            }),
          ],

          // Incident Announcement
          if (software.hasFailureOccurred) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.error_rounded, color: AppTheme.coralDark, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'APPLICATION FAILURE DETECTED',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.coralDark,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Database connection failed. Socket timeouts detected on port 5432. Health probe returned HTTP 500.',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),

                  // Real-time error log snippet
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.strokeBlack,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '[10:34:12] ERROR: connection refused at db.internal:5432',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Colors.white),
                        ),
                        Text(
                          '[10:34:14] FATAL: connection pool exhausted, 24 queries failed',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFFF87171)),
                        ),
                        Text(
                          '[10:34:15] CRITICAL: /healthz health check returned HTTP 500',
                          style: TextStyle(fontFamily: 'monospace', fontSize: 10, color: Color(0xFFF87171)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  // --- Step 5: AI Diagnosis Card ---
  Widget _buildAiDiagnosisCard(
    BuildContext context,
    SoftwareSafetyProvider software,
    AppStateProvider appState,
  ) {
    return NeoCard(
      backgroundColor: AppTheme.pastelAmber,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              AiDiagnosisIllustration(width: 60, height: 48),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI DIAGNOSIS',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.strokeBlack,
                      ),
                    ),
                    Text(
                      'Root-cause analysis from change timeline & logs',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Flowchart Pipeline: RECENT CHANGE -> LOGS -> ERRORS -> SYSTEM HEALTH -> PROBABLE CAUSE
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'INVESTIGATION PIPELINE',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted),
                ),
                const SizedBox(height: 8),
                _buildPipelineStep('1. Recent Change', software.selectedAction, AppTheme.pastelPurple),
                _buildPipelineConnector(),
                _buildPipelineStep('2. Error Logs', 'Socket timeouts & pool exhaustion', AppTheme.pastelAmber),
                _buildPipelineConnector(),
                _buildPipelineStep('3. System Health', 'Health check failed (HTTP 500)', AppTheme.pastelCoral),
                _buildPipelineConnector(),
                _buildPipelineStep('4. Probable Cause', 'Database Configuration Change', AppTheme.pastelMint),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Evidence Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'EVIDENCE USED',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.textMuted),
                ),
                SizedBox(height: 6),
                _EvidenceLine('Configuration modified at 10:34 AM (pool_size reduced)'),
                SizedBox(height: 4),
                _EvidenceLine('Socket timeouts on port 5432 within 2 seconds of change'),
                SizedBox(height: 4),
                _EvidenceLine('Failure condition matched pre-change risk prediction'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // --- Step 6: Recovery Guidance Card ---
  Widget _buildRecoveryGuidanceCard(
    BuildContext context,
    SoftwareSafetyProvider software,
    AppStateProvider appState,
  ) {
    final availablePoint = appState.recoveryPoints.isNotEmpty ? appState.recoveryPoints.first : null;

    return NeoCard(
      backgroundColor: AppTheme.pastelPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              RecoveryIllustration(width: 60, height: 48),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOVERY GUIDANCE',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.strokeBlack,
                      ),
                    ),
                    Text(
                      'Recommended rollback & validation plan',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'RECOMMENDED ACTION',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppTheme.lilacDark),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Restore the last known healthy configuration snapshot.',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
                ),
                if (availablePoint != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Available Point: ${availablePoint.title} (${availablePoint.versionLabel})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),

          if (!software.isRecoveryVerified) ...[
            ElevatedButton.icon(
              onPressed: software.isRestoring
                  ? null
                  : () {
                      final pt = availablePoint ??
                          RecoveryPoint(
                            id: 'fallback_point',
                            title: 'Baseline Healthy Snapshot',
                            timestamp: DateTime.now(),
                            isApplicationHealthy: true,
                            isDatabaseConnected: true,
                            hasRecentErrors: false,
                            versionLabel: 'v2.4.2-verified',
                            actionSource: software.selectedAction,
                          );
                      software.restoreSafeVersion(pt, appState);
                    },
              icon: const Icon(Icons.settings_backup_restore_rounded, size: 20),
              label: software.isRestoring
                  ? const Text('RECOVERING SYSTEM...')
                  : const Text('RECOVER SAFELY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pastelMint,
              ),
            ),
          ],

          // 4-Step Animated Recovery Execution Progress
          if (software.isRestoring || software.isRecoveryVerified) ...[
            const SizedBox(height: 12),
            ...software.recoverySteps.map((step) {
              return StepProgressCard(
                title: step.title,
                isInProgress: step.status == RecoveryStepStatus.inProgress,
                isSuccess: step.status == RecoveryStepStatus.success,
                isFailure: false,
              );
            }),
          ],
        ],
      ),
    );
  }

  // --- Step 7: Verification Card ---
  Widget _buildVerificationCard(
    BuildContext context,
    SoftwareSafetyProvider software,
    AppStateProvider appState,
  ) {
    return NeoCard(
      backgroundColor: AppTheme.pastelMint,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: const [
              VerificationIllustration(width: 60, height: 48),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RECOVERY VERIFIED',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.strokeBlack,
                      ),
                    ),
                    Text(
                      'SYSTEM HEALTHY',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppTheme.mintDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: Column(
              children: [
                _buildCheckRow('Configuration restored with zero drift', true),
                const SizedBox(height: 6),
                _buildCheckRow('Application state running healthy (PID 4118)', true),
                const SizedBox(height: 6),
                _buildCheckRow('Database state healthy & connected', true),
                const SizedBox(height: 6),
                _buildCheckRow('Health check passed (HTTP 200 OK)', true),
                const SizedBox(height: 6),
                _buildCheckRow('Previous failure condition resolved', true),
              ],
            ),
          ),
          const SizedBox(height: 14),

          ElevatedButton(
            onPressed: () {
              appState.setNavIndex(0); // Switch to Home Safety Pulse
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
            ),
            child: const Text('BACK TO SAFETY PULSE'),
          ),
          const SizedBox(height: 8),

          OutlinedButton(
            onPressed: () {
              software.resetSoftwareSafetyState();
            },
            child: const Text('EVALUATE ANOTHER ACTION'),
          ),
        ],
      ),
    );
  }

  // --- Helper Widgets ---
  Widget _buildCheckRow(String label, bool isChecked) {
    return Row(
      children: [
        Icon(
          isChecked ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 16,
          color: isChecked ? AppTheme.mintDark : AppTheme.coralDark,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }

  Widget _buildTelemetryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.textSecondary),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
        ),
      ],
    );
  }

  Widget _buildPipelineStep(String label, String detail, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: AppTheme.strokeBlack, width: 1.0),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textPrimary),
        ),
        Expanded(
          child: Text(
            detail,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }

  Widget _buildPipelineConnector() {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      height: 10,
      width: 2,
      color: AppTheme.strokeBlack,
    );
  }

  void _showInvestigationModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppTheme.bgNeutral,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppTheme.radiusLarge),
            topRight: Radius.circular(AppTheme.radiusLarge),
          ),
          border: Border(
            top: BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
            left: BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
            right: BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
          ),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'WHY DID THIS HAPPEN?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              NeoCard(
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'HISTORICAL VOLATILITY CORRELATION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMuted),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '“Your application started experiencing database connection errors shortly after its configuration was changed.”',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('GOT IT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EvidenceLine extends StatelessWidget {
  final String text;
  const _EvidenceLine(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.check_circle_rounded, size: 14, color: AppTheme.mintDark),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
          ),
        ),
      ],
    );
  }
}
