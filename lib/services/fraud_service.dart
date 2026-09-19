import '../models/risk_model.dart';

/// Digital Fraud Risk Engine
/// Multi-signal heuristic analyzer for SMS/WhatsApp text, URLs, and Banking scams.
class FraudService {
  static final FraudService _instance = FraudService._internal();
  static FraudService get instance => _instance;
  FraudService._internal();

  /// Analyzes general text messages for social engineering & phishing indicators
  Future<RiskResult> analyzeMessage(String text) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final normalized = text.toLowerCase();
    final signals = <RiskSignal>[];
    final reasons = <String>[];
    int score = 15; // Baseline low risk

    // 1. Urgency / Threat signals
    final urgencyRegex = RegExp(
        r'\b(urgent|immediately|within \d+ hours?|blocked|suspended|terminated|frozen|action required|final notice|expires today)\b');
    final hasUrgency = urgencyRegex.hasMatch(normalized);
    if (hasUrgency) {
      score += 25;
      reasons.add('Urgent or threatening language pushing rapid action');
      signals.add(const RiskSignal(
        label: 'Urgent Tone',
        isTriggered: true,
        description: 'Pressure tactics attempting to bypass critical thinking',
        severity: RiskLevel.high,
      ));
    }

    // 2. Suspicious URL presence
    final hasHttp = normalized.contains('http://');
    final hasHttps = normalized.contains('https://');
    final hasUrl = hasHttp || hasHttps || normalized.contains('www.');
    if (hasUrl) {
      if (hasHttp && !hasHttps) {
        score += 30;
        reasons.add('Insecure unencrypted link (HTTP instead of HTTPS)');
        signals.add(const RiskSignal(
          label: 'Insecure Link',
          isTriggered: true,
          description: 'Link does not use SSL/TLS encryption',
          severity: RiskLevel.critical,
        ));
      } else {
        score += 15;
        reasons.add('Contains an external link directing away from official app');
        signals.add(const RiskSignal(
          label: 'External Redirection',
          isTriggered: true,
          description: 'Link redirects outside the application or platform',
          severity: RiskLevel.medium,
        ));
      }
    }

    // 3. Credential or Identity harvesting
    final credentialRegex = RegExp(
        r'\b(verify your identity|login|password|pin|otp|kyc|pan card|bank account|credentials|click here to verify)\b');
    final hasCredentialRequest = credentialRegex.hasMatch(normalized);
    if (hasCredentialRequest) {
      score += 25;
      reasons.add('Requests identity verification or credential entry');
      signals.add(const RiskSignal(
        label: 'Credential Request',
        isTriggered: true,
        description: 'Prompts the user to enter private verification data',
        severity: RiskLevel.high,
      ));
    }

    // 4. Impersonation indicators
    final impersonationRegex =
        RegExp(r'\b(official|security team|support desk|customer care|bank|service center)\b');
    if (impersonationRegex.hasMatch(normalized)) {
      score += 15;
      reasons.add('Possible entity impersonation attempting to mimic authority');
      signals.add(const RiskSignal(
        label: 'Authority Impersonation',
        isTriggered: true,
        description: 'Claims to originate from an official security or support team',
        severity: RiskLevel.medium,
      ));
    }

    // Determine Risk Level & Summary
    final clampedScore = score.clamp(10, 95);
    final RiskLevel level;
    final String summary;
    final String impact;
    final String recommendation;

    if (clampedScore >= 70) {
      level = RiskLevel.high;
      summary =
          'Multiple warning signs detected commonly associated with phishing and social engineering.';
      impact =
          'Opening links or responding could compromise accounts, private identity, or login credentials.';
      recommendation =
          'Do not click the link or reply. Verify the sender through an official phone number or app directly.';
    } else if (clampedScore >= 40) {
      level = RiskLevel.medium;
      summary =
          'Some indicators suggest caution before acting on this message.';
      impact =
          'May be an unsolicited marketing blast or low-confidence phishing attempt.';
      recommendation =
          'Confirm the legitimacy of the request through known official channels before proceeding.';
    } else {
      level = RiskLevel.low;
      summary =
          'No prominent phishing patterns or malicious triggers were detected in this message.';
      impact = 'Appears to be standard conversational or transactional text.';
      recommendation =
          'Always remain vigilant. Never share passwords, OTPs, or private keys with anyone.';
      if (reasons.isEmpty) {
        reasons.add('No urgency triggers or credential harvesting phrases found');
      }
    }

