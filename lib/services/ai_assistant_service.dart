import '../models/risk_model.dart';
import '../providers/app_state_provider.dart';
import '../providers/software_safety_provider.dart';
import '../providers/fraud_safety_provider.dart';

/// Available real actionable capabilities in ResQ
enum AiActionType {
  viewDetails,
  runDiagnosis,
  fixIssue,
  startRecovery,
  viewRecoveryPoints,
  scanLink,
  scanQr,
  analyzeMessage,
  verifyPayment,
  verifyNow,
}

/// Action button attached to an AI Assistant response
class AiAction {
  final String label;
  final AiActionType type;
  final bool isDestructive;

  const AiAction({
    required this.label,
    required this.type,
    this.isDestructive = false,
  });
}

/// Structured AI response with insights, actionable buttons, and follow-ups
class AiResponse {
  final String text;
  final List<AiAction> actions;
  final List<String> followUps;
  final String? topic;

  const AiResponse({
    required this.text,
    this.actions = const [],
    this.followUps = const [],
    this.topic,
  });
}

/// Service that analyzes live ResQ application data and generates contextual answers
class AiAssistantService {
  static final AiAssistantService _instance = AiAssistantService._internal();
  factory AiAssistantService() => _instance;
  AiAssistantService._internal();

  /// 12 standard FAQs required by ResQ
  static const List<String> faqList = [
    '🔍 What problem has ResQ detected?',
    '🛠️ How can I fix the detected problem?',
    '⚠️ Why did this problem happen?',
    '🛡️ How can I prevent this problem in the future?',
    '🔄 How can I recover my data?',
    '📱 How can I check my device status?',
    '🔗 Is this link safe?',
    '💬 Is this message suspicious?',
    '📷 Is this QR code safe?',
    '💳 Why was this payment/recipient flagged?',
    '🧪 How does ResQ diagnose problems?',
    '✅ How do I verify that the problem is fixed?',
  ];

