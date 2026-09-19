import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

/// Flat Vector 2D Custom Illustrative Components
/// Adheres strictly to modern SaaS flat vector aesthetic with 2px black strokes,
/// pastel geometric blobs, and zero gradients/drop shadows.

class ResqLogo extends StatelessWidget {
  final double size;

  const ResqLogo({super.key, this.size = 80});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ResqLogoPainter(),
    );
  }
}

class _ResqLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final strokePaint = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final fillShield = Paint()
      ..color = AppTheme.pastelPurple
      ..style = PaintingStyle.fill;

    final fillQ = Paint()
      ..color = AppTheme.pastelBlue
      ..style = PaintingStyle.fill;

    final fillAccent = Paint()
      ..color = AppTheme.lilacDark
      ..style = PaintingStyle.fill;

    final center = Offset(size.width * 0.5, size.height * 0.5);
    final radius = size.width * 0.42;

    // 1. Protective circular shield background
    final shieldPath = Path();
    shieldPath.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromCircle(center: center, radius: radius),
        Radius.circular(size.width * 0.3),
      ),
    );
    canvas.drawPath(shieldPath, fillShield);
    canvas.drawPath(shieldPath, strokePaint);

    // 2. Rounded Q Body
    final qRect = Rect.fromCenter(
      center: Offset(center.dx - size.width * 0.04, center.dy - size.height * 0.04),
      width: size.width * 0.44,
      height: size.height * 0.44,
    );
    canvas.drawOval(qRect, fillQ);
    canvas.drawOval(qRect, strokePaint);

    // Q Inner hole
    final holeRect = Rect.fromCenter(
      center: qRect.center,
      width: size.width * 0.2,
      height: size.height * 0.2,
    );
    final whitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawOval(holeRect, whitePaint);
    canvas.drawOval(holeRect, strokePaint);

    // Q Tail
    final tailPath = Path()
      ..moveTo(qRect.center.dx + size.width * 0.1, qRect.center.dy + size.height * 0.08)
      ..lineTo(qRect.center.dx + size.width * 0.24, qRect.center.dy + size.height * 0.22)
      ..lineTo(qRect.center.dx + size.width * 0.18, qRect.center.dy + size.height * 0.26)
      ..close();
    canvas.drawPath(tailPath, fillAccent);
    canvas.drawPath(tailPath, strokePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Onboarding Screen 1: User + Warning + Guardian
class GuardianIllustration extends StatelessWidget {
  final double width;
  final double height;

  const GuardianIllustration({super.key, this.width = 240, this.height = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _GuardianPainter(),
      ),
    );
  }
}