    return RiskResult(
      score: clampedScore,
      level: level,
      summary: summary,
      reasons: reasons,
      potentialImpact: impact,
      recommendedAction: recommendation,
      signals: signals,
    );
  }

  /// Analyzes a web link/URL for domain structure, typosquatting, and phishing indicators
  Future<RiskResult> analyzeUrl(String rawUrl) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final normalized = rawUrl.trim().toLowerCase();
    final signals = <RiskSignal>[];
    final reasons = <String>[];
    int score = 10;

    // 1. Insecure protocol
    if (normalized.startsWith('http://')) {
      score += 30;
      reasons.add('Link uses unencrypted HTTP protocol');
      signals.add(const RiskSignal(
        label: 'No HTTPS Encryption',
        isTriggered: true,
        description: 'Traffic can be intercepted or manipulated in transit',
        severity: RiskLevel.high,
      ));
    } else if (normalized.startsWith('https://')) {
      signals.add(const RiskSignal(
        label: 'HTTPS Valid',
        isTriggered: false,
        description: 'Connection is encrypted with SSL/TLS certificate',
        severity: RiskLevel.low,
      ));
    }

    // 2. IP-based URL
    final ipRegex = RegExp(r'https?://\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}');
    if (ipRegex.hasMatch(normalized)) {
      score += 40;
      reasons.add('Raw IP address used instead of legitimate domain name');
      signals.add(const RiskSignal(
        label: 'IP-based Address',
        isTriggered: true,
        description: 'Direct server IP bypasses domain reputational checks',
        severity: RiskLevel.critical,
      ));
    }

    // 3. Suspicious or high-risk TLDs
    final suspiciousTlds = ['.xyz', '.top', '.info', '.buzz', '.tk', '.ml', '.ga', '.cf', '.gq', '.icu', '.club'];
    final matchedTld = suspiciousTlds.firstWhere((tld) => normalized.contains(tld), orElse: () => '');
    if (matchedTld.isNotEmpty) {
      score += 25;
      reasons.add('Domain uses high-risk registrar extension ($matchedTld)');
      signals.add(RiskSignal(
        label: 'High-Risk TLD ($matchedTld)',
        isTriggered: true,
        description: 'Frequently abused in automated phishing campaigns',
        severity: RiskLevel.high,
      ));
    }

    // 4. Typosquatting / deceptive brand imitation
    final brandDeceptions = [
      'paypa1', 'g00gle', 'amaz0n', 'netf1ix', 'app1e', 'micros0ft',
      'faceb00k', 'instagrarn', 'bank-security', 'secure-verify', 'kyc-update'
    ];
    for (final deceptive in brandDeceptions) {
      if (normalized.contains(deceptive)) {
        score += 35;
        reasons.add('Deceptive brand typosquatting detected ($deceptive)');
        signals.add(RiskSignal(
          label: 'Typosquatting Detected',
          isTriggered: true,
          description: 'Deliberate character substitution designed to deceive eyes',
          severity: RiskLevel.critical,
        ));
        break;
      }
    }

    // 5. Shortened link
    final shorteners = ['bit.ly', 'tinyurl.com', 't.co', 'rb.gy', 'is.gd', 'cutt.ly'];
    if (shorteners.any((s) => normalized.contains(s))) {
      score += 20;
      reasons.add('URL is shortened, hiding the true destination');
      signals.add(const RiskSignal(
        label: 'Shortened Link',
        isTriggered: true,
        description: 'Hides final destination until clicked',
        severity: RiskLevel.medium,
      ));
    }

    // Clamped score & result
    final clampedScore = score.clamp(10, 95);
    final RiskLevel level;
    final String summary;
    final String impact;
    final String recommendation;

    if (clampedScore >= 70) {
      level = RiskLevel.high;
      summary = 'Several high-confidence warning signs were detected on this link.';
      impact = 'Visiting this site may expose your browser to malware or fake login forms.';
      recommendation =
          'Do not open this link or input any credentials. Navigate to the service via bookmarks or official search.';
    } else if (clampedScore >= 40) {
      level = RiskLevel.medium;
      summary = 'Caution recommended. Link exhibits anomalous domain patterns.';
      impact = 'Destination reputation cannot be verified with certainty.';
      recommendation = 'Confirm the origin before submitting any personal information.';
    } else {
      level = RiskLevel.low;
      summary = 'Standard domain structure without obvious phishing characteristics.';
      impact = 'No immediate structural anomalies detected.';
      recommendation = 'Proceed with normal awareness. Verify certificates if entering logins.';
      if (reasons.isEmpty) {
        reasons.add('Domain uses standard structure and secure HTTPS');
      }
    }

    return RiskResult(
      score: clampedScore,
      level: level,
      summary: summary,
      reasons: reasons,
      potentialImpact: impact,
      recommendedAction: recommendation,
      signals: signals,
    );
  }

  /// Specialized analyzer for banking & financial messages
  Future<RiskResult> analyzeBankMessage(String text) async {
    await Future.delayed(const Duration(milliseconds: 500));

    final normalized = text.toLowerCase();
    final signals = <RiskSignal>[];
    final reasons = <String>[];
    int score = 20;

    // Check for banking keywords
    final hasBankName = normalized.contains('bank') ||
        normalized.contains('hdfc') ||
        normalized.contains('sbi') ||
        normalized.contains('icici') ||
        normalized.contains('axis') ||
        normalized.contains('account');

    if (hasBankName) {
      signals.add(const RiskSignal(
        label: 'Financial Institution Reference',
        isTriggered: true,
        description: 'References banking or financial provider',
        severity: RiskLevel.medium,
      ));
    }

    // KYC & PAN suspension threat
    final hasKycThreat = normalized.contains('kyc') ||
        normalized.contains('pan') ||
        normalized.contains('blocked today') ||
        normalized.contains('deactivation') ||
        normalized.contains('suspended');

    if (hasKycThreat) {
      score += 35;
      reasons.add('Threatens immediate account or card deactivation due to KYC/PAN');
      signals.add(const RiskSignal(
        label: 'KYC Deactivation Threat',
        isTriggered: true,
        description: 'Banks never threaten same-day deactivation via SMS',
        severity: RiskLevel.critical,
      ));
    }

    // Link present in bank SMS
    if (normalized.contains('http://') || normalized.contains('https://') || normalized.contains('.info') || normalized.contains('.xyz')) {
      score += 30;
      reasons.add('Contains link redirecting outside legitimate banking portal');
      signals.add(const RiskSignal(
        label: 'Third-Party Link',
        isTriggered: true,
        description: 'RBI and international bank guidelines prohibit links in transactional SMS',
        severity: RiskLevel.critical,
      ));
    }

    // Urgency
    if (normalized.contains('today') || normalized.contains('immediately') || normalized.contains('urgent')) {
      score += 15;
      reasons.add('Artificially creates urgency to provoke panic');
      signals.add(const RiskSignal(
        label: 'Panic Trigger',
        isTriggered: true,
        description: 'Designed to force quick action without verification',
        severity: RiskLevel.high,
      ));
    }

    final clampedScore = score.clamp(15, 95);
    final RiskLevel level;
    final String summary;
    final String impact;
    final String recommendation;

    if (clampedScore >= 65) {
      level = RiskLevel.high;
      summary = 'ResQ found multiple warning signs commonly associated with banking phishing or impersonation.';
      impact = 'Risk of bank account unauthorized debits, credential loss, or identity theft.';
      recommendation =
          'Verify through your bank\'s official mobile app or visit your local branch. NEVER share OTP, UPI PIN, CVV, or passwords.';
    } else if (clampedScore >= 40) {
      level = RiskLevel.medium;
      summary = 'Potentially suspicious banking notification requiring verification.';
      impact = 'Unverified sender claiming banking association.';
      recommendation = 'Log in to your bank’s official portal independently to check notifications.';
    } else {
      level = RiskLevel.low;
      summary = 'No obvious predatory banking phishing patterns found.';
      impact = 'Low probability of phishing payload.';
      recommendation = 'Remember: legitimate bank staff will NEVER ask for your PIN, OTP, or CVV.';
      if (reasons.isEmpty) {
        reasons.add('Standard informational notice without extortion or link redirect');
      }
    }

    return RiskResult(
      score: clampedScore,
      level: level,
      summary: summary,
      reasons: reasons,
      potentialImpact: impact,
      recommendedAction: recommendation,
      signals: signals,
    );
  }
}