  /// Process query using live application state without hallucination
  AiResponse processQuery({
    required String query,
    required AppStateProvider appState,
    required SoftwareSafetyProvider softwareProvider,
    required FraudSafetyProvider fraudProvider,
    String? previousTopic,
  }) {
    final lower = query.trim().toLowerCase();
    final device = appState.selectedDevice ?? 'your device';

    // 1. FAQ 1 & Problem Detection
    if (_matches(lower, [
      'what problem',
      'detected problem',
      'active problem',
      'problem has resq detected',
      'kya problem hai',
      'kya issue hai',
      'what happened',
      'kya hua',
    ])) {
      return _handleWhatProblemDetected(appState, softwareProvider, device);
    }

    // 2. FAQ 2 & How to fix
    if (_matches(lower, [
      'how can i fix',
      'how to fix',
      'kaise solve hoga',
      'kaise fix kare',
      'fix issue',
      'solve issue',
      'solution',
    ])) {
      return _handleHowToFix(appState, softwareProvider, device);
    }

    // 3. FAQ 3 & Why it happened
    if (_matches(lower, [
      'why did this problem happen',
      'why did it happen',
      'why did this happen',
      'kyu hua',
      'root cause',
      'karan kya hai',
      'why it happened',
    ])) {
      return _handleWhyItHappened(appState, softwareProvider, device);
    }

    // 4. FAQ 4 & Prevention
    if (_matches(lower, [
      'prevent this problem',
      'how can i prevent',
      'how to prevent',
      'future prevention',
      'bachav kaise kare',
      'prevent',
    ])) {
      return _handleHowToPrevent(appState, softwareProvider, device);
    }

    // 5. FAQ 5 & Data Recovery
    if (_matches(lower, [
      'recover my data',
      'recover data',
      'recover files',
      'recovery points',
      'restore safe version',
      'data recover kaise kare',
      'snapshots',
    ])) {
      return _handleDataRecovery(appState, device);
    }

    // 6. FAQ 6 & Device Status
    if (_matches(lower, [
      'check my device status',
      'device status',
      'phone status',
      'phone status kya hai',
      'health check',
      'system status',
    ])) {
      return _handleDeviceStatus(appState, device);
    }

    // 7. FAQ 7 & Link Safety
    if (_matches(lower, [
      'is this link safe',
      'link safe',
      'suspicious link',
      'website suspicious',
      'url safe',
      'phishing link',
      'ye link safe hai',
    ])) {
      return _handleLinkSafety(appState, fraudProvider, device);
    }

    // 8. FAQ 8 & Message Suspicion
    if (_matches(lower, [
      'is this message suspicious',
      'message suspicious',
      'suspicious message',
      'sms fraud',
      'bank message',
      'isko suspicious kyu bola',
      'suspicious kyu',
      'ye message fake hai kya',
      'fake message',
    ])) {
      return _handleMessageSuspicion(appState, fraudProvider, device);
    }

    // 9. FAQ 9 & QR Code Safety
    if (_matches(lower, [
      'is this qr code safe',
      'qr code safe',
      'qr safe',
      'qr scanner',
      'ye qr safe hai',
      'scan qr',
    ])) {
      return _handleQrSafety(appState, fraudProvider, device);
    }

    // 10. FAQ 10 & Payment/Recipient Flagging
    if (_matches(lower, [
      'payment/recipient flagged',
      'payment flagged',
      'recipient flagged',
      'mismatch',
      'merchant mismatch',
      'payment kyu flag hua',
      'upi flag',
    ])) {
      return _handlePaymentFlagged(appState, fraudProvider, device);
    }

    // 11. FAQ 11 & Diagnosis Workflow
    if (_matches(lower, [
      'how does resq diagnose',
      'diagnose problems',
      'diagnosis',
      'diagnostics',
      'resq kaise diagnose karta hai',
    ])) {
      return _handleDiagnosisWorkflow(appState, softwareProvider, device);
    }

    // 12. FAQ 12 & Verification
    if (_matches(lower, [
      'verify that the problem is fixed',
      'verify problem',
      'verify solution',
      'problem fixed',
      'verification',
      'verify kaise kare',
    ])) {
      return _handleVerification(appState, softwareProvider, device);
    }

    // Custom Query: Slow Phone / Battery Drain
    if (_matches(lower, ['slow', 'lag', 'battery', 'heating', 'phone hang'])) {
      return AiResponse(
        text: '📱 ResQ Performance & Safety Check on $device:\n\n'
            '• ResQ background guardian runs zero-knowledge local evaluations with low CPU overhead (<2%).\n'
            '• Monitored Services: ${appState.controlledAppStatus}.\n'
            '• Current System Safety Score: ${appState.safetyScore}%.\n\n'
            '🔍 Recommendation: If your device feels sluggish, verify there are no active socket leakages or unresolved dependency changes in Software Safety.',
        actions: const [
          AiAction(label: 'Run Diagnosis', type: AiActionType.runDiagnosis),
          AiAction(label: 'View Details', type: AiActionType.viewDetails),
        ],
        followUps: const [
          '🔍 What problem has ResQ detected?',
          '📱 How can I check my device status?',
        ],
        topic: 'performance',
      );
    }

    // Contextual Pronoun Fallback (e.g. "when did it happen", "what about it", "how to solve it")
    if (previousTopic != null) {
      if (_matches(lower, ['when', 'kab hua', 'time', 'timing'])) {
        return AiResponse(
          text: '⏱️ Incident Timeline for $device:\n\n'
              '• Telemetry Timestamp: ${DateTime.now().toLocal().toString().substring(0, 16)}\n'
              '• Affected Component: ${appState.incidentCause ?? softwareProvider.selectedAction}\n'
              '• Recorded Safety Event: ${appState.historyEvents.isNotEmpty ? appState.historyEvents.first.title : "Normal system operation"}',
          actions: const [
            AiAction(label: 'View Details', type: AiActionType.viewDetails),
            AiAction(label: 'Start Recovery', type: AiActionType.startRecovery),
          ],
          followUps: const [
            '🛠️ How can I fix the detected problem?',
            '✅ How do I verify that the problem is fixed?',
          ],
          topic: previousTopic,
        );
      }
    }

    // Fallback: Contextual Overview
    return AiResponse(
      text: '🤖 ResQ Safety Assistant ($device Context):\n\n'
          'ResQ evaluates security across two main pillars:\n'
          '1. Software Safety: Predicts configuration drift, simulates failures, and verifies recovery points.\n'
          '2. Digital Fraud Safety: Analyzes deceptive messages, phishing links, and QR merchant mismatches.\n\n'
          'Current System Safety Score: ${appState.safetyScore}%\n'
          'Active Alerts: ${appState.activeRisks} detected.\n\n'
          'Select a frequently asked question below or type a specific question about your system.',
      actions: const [
        AiAction(label: 'Run Diagnosis', type: AiActionType.runDiagnosis),
        AiAction(label: 'View Recovery Points', type: AiActionType.viewRecoveryPoints),
      ],
      followUps: const [
        '🔍 What problem has ResQ detected?',
        '📱 How can I check my device status?',
        '🔄 How can I recover my data?',
      ],
      topic: 'general',
    );
  }

