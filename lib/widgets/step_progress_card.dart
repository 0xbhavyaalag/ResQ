import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';

class StepProgressCard extends StatelessWidget {
  final String title;
  final bool isPending;
  final bool isInProgress;
  final bool isSuccess;
  final bool isFailure;
  final String? failureMessage;

  const StepProgressCard({
    super.key,
    required this.title,
    this.isPending = false,
    this.isInProgress = false,
    this.isSuccess = false,
    this.isFailure = false,
    this.failureMessage,
  });

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Widget statusWidget;

    if (isInProgress) {
      bgColor = AppTheme.pastelBlue;
      statusWidget = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.strokeBlack),
        ),
      );
    } else if (isSuccess) {
      bgColor = AppTheme.pastelMint;
      statusWidget = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: AppTheme.mintDark,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
        ),
        child: const Icon(
          Icons.check,
          color: Colors.white,
          size: 16,
        ),
      );
    } else if (isFailure) {
      bgColor = AppTheme.pastelCoral;
      statusWidget = Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: AppTheme.coralDark,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
        ),
        child: Text(
          failureMessage ?? 'Failed',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w800,
          ),
        ),
      );
    } else {
      // Pending
      bgColor = AppTheme.bgSurface;
      statusWidget = Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.textMuted, width: 1.5),
        ),
      );
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.strokeBlack,
          width: AppTheme.strokeWidth,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isInProgress || isSuccess || isFailure ? FontWeight.w800 : FontWeight.w600,
                color: isPending ? AppTheme.textMuted : AppTheme.textPrimary,
              ),
            ),
          ),
          statusWidget,
        ],
      ),
    );
  }
}