class _GuardianPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Organic background blob
    final blob = Path()
      ..moveTo(size.width * 0.2, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.05, size.width * 0.8, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.6, size.width * 0.75, size.height * 0.85)
      ..quadraticBezierTo(size.width * 0.4, size.height * 0.95, size.width * 0.15, size.height * 0.7)
      ..close();
    final blobPaint = Paint()..color = AppTheme.pastelBlue;
    canvas.drawPath(blob, blobPaint);
    canvas.drawPath(blob, stroke);

    // Large Guardian Shield
    final shield = Path()
      ..moveTo(size.width * 0.35, size.height * 0.25)
      ..lineTo(size.width * 0.65, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.55, size.width * 0.5, size.height * 0.75)
      ..quadraticBezierTo(size.width * 0.35, size.height * 0.55, size.width * 0.35, size.height * 0.25)
      ..close();
    final shieldPaint = Paint()..color = AppTheme.pastelPurple;
    canvas.drawPath(shield, shieldPaint);
    canvas.drawPath(shield, stroke);

    // Checkmark inside shield
    final check = Path()
      ..moveTo(size.width * 0.44, size.height * 0.44)
      ..lineTo(size.width * 0.49, size.height * 0.50)
      ..lineTo(size.width * 0.58, size.height * 0.38);
    final checkPaint = Paint()
      ..color = AppTheme.mintDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(check, checkPaint);

    // Warning Badge on top right
    final warnBadge = Rect.fromCircle(center: Offset(size.width * 0.75, size.height * 0.35), radius: 18);
    final warnPaint = Paint()..color = AppTheme.pastelAmber;
    canvas.drawOval(warnBadge, warnPaint);
    canvas.drawOval(warnBadge, stroke);

    // Warning exclamation
    final textPainter = TextPainter(
      text: const TextSpan(
        text: '!',
        style: TextStyle(color: AppTheme.strokeBlack, fontSize: 20, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textPainter.paint(canvas, Offset(size.width * 0.75 - 4, size.height * 0.35 - 13));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Onboarding Screen 2: Application + Error + Investigation
class InvestigationIllustration extends StatelessWidget {
  final double width;
  final double height;

  const InvestigationIllustration({super.key, this.width = 240, this.height = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _InvestigationPainter(),
      ),
    );
  }
}

class _InvestigationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Background lilac blob
    final blob = Path()
      ..moveTo(size.width * 0.15, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.45, size.height * 0.05, size.width * 0.85, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.65, size.width * 0.7, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.9, size.width * 0.1, size.height * 0.65)
      ..close();
    canvas.drawPath(blob, Paint()..color = AppTheme.lilac);
    canvas.drawPath(blob, stroke);

    // Application window box
    final appRect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(size.width * 0.45, size.height * 0.5), width: 130, height: 85),
      const Radius.circular(12),
    );
    canvas.drawRRect(appRect, Paint()..color = Colors.white);
    canvas.drawRRect(appRect, stroke);

    // App header bar
    final headerBar = Path()
      ..moveTo(appRect.left, appRect.top + 22)
      ..lineTo(appRect.right, appRect.top + 22);
    canvas.drawPath(headerBar, stroke);

    // Header 3 dots
    canvas.drawCircle(Offset(appRect.left + 12, appRect.top + 11), 3.5, Paint()..color = AppTheme.pastelCoral);
    canvas.drawCircle(Offset(appRect.left + 12, appRect.top + 11), 3.5, stroke);
    canvas.drawCircle(Offset(appRect.left + 22, appRect.top + 11), 3.5, Paint()..color = AppTheme.pastelAmber);
    canvas.drawCircle(Offset(appRect.left + 22, appRect.top + 11), 3.5, stroke);

    // Error alert banner in app
    final errRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(appRect.left + 12, appRect.top + 34, 106, 32),
      const Radius.circular(6),
    );
    canvas.drawRRect(errRect, Paint()..color = AppTheme.pastelCoral);
    canvas.drawRRect(errRect, stroke);

    // Magnifying glass over app
    final lensCenter = Offset(size.width * 0.68, size.height * 0.55);
    final lensRadius = 24.0;
    canvas.drawCircle(lensCenter, lensRadius, Paint()..color = AppTheme.pastelBlue);
    canvas.drawCircle(lensCenter, lensRadius, stroke);

    // Lens handle
    final handle = Path()
      ..moveTo(lensCenter.dx + 16, lensCenter.dy + 16)
      ..lineTo(lensCenter.dx + 34, lensCenter.dy + 34);
    final handlePaint = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(handle, handlePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Onboarding Screen 3: Recovery Loop + Verification Checkmark
class RecoveryIllustration extends StatelessWidget {
  final double width;
  final double height;

  const RecoveryIllustration({super.key, this.width = 240, this.height = 180});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _RecoveryPainter(),
      ),
    );
  }
}

class _RecoveryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Pastel mint background blob
    final blob = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.05, size.width * 0.85, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.7, size.width * 0.7, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.95, size.width * 0.12, size.height * 0.6)
      ..close();
    canvas.drawPath(blob, Paint()..color = AppTheme.pastelMint);
    canvas.drawPath(blob, stroke);

    // Central circular recovery badge
    final center = Offset(size.width * 0.5, size.height * 0.5);
    canvas.drawCircle(center, 46, Paint()..color = Colors.white);
    canvas.drawCircle(center, 46, stroke);

    // Recovery curved arrow
    final arcRect = Rect.fromCircle(center: center, radius: 32);
    final arcPaint = Paint()
      ..color = AppTheme.pastelPurple
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(arcRect, -0.4, 4.2, false, arcPaint);
    canvas.drawArc(arcRect, -0.4, 4.2, false, stroke);

    // Arrowhead
    final arrow = Path()
      ..moveTo(center.dx + 26, center.dy - 18)
      ..lineTo(center.dx + 35, center.dy - 8)
      ..lineTo(center.dx + 22, center.dy - 6)
      ..close();
    canvas.drawPath(arrow, Paint()..color = AppTheme.lilacDark);
    canvas.drawPath(arrow, stroke);

    // Large Verified Checkmark Badge
    final checkCenter = Offset(center.dx + 26, center.dy + 26);
    canvas.drawCircle(checkCenter, 18, Paint()..color = AppTheme.mintDark);
    canvas.drawCircle(checkCenter, 18, stroke);

    final check = Path()
      ..moveTo(checkCenter.dx - 7, checkCenter.dy)
      ..lineTo(checkCenter.dx - 2, checkCenter.dy + 5)
      ..lineTo(checkCenter.dx + 7, checkCenter.dy - 5);
    final checkStroke = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(check, checkStroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 4. Risk Prediction: Brain/AI + Warning Glyph
class RiskBrainIllustration extends StatelessWidget {
  final double width;
  final double height;

  const RiskBrainIllustration({super.key, this.width = 160, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _RiskBrainPainter()),
    );
  }
}