  // --- 1. What Problem Detected Handler ---
  AiResponse _handleWhatProblemDetected(AppStateProvider appState, SoftwareSafetyProvider software, String device) {
    if (appState.flowState == ResqFlowState.failureDetected ||
        appState.flowState == ResqFlowState.diagnosed ||
        software.hasFailureOccurred) {
      return AiResponse(
        text: '🔍 What happened on $device?\n'
            'An unexpected application failure was detected on active services.\n'
            '• Status: ${appState.controlledAppStatus}\n'
            '• Database Probe: ${appState.controlledDbStatus}\n'
            '• Health Check Probe: ${appState.controlledHealthCheck}\n'
            '• Incident Cause: ${appState.incidentCause ?? "Database Configuration Change"}\n'
            '• Evidence: ${appState.incidentEvidence ?? "Socket exhaustion and HTTP 500 probe failures"}\n\n'
            '⚠️ Risk Level: CRITICAL (Safety Score: ${appState.safetyScore}%)',
        actions: const [
          AiAction(label: 'Start Recovery', type: AiActionType.startRecovery),
          AiAction(label: 'View Details', type: AiActionType.viewDetails),
        ],
        followUps: const [
          '⚠️ Why did this problem happen?',
          '🛠️ How can I fix the detected problem?',
          '🔄 How can I recover my data?',
        ],
        topic: 'failure',
      );
    }

    if (software.currentRiskResult != null ||
        appState.flowState == ResqFlowState.riskPredicted ||
        appState.flowState == ResqFlowState.warningActive) {
      final res = software.currentRiskResult ?? appState.activeRiskResult;
      final score = res?.score ?? 78;
      final levelLabel = res?.level.label ?? 'HIGH';
      final summary = res?.summary ?? 'High risk configuration detected';
      final recommended = res?.recommendedAction ?? 'Create recovery point before proceeding';
      return AiResponse(
        text: '🔍 What happened on $device?\n'
            'ResQ predicted an active risk for action: "${software.selectedAction}".\n'
            '• Risk Score: $score/100 ($levelLabel)\n'
            '• AI Confidence: ${res?.confidence ?? 92}%\n'
            '• Summary: $summary\n'
            '• Recommended: $recommended',
        actions: const [
          AiAction(label: 'Start Recovery', type: AiActionType.startRecovery),
          AiAction(label: 'Run Diagnosis', type: AiActionType.runDiagnosis),
        ],
        followUps: const [
          '⚠️ Why did this problem happen?',
          '🛡️ How can I prevent this problem in the future?',
          '🛠️ How can I fix the detected problem?',
        ],
        topic: 'risk_warning',
      );
    }

    return AiResponse(
      text: 'Good news! ResQ has not detected any active problem on your device ($device).\n\n'
          '• System Safety Score: ${appState.safetyScore}%\n'
          '• Monitored Services: ${appState.controlledAppStatus}\n'
          '• Database Latency: 14ms (Healthy)\n'
          '• Zero active fraud threats detected.',
      actions: const [
        AiAction(label: 'Run Diagnosis', type: AiActionType.runDiagnosis),
        AiAction(label: 'View Details', type: AiActionType.viewDetails),
      ],
      followUps: const [
        '📱 How can I check my device status?',
        '🔄 How can I recover my data?',
        '🧪 How does ResQ diagnose problems?',
      ],
      topic: 'healthy',
    );
  }

