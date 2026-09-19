/// App-wide constants for ResQ Digital Safety Guardian
class AppConstants {
  static const String appName = 'ResQ';
  static const String appTagline = 'Think Before You Act. Recover When Things Go Wrong.';
  static const String appSubtitle = 'Your Digital Safety Guardian';

  // Pillars
  static const String pillarSoftwareSafety = 'SOFTWARE SAFETY';
  static const String pillarFraudSafety = 'DIGITAL FRAUD SAFETY';

  // Navigation Items
  static const String navHome = 'Home';
  static const String navScan = 'Scan';
  static const String navSafety = 'Safety';
  static const String navHistory = 'History';
  static const String navProfile = 'Profile';

  // Software Action Types
  static const String actionDbConfig = 'Database Configuration';
  static const String actionDependencyUpdate = 'Dependency Update';
  static const String actionPermissionChange = 'Permission Change';
  static const String actionAppUpdate = 'Application Update';
  static const String actionFileSystemChange = 'File/System Change';

  static const List<String> softwareActions = [
    actionDbConfig,
    actionDependencyUpdate,
    actionPermissionChange,
    actionAppUpdate,
    actionFileSystemChange,
  ];

  // Storage Keys
  static const String keyFirstLaunch = 'resq_first_launch';
  static const String keyPresentationMode = 'resq_presentation_mode';
  static const String keyDemoMode = 'resq_demo_mode';
  static const String keyRecoveryPoints = 'resq_recovery_points';
  static const String keyHistoryEvents = 'resq_history_events';
  static const String keySystemSafetyScore = 'resq_safety_score';
  static const String keySelectedBrand = 'resq_selected_brand';
  static const String keySelectedModel = 'resq_selected_model';

  // Demo Scenarios - Suspicious / Harmful
  static const String demoSuspiciousMessage = 
      'URGENT: Your account has been temporarily suspended due to unusual activity. Tap here immediately to verify your identity: http://secure-verify-auth.net/login or your funds will be frozen within 2 hours.';

  static const String demoSuspiciousBankMessage = 
      'Dear Customer, your HDFC/SBI NetBanking access will be blocked today due to pending KYC update. Click http://bank-kyc-service.info to update PAN and prevent card deactivation.';

  static const String demoSuspiciousUrl = 
      'http://paypa1-security-update.xyz/login?session=89324';

  static const String demoQrMerchantName = 'ABC Electronics';
  static const String demoQrRecipientName = 'XYZ Services';
  static const String demoQrVpa = 'xyzservices.payments@okaxis';
  static const double demoQrAmount = 1499.0;

  // Demo Scenarios - Genuine / Safe
  static const String demoSafeMessage = 
      'Hey! Just checking in about our project meeting tomorrow at 3 PM at the main office. Let me know if that time still works for you.';

  static const String demoSafeBankMessage = 
      'Your account XX4102 has been credited with INR 3,500.00 on 18-Sep via NEFT transfer Ref 849201. Available balance is INR 28,450.00. - State Bank of India';

  static const String demoSafeUrl = 
      'https://www.google.com';

  static const String demoSafeQrMerchantName = 'Starbucks Coffee';
  static const String demoSafeQrRecipientName = 'Starbucks Coffee';
  static const String demoSafeQrVpa = 'starbucks.retail@icici';
  static const double demoSafeQrAmount = 349.0;
}
