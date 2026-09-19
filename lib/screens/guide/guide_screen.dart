import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/app_state_provider.dart';
import '../../providers/software_safety_provider.dart';
import '../../providers/fraud_safety_provider.dart';
import '../../services/ai_assistant_service.dart';
import '../../widgets/neo_card.dart';
import '../../widgets/vector_illustrations.dart';
import '../../widgets/voice_assistant_modal.dart';
import '../recovery/recovery_center_screen.dart';

class GuideScreen extends StatefulWidget {
  const GuideScreen({super.key});

  @override
  State<GuideScreen> createState() => _GuideScreenState();
}

class _GuideScreenState extends State<GuideScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final AiAssistantService _aiService = AiAssistantService();

  String? _currentTopic;
  bool _isFaqExpanded = true;

  final List<Map<String, dynamic>> _messages = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initial greeting from ResQ AI Assistant
    _messages.add({
      'isUser': false,
      'text':
          'Hi! I’m your ResQ Safety Assistant. I can analyze your ResQ data and help you understand and solve problems.\n\nTap any question below or type your own question to analyze live system telemetry.',
      'time': 'Just now',
      'actions': <AiAction>[
        const AiAction(label: 'Run Diagnosis', type: AiActionType.runDiagnosis),
        const AiAction(label: 'View Recovery Points', type: AiActionType.viewRecoveryPoints),
      ],
      'followUps': <String>[
        '🔍 What problem has ResQ detected?',
        '📱 How can I check my device status?',
        '🔄 How can I recover my data?',
      ],
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage([String? presetText]) {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    final appState = context.read<AppStateProvider>();
    final softwareProvider = context.read<SoftwareSafetyProvider>();
    final fraudProvider = context.read<FraudSafetyProvider>();

    setState(() {
      _messages.add({
        'isUser': true,
        'text': text,
        'time': 'Just now',
      });
      if (presetText == null) {
        _textController.clear();
      }
    });

    _scrollToBottom();

    // AI Analysis using live ResQ data
    Future.delayed(const Duration(milliseconds: 350), () {
      if (!mounted) return;

      final response = _aiService.processQuery(
        query: text,
        appState: appState,
        softwareProvider: softwareProvider,
        fraudProvider: fraudProvider,
        previousTopic: _currentTopic,
      );

      _currentTopic = response.topic;

      setState(() {
        _messages.add({
          'isUser': false,
          'text': response.text,
          'time': 'Just now',
          'actions': response.actions,
          'followUps': response.followUps,
        });
      });

      _scrollToBottom();
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _executeAction(AiAction action) {
    final appState = context.read<AppStateProvider>();
    final fraudProvider = context.read<FraudSafetyProvider>();

    if (action.isDestructive) {
      // Confirm destructive/irreversible actions
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            side: const BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
          ),
          title: Text(action.label),
          content: const Text(
            'This action will restore a previous snapshot and revert configuration drift. Do you want to proceed?',
          ),
          actions: [
            OutlinedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('CANCEL'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx);
                _performActionNavigation(action, appState, fraudProvider);
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelCoral),
              child: const Text('PROCEED'),
            ),
          ],
        ),
      );
    } else {
      _performActionNavigation(action, appState, fraudProvider);
    }
  }

  void _performActionNavigation(
    AiAction action,
    AppStateProvider appState,
    FraudSafetyProvider fraudProvider,
  ) {
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
        Navigator.of(context).pop();
        break;

      case AiActionType.scanLink:
        fraudProvider.setUrlPreset();
        appState.setNavIndex(1); // Scan Screen
        Navigator.of(context).pop();
        break;

      case AiActionType.analyzeMessage:
        fraudProvider.setMessagePreset();
        appState.setNavIndex(1); // Scan Screen
        Navigator.of(context).pop();
        break;

      case AiActionType.scanQr:
      case AiActionType.verifyPayment:
        appState.setNavIndex(1); // Scan Screen
        Navigator.of(context).pop();
        break;

      case AiActionType.verifyNow:
        appState.onRecoveryVerified();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTheme.strokeBlack,
            content: Row(
              children: const [
                Icon(Icons.check_circle_rounded, color: AppTheme.pastelMint, size: 20),
                SizedBox(width: 8),
                Text('Recovery verified! System 100% healthy.'),
              ],
            ),
          ),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final device = appState.selectedDevice ?? 'your device';

    return Scaffold(
      backgroundColor: AppTheme.bgNeutral,
      appBar: AppBar(
        title: const Text('🤖 ResQ AI Assistant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.mic_rounded, size: 24),
            tooltip: 'Ask ResQ (Voice)',
            onPressed: () => VoiceAssistantModal.show(context),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(54),
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
              labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
              tabs: const [
                Tab(text: 'AI CHATBOT'),
                Tab(text: 'FAQ KNOWLEDGE'),
              ],
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildChatTab(appState, device),
          _buildFaqTab(),
        ],
      ),
    );
  }

  Widget _buildChatTab(AppStateProvider appState, String device) {
    return Column(
      children: [
        // Live Context Header Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: AppTheme.strokeBlack, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.pastelBlue,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.strokeBlack, width: 1.2),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.phone_android_rounded, size: 14, color: AppTheme.strokeBlack),
                    const SizedBox(width: 4),
                    Text(
                      device,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: appState.pulseStatusBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.strokeBlack, width: 1.2),
                ),
                child: Text(
                  '${appState.safetyScore}% Score',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900),
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  setState(() {
                    _isFaqExpanded = !_isFaqExpanded;
                  });
                },
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceSecondary,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.strokeBlack, width: 1.0),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _isFaqExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppTheme.strokeBlack,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _isFaqExpanded ? 'Hide FAQs' : 'Show FAQs (12)',
                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // Chat messages list with interactive FAQ Header
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              // Welcome Banner
              NeoCard(
                backgroundColor: AppTheme.pastelPurple,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        ChatbotAvatarIllustration(size: 32),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '🤖 ResQ AI Assistant',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '“Hi! I’m your ResQ Safety Assistant. I can analyze your ResQ data and help you understand and solve problems.”',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              // Frequently Asked Questions Collapsible Section
              if (_isFaqExpanded) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text(
                      'FREQUENTLY ASKED QUESTIONS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppTheme.textMuted,
                      ),
                    ),
                    Text(
                      'Tap any question',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.lilacDark),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: AiAssistantService.faqList.map((faq) {
                    return InkWell(
                      onTap: () => _sendMessage(faq),
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTheme.strokeBlack, width: 1.2),
                        ),
                        child: Text(
                          faq,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),
                const Divider(color: AppTheme.strokeBlack, thickness: 1.0),
                const SizedBox(height: 14),
              ],

              // Conversation Messages
              ...List.generate(_messages.length, (index) {
                final msg = _messages[index];
                final isUser = msg['isUser'] as bool;
                final actions = (msg['actions'] as List<AiAction>?) ?? [];
                final followUps = (msg['followUps'] as List<String>?) ?? [];

                return _buildMessageBubble(
                  isUser: isUser,
                  text: msg['text'] as String,
                  actions: actions,
                  followUps: followUps,
                );
              }),
            ],
          ),
        ),

        // Bottom Input Area
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              top: BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              children: [
                // Voice Button
                InkWell(
                  onTap: () => VoiceAssistantModal.show(context),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.pastelPurple,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                    ),
                    child: const Icon(Icons.mic_rounded, size: 22, color: AppTheme.strokeBlack),
                  ),
                ),
                const SizedBox(width: 10),

                // Text Input
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: AppTheme.bgNeutral,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                      border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                    ),
                    child: TextField(
                      controller: _textController,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      decoration: const InputDecoration(
                        hintText: 'Ask anything in English, Hindi, or Hinglish...',
                        hintStyle: TextStyle(fontSize: 12, color: AppTheme.textMuted),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),

                // Send Button
                InkWell(
                  onTap: () => _sendMessage(),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.pastelMint,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                    ),
                    child: const Icon(Icons.send_rounded, size: 22, color: AppTheme.strokeBlack),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMessageBubble({
    required bool isUser,
    required String text,
    required List<AiAction> actions,
    required List<String> followUps,
  }) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.88,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isUser ? AppTheme.pastelPurple : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(AppTheme.radiusMedium),
            topRight: const Radius.circular(AppTheme.radiusMedium),
            bottomLeft: isUser ? const Radius.circular(AppTheme.radiusMedium) : Radius.zero,
            bottomRight: isUser ? Radius.zero : const Radius.circular(AppTheme.radiusMedium),
          ),
          border: Border.all(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isUser) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  ChatbotAvatarIllustration(size: 22),
                  SizedBox(width: 6),
                  Text(
                    'ResQ Assistant',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppTheme.lilacDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],

            // Message text with structured rendering
            SelectableText(
              text,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                height: 1.45,
                color: AppTheme.textPrimary,
              ),
            ),

            // Real Action Buttons
            if (!isUser && actions.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: actions.map((act) {
                  return ElevatedButton(
                    onPressed: () => _executeAction(act),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: act.isDestructive ? AppTheme.pastelCoral : AppTheme.pastelPurple,
                      foregroundColor: AppTheme.strokeBlack,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: const BorderSide(color: AppTheme.strokeBlack, width: 1.5),
                      ),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900),
                    ),
                    child: Text(act.label),
                  );
                }).toList(),
              ),
            ],

            // Clickable Follow-up Questions
            if (!isUser && followUps.isNotEmpty) ...[
              const SizedBox(height: 14),
              const Text(
                'SUGGESTED FOLLOW-UPS',
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
                children: followUps.map((fu) {
                  return InkWell(
                    onTap: () => _sendMessage(fu),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceSecondary,
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
    );
  }

  Widget _buildFaqTab() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'FREQUENTLY ASKED QUESTIONS',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: AppTheme.textMuted,
          ),
        ),
        const SizedBox(height: 12),

        _buildFaqCard(
          question: 'How does ResQ predict software failures before they happen?',
          answer:
              'ResQ evaluates multi-dimensional telemetry: current action type, recent schema and configuration edits, active socket timeouts, and health check state. If anomalous combinations are detected, ResQ scores the risk and advises creating a safe snapshot before changes are applied.',
        ),
        _buildFaqCard(
          question: 'What is a recovery point snapshot?',
          answer:
              'A recovery point is an immutable snapshot of your healthy system state: configuration files, environment variables, dependencies, and database connection settings. If a failure is detected, you can restore to this exact version with one tap.',
        ),
        _buildFaqCard(
          question: 'How does QR Merchant Mismatch detection work?',
          answer:
              'When scanning a payment QR code, ResQ parses the raw UPI payload and verifies if the store\'s public merchant name (e.g. "ABC Electronics") matches the actual recipient account ("XYZ Services"). If they diverge, ResQ sounds a mismatch warning to prevent payment diversion fraud.',
        ),
        _buildFaqCard(
          question: 'Does ResQ ever ask for or store passwords or UPI PINs?',
          answer:
              'Never. ResQ never asks for, stores, or transmits your UPI PIN, passwords, CVV, or banking OTPs. All fraud analysis and safety evaluations occur strictly on your device.',
        ),
        _buildFaqCard(
          question: 'Can ResQ connect to real Windows, Linux, and Cloud servers?',
          answer:
              'Yes. In this mobile app demonstration, ResQ operates against a controlled local demo environment. The modular architecture is designed to communicate with background daemon agents on Windows, Linux systemd services, and Kubernetes clusters.',
        ),
        _buildFaqCard(
          question: 'What is the difference between Risk Score and AI Confidence?',
          answer:
              'Risk Score (0 to 100) measures how likely and severe an outage or fraud incident would be. AI Confidence (0 to 100%) represents the certainty of the machine learning model based on the completeness and clarity of the input telemetry.',
        ),
      ],
    );
  }

  Widget _buildFaqCard({required String question, required String answer}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: NeoCard(
        backgroundColor: Colors.white,
        padding: EdgeInsets.zero,
        child: Theme(
          data: ThemeData(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            title: Text(
              question,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary,
              ),
            ),
            iconColor: AppTheme.strokeBlack,
            collapsedIconColor: AppTheme.strokeBlack,
            children: [
              Text(
                answer,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  height: 1.4,
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