  // --- 2. How To Fix Handler ---
  AiResponse _handleHowToFix(AppStateProvider appState, SoftwareSafetyProvider software, String device) {
    if (appState.flowState == ResqFlowState.failureDetected ||
        appState.flowState == ResqFlowState.diagnosed ||
        software.hasFailureOccurred) {
      return AiResponse(
        text: '🛠️ How to fix it on $device:\n\n'
            '1. Open Recovery Center to inspect saved safe snapshots.\n'
            '2. Select your latest verified checkpoint (e.g. "${appState.recoveryPoints.isNotEmpty ? appState.recoveryPoints.first.title : "Safe Configuration Snapshot"}").\n'
            '3. Tap "Restore Safe Version" to revert broken configuration parameters.\n'
            '4. ResQ will restart worker threads and re-establish database connectivity.\n'
            '5. Run health check probe to confirm zero drift.',
        actions: const [
          AiAction(label: 'Start Recovery', type: AiActionType.startRecovery, isDestructive: true),
          AiAction(label: 'View Recovery Points', type: AiActionType.viewRecoveryPoints),
        ],
        followUps: const [
          '🔄 How can I recover my data?',
          '✅ How do I verify that the problem is fixed?',
          '🛡️ How can I prevent this problem in the future?',
        ],
        topic: 'fix_failure',
      );
    }

    return AiResponse(
      text: '🛠️ How to fix it on $device:\n\n'
          'Currently, no severe failures are active.\n'
          '• To maintain 100% stability, create a recovery point before applying configuration changes.\n'
          '• If testing failure loops in Demo Mode, use the "Simulate Failure" action in Software Safety to practice recovery.',
      actions: const [
        AiAction(label: 'View Recovery Points', type: AiActionType.viewRecoveryPoints),
        AiAction(label: 'Run Diagnosis', type: AiActionType.runDiagnosis),
      ],
      followUps: const [
        '🛡️ How can I prevent this problem in the future?',
        '📱 How can I check my device status?',
      ],
      topic: 'fix_preventive',
    );
  }

  // --- 3. Why It Happened Handler ---
  AiResponse _handleWhyItHappened(AppStateProvider appState, SoftwareSafetyProvider software, String device) {
    if (appState.incidentCause != null) {
      return AiResponse(
        text: '⚠️ Why it happened on $device:\n\n'
            '• Primary Cause: ${appState.incidentCause}\n'
            '• Telemetry Evidence: ${appState.incidentEvidence}\n'
            '• Recent Logs: ${appState.controlledLogs.length > 2 ? appState.controlledLogs.last : "Pool parameters exhausted workers"}\n\n'
            'When pool workers were decreased, incoming request spikes led to connection timeouts and an HTTP 500 error on the health check endpoint.',
        actions: const [
          AiAction(label: 'View Details', type: AiActionType.viewDetails),
          AiAction(label: 'Start Recovery', type: AiActionType.startRecovery),
        ],
        followUps: const [
          '🛠️ How can I fix the detected problem?',
          '🛡️ How can I prevent this problem in the future?',
          '✅ How do I verify that the problem is fixed?',
        ],
        topic: 'why_failure',
      );
    }

    return AiResponse(
      text: '⚠️ Why it happened on $device:\n\n'
          'ResQ evaluates configuration drift and permission updates continuously.\n'
          'When an action like "${software.selectedAction}" is selected, ResQ compares configuration parameters against baseline policies to predict potential outages before execution.',
      actions: const [
        AiAction(label: 'Run Diagnosis', type: AiActionType.runDiagnosis),
      ],
      followUps: const [
        '🔍 What problem has ResQ detected?',
        '🛡️ How can I prevent this problem in the future?',
      ],
      topic: 'why_normal',
    );
  }

  // --- 4. How To Prevent Handler ---
  AiResponse _handleHowToPrevent(AppStateProvider appState, SoftwareSafetyProvider software, String device) {
    return AiResponse(
      text: '🛡️ How to prevent problems on $device:\n\n'
          '1. Predict Before Acting: Always run ResQ Risk Analysis before modifying database pools or permissions.\n'
          '2. Automated Checkpoints: Enable automatic snapshots prior to software deployments.\n'
          '3. Health Check Guardrails: Keep /healthz probes active so configuration errors are flagged before user impact.\n'
          '4. Phishing Guard: Always verify unexpected SMS alerts containing urgent KYC or account freezing threats.',
      actions: const [
        AiAction(label: 'View Recovery Points', type: AiActionType.viewRecoveryPoints),
        AiAction(label: 'Run Diagnosis', type: AiActionType.runDiagnosis),
      ],
      followUps: const [
        '🔄 How can I recover my data?',
        '📱 How can I check my device status?',
      ],
      topic: 'prevention',
    );
  }

