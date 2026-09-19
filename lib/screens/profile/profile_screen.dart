import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/settings_provider.dart';
import '../../providers/software_safety_provider.dart';
import '../../providers/fraud_safety_provider.dart';
import '../../widgets/neo_card.dart';
import '../../widgets/vector_illustrations.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final appState = context.read<AppStateProvider>();
    final softwareProvider = context.read<SoftwareSafetyProvider>();
    final fraudProvider = context.read<FraudSafetyProvider>();

    return Scaffold(
      backgroundColor: AppTheme.bgNeutral,
      appBar: AppBar(
        title: const Text('Profile & Settings'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ResQ Brand Card
              NeoCard(
                backgroundColor: AppTheme.pastelPurple,
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const ResqLogo(size: 60),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            AppConstants.appName,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Digital Safety Guardian',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lilacDark,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '“${AppConstants.appTagline}”',
                            style: TextStyle(
                              fontSize: 11,
                              fontStyle: FontStyle.italic,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // LIVE DEMO LAUNCHER (Hackathon Judge Helper)
              const Text(
                'LIVE HACKATHON DEMO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppTheme.lilacDark,
                ),
              ),
              const SizedBox(height: 8),

              NeoCard(
                backgroundColor: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Choose a scenario to test instantly:',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    _buildDemoLauncherButton(
                      title: '1. Software Failure & Recovery Loop',
                      subtitle: 'Database config risk -> failure simulation -> root cause -> verified recovery',
                      color: AppTheme.pastelPurple,
                      onTap: () {
                        softwareProvider.selectAction(AppConstants.actionDbConfig);
                        appState.setNavIndex(2);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildDemoLauncherButton(
                      title: '2. Suspicious Bank Phishing SMS',
                      subtitle: 'Urgency + fake KYC block threat detection with safe advice',
                      color: AppTheme.pastelBlue,
                      onTap: () {
                        fraudProvider.setBankPreset();
                        appState.setNavIndex(1);
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildDemoLauncherButton(
                      title: '3. QR Merchant Mismatch',
                      subtitle: 'Intended "ABC Electronics" vs QR recipient "XYZ Services"',
                      color: AppTheme.pastelRose,
                      onTap: () {
                        fraudProvider.loadDemoQrMismatch(appState);
                        appState.setNavIndex(1);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Settings Controls
              const Text(
                'APPLICATION MODES',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),

              NeoCard(
                backgroundColor: Colors.white,
                child: Column(
                  children: [
                    Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile(
                        title: const Text(
                          'Presentation Mode',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        subtitle: const Text(
                          'Optimizes UI with larger typography and focused demo steps.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        activeThumbColor: AppTheme.lilacDark,
                        value: settings.isPresentationMode,
                        onChanged: (val) => settings.togglePresentationMode(val),
                      ),
                    ),
                    const Divider(color: AppTheme.strokeBlack, thickness: 1.0),
                    Material(
                      type: MaterialType.transparency,
                      child: SwitchListTile(
                        title: const Text(
                          'Demo Mode',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                        ),
                        subtitle: const Text(
                          'Preloads test vectors for 100% offline hackathon presentation.',
                          style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                        ),
                        activeThumbColor: AppTheme.mintDark,
                        value: settings.isDemoMode,
                        onChanged: (val) => settings.toggleDemoMode(val),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),

              // Responsible Use & Disclaimers
              const Text(
                'ABOUT RESQ',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 8),

              NeoCard(
                backgroundColor: AppTheme.surfaceSecondary,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'ResQ v1.0.0 (Release Build)',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                    ),
                    SizedBox(height: 6),
                    Text(
                      '“Digital safety shouldn\'t begin after something goes wrong.”\n\n'
                      'ResQ helps you spot risk, understand problems, recover safely, and move forward with confidence.',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textSecondary, height: 1.4),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Privacy Guarantee: ResQ operates offline-first on device. No sensitive data, passwords, or personal credentials are transmitted.',
                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.textMuted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Reset Button
              OutlinedButton.icon(
                onPressed: () => _confirmReset(context, settings, appState, softwareProvider),
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('RESET DEMO DATA'),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDemoLauncherButton({
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppTheme.textSecondary),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppTheme.strokeBlack),
          ],
        ),
      ),
    );
  }

  void _confirmReset(
    BuildContext context,
    SettingsProvider settings,
    AppStateProvider appState,
    SoftwareSafetyProvider softwareProvider,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
        ),
        title: const Text('Reset All Demo State?'),
        content: const Text('This resets safety scores, recovery checkpoints, and audit logs to the initial baseline.'),
        actions: [
          OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(ctx).pop();
              await settings.resetAllData();
              appState.resetAllDemoFlow();
              softwareProvider.resetSoftwareSafetyState();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Demo state successfully reset to default baseline.')),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelCoral),
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
