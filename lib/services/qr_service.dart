import '../core/constants/app_constants.dart';
import '../models/qr_scan_data.dart';
import '../models/risk_model.dart';

/// QR & Payment Safety Service
/// Parses UPI/Payment QR formats and flags merchant-recipient discrepancies.
/// NEVER executes real money transactions and NEVER asks for PINs/OTPs.
class QrService {
  static final QrService _instance = QrService._internal();
  factory QrService() => _instance;
  QrService._internal();

  /// Generates the standard demo mismatch scenario for hackathon judges
  QrScanData getDemoMismatchScenario() {
    return QrScanData(
      merchantName: AppConstants.demoQrMerchantName,
      recipientName: AppConstants.demoQrRecipientName,
      vpa: AppConstants.demoQrVpa,
      amount: AppConstants.demoQrAmount,
      isMismatch: true,
      riskLevel: RiskLevel.high,
      timestamp: DateTime.now(),
      rawPayload: 'upi://pay?pa=xyzservices.payments@okaxis&pn=XYZ%20Services&am=1499.00&cu=INR',
      notes: 'Intended store billing counter belongs to "ABC Electronics", but the QR resolves to "XYZ Services".',
    );
  }

  /// Generates a verified legitimate QR scenario (Safe / Matching recipient)
  QrScanData getDemoSafeScenario() {
    return QrScanData(
      merchantName: AppConstants.demoSafeQrMerchantName,
      recipientName: AppConstants.demoSafeQrRecipientName,
      vpa: AppConstants.demoSafeQrVpa,
      amount: AppConstants.demoSafeQrAmount,
      isMismatch: false,
      riskLevel: RiskLevel.low,
      timestamp: DateTime.now(),
      rawPayload: 'upi://pay?pa=starbucks.retail@icici&pn=Starbucks%20Coffee&am=349.00&cu=INR',
      notes: 'Verified recipient name matches the intended merchant. No mismatch detected.',
    );
  }

  /// Parses a raw QR payload (e.g. UPI scheme or generic text)
  QrScanData parsePayload(String rawPayload, {String? expectedMerchant}) {
    final merchant = expectedMerchant ?? 'Store Counter';
    String recipient = 'Unknown Entity';
    String vpa = 'unresolved@payment';
    double amount = 0.0;
    bool mismatch = false;

    if (rawPayload.startsWith('upi://pay?')) {
      final uri = Uri.tryParse(rawPayload);
      if (uri != null) {
        recipient = Uri.decodeComponent(uri.queryParameters['pn'] ?? 'Independent Recipient');
        vpa = uri.queryParameters['pa'] ?? 'unspecified';
        amount = double.tryParse(uri.queryParameters['am'] ?? '0.0') ?? 0.0;
      }
    } else {
      recipient = 'Direct Transfer Target';
    }

    // Check mismatch
    if (merchant.toLowerCase() != recipient.toLowerCase() && merchant != 'Store Counter') {
      mismatch = true;
    }

    return QrScanData(
      merchantName: merchant,
      recipientName: recipient,
      vpa: vpa,
      amount: amount,
      isMismatch: mismatch,
      riskLevel: mismatch ? RiskLevel.high : RiskLevel.low,
      timestamp: DateTime.now(),
      rawPayload: rawPayload,
      notes: mismatch
          ? 'Destination recipient does not match intended merchant name.'
          : 'Verified recipient name aligns with expected seller.',
    );
  }
}
