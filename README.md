# ResQ 🛡️

### Think Before You Act. Recover When Things Go Wrong.

ResQ is an AI-powered **Digital Safety Guardian** that helps users identify risky actions before they cause problems, understand what went wrong, recover safely, and verify that the system is healthy again.

## 🚀 Core Concept

ResQ combines:

- 🛡️ **Software Safety**
- 🔐 **Digital Fraud Safety**

Core workflow:

**User Action → Risk Prediction → Warning → Failure Detection → AI Diagnosis → Recovery Guidance → Verification**

Broader safety philosophy:

**Predict → Prevent → Detect → Diagnose → Recover → Verify**

## ✨ Features

### 🛡️ Software Safety
- Risk analysis for software actions
- Database configuration analysis
- Dependency update analysis
- Permission change analysis
- Application update analysis
- File/system modification analysis
- AI-assisted risk explanation
- Recovery point creation
- Failure detection
- AI diagnosis
- Recovery guidance
- Safe-state restoration
- Post-recovery verification
- Safety Pulse
- Security history

### 🔐 Digital Fraud Safety
- 💬 Suspicious message detection
- 🔗 Suspicious link detection
- 🏦 Bank-message checking
- 📱 QR/payment safety
- Merchant/recipient mismatch detection
- Risk explanations and recommended actions

### 🤖 AI & Assistant
- AI risk prediction
- AI confidence indicators
- Explainable diagnosis
- Ask ResQ voice interaction
- AI-style ResQ Guide chatbot
- Frequently Asked Questions

## 🔄 How ResQ Works

```text
USER ACTION
    ↓
RISK PREDICTION
    ↓
WARNING
    ↓
FAILURE DETECTION
    ↓
AI DIAGNOSIS
    ↓
RECOVERY GUIDANCE
    ↓
VERIFICATION
    ↓
SYSTEM HEALTHY
```

## 🧪 Main Hackathon Demo

The main demonstration uses a controlled database-configuration scenario:

```text
Database Configuration
        ↓
Analyze Risk
        ↓
High Risk Detected
        ↓
Explain Why
        ↓
Create Recovery Point
        ↓
Simulate Failure
        ↓
Failure Detected
        ↓
AI Diagnosis
        ↓
Recover Safely
        ↓
Restore Safe Version
        ↓
Run Health Checks
        ↓
Recovery Verified
```

The software-safety demo uses a controlled application environment rather than claiming unsafe/root access to arbitrary device applications.

## 📊 Risk Analysis

ResQ uses:

| Level | Meaning |
|---|---|
| 🟢 LOW | Few warning indicators |
| 🟡 MEDIUM | Some risk indicators |
| 🟠 HIGH | Significant risk indicators |
| 🔴 CRITICAL | Strong warning indicators |

Results can include:

- Risk Score
- AI Confidence
- What ResQ found
- Why it matters
- Potential impact
- Recommended action

> AI confidence indicates how strongly the available evidence supports an analysis. It is not a guarantee.

## 🧠 AI / ML Approach

- **Random Forest** — software risk prediction concept
- **Isolation Forest** — anomaly detection concept
- **Explainable rule-based logic** — MVP diagnosis

Typical evidence can include recent changes, application state, error activity, system health, previous incidents, and configuration deviations.

## ♻️ Recovery

ResQ creates recovery points containing relevant demo state such as:

- Application configuration
- Application health
- Database state
- Timestamp
- Recovery point ID
- Incident information

Recovery flow:

```text
Create Backup
      ↓
Restore Configuration
      ↓
Apply / Restart State
      ↓
Run Health Checks
      ↓
Verify Recovery
```

Final state:

**✓ RECOVERY VERIFIED**

**SYSTEM HEALTHY**

## 🔐 Digital Fraud Safety

### 💬 Message Checker

Analyzes user-provided messages for:

- Urgent language
- Suspicious links
- Credential requests
- Possible impersonation
- Suspicious payment instructions
- Reward/prize patterns

### 🔗 Link Checker

Checks signals such as:

- HTTPS
- IP-based URLs
- Suspicious domain structure
- URL shorteners
- Suspicious characters
- Excessive subdomains
- Phishing-like patterns
- Domain mismatch

### 🏦 Bank Message Checker

Checks bank-related messages for suspicious domains, urgency, credential requests, impersonation, link mismatch, and other suspicious patterns.

### 📱 QR / Payment Safety

QR safety can decode payment information and compare available merchant/recipient information.

Example:

