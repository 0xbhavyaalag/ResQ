import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/fraud_safety_provider.dart';
import '../../widgets/neo_card.dart';
import '../../widgets/risk_badge.dart';
import '../../widgets/why_explanation_sheet.dart';
import '../../widgets/vector_illustrations.dart';
import '../../widgets/voice_assistant_modal.dart';
import '../../models/risk_model.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgNeutral,
      appBar: AppBar(
        title: const Text('Fraud Safety Hub'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_rounded, size: 24),
            tooltip: 'Ask ResQ (Voice)',
            onPressed: () => VoiceAssistantModal.show(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppTheme.pastelPurple,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall - 2),
                border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: AppTheme.textPrimary,
              unselectedLabelColor: AppTheme.textMuted,
              labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
              tabs: const [
                Tab(text: 'MESSAGE'),
                Tab(text: 'LINK'),
                Tab(text: 'BANK MSG'),
                Tab(text: 'QR / PAY'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _MessageCheckerTab(),
          _LinkCheckerTab(),
          _BankCheckerTab(),
          _QrPaymentCheckerTab(),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 1. MESSAGE CHECKER TAB
// -------------------------------------------------------------
class _MessageCheckerTab extends StatelessWidget {
  const _MessageCheckerTab();

  @override
  Widget build(BuildContext context) {
    final fraudProvider = context.watch<FraudSafetyProvider>();
    final appState = context.read<AppStateProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Check Before You Trust.',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Messages, links and payment details can look genuine. ResQ helps you spot warning signs before you act.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          // Preset helper buttons: Safe vs Harmful
          const Text(
            'Is this message safe?',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => fraudProvider.setMessagePresetSafe(),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppTheme.mintDark),
                  label: const Text('✓ Safe Sample'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.pastelMint.withValues(alpha: 0.3),
                    side: const BorderSide(color: AppTheme.mintDark, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => fraudProvider.setMessagePresetSuspicious(),
                  icon: const Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.coralDark),
                  label: const Text('⚠ Harmful Sample'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.pastelCoral.withValues(alpha: 0.3),
                    side: const BorderSide(color: AppTheme.coralDark, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Input field
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
            ),
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: fraudProvider.messageController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Paste a suspicious message here...',
                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Check Button
          ElevatedButton(
            onPressed: fraudProvider.isAnalyzingMessage
                ? null
                : () => fraudProvider.analyzeMessage(appState),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelPurple),
            child: fraudProvider.isAnalyzingMessage
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.strokeBlack),
                  )
                : const Text('CHECK WITH RESQ'),
          ),
          const SizedBox(height: 20),

          // Analysis Result Card
          if (fraudProvider.messageResult != null)
            _buildResultCard(
              context: context,
              title: 'Message Safety Assessment',
              result: fraudProvider.messageResult!,
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 2. LINK CHECKER TAB
// -------------------------------------------------------------
class _LinkCheckerTab extends StatelessWidget {
  const _LinkCheckerTab();

  @override
  Widget build(BuildContext context) {
    final fraudProvider = context.watch<FraudSafetyProvider>();
    final appState = context.read<AppStateProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Check Before You Open',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Detect deceptive brand misspellings, unencrypted links, and high-risk domain extensions.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Paste URL to verify',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => fraudProvider.setUrlPresetSafe(),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppTheme.mintDark),
                  label: const Text('✓ Safe Link'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.pastelMint.withValues(alpha: 0.3),
                    side: const BorderSide(color: AppTheme.mintDark, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => fraudProvider.setUrlPresetSuspicious(),
                  icon: const Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.coralDark),
                  label: const Text('⚠ Harmful Link'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.pastelCoral.withValues(alpha: 0.3),
                    side: const BorderSide(color: AppTheme.coralDark, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            child: TextField(
              controller: fraudProvider.urlController,
              decoration: const InputDecoration(
                hintText: 'https://example.com/login',
                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: fraudProvider.isAnalyzingUrl
                ? null
                : () => fraudProvider.analyzeUrl(appState),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelAmber),
            child: fraudProvider.isAnalyzingUrl
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.strokeBlack),
                  )
                : const Text('ANALYZE LINK'),
          ),
          const SizedBox(height: 20),

          if (fraudProvider.urlResult != null)
            _buildResultCard(
              context: context,
              title: 'Link Safety Assessment',
              result: fraudProvider.urlResult!,
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 3. BANK MESSAGE CHECKER TAB
// -------------------------------------------------------------
class _BankCheckerTab extends StatelessWidget {
  const _BankCheckerTab();

  @override
  Widget build(BuildContext context) {
    final fraudProvider = context.watch<FraudSafetyProvider>();
    final appState = context.read<AppStateProvider>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Verify Before You Trust',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Banks will never threaten immediate account suspension via SMS or ask for credentials.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),

          // Crucial Privacy Alert Banner
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.pastelMint,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
            ),
            child: const Row(
              children: [
                Icon(Icons.lock_rounded, size: 20, color: AppTheme.mintDark),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'SECURITY RULE: Never enter or share OTP, UPI PIN, CVV, or passwords.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          const Text(
            'Paste bank-related message',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => fraudProvider.setBankPresetSafe(),
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppTheme.mintDark),
                  label: const Text('✓ Safe Bank Msg'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.pastelMint.withValues(alpha: 0.3),
                    side: const BorderSide(color: AppTheme.mintDark, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => fraudProvider.setBankPresetSuspicious(),
                  icon: const Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.coralDark),
                  label: const Text('⚠ Harmful Bank Scam'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.pastelCoral.withValues(alpha: 0.3),
                    side: const BorderSide(color: AppTheme.coralDark, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
            ),
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: fraudProvider.bankController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Paste message mentioning KYC, account blocked, or card update...',
                hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 14),
                border: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: fraudProvider.isAnalyzingBank
                ? null
                : () => fraudProvider.analyzeBankMessage(appState),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelBlue),
            child: fraudProvider.isAnalyzingBank
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppTheme.strokeBlack),
                  )
                : const Text('CHECK MESSAGE'),
          ),
          const SizedBox(height: 20),

          if (fraudProvider.bankResult != null)
            _buildResultCard(
              context: context,
              title: 'Bank Notice Safety Check',
              result: fraudProvider.bankResult!,
            ),
        ],
      ),
    );
  }
}

// -------------------------------------------------------------
// 4. QR / PAYMENT CHECKER TAB
// -------------------------------------------------------------
class _QrPaymentCheckerTab extends StatelessWidget {
  const _QrPaymentCheckerTab();

  @override
  Widget build(BuildContext context) {
    final fraudProvider = context.watch<FraudSafetyProvider>();
    final appState = context.read<AppStateProvider>();
    final qrData = fraudProvider.currentQrData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Check Before You Pay',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppTheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Ensure the payment recipient matches the merchant counter you are purchasing from.',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),

          // Action Buttons: Real Scan or Demo QR
          OutlinedButton.icon(
            onPressed: () {
              _showScannerModal(context, fraudProvider, appState);
            },
            icon: const Icon(Icons.camera_alt_outlined, size: 18),
            label: const Text('SCAN QR CODE'),
          ),
          const SizedBox(height: 12),

          const Text(
            '1-Click Demo Scenarios:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppTheme.textMuted),
          ),
          const SizedBox(height: 6),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    fraudProvider.loadDemoQrSafe(appState);
                  },
                  icon: const Icon(Icons.check_circle_outline_rounded, size: 16, color: AppTheme.mintDark),
                  label: const Text('✓ Safe QR (Verified)'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.pastelMint.withValues(alpha: 0.3),
                    side: const BorderSide(color: AppTheme.mintDark, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    fraudProvider.loadDemoQrMismatch(appState);
                  },
                  icon: const Icon(Icons.warning_amber_rounded, size: 16, color: AppTheme.coralDark),
                  label: const Text('⚠ Harmful QR (Mismatch)'),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppTheme.pastelCoral.withValues(alpha: 0.3),
                    side: const BorderSide(color: AppTheme.coralDark, width: 1.5),
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Visual Mismatch Display when active
          if (qrData != null) ...[
            NeoCard(
              backgroundColor: qrData.isMismatch ? AppTheme.pastelCoral : AppTheme.pastelMint,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'QR SAFETY AUDIT',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.0,
                          color: AppTheme.strokeBlack,
                        ),
                      ),
                      RiskBadge(level: qrData.riskLevel, isCompact: true),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // INTENDED MERCHANT BOX
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
                          'INTENDED MERCHANT',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          qrData.merchantName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // VISUAL MISMATCH ICON (≠)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: qrData.isMismatch ? AppTheme.coralDark : AppTheme.mintDark,
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
                        ),
                        child: Center(
                          child: Text(
                            qrData.isMismatch ? '≠' : '=',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // ACTUAL RECIPIENT BOX
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
                          'PAYMENT RECIPIENT ON QR',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textMuted,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          qrData.recipientName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppTheme.coralDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'UPI ID: ${qrData.vpa}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Result text
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
                        Text(
                          qrData.isMismatch ? '⚠ POSSIBLE MISMATCH' : '✓ RECIPIENT VERIFIED',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: qrData.isMismatch ? AppTheme.coralDark : AppTheme.mintDark,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          qrData.notes,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  ElevatedButton(
                    onPressed: () => fraudProvider.clearQrData(),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.white),
                    child: const Text('VERIFY AGAIN'),
                  ),
                ],
              ),
            ),
          ] else ...[
            // Empty placeholder card
            NeoCard(
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: const [
                  QrShieldIllustration(width: 140, height: 100),
                  SizedBox(height: 12),
                  Text(
                    'No QR Scanned Yet',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Tap "TRY DEMO QR" to preview a realistic merchant-recipient discrepancy detection flow.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          // Strict disclaimers
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceSecondary,
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              border: Border.all(color: AppTheme.strokeBlack, width: 1.0),
            ),
            child: const Text(
              'RESPONSIBLE DISCLOSURE: ResQ does NOT execute financial transactions and NEVER requests passwords, PINs, or card credentials.',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showScannerModal(BuildContext context, FraudSafetyProvider fraudProvider, AppStateProvider appState) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Camera Scanner Ready',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text(
              'On physical mobile devices, camera viewfinder activates for live QR analysis. For test runs, you can trigger sample UPI data.',
              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                fraudProvider.loadDemoQrMismatch(appState);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelPurple),
              child: const Text('SIMULATE CAMERA QR SCAN'),
            ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------
// REUSABLE RESULT CARD HELPER
// -------------------------------------------------------------
Widget _buildResultCard({
  required BuildContext context,
  required String title,
  required RiskResult result,
}) {
  return NeoCard(
    backgroundColor: result.level.pastelBg,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              result.level.label,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: AppTheme.strokeBlack,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
              ),
              child: Text(
                '${result.score}/100',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.strokeBlack,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Summary
        Text(
          result.summary,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Why points
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
                'WHY?',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                  color: AppTheme.textMuted,
                ),
              ),
              const SizedBox(height: 6),
              ...result.reasons.map((r) => Padding(
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
        const SizedBox(height: 12),

        // Recommendation
        Text(
          'Recommendation: ${result.recommendedAction}',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 14),

        // Action buttons: WHY, ASK RESQ, CHECK ANOTHER
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  WhyExplanationSheet.show(
                    context,
                    title: title,
                    riskResult: result,
                  );
                },
                icon: const Icon(Icons.help_outline_rounded, size: 16),
                label: const Text('WHY?'),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => VoiceAssistantModal.show(context),
                icon: const Icon(Icons.mic_rounded, size: 16, color: AppTheme.lilacDark),
                label: const Text('ASK RESQ 🎙️'),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
