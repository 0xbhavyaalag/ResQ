import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/risk_model.dart';

/// Accessible Risk Badge: Color + Icon + Label + Text
class RiskBadge extends StatelessWidget {
  final RiskLevel level;
  final bool isCompact;

  const RiskBadge({
    super.key,
    required this.level,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 14,
        vertical: isCompact ? 5 : 8,
      ),
      decoration: BoxDecoration(
        color: level.pastelBg,
        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        border: Border.all(
          color: AppTheme.strokeBlack,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            level.icon,
            size: isCompact ? 16 : 18,
            color: AppTheme.strokeBlack,
          ),
          const SizedBox(width: 6),
          Text(
            level.label,
            style: TextStyle(
              color: AppTheme.strokeBlack,
              fontSize: isCompact ? 12 : 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