```text
Merchant:  ABC Electronics
Recipient: XYZ Services

ABC Electronics ≠ XYZ Services

⚠️ POSSIBLE MISMATCH
```

ResQ is a **safety-checking tool**, not a payment application. It does not make payments or request/store OTPs, UPI PINs, CVV, passwords, or banking credentials.

## 🎙️ Ask ResQ

Users can ask questions such as:

- “Is my system safe?”
- “Why is this action risky?”
- “What happened?”
- “How can I recover?”
- “How does QR safety work?”

The assistant explains results using the current ResQ context.

## 💬 ResQ Guide & FAQ

The Guide provides an AI-style chatbot and expandable FAQ covering:

- What is ResQ?
- How does risk prediction work?
- What is a recovery point?
- How does AI diagnosis work?
- How does ResQ detect fraud?
- How does QR safety work?
- Does ResQ make payments?
- Does ResQ store OTP or UPI PIN?
- What does AI confidence mean?

## 🎨 Design System

ResQ follows a **modern SaaS landing-page / flat-vector** visual style:

- 2D flat vector design
- Abstract geometric shapes and organic blobs
- Soft pastel blue
- Soft pastel purple
- Soft lilac
- White / very light backgrounds
- Bold dark outlines
- Consistent stroke width
- Rounded corners
- Smooth curves
- Clean minimal layouts
- Playful yet professional
- Dribbble-style startup aesthetic

### Avoided

- Dark cyber-security dashboards
- Cyberpunk/neon styling
- 3D graphics
- Heavy shadows
- Glow effects
- Glassmorphism
- Excessive gradients
- Overcrowded dashboards

**Design goal:** Playful on the surface, powerful under the hood.

## 📱 Navigation

```text
HOME
 └── Safety Pulse

SCAN
 ├── Message Checker
 ├── Link Checker
 ├── Bank Message Checker
 └── QR / Payment Safety

SAFETY
 └── Software Safety
      ├── Risk Analysis
      ├── Protection
      └── Recovery

HISTORY
 └── Security Events

PROFILE / GUIDE
 ├── Ask ResQ
 ├── Voice
 ├── FAQ
 └── Privacy / App Information
```

## 🛠️ Tech Stack

### Frontend
- Flutter
- Dart

### Local Data
- Hive / SharedPreferences
- Local demo data
- Local history
- Local recovery points

### AI / ML
- Random Forest
- Isolation Forest
- Explainable rule-based diagnosis for MVP

### Supporting
- Flutter QR scanning package
- `fl_chart`
- `Dio` / `http` where required

The MVP prioritizes reliable, demonstrable, offline-capable functionality.

## ⚙️ Getting Started

### Prerequisites

Install:

- Flutter SDK
- Dart SDK
- Android Studio
- Android SDK
- Android emulator or physical Android device

Check the environment:

```bash
flutter doctor
```

### Installation

```bash
git clone <YOUR_GITHUB_REPOSITORY_URL>
cd <PROJECT_FOLDER>
flutter pub get
flutter run
```

## 📦 Build APK

```bash
flutter build apk --release
```

Typical output:

```text
build/app/outputs/flutter-apk/app-release.apk
```

## 🧪 Demo Reset

Use the demo reset option to return the controlled ResQ environment to its initial healthy state and repeat the complete hackathon demonstration.

## 🔒 Privacy & Safety

ResQ is designed not to request or store:

- OTP
- UPI PIN
- CVV
- Passwords
- Banking credentials
- Full payment-card information

## 🗺️ Future Scope

- Real desktop monitoring agents
- Windows/Linux/macOS integration
- Real-time telemetry
- On-device ML models
- Cloud model inference
- Advanced anomaly detection
- Automated incident correlation
- More recovery strategies
- Enterprise deployment
- Cross-platform support
- Secure cloud recovery-point storage

## 🎯 Project Goal

Traditional approach:

```text
Something went wrong → Fix it
```

ResQ approach:

```text
Understand the risk
       ↓
Prevent damage
       ↓
Detect failure
       ↓
Understand why
       ↓
Recover safely
       ↓
Verify the result
```

## ⚠️ Disclaimer

ResQ is a prototype/hackathon project demonstrating digital safety, risk analysis, diagnosis, recovery concepts, and fraud-safety checks.

Risk results are indicators, not guarantees. Important security, banking, software, and payment decisions should be independently verified through trusted official sources.

## 👥 Team

**Team: CodeCrew**

Add final member details here.

---

# ⭐ ResQ

**Think Before You Act. Recover When Things Go Wrong.**

**Predict → Prevent → Detect → Diagnose → Recover → Verify**