class _RiskBrainPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Background pastel blob
    final blob = Path()
      ..moveTo(size.width * 0.2, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.05, size.width * 0.8, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.7, size.width * 0.7, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.3, size.height * 0.95, size.width * 0.15, size.height * 0.6)
      ..close();
    canvas.drawPath(blob, Paint()..color = AppTheme.pastelAmber);
    canvas.drawPath(blob, stroke);

    final center = Offset(size.width * 0.48, size.height * 0.52);

    // AI Brain container
    final brainLeft = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx - 40, center.dy - 30, 36, 60),
      const Radius.circular(18),
    );
    final brainRight = RRect.fromRectAndRadius(
      Rect.fromLTWH(center.dx + 4, center.dy - 30, 36, 60),
      const Radius.circular(18),
    );
    canvas.drawRRect(brainLeft, Paint()..color = AppTheme.pastelPurple);
    canvas.drawRRect(brainLeft, stroke);
    canvas.drawRRect(brainRight, Paint()..color = AppTheme.pastelPurple);
    canvas.drawRRect(brainRight, stroke);

    // Neural circuitry connectors
    canvas.drawLine(Offset(center.dx - 22, center.dy - 10), Offset(center.dx - 10, center.dy - 10), stroke);
    canvas.drawLine(Offset(center.dx - 22, center.dy + 10), Offset(center.dx - 10, center.dy + 10), stroke);
    canvas.drawLine(Offset(center.dx + 10, center.dy - 10), Offset(center.dx + 22, center.dy - 10), stroke);
    canvas.drawLine(Offset(center.dx + 10, center.dy + 10), Offset(center.dx + 22, center.dy + 10), stroke);

    // Neural node dots
    canvas.drawCircle(Offset(center.dx - 22, center.dy - 10), 3.5, Paint()..color = AppTheme.lilacDark);
    canvas.drawCircle(Offset(center.dx - 22, center.dy - 10), 3.5, stroke);
    canvas.drawCircle(Offset(center.dx + 22, center.dy + 10), 3.5, Paint()..color = AppTheme.lilacDark);
    canvas.drawCircle(Offset(center.dx + 22, center.dy + 10), 3.5, stroke);

    // Warning Badge overlay
    final badgeCenter = Offset(size.width * 0.78, size.height * 0.32);
    canvas.drawCircle(badgeCenter, 16, Paint()..color = AppTheme.coralDark);
    canvas.drawCircle(badgeCenter, 16, stroke);

    final textP = TextPainter(
      text: const TextSpan(
        text: '!',
        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    textP.paint(canvas, Offset(badgeCenter.dx - 3.5, badgeCenter.dy - 12));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 5. AI Diagnosis: Eye / AI Sensor + Connected Evidence Nodes
class AiDiagnosisIllustration extends StatelessWidget {
  final double width;
  final double height;

  const AiDiagnosisIllustration({super.key, this.width = 180, this.height = 130});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _AiDiagnosisPainter()),
    );
  }
}

class _AiDiagnosisPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Organic lavender blob
    final blob = Path()
      ..moveTo(size.width * 0.15, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.55, size.height * 0.05, size.width * 0.88, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.7, size.width * 0.65, size.height * 0.92)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.9, size.width * 0.08, size.height * 0.55)
      ..close();
    canvas.drawPath(blob, Paint()..color = AppTheme.pastelPurple);
    canvas.drawPath(blob, stroke);

    final center = Offset(size.width * 0.5, size.height * 0.48);

    // AI Eye lens
    final eyePath = Path()
      ..moveTo(center.dx - 46, center.dy)
      ..quadraticBezierTo(center.dx, center.dy - 28, center.dx + 46, center.dy)
      ..quadraticBezierTo(center.dx, center.dy + 28, center.dx - 46, center.dy)
      ..close();
    canvas.drawPath(eyePath, Paint()..color = Colors.white);
    canvas.drawPath(eyePath, stroke);

    // Iris circle
    canvas.drawCircle(center, 18, Paint()..color = AppTheme.pastelBlue);
    canvas.drawCircle(center, 18, stroke);

    // Pupil
    canvas.drawCircle(center, 9, Paint()..color = AppTheme.strokeBlack);

    // Connected diagnostic nodes below
    final node1 = Offset(center.dx - 36, size.height * 0.82);
    final node2 = Offset(center.dx, size.height * 0.86);
    final node3 = Offset(center.dx + 36, size.height * 0.82);

    canvas.drawLine(center + const Offset(-12, 16), node1, stroke);
    canvas.drawLine(center + const Offset(0, 18), node2, stroke);
    canvas.drawLine(center + const Offset(12, 16), node3, stroke);

    canvas.drawCircle(node1, 7, Paint()..color = AppTheme.pastelMint);
    canvas.drawCircle(node1, 7, stroke);
    canvas.drawCircle(node2, 7, Paint()..color = AppTheme.pastelAmber);
    canvas.drawCircle(node2, 7, stroke);
    canvas.drawCircle(node3, 7, Paint()..color = AppTheme.pastelCoral);
    canvas.drawCircle(node3, 7, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 6. Verification: Protective Shield + Large Verified Checkmark
class VerificationIllustration extends StatelessWidget {
  final double width;
  final double height;

  const VerificationIllustration({super.key, this.width = 160, this.height = 130});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _VerificationPainter()),
    );
  }
}