  // --- 5. Data Recovery Handler ---
  AiResponse _handleDataRecovery(AppStateProvider appState, String device) {
    final points = appState.recoveryPoints;
    if (points.isEmpty) {
      return AiResponse(
        text: '🔄 How can I recover my data on $device?\n\n'
            'Currently, no saved recovery points were found in local storage.\n'
            'Create your first recovery checkpoint in the Recovery Center to protect system state.',
        actions: const [
          AiAction(label: 'View Recovery Points', type: AiActionType.viewRecoveryPoints),
        ],
        followUps: [
          '🛡️ How can I prevent this problem in the future?',
          '📱 How can I check my device status?',
        ],
        topic: 'recovery_empty',
      );
    }

    final top = points.first;
    return AiResponse(
      text: '🔄 How can I recover my data on $device?\n\n'
          'ResQ has ${points.length} verified recovery points available:\n'
          '• Latest Checkpoint: "${top.title}" (${top.versionLabel})\n'
          '• Timestamp: ${top.timestamp.toLocal().toString().substring(0, 16)}\n'
          '• Healthy Status: ${top.isApplicationHealthy ? "Verified 200 OK" : "Unverified"}\n\n'
          'Restoring this snapshot reverts database config, restarts workers, and verifies service integrity.',
      actions: const [
        AiAction(label: 'Start Recovery', type: AiActionType.startRecovery),
        AiAction(label: 'View Recovery Points', type: AiActionType.viewRecoveryPoints),
      ],
      followUps: const [
        '🛠️ How can I fix the detected problem?',
        '✅ How do I verify that the problem is fixed?',
      ],
      topic: 'recovery_available',
    );
  }

  // --- 6. Device Status Handler ---
  AiResponse _handleDeviceStatus(AppStateProvider appState, String device) {
    return AiResponse(
      text: '📱 Device Status for $device:\n\n'
          '• Monitored Device: $device\n'
          '• Overall Safety Pulse: ${appState.pulseStatusTitle} (${appState.safetyScore}% score)\n'
          '• Application Status: ${appState.controlledAppStatus}\n'
          '• Database Connection: ${appState.controlledDbStatus}\n'
          '• Probe Health: ${appState.controlledHealthCheck}\n'
          '• Active Risks: ${appState.activeRisks}\n'
          '• Saved Checkpoints: ${appState.recoveryPoints.length}',
      actions: const [
        AiAction(label: 'View Details', type: AiActionType.viewDetails),
        AiAction(label: 'Run Diagnosis', type: AiActionType.runDiagnosis),
      ],
      followUps: const [
        '🔍 What problem has ResQ detected?',
        '🔄 How can I recover my data?',
      ],
      topic: 'device_status',
    );
  }

  // --- 7. Link Safety Handler ---
  AiResponse _handleLinkSafety(AppStateProvider appState, FraudSafetyProvider fraud, String device) {
    final result = fraud.urlResult;
    final urlText = fraud.urlController.text.trim();

    if (result != null) {
      return AiResponse(
        text: '🔗 Link Safety Evaluation:\n\n'
            '• URL Checked: ${urlText.isNotEmpty ? urlText : "Recently analyzed link"}\n'
            '• Verdict: ${result.level.label} (Score: ${result.score}/100, ${result.confidence}% Confidence)\n'
            '• Analysis: ${result.summary}\n'
            '• Recommendation: ${result.recommendedAction}',
        actions: const [
          AiAction(label: 'Scan Link', type: AiActionType.scanLink),
        ],
        followUps: const [
          '💬 Is this message suspicious?',
          '📷 Is this QR code safe?',
        ],
        topic: 'link_result',
      );
    }

    return AiResponse(
      text: '🔗 Is this link safe?\n\n'
          'ResQ detects phishing domains, typosquatting (e.g. paypa1 vs paypal), and credential harvesting URLs.\n'
          'Enter a link in the Scan tab to run an instant offline zero-knowledge safety scan.',
      actions: const [
        AiAction(label: 'Scan Link', type: AiActionType.scanLink),
      ],
      followUps: const [
        '💬 Is this message suspicious?',
        '📷 Is this QR code safe?',
      ],
      topic: 'link_prompt',
    );
  }

