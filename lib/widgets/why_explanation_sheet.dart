import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../models/risk_model.dart';
import 'neo_card.dart';
import 'risk_badge.dart';

class WhyExplanationSheet extends StatelessWidget {
  final String title;
  final RiskResult riskResult;

  const WhyExplanationSheet({
    super.key,
    required this.title,
    required this.riskResult,
  });

  static void show(BuildContext context, {required String title, required RiskResult riskResult}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => WhyExplanationSheet(
        title: title,
        riskResult: riskResult,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: const BoxDecoration(
        color: AppTheme.bgNeutral,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLarge),
          topRight: Radius.circular(AppTheme.radiusLarge),
        ),
        border: Border(
          top: BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
          left: BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
          right: BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 48,
            height: 5,
            decoration: BoxDecoration(
              color: AppTheme.strokeBlack,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'RESQ EXPLAINS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.2,
                          color: AppTheme.lilacDark,
                        ),
                      ),
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                RiskBadge(level: riskResult.level, isCompact: true),
              ],
            ),
          ),
          const Divider(color: AppTheme.strokeBlack, thickness: AppTheme.strokeWidth, height: 1),
          // Content
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // SECTION 1: WHAT WE FOUND
                  _buildSectionHeader(
                    icon: Icons.search_rounded,
                    title: 'WHAT WE FOUND',
                    bgColor: AppTheme.pastelBlue,
                  ),
                  const SizedBox(height: 10),
                  NeoCard(
                    backgroundColor: AppTheme.bgSurface,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: riskResult.reasons.map((reason) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_rounded,
                                color: AppTheme.mintDark,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  reason,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // SECTION 2: WHY IT MATTERS
                  _buildSectionHeader(
                    icon: Icons.lightbulb_outline_rounded,
                    title: 'WHY IT MATTERS',
                    bgColor: AppTheme.pastelAmber,
                  ),
                  const SizedBox(height: 10),
                  NeoCard(
                    backgroundColor: AppTheme.bgSurface,
                    child: Text(
                      riskResult.potentialImpact,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // SECTION 3: WHAT YOU CAN DO
                  _buildSectionHeader(
                    icon: Icons.shield_outlined,
                    title: 'WHAT YOU CAN DO',
                    bgColor: AppTheme.pastelPurple,
                  ),
                  const SizedBox(height: 10),
                  NeoCard(
                    backgroundColor: AppTheme.bgSurface,
                    child: Text(
                      riskResult.recommendedAction,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        height: 1.45,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Dismiss button
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.pastelPurple,
                    ),
                    child: const Text('GOT IT'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required Color bgColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
          ),
          child: Icon(icon, size: 16, color: AppTheme.strokeBlack),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.8,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }
}
