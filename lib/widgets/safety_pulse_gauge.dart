import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class SafetyPulseGauge extends StatelessWidget {
  final int safetyScore; // 0 to 100
  final int activeRisks;
  final int recentAlerts;
  final int recoveryPoints;
  final String? statusTitle;
  final Color? statusBgColorOverride;

  const SafetyPulseGauge({
    super.key,
    required this.safetyScore,
    required this.activeRisks,
    required this.recentAlerts,
    required this.recoveryPoints,
    this.statusTitle,
    this.statusBgColorOverride,
  });

  String get statusText {
    if (statusTitle != null) return statusTitle!;
    if (safetyScore >= 90) return 'LOOKING GOOD';
    if (safetyScore >= 60) return 'ATTENTION';
    return 'ACTION REQUIRED';
  }

  Color get statusBgColor {
    if (statusBgColorOverride != null) return statusBgColorOverride!;
    if (safetyScore >= 90) return AppTheme.pastelMint;
    if (safetyScore >= 60) return AppTheme.pastelAmber;
    return AppTheme.pastelCoral;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.bgSurface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.strokeBlack,
          width: AppTheme.strokeWidth,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header Label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'RESQ SAFETY PULSE',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusBgColor,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                ),
                child: Text(
                  statusText,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // Central Pulse Metric Circle
          Row(
            children: [
              // Large circular meter
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppTheme.pastelPurple,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.strokeBlack,
                    width: AppTheme.strokeWidth,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$safetyScore%',
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -1.0,
                        ),
                      ),
                      const Text(
                        'SAFETY',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // Three stats columns
              Expanded(
                child: Column(
                  children: [
                    _buildStatRow(
                      label: 'System Safety',
                      value: '$safetyScore%',
                      dotColor: safetyScore >= 90 ? AppTheme.mintDark : AppTheme.coralDark,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      label: 'Active Risks',
                      value: '$activeRisks',
                      dotColor: activeRisks == 0 ? AppTheme.mintDark : AppTheme.amberDark,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      label: 'Recent Alerts',
                      value: '$recentAlerts',
                      dotColor: AppTheme.lilacDark,
                    ),
                    const SizedBox(height: 8),
                    _buildStatRow(
                      label: 'Recovery Points',
                      value: '$recoveryPoints',
                      dotColor: AppTheme.textPrimary,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow({
    required String label,
    required String value,
    required Color dotColor,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.strokeBlack, width: 1.0),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w900,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