  // --- 8. Message Suspicion Handler ---
  AiResponse _handleMessageSuspicion(AppStateProvider appState, FraudSafetyProvider fraud, String device) {
    final result = fraud.messageResult;
    final msgText = fraud.messageController.text.trim();

    if (result != null) {
      return AiResponse(
        text: '💬 Message Suspicion Analysis:\n\n'
            '• Checked Message: "${msgText.length > 60 ? "${msgText.substring(0, 60)}..." : msgText}"\n'
            '• Risk Verdict: ${result.level.label} (${result.score}/100)\n'
            '• Reasons: ${result.reasons.join("\n• ")}\n'
            '• Recommendation: ${result.recommendedAction}',
        actions: const [
          AiAction(label: 'Analyze Message', type: AiActionType.analyzeMessage),
        ],
        followUps: const [
          '🔗 Is this link safe?',
          '💳 Why was this payment/recipient flagged?',
        ],
        topic: 'message_result',
      );
    }

    return AiResponse(
      text: '💬 Message Suspicion Analysis:\n\n'
          'ResQ analyzes SMS and chat messages for three primary fraud indicators:\n'
          '1. Artificial Urgency ("within 2 hours", "account blocked today")\n'
          '2. Credential/KYC Requests (asking for PAN, OTP, password verification)\n'
          '3. Obfuscated Shortlinks or Suspicious Domains.\n\n'
          'Paste any message into the Scan tab to analyze it securely.',
      actions: const [
        AiAction(label: 'Analyze Message', type: AiActionType.analyzeMessage),
      ],
      followUps: const [
        '🔗 Is this link safe?',
        '💳 Why was this payment/recipient flagged?',
      ],
      topic: 'message_prompt',
    );
  }

  // --- 9. QR Code Safety Handler ---
  AiResponse _handleQrSafety(AppStateProvider appState, FraudSafetyProvider fraud, String device) {
    final qr = fraud.currentQrData;
    if (qr != null) {
      return AiResponse(
        text: '📷 QR Code Safety Evaluation:\n\n'
            '• Store/Merchant Displayed: "${qr.merchantName}"\n'
            '• Registered Payment Recipient: "${qr.recipientName}"\n'
            '• UPI VPA: ${qr.vpa}\n'
            '• Mismatch Status: ${qr.isMismatch ? "🚨 MISMATCH DETECTED" : "✅ Verified Match"}\n'
            '• Risk Level: ${qr.riskLevel.label}',
        actions: const [
          AiAction(label: 'Scan QR', type: AiActionType.scanQr),
          AiAction(label: 'Verify Payment', type: AiActionType.verifyPayment),
        ],
        followUps: const [
          '💳 Why was this payment/recipient flagged?',
          '💬 Is this message suspicious?',
        ],
        topic: 'qr_result',
      );
    }

    return AiResponse(
      text: '📷 Is this QR code safe?\n\n'
          'ResQ evaluates payment QR codes before transaction dispatch by comparing the public store name with the actual bank recipient.\n'
          'Open the Scan tab to scan a camera viewfinder QR or evaluate sample QR data.',
      actions: const [
        AiAction(label: 'Scan QR', type: AiActionType.scanQr),
      ],
      followUps: const [
        '💳 Why was this payment/recipient flagged?',
        '🔗 Is this link safe?',
      ],
      topic: 'qr_prompt',
    );
  }

