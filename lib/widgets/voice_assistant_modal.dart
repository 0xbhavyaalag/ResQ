import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/app_theme.dart';
import '../models/risk_model.dart';
import '../providers/app_state_provider.dart';
import '../providers/software_safety_provider.dart';
import '../providers/fraud_safety_provider.dart';
import '../services/ai_assistant_service.dart';
import '../screens/recovery/recovery_center_screen.dart';
import '../screens/guide/guide_screen.dart';
import 'neo_card.dart';
import 'vector_illustrations.dart';

class VoiceAssistantModal extends StatefulWidget {
  const VoiceAssistantModal({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const VoiceAssistantModal(),
    );
  }

  @override
  State<VoiceAssistantModal> createState() => _VoiceAssistantModalState();
}

class _VoiceAssistantModalState extends State<VoiceAssistantModal> with SingleTickerProviderStateMixin {
  bool _isListening = false;
  String _activeQuery = '';
  AiResponse? _currentResponse;

  final AiAssistantService _aiService = AiAssistantService();
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _processVoiceQuery(
    String query,
    AppStateProvider appState,
    SoftwareSafetyProvider software,
    FraudSafetyProvider fraud,
  ) {
    setState(() {
      _activeQuery = query;
      _isListening = false;
    });

    final resp = _aiService.processQuery(
      query: query,
      appState: appState,
      softwareProvider: softwareProvider(context),
      fraudProvider: fraudProvider(context),
    );

    setState(() {
      _currentResponse = resp;
    });
  }

  SoftwareSafetyProvider softwareProvider(BuildContext ctx) => ctx.read<SoftwareSafetyProvider>();
  FraudSafetyProvider fraudProvider(BuildContext ctx) => ctx.read<FraudSafetyProvider>();