class _VerificationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Background mint blob
    final blob = Path()
      ..moveTo(size.width * 0.2, size.height * 0.15)
      ..quadraticBezierTo(size.width * 0.65, size.height * 0.05, size.width * 0.88, size.height * 0.3)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.75, size.width * 0.6, size.height * 0.92)
      ..quadraticBezierTo(size.width * 0.15, size.height * 0.9, size.width * 0.1, size.height * 0.5)
      ..close();
    canvas.drawPath(blob, Paint()..color = AppTheme.pastelMint);
    canvas.drawPath(blob, stroke);

    final center = Offset(size.width * 0.5, size.height * 0.5);

    // Large Shield
    final shield = Path()
      ..moveTo(center.dx - 36, center.dy - 32)
      ..lineTo(center.dx + 36, center.dy - 32)
      ..quadraticBezierTo(center.dx + 36, center.dy + 12, center.dx, center.dy + 38)
      ..quadraticBezierTo(center.dx - 36, center.dy + 12, center.dx - 36, center.dy - 32)
      ..close();
    canvas.drawPath(shield, Paint()..color = Colors.white);
    canvas.drawPath(shield, stroke);

    // Large Green Checkmark
    final check = Path()
      ..moveTo(center.dx - 18, center.dy + 2)
      ..lineTo(center.dx - 4, center.dy + 16)
      ..lineTo(center.dx + 18, center.dy - 12);
    final checkPaint = Paint()
      ..color = AppTheme.mintDark
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(check, checkPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 7. Voice Assistant Illustration: Microphone + Speech Bubble
class VoiceIllustration extends StatelessWidget {
  final double width;
  final double height;

  const VoiceIllustration({super.key, this.width = 160, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _VoicePainter()),
    );
  }
}

class _VoicePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Lavender background blob
    final blob = Path()
      ..moveTo(size.width * 0.2, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.6, size.height * 0.05, size.width * 0.85, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.7, size.width * 0.65, size.height * 0.92)
      ..quadraticBezierTo(size.width * 0.2, size.height * 0.9, size.width * 0.1, size.height * 0.55)
      ..close();
    canvas.drawPath(blob, Paint()..color = AppTheme.pastelPurple);
    canvas.drawPath(blob, stroke);

    final center = Offset(size.width * 0.45, size.height * 0.5);

    // Microphone capsule
    final micCapsule = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy - 8), width: 22, height: 42),
      const Radius.circular(11),
    );
    canvas.drawRRect(micCapsule, Paint()..color = AppTheme.pastelBlue);
    canvas.drawRRect(micCapsule, stroke);

    // Mic cradle
    final cradle = Path()
      ..moveTo(center.dx - 18, center.dy - 12)
      ..lineTo(center.dx - 18, center.dy + 8)
      ..quadraticBezierTo(center.dx - 18, center.dy + 24, center.dx, center.dy + 24)
      ..quadraticBezierTo(center.dx + 18, center.dy + 24, center.dx + 18, center.dy + 8)
      ..lineTo(center.dx + 18, center.dy - 12);
    canvas.drawPath(cradle, stroke);

    // Mic stand & base
    canvas.drawLine(Offset(center.dx, center.dy + 24), Offset(center.dx, center.dy + 36), stroke);
    canvas.drawLine(Offset(center.dx - 14, center.dy + 36), Offset(center.dx + 14, center.dy + 36), stroke);

    // Soundwaves
    final wave1 = Path()
      ..moveTo(center.dx + 28, center.dy - 14)
      ..quadraticBezierTo(center.dx + 38, center.dy - 2, center.dx + 28, center.dy + 10);
    final wave2 = Path()
      ..moveTo(center.dx + 36, center.dy - 22)
      ..quadraticBezierTo(center.dx + 48, center.dy - 2, center.dx + 36, center.dy + 18);
    canvas.drawPath(wave1, stroke);
    canvas.drawPath(wave2, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 8. QR + Payment Shield Illustration
class QrShieldIllustration extends StatelessWidget {
  final double width;
  final double height;

  const QrShieldIllustration({super.key, this.width = 160, this.height = 120});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(painter: _QrShieldPainter()),
    );
  }
}