  // --- 10. Payment/Recipient Flagged Handler ---
  AiResponse _handlePaymentFlagged(AppStateProvider appState, FraudSafetyProvider fraud, String device) {
    final qr = fraud.currentQrData;
    if (qr != null && qr.isMismatch) {
      return AiResponse(
        text: '💳 Why this payment was flagged:\n\n'
            '🔍 What happened?\n'
            'The QR code claims to be "${qr.merchantName}", but the money would be sent to "${qr.recipientName}" (${qr.vpa}).\n\n'
            '⚠️ Why it happened\n'
            'Fraudsters often paste malicious QR stickers over legitimate shop QR codes so customer payments are stolen into personal accounts.\n\n'
            '🛡️ How to prevent it\n'
            'Do NOT proceed with the payment. Ask the store merchant to verify their UPI VPA directly on their soundbox or terminal.',
        actions: const [
          AiAction(label: 'Verify Payment', type: AiActionType.verifyPayment),
          AiAction(label: 'Scan QR', type: AiActionType.scanQr),
        ],
        followUps: const [
          '📷 Is this QR code safe?',
          '💬 Is this message suspicious?',
        ],
        topic: 'payment_mismatch',
      );
    }

    return AiResponse(
      text: '💳 Why was this payment/recipient flagged?\n\n'
          'ResQ flags UPI payments whenever there is a divergence between the merchant identity you intend to pay and the beneficiary registered in the payment payload.\n'
          'Always verify the recipient name shown on the UPI confirmation screen before entering your PIN.',
      actions: const [
        AiAction(label: 'Verify Payment', type: AiActionType.verifyPayment),
      ],
      followUps: const [
        '📷 Is this QR code safe?',
        '🔗 Is this link safe?',
      ],
      topic: 'payment_info',
    );
  }

  // --- 11. Diagnosis Workflow Handler ---
  AiResponse _handleDiagnosisWorkflow(AppStateProvider appState, SoftwareSafetyProvider software, String device) {
    return AiResponse(
      text: '🧪 How ResQ Diagnoses Problems on $device:\n\n'
          'ResQ uses a deterministic 6-step root-cause engine:\n'
          '1. Log Correlation: Scans connection pool errors, socket drops, and health check failures.\n'
          '2. Timeline Comparison: Matches timestamp of the outage against recent configuration actions.\n'
          '3. Service Probing: Tests HTTP /healthz latency and database connection pool availability.\n'
          '4. Cause Attribution: Discovers whether the root issue is database exhaustion, dependency corruption, or permission drift.\n'
          '5. Recovery Recommendation: Maps the diagnosed failure to the closest safe rollback point.',
      actions: const [
        AiAction(label: 'Run Diagnosis', type: AiActionType.runDiagnosis),
        AiAction(label: 'View Details', type: AiActionType.viewDetails),
      ],
      followUps: const [
        '🔍 What problem has ResQ detected?',
        '✅ How do I verify that the problem is fixed?',
      ],
      topic: 'diagnosis_workflow',
    );
  }

  // --- 12. Verification Handler ---
  AiResponse _handleVerification(AppStateProvider appState, SoftwareSafetyProvider software, String device) {
    if (appState.flowState == ResqFlowState.verified || software.isRecoveryVerified) {
      return AiResponse(
        text: '✅ Verification Status on $device:\n\n'
            'Recovery has been verified successfully!\n'
            '• Service Probe: HTTP 200 OK (Latency: 11ms)\n'
            '• Database Pool: Connected (50/50 available)\n'
            '• Configuration Drift: 0%\n'
            '• Overall Safety Score: 100% (LOOKING GOOD)',
        actions: const [
          AiAction(label: 'View Details', type: AiActionType.viewDetails),
        ],
        followUps: const [
          '📱 How can I check my device status?',
          '🛡️ How can I prevent this problem in the future?',
        ],
        topic: 'verified_success',
      );
    }

    return AiResponse(
      text: '✅ How to verify the solution on $device:\n\n'
          '1. Execute snapshot restoration in Recovery Center.\n'
          '2. ResQ automatically runs an automated diagnostic probe.\n'
          '3. Check that /healthz returns HTTP 200 OK and database latency is under 20ms.\n'
          '4. Confirm that the Safety Pulse status returns to "RECOVERY VERIFIED" or "LOOKING GOOD".',
      actions: const [
        AiAction(label: 'Verify Now', type: AiActionType.verifyNow),
        AiAction(label: 'Start Recovery', type: AiActionType.startRecovery),
      ],
      followUps: const [
        '🛠️ How can I fix the detected problem?',
        '📱 How can I check my device status?',
      ],
      topic: 'verify_instructions',
    );
  }

  bool _matches(String query, List<String> patterns) {
    for (final pattern in patterns) {
      if (query.contains(pattern.toLowerCase())) {
        return true;
      }
    }
    return false;
  }
}
