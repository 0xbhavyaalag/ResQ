import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../models/security_event.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/neo_card.dart';
import '../../widgets/risk_badge.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _selectedFilter = 'ALL';

  final List<String> _filters = ['ALL', 'SOFTWARE', 'FRAUD', 'RECOVERY'];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppStateProvider>();
    final allEvents = appState.historyEvents;

    final filteredEvents = allEvents.where((e) {
      if (_selectedFilter == 'ALL') return true;
      if (_selectedFilter == 'SOFTWARE') return e.category == SecurityCategory.software;
      if (_selectedFilter == 'FRAUD') return e.category == SecurityCategory.fraud;
      if (_selectedFilter == 'RECOVERY') return e.category == SecurityCategory.recovery;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTheme.bgNeutral,
      appBar: AppBar(
        title: const Text('Security Timeline'),
        actions: [
          if (allEvents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_outline_rounded, size: 22),
              tooltip: 'Clear History',
              onPressed: () => _confirmClear(context, appState),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Filter Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = filter),
                        borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.pastelPurple : Colors.white,
                            borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                            border: Border.all(
                              color: AppTheme.strokeBlack,
                              width: isSelected ? 2.0 : 1.5,
                            ),
                          ),
                          child: Text(
                            filter,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            const Divider(color: AppTheme.strokeBlack, thickness: AppTheme.strokeWidth, height: 1),

            // Events List
            Expanded(
              child: filteredEvents.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                color: AppTheme.pastelPurple,
                                shape: BoxShape.circle,
                                border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                              ),
                              child: const Icon(Icons.history_rounded, size: 32, color: AppTheme.strokeBlack),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No Events In This Category',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                            ),
                            const SizedBox(height: 6),
                            const Text(
                              'Perform a software check or fraud scan to populate your security timeline.',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredEvents.length,
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        final timeFormat = DateFormat('h:mm a');
                        final timeString = timeFormat.format(event.timestamp);

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: NeoCard(
                            backgroundColor: Colors.white,
                            onTap: () => _showEventDetailsModal(context, event),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category Icon
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: _getCategoryColor(event.category),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: AppTheme.strokeBlack, width: 1.5),
                                  ),
                                  child: Icon(
                                    _getCategoryIcon(event.category),
                                    size: 18,
                                    color: AppTheme.strokeBlack,
                                  ),
                                ),
                                const SizedBox(width: 12),

                                // Title & Subtitle
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              event.title,
                                              style: const TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w800,
                                                color: AppTheme.textPrimary,
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          Text(
                                            timeString,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        event.subtitle,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      RiskBadge(level: event.riskLevel, isCompact: true),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(SecurityCategory cat) {
    switch (cat) {
      case SecurityCategory.software:
        return AppTheme.pastelBlue;
      case SecurityCategory.fraud:
        return AppTheme.pastelAmber;
      case SecurityCategory.recovery:
        return AppTheme.pastelMint;
    }
  }

  IconData _getCategoryIcon(SecurityCategory cat) {
    switch (cat) {
      case SecurityCategory.software:
        return Icons.code_rounded;
      case SecurityCategory.fraud:
        return Icons.shield_outlined;
      case SecurityCategory.recovery:
        return Icons.restore_rounded;
    }
  }

  void _showEventDetailsModal(BuildContext context, SecurityEvent event) {
    final dateFormat = DateFormat('EEEE, MMMM d, y — h:mm a');
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  event.category.label,
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppTheme.textMuted),
                ),
                RiskBadge(level: event.riskLevel, isCompact: true),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              event.title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 4),
            Text(
              dateFormat.format(event.timestamp),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.textMuted),
            ),
            const SizedBox(height: 16),
            NeoCard(
              backgroundColor: AppTheme.bgNeutral,
              child: Text(
                event.subtitle,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('CLOSE'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmClear(BuildContext context, AppStateProvider appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          side: const BorderSide(color: AppTheme.strokeBlack, width: AppTheme.strokeWidth),
        ),
        title: const Text('Clear Security History?'),
        content: const Text('This will reset your local audit timeline.'),
        actions: [
          OutlinedButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              appState.clearHistory();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.pastelCoral),
            child: const Text('CLEAR ALL'),
          ),
        ],
      ),
    );
  }
}
