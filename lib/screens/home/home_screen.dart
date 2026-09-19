import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/safety_pulse_gauge.dart';
import '../../widgets/quick_action_card.dart';
import '../../widgets/neo_card.dart';
import '../../widgets/vector_illustrations.dart';
import '../../widgets/voice_assistant_modal.dart';
import '../../widgets/device_selector_modal.dart';
import '../guide/guide_screen.dart';
import '../recovery/recovery_center_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgNeutral,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.pastelPurple,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
              ),
              child: const Center(
                child: Text(
                  'Q',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.strokeBlack,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text(
              AppConstants.appName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppTheme.strokeBlack,
              ),
            ),
          ],
        ),
        actions: [
          // Guide / AI Chatbot & FAQ button
          IconButton(
            icon: const Icon(Icons.help_outline_rounded, size: 22),
            tooltip: 'ResQ Guide & FAQ',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const GuideScreen()),
              );
            },
          ),
          // Live status pill
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: appState.pulseStatusBgColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.shield_outlined, size: 14, color: AppTheme.strokeBlack),
                const SizedBox(width: 4),
                Text(
                  appState.pulseStatusTitle,
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.strokeBlack,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Greeting & Title
              const Text(
                'Good to see you.',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Your Safety Pulse',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),

              // Device Selector Card
              NeoCard(
                backgroundColor: appState.selectedDevice != null ? AppTheme.pastelBlue : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                onTap: () => DeviceSelectorModal.show(context),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: appState.selectedDevice != null ? AppTheme.pastelPurple : AppTheme.surfaceSecondary,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                      ),
                      child: const Icon(
                        Icons.phone_android_rounded,
                        size: 22,
                        color: AppTheme.strokeBlack,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appState.selectedDevice != null ? 'MONITORED DEVICE' : 'DEVICE SELECTION',
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                              color: AppTheme.textMuted,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            appState.selectedDevice ?? 'Select Device',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (appState.selectedDevice != null) ...[
                      // Small Change Device action next to the selected device
                      InkWell(
                        onTap: () => DeviceSelectorModal.show(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.swap_horiz_rounded, size: 14, color: AppTheme.strokeBlack),
                              SizedBox(width: 4),
                              Text(
                                'Change Device',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: AppTheme.strokeBlack,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppTheme.pastelPurple,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                        ),
                        child: const Text(
                          'Select Device',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.strokeBlack,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Dynamic Safety Pulse Gauge
              SafetyPulseGauge(
                safetyScore: appState.safetyScore,
                activeRisks: appState.activeRisks,
                recentAlerts: appState.recentAlerts,
                recoveryPoints: appState.recoveryPoints.length,
                statusTitle: appState.pulseStatusTitle,
                statusBgColorOverride: appState.pulseStatusBgColor,
              ),
              const SizedBox(height: 20),

              // Voice Assistant Quick Launcher Card
              NeoCard(
                backgroundColor: AppTheme.pastelPurple,
                onTap: () => VoiceAssistantModal.show(context),
                child: Row(
                  children: [
                    const VoiceIllustration(width: 70, height: 60),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'ASK RESQ 🎙️',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Tap to ask "Why is this risky?" or "What happened?"',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: AppTheme.strokeBlack),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Smart Insight: "WHAT SHOULD YOU KNOW?"
              const Text(
                'WHAT SHOULD YOU KNOW?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 10),

              NeoCard(
                backgroundColor: appState.isInsightWarning ? AppTheme.pastelAmber : AppTheme.pastelMint,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          appState.isInsightWarning
                              ? Icons.warning_amber_rounded
                              : Icons.check_circle_outline_rounded,
                          color: AppTheme.strokeBlack,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appState.insightMessage,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                appState.insightRecommendation,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (appState.insightActionLabel != null) ...[
                      const SizedBox(height: 14),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: () {
                            if (appState.insightActionLabel == 'RESTORE NOW') {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const RecoveryCenterScreen()),
                              );
                            } else {
                              // Directs to safety screen
                              appState.setNavIndex(2);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                          ),
                          child: Text(
                            appState.insightActionLabel!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.strokeBlack,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Quick Actions Header
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 12),

              // 4 Functional Cards
              QuickActionCard(
                title: 'PROTECT SOFTWARE',
                subtitle: 'Analyze database, dependency, and permission risks',
                icon: Icons.shield_rounded,
                backgroundColor: AppTheme.pastelPurple,
                onTap: () => appState.setNavIndex(2),
              ),
              const SizedBox(height: 12),

              QuickActionCard(
                title: 'CHECK MESSAGE',
                subtitle: 'Detect urgency, credential requests, and fraud',
                icon: Icons.chat_bubble_outline_rounded,
                backgroundColor: AppTheme.pastelBlue,
                onTap: () => appState.setNavIndex(1),
              ),
              const SizedBox(height: 12),

              QuickActionCard(
                title: 'CHECK LINK',
                subtitle: 'Spot phishing domains and typosquatting scams',
                icon: Icons.link_rounded,
                backgroundColor: AppTheme.pastelAmber,
                onTap: () => appState.setNavIndex(1),
              ),
              const SizedBox(height: 12),

              QuickActionCard(
                title: 'CHECK QR',
                subtitle: 'Verify merchant and recipient before payment',
                icon: Icons.qr_code_scanner_rounded,
                backgroundColor: AppTheme.pastelRose,
                onTap: () => appState.setNavIndex(1),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}
