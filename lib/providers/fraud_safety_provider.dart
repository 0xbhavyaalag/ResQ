import 'package:flutter/material.dart';
import '../core/constants/app_constants.dart';
import '../models/risk_model.dart';
import '../models/qr_scan_data.dart';
import '../models/security_event.dart';
import '../services/fraud_service.dart';
import '../services/qr_service.dart';
import 'app_state_provider.dart';

class FraudSafetyProvider extends ChangeNotifier {
  final FraudService _fraudService = FraudService.instance;
  final QrService _qrService = QrService();

  // Message check
  final TextEditingController messageController = TextEditingController();
  bool _isAnalyzingMessage = false;
  RiskResult? _messageResult;

  // Link check
  final TextEditingController urlController = TextEditingController();
  bool _isAnalyzingUrl = false;
  RiskResult? _urlResult;

  // Bank message check
  final TextEditingController bankController = TextEditingController();
  bool _isAnalyzingBank = false;
  RiskResult? _bankResult;

  // QR scan
  QrScanData? _currentQrData;
  final bool _isCameraScannerActive = false;

  // Getters
  bool get isAnalyzingMessage => _isAnalyzingMessage;
  RiskResult? get messageResult => _messageResult;

  bool get isAnalyzingUrl => _isAnalyzingUrl;
  RiskResult? get urlResult => _urlResult;

  bool get isAnalyzingBank => _isAnalyzingBank;
  RiskResult? get bankResult => _bankResult;

  QrScanData? get currentQrData => _currentQrData;
  bool get isCameraScannerActive => _isCameraScannerActive;

  // Message actions
  void setMessagePresetSafe() {
    messageController.text = AppConstants.demoSafeMessage;
    _messageResult = null;
    notifyListeners();
  }

  void setMessagePresetSuspicious() {
    messageController.text = AppConstants.demoSuspiciousMessage;
    _messageResult = null;
    notifyListeners();
  }

  void setMessagePreset() => setMessagePresetSuspicious();

  Future<void> analyzeMessage(AppStateProvider appState) async {
    final text = messageController.text.trim();
    if (text.isEmpty) return;

    _isAnalyzingMessage = true;
    _messageResult = null;
    notifyListeners();

    try {
      final result = await _fraudService.analyzeMessage(text);
      _messageResult = result;

      await appState.logSecurityEvent(
        SecurityEvent(
          id: 'evt_msg_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Message Checked',
          subtitle: '${result.level.label} (${result.score}/100)',
          timestamp: DateTime.now(),
          category: SecurityCategory.fraud,
          riskLevel: result.level,
        ),
      );
    } finally {
      _isAnalyzingMessage = false;
      notifyListeners();
    }
  }

  // URL actions
  void setUrlPresetSafe() {
    urlController.text = AppConstants.demoSafeUrl;
    _urlResult = null;
    notifyListeners();
  }

  void setUrlPresetSuspicious() {
    urlController.text = AppConstants.demoSuspiciousUrl;
    _urlResult = null;
    notifyListeners();
  }

  void setUrlPreset() => setUrlPresetSuspicious();

  Future<void> analyzeUrl(AppStateProvider appState) async {
    final url = urlController.text.trim();
    if (url.isEmpty) return;

    _isAnalyzingUrl = true;
    _urlResult = null;
    notifyListeners();

    try {
      final result = await _fraudService.analyzeUrl(url);
      _urlResult = result;

      await appState.logSecurityEvent(
        SecurityEvent(
          id: 'evt_url_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Link Analyzed',
          subtitle: '${result.level.label} - ${url.length > 30 ? url.substring(0, 30) : url}',
          timestamp: DateTime.now(),
          category: SecurityCategory.fraud,
          riskLevel: result.level,
        ),
      );
    } finally {
      _isAnalyzingUrl = false;
      notifyListeners();
    }
  }

  // Bank message actions
  void setBankPresetSafe() {
    bankController.text = AppConstants.demoSafeBankMessage;
    _bankResult = null;
    notifyListeners();
  }

  void setBankPresetSuspicious() {
    bankController.text = AppConstants.demoSuspiciousBankMessage;
    _bankResult = null;
    notifyListeners();
  }

  void setBankPreset() => setBankPresetSuspicious();

  Future<void> analyzeBankMessage(AppStateProvider appState) async {
    final text = bankController.text.trim();
    if (text.isEmpty) return;

    _isAnalyzingBank = true;
    _bankResult = null;
    notifyListeners();

    try {
      final result = await _fraudService.analyzeBankMessage(text);
      _bankResult = result;

      await appState.logSecurityEvent(
        SecurityEvent(
          id: 'evt_bank_${DateTime.now().millisecondsSinceEpoch}',
          title: 'Bank Notice Verified',
          subtitle: '${result.level.label}: ${result.summary}',
          timestamp: DateTime.now(),
          category: SecurityCategory.fraud,
          riskLevel: result.level,
        ),
      );
    } finally {
      _isAnalyzingBank = false;
      notifyListeners();
    }
  }

  // QR Actions
  void loadDemoQrSafe(AppStateProvider appState) {
    _currentQrData = _qrService.getDemoSafeScenario();
    appState.logSecurityEvent(
      SecurityEvent(
        id: 'evt_qr_${DateTime.now().millisecondsSinceEpoch}',
        title: 'QR Merchant Verified',
        subtitle: 'Starbucks Coffee = Starbucks Coffee (₹349.00)',
        timestamp: DateTime.now(),
        category: SecurityCategory.fraud,
        riskLevel: RiskLevel.low,
      ),
    );
    notifyListeners();
  }

  void loadDemoQrMismatch(AppStateProvider appState) {
    _currentQrData = _qrService.getDemoMismatchScenario();
    appState.logSecurityEvent(
      SecurityEvent(
        id: 'evt_qr_${DateTime.now().millisecondsSinceEpoch}',
        title: 'QR Merchant Mismatch Detected',
        subtitle: 'ABC Electronics ≠ XYZ Services (₹1499.00)',
        timestamp: DateTime.now(),
        category: SecurityCategory.fraud,
        riskLevel: RiskLevel.high,
      ),
    );
    notifyListeners();
  }

  void handleScannedQrPayload(String rawPayload, AppStateProvider appState) {
    final data = _qrService.parsePayload(rawPayload);
    _currentQrData = data;
    appState.logSecurityEvent(
      SecurityEvent(
        id: 'evt_qr_${DateTime.now().millisecondsSinceEpoch}',
        title: 'QR Payment Scanned',
        subtitle: 'Recipient: ${data.recipientName} - ${data.riskLevel.label}',
        timestamp: DateTime.now(),
        category: SecurityCategory.fraud,
        riskLevel: data.riskLevel,
      ),
    );
    notifyListeners();
  }

  void clearQrData() {
    _currentQrData = null;
    notifyListeners();
  }
}
