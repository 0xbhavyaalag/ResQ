import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/recovery_point.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/software_safety_provider.dart';
import '../../widgets/neo_card.dart';
import '../../widgets/step_progress_card.dart';
import '../../services/recovery_service.dart';

class RecoveryCenterScreen extends StatelessWidget {
  const RecoveryCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final softwareProvider = context.watch<SoftwareSafetyProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgNeutral,
      appBar: AppBar(
        title: const Text('Recovery Center'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Recover Safely',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Restore verified checkpoints with zero configuration drift and automatic post-recovery validation.',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),

              // Active animated recovery sequence if restoring or verified
              if (softwareProvider.isRestoring || softwareProvider.isRecoveryVerified) ...[
                _buildActiveRecoveryCard(context, softwareProvider),
                const SizedBox(height: 24),
              ],

              // Recovery Points List Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'AVAILABLE SAFE VERSIONS',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.0,
                      color: AppTheme.textMuted,
                    ),
                  ),
                  Text(
                    '${appState.recoveryPoints.length} Saved',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.lilacDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              if (appState.recoveryPoints.isEmpty)
                NeoCard(
                  backgroundColor: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: const Center(
                    child: Text(
                      'No recovery points saved yet. Use "Protect Software" to snapshot safe versions.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ),
                )
              else
                ...appState.recoveryPoints.map((point) {
                  return _buildRecoveryPointCard(context, point, softwareProvider, appState);
                }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecoveryPointCard(
    BuildContext context,
    RecoveryPoint point,
    SoftwareSafetyProvider softwareProvider,
    AppStateProvider appState,
  ) {
    final dateFormat = DateFormat('MMM d — h:mm a');
    final formattedDate = dateFormat.format(point.timestamp);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      child: NeoCard(
        backgroundColor: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.pastelMint,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                  ),
                  child: const Text(
                    'SAFE VERSION',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0.5,
                      color: AppTheme.strokeBlack,
                    ),
                  ),
                ),
                Text(
                  point.versionLabel,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Text(
              point.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w900,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              formattedDate,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMuted,
              ),
            ),
            const SizedBox(height: 12),

            // Health Checklist
            _buildCheckItem(
              'Application Healthy',
              point.isApplicationHealthy,
            ),
            const SizedBox(height: 4),
            _buildCheckItem(
              'Database Connected',
              point.isDatabaseConnected,
            ),
            const SizedBox(height: 4),
            _buildCheckItem(
              'No Recent Errors',
              !point.hasRecentErrors,
            ),
            const SizedBox(height: 16),

            // Restore Button
            ElevatedButton(
              onPressed: softwareProvider.isRestoring
                  ? null
                  : () => _confirmRestore(context, point, softwareProvider, appState),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.pastelPurple,
              ),
              child: const Text('RESTORE'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckItem(String label, bool isOk) {
    return Row(
      children: [
        Icon(
          isOk ? Icons.check_circle_rounded : Icons.cancel_rounded,
          size: 16,
          color: isOk ? AppTheme.mintDark : AppTheme.coralDark,
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  void _confirmRestore(
    BuildContext context,
    RecoveryPoint point,
    SoftwareSafetyProvider softwareProvider,
    AppStateProvider appState,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
        ),
        title: const Text(
          'Restore this safe version?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
        content: const Text(
          'Your current configuration will be replaced with this recovery point.',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.textSecondary,
          ),
        ),
        actions: [
          OutlinedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              softwareProvider.restoreSafeVersion(point, appState);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelMint),
            child: const Text('RESTORE SAFELY'),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveRecoveryCard(BuildContext context, SoftwareSafetyProvider softwareProvider) {
    return NeoCard(
      backgroundColor: softwareProvider.isRecoveryVerified ? AppTheme.pastelMint : AppTheme.pastelPurple,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                softwareProvider.isRecoveryVerified ? '✓ RECOVERY VERIFIED' : 'RESTORATION IN PROGRESS',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppTheme.strokeBlack,
                ),
              ),
              if (softwareProvider.isRestoring)
                const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.strokeBlack),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // 4 Animated Steps
          ...softwareProvider.recoverySteps.map((s) {
            return StepProgressCard(
              title: s.title,
              isInProgress: s.status == RecoveryStepStatus.inProgress,
              isSuccess: s.status == RecoveryStepStatus.success,
              isPending: s.status == RecoveryStepStatus.pending,
            );
          }),

          if (softwareProvider.isRecoveryVerified) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const _VerifiedCheckRow('Configuration restored'),
                  const SizedBox(height: 4),
                  const _VerifiedCheckRow('Application running'),
                  const SizedBox(height: 4),
                  const _VerifiedCheckRow('Database connected'),
                  const SizedBox(height: 4),
                  const _VerifiedCheckRow('Health check passed'),
                  const SizedBox(height: 10),
                  const Text(
                    'RECOVERY VERIFIED — SYSTEM HEALTHY',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.mintDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () {
                      final appState = context.read<AppStateProvider>();
                      appState.setNavIndex(0);
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelMint),
                    child: const Text('BACK TO SAFETY PULSE'),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _VerifiedCheckRow extends StatelessWidget {
  final String text;
  const _VerifiedCheckRow(this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.check_circle_rounded, size: 16, color: AppTheme.mintDark),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