  void _startListening(
    AppStateProvider appState,
    SoftwareSafetyProvider software,
    FraudSafetyProvider fraud,
  ) {
    setState(() {
      _isListening = true;
      _activeQuery = 'Listening (English, Hindi, Hinglish)...';
    });

    // Realistic speech recognition simulation with state context fallback
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (mounted && _isListening) {
        if (software.hasFailureOccurred || appState.flowState == ResqFlowState.failureDetected) {
          _processVoiceQuery('Why did this problem happen?', appState, software, fraud);
        } else if (software.currentRiskResult != null) {
          _processVoiceQuery('🔍 What problem has ResQ detected?', appState, software, fraud);
        } else {
          _processVoiceQuery('📱 How can I check my device status?', appState, software, fraud);
        }
      }
    });
  }

  void _executeAction(AiAction action, AppStateProvider appState, FraudSafetyProvider fraud) {
    Navigator.pop(context);

    switch (action.type) {
      case AiActionType.startRecovery:
      case AiActionType.viewRecoveryPoints:
      case AiActionType.fixIssue:
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const RecoveryCenterScreen()),
        );
        break;

      case AiActionType.runDiagnosis:
      case AiActionType.viewDetails:
        appState.setNavIndex(2); // Safety Screen
        break;

      case AiActionType.scanLink:
        fraud.setUrlPreset();
        appState.setNavIndex(1); // Scan Screen
        break;

      case AiActionType.analyzeMessage:
        fraud.setMessagePreset();
        appState.setNavIndex(1); // Scan Screen
        break;

      case AiActionType.scanQr:
      case AiActionType.verifyPayment:
        appState.setNavIndex(1); // Scan Screen
        break;

      case AiActionType.verifyNow:
        appState.onRecoveryVerified();
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final software = context.watch<SoftwareSafetyProvider>();
    final fraud = context.watch<FraudSafetyProvider>();
    final device = appState.selectedDevice ?? 'your device';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.all(20),
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
            // Top Drag Handle
            Center(
              child: Container(
                width: 48,
                height: 5,
                decoration: BoxDecoration(
                  color: AppTheme.strokeBlack,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header Row with Voice Illustration
            Row(
              children: [
                const VoiceIllustration(width: 70, height: 60),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '🤖 ResQ AI Assistant (Voice)',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: AppTheme.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Supports English, Hindi, and Hinglish • $device',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.lilacDark,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 22, color: AppTheme.strokeBlack),
                  onPressed: () => Navigator.pop(context),
                  tooltip: 'Close',
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Voice Interaction / Waveform Card
            NeoCard(
              backgroundColor: _isListening ? AppTheme.pastelPurple : Colors.white,
              child: Column(
                children: [
                  if (_isListening) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return AnimatedBuilder(
                          animation: _animController,
                          builder: (context, child) {
                            final factor = (index % 2 == 0) ? _animController.value : (1.0 - _animController.value);
                            final height = 14.0 + (factor * 26.0);
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: 6,
                              height: height,
                              decoration: BoxDecoration(
                                color: AppTheme.lilacDark,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTheme.strokeBlack, width: 1.2),
                              ),
                            );
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    _activeQuery.isEmpty ? 'Tap microphone or a question below' : '“$_activeQuery”',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      fontStyle: _activeQuery.isEmpty ? FontStyle.normal : FontStyle.italic,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Mic Button
                  GestureDetector(
                    onTap: () => _startListening(appState, software, fraud),
                    child: Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: _isListening ? AppTheme.pastelCoral : AppTheme.pastelBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
                      ),
                      child: Icon(
                        _isListening ? Icons.mic_rounded : Icons.mic_none_rounded,
                        size: 30,
                        color: AppTheme.strokeBlack,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Quick Questions (Including Hindi & Hinglish)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'QUICK SPOKEN QUESTIONS',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.0,
                    color: AppTheme.textMuted,
                  ),
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const GuideScreen()),
                    );
                  },
                  child: const Text(
                    'Open Full Chat 💬',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.lilacDark),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildQueryChip('🔍 What problem has ResQ detected?', appState, software, fraud),
                _buildQueryChip('🛠️ How can I fix the detected problem?', appState, software, fraud),
                _buildQueryChip('Mere phone mein kya problem hai?', appState, software, fraud),
                _buildQueryChip('Ye issue kaise solve hoga?', appState, software, fraud),
                _buildQueryChip('ResQ ne isko suspicious kyu bola?', appState, software, fraud),
                _buildQueryChip('📷 Is this QR code safe?', appState, software, fraud),
              ],
            ),
            const SizedBox(height: 18),

            // Dynamic Response Answer Card
            if (_currentResponse != null) ...[
              NeoCard(
                backgroundColor: AppTheme.pastelMint,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.auto_awesome_rounded, color: AppTheme.mintDark, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'RESQ AI INTELLIGENCE',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                            color: AppTheme.mintDark,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SelectableText(
                      _currentResponse!.text,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        height: 1.45,
                        color: AppTheme.textPrimary,
                      ),
                    ),

                    // Action Buttons
                    if (_currentResponse!.actions.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: _currentResponse!.actions.map((act) {
                          return ElevatedButton(
                            onPressed: () => _executeAction(act, appState, fraud),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.strokeBlack,
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                                side: const BorderSide(color: AppTheme.strokeBlack, width: 1.5),
                              ),
                            ),
                            child: Text(
                              act.label,
                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                            ),
                          );
                        }).toList(),
                      ),
                    ],

                    // Follow-Up Questions
                    if (_currentResponse!.followUps.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'FOLLOW-UP QUESTIONS',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                          color: AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: _currentResponse!.followUps.map((fu) {
                          return InkWell(
                            onTap: () => _processVoiceQuery(fu, appState, software, fraud),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppTheme.strokeBlack, width: 1.0),
                              ),
                              child: Text(
                                '• $fu',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQueryChip(
    String query,
    AppStateProvider appState,
    SoftwareSafetyProvider software,
    FraudSafetyProvider fraud,
  ) {
    return InkWell(
      onTap: () => _processVoiceQuery(query, appState, software, fraud),
      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
          border: Border.all(color: AppTheme.strokeBlack, width: 1.2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.record_voice_over_rounded, size: 14, color: AppTheme.lilacDark),
            const SizedBox(width: 6),
            Text(
              query,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
