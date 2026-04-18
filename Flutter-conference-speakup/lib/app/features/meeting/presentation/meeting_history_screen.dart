import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/utils/formatters.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

/// Meeting history — past meetings with search + filter
class MeetingHistoryScreen extends ConsumerStatefulWidget {
  const MeetingHistoryScreen({super.key});

  @override
  ConsumerState<MeetingHistoryScreen> createState() =>
      _MeetingHistoryScreenState();
}

class _MeetingHistoryScreenState extends ConsumerState<MeetingHistoryScreen> {
  String _filter = 'all';
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final meetings = ref.watch(meetingsProvider(null));

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
        title: Text('Meeting History',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: isDark ? SColors.textDark : SColors.textLight,
            )),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(SIcons.back,
              color: isDark ? SColors.textDark : SColors.textLight),
          onPressed: () => context.pop(),
        ),
      ),
      body: ResponsiveBody(child: Column(
        children: [
          // Search + Filter row
          Padding(
            padding: const EdgeInsets.fromLTRB(
                SSizes.pagePadding, 8, SSizes.pagePadding, 8),
            child: Row(
              children: [
                Expanded(
                  child: SSearchBar(
                    controller: _searchCtrl,
                    hint: 'Search meetings...',
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                const SizedBox(width: 8),
                _FilterButton(
                  isDark: isDark,
                  onTap: _showFilterSheet,
                ),
              ],
            ),
          ),

          // Filter chips
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: SSizes.pagePadding),
              children: [
                SChip(
                  label: 'All',
                  isSelected: _filter == 'all',
                  onTap: () => setState(() => _filter = 'all'),
                ),
                const SizedBox(width: 6),
                SChip(
                  label: 'Ended',
                  isSelected: _filter == 'ended',
                  onTap: () => setState(() => _filter = 'ended'),
                ),
                const SizedBox(width: 6),
                SChip(
                  label: 'Cancelled',
                  isSelected: _filter == 'cancelled',
                  onTap: () => setState(() => _filter = 'cancelled'),
                ),
                const SizedBox(width: 6),
                SChip(
                  label: 'Recorded',
                  isSelected: _filter == 'recorded',
                  icon: SIcons.record,
                  onTap: () => setState(() => _filter = 'recorded'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Meetings list
          Expanded(
            child: meetings.when(
              data: (list) {
                var filtered = list.where((m) {
                  if (_filter == 'ended') return m.status == MeetingStatus.ended;
                  if (_filter == 'cancelled') return m.status == MeetingStatus.cancelled;
                  if (_filter == 'recorded') return m.isRecording;
                  return true;
                }).toList();

                final query = _searchCtrl.text.toLowerCase();
                if (query.isNotEmpty) {
                  filtered = filtered
                      .where((m) =>
                          m.title.toLowerCase().contains(query) ||
                          (m.description?.toLowerCase().contains(query) ?? false))
                      .toList();
                }

                // Group by date
                final grouped = <String, List<MeetingModel>>{};
                for (final m in filtered) {
                  final key = m.endedAt != null
                      ? SFormatters.formatDateMedium(m.endedAt!)
                      : m.createdAt != null
                          ? SFormatters.formatDateMedium(m.createdAt)
                          : 'Unknown';
                  grouped.putIfAbsent(key, () => []).add(m);
                }

                if (filtered.isEmpty) {
                  return EmptyState(
                    icon: SIcons.meetings,
                    message: 'No meetings found',
                    subMessage: 'Your meeting history will appear here',
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: SSizes.pagePadding),
                  itemCount: grouped.length,
                  itemBuilder: (context, index) {
                    final date = grouped.keys.elementAt(index);
                    final items = grouped[date]!;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Text(
                            date,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? SColors.textDarkTertiary
                                  : SColors.textLightTertiary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        ...items.asMap().entries.map((entry) {
                          final m = entry.value;
                          return _HistoryTile(
                            meeting: m,
                            isDark: isDark,
                            onTap: () =>
                                context.push('/meeting/${m.id}/detail'),
                          )
                              .animate()
                              .fadeIn(
                                  duration: 300.ms,
                                  delay: (entry.key * 50).ms)
                              .slideX(begin: 0.02, end: 0);
                        }),
                      ],
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CupertinoActivityIndicator()),
              error: (_, _) => EmptyState(
                icon: SIcons.error,
                message: 'Failed to load history',
                actionLabel: 'Retry',
                onAction: () => ref.invalidate(meetingsProvider(null)),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }

  void _showFilterSheet() {
    showCupertinoModalPopup(
      context: context,
      builder: (_) => CupertinoActionSheet(
        title: const Text('Filter Meetings'),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _filter = 'all');
              Navigator.pop(context);
            },
            child: const Text('All Meetings'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _filter = 'ended');
              Navigator.pop(context);
            },
            child: const Text('Completed'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              setState(() => _filter = 'cancelled');
              Navigator.pop(context);
            },
            child: const Text('Cancelled'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool isDark;
  final VoidCallback onTap;
  const _FilterButton({required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: isDark ? SColors.darkElevated : SColors.lightElevated,
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
        ),
        child: Icon(Icons.tune_rounded,
            size: 18,
            color: isDark
                ? SColors.textDarkSecondary
                : SColors.textLightSecondary),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  final MeetingModel meeting;
  final bool isDark;
  final VoidCallback? onTap;

  const _HistoryTile({
    required this.meeting,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final duration = meeting.startedAt != null && meeting.endedAt != null
        ? meeting.endedAt!.difference(meeting.startedAt!)
        : null;
    final durationStr = duration != null
        ? '${duration.inMinutes}m'
        : '';

    return DenseTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: meeting.status == MeetingStatus.cancelled
              ? SColors.error.withValues(alpha: 0.1)
              : SColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
        ),
        child: Icon(
          meeting.status == MeetingStatus.cancelled
              ? Icons.cancel_outlined
              : Icons.videocam_outlined,
          size: 18,
          color: meeting.status == MeetingStatus.cancelled
              ? SColors.error
              : SColors.primary,
        ),
      ),
      title: meeting.title,
      subtitle: [
        if (durationStr.isNotEmpty) durationStr,
        '${meeting.participantCount} participants',
      ].join(' · '),
      trailing: Text(
        meeting.endedAt != null
            ? SFormatters.formatTime(meeting.endedAt!)
            : '',
        style: TextStyle(
          fontSize: 11,
          color: isDark
              ? SColors.textDarkTertiary
              : SColors.textLightTertiary,
        ),
      ),
      showChevron: true,
      onTap: onTap,
    );
  }
}