class _QrShieldPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Rose/coral pastel blob
    final blob = Path()
      ..moveTo(size.width * 0.15, size.height * 0.25)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.05, size.width * 0.85, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.95, size.height * 0.65, size.width * 0.7, size.height * 0.9)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.95, size.width * 0.1, size.height * 0.6)
      ..close();
    canvas.drawPath(blob, Paint()..color = AppTheme.pastelRose);
    canvas.drawPath(blob, stroke);

    final center = Offset(size.width * 0.44, size.height * 0.5);

    // QR Code Frame
    final qrBox = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 68, height: 68),
      const Radius.circular(10),
    );
    canvas.drawRRect(qrBox, Paint()..color = Colors.white);
    canvas.drawRRect(qrBox, stroke);

    // QR 3 corner markers
    canvas.drawRect(Rect.fromLTWH(center.dx - 26, center.dy - 26, 14, 14), Paint()..color = AppTheme.strokeBlack);
    canvas.drawRect(Rect.fromLTWH(center.dx + 12, center.dy - 26, 14, 14), Paint()..color = AppTheme.strokeBlack);
    canvas.drawRect(Rect.fromLTWH(center.dx - 26, center.dy + 12, 14, 14), Paint()..color = AppTheme.strokeBlack);

    // Overlay Protective Badge
    final badgeCenter = Offset(size.width * 0.74, size.height * 0.62);
    canvas.drawCircle(badgeCenter, 18, Paint()..color = AppTheme.pastelMint);
    canvas.drawCircle(badgeCenter, 18, stroke);

    final iconPainter = TextPainter(
      text: const TextSpan(
        text: '₹',
        style: TextStyle(color: AppTheme.strokeBlack, fontSize: 18, fontWeight: FontWeight.w900),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    iconPainter.paint(canvas, Offset(badgeCenter.dx - 5, badgeCenter.dy - 11));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 9. Chatbot / AI Avatar Illustration
class ChatbotAvatarIllustration extends StatelessWidget {
  final double size;

  const ChatbotAvatarIllustration({super.key, this.size = 64});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _ChatbotAvatarPainter()),
    );
  }
}

class _ChatbotAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = Paint()
      ..color = AppTheme.strokeBlack
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final center = Offset(size.width * 0.5, size.height * 0.5);

    // Head rounded rectangle
    final head = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: size.width * 0.8, height: size.height * 0.7),
      Radius.circular(size.width * 0.2),
    );
    canvas.drawRRect(head, Paint()..color = AppTheme.pastelPurple);
    canvas.drawRRect(head, stroke);

    // Antenna
    canvas.drawLine(Offset(center.dx, center.dy - size.height * 0.35), Offset(center.dx, center.dy - size.height * 0.46), stroke);
    canvas.drawCircle(Offset(center.dx, center.dy - size.height * 0.46), 3, Paint()..color = AppTheme.lilacDark);
    canvas.drawCircle(Offset(center.dx, center.dy - size.height * 0.46), 3, stroke);

    // Friendly wide visor / screen
    final visor = RRect.fromRectAndRadius(
      Rect.fromCenter(center: Offset(center.dx, center.dy - size.height * 0.04), width: size.width * 0.56, height: size.height * 0.26),
      Radius.circular(size.width * 0.08),
    );
    canvas.drawRRect(visor, Paint()..color = Colors.white);
    canvas.drawRRect(visor, stroke);

    // Two happy eyes
    canvas.drawCircle(Offset(center.dx - size.width * 0.14, center.dy - size.height * 0.04), 3.5, Paint()..color = AppTheme.strokeBlack);
    canvas.drawCircle(Offset(center.dx + size.width * 0.14, center.dy - size.height * 0.04), 3.5, Paint()..color = AppTheme.strokeBlack);

    // Smile
    final smile = Path()
      ..moveTo(center.dx - size.width * 0.1, center.dy + size.height * 0.18)
      ..quadraticBezierTo(center.dx, center.dy + size.height * 0.25, center.dx + size.width * 0.1, center.dy + size.height * 0.18);
    canvas.drawPath(smile, stroke);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

