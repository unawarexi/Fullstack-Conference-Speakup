import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';
import 'package:flutter_conference_speakup/store/recording_provider.dart';

class RecordingsScreen extends ConsumerStatefulWidget {
  const RecordingsScreen({super.key});

  @override
  ConsumerState<RecordingsScreen> createState() => _RecordingsScreenState();
}

class _RecordingsScreenState extends ConsumerState<RecordingsScreen> {
  int _selectedFilter = 0;
  String _searchQuery = '';

  Future<void> _onRefresh() async {
    ref.invalidate(recordingsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final recordingsAsync = ref.watch(recordingsProvider);
    final filters = ['All', 'Ready', 'Processing', 'Failed'];

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        title: Text('Recordings', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: SColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SSearchBar(
                  hint: 'Search recordings...',
                  onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => SChip(
                    label: filters[i],
                    isSelected: _selectedFilter == i,
                    onTap: () => setState(() => _selectedFilter = i),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Recordings list
            recordingsAsync.when(
              data: (recordings) {
                var filtered = recordings.toList();
                if (_searchQuery.isNotEmpty) {
                  filtered = filtered.where((r) =>
                    (r.meetingTitle ?? '').toLowerCase().contains(_searchQuery)
                  ).toList();
                }
                switch (_selectedFilter) {
                  case 1: filtered = filtered.where((r) => r.status == RecordingStatus.ready).toList();
                  case 2: filtered = filtered.where((r) => r.status == RecordingStatus.processing).toList();
                  case 3: filtered = filtered.where((r) => r.status == RecordingStatus.failed).toList();
                }

                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: CupertinoIcons.film,
                      message: 'No recordings yet',
                      subMessage: 'Record a meeting to see it here',
                    ),
                  );
                }

                // Stats header
                final ready = recordings.where((r) => r.status == RecordingStatus.ready).length;
                final totalSize = recordings.fold<int>(0, (s, r) => s + r.sizeBytes);
                final totalDuration = recordings.fold<int>(0, (s, r) => s + r.duration);

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Row(
                            children: [
                              _MiniStat(label: 'Total', value: '${recordings.length}', isDark: isDark),
                              const SizedBox(width: 16),
                              _MiniStat(label: 'Ready', value: '$ready', isDark: isDark),
                              const SizedBox(width: 16),
                              _MiniStat(
                                label: 'Size',
                                value: _formatBytes(totalSize),
                                isDark: isDark,
                              ),
                              const SizedBox(width: 16),
                              _MiniStat(
                                label: 'Duration',
                                value: _formatDurationShort(totalDuration),
                                isDark: isDark,
                              ),
                            ],
                          ),
                        ).animate().fadeIn(duration: 200.ms);
                      }

                      final rec = filtered[index - 1];
                      return _RecordingTile(
                        recording: rec,
                        isDark: isDark,
                        onTap: () => _showRecordingDetail(context, rec, isDark),
                      ).animate().fadeIn(
                        duration: 200.ms,
                        delay: (40 * index).ms,
                      );
                    },
                    childCount: filtered.length + 1,
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator(color: SColors.primary)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: CupertinoIcons.exclamationmark_triangle,
                  message: 'Failed to load recordings',
                  actionLabel: 'Retry',
                  onAction: _onRefresh,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }

  void _showRecordingDetail(BuildContext context, RecordingModel rec, bool isDark) {
    HapticFeedback.selectionClick();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: Text(rec.meetingTitle ?? 'Recording'),
        message: Text('${rec.formattedDuration} · ${rec.formattedSize}'),
        actions: [
          if (rec.status == RecordingStatus.ready) ...[
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Play'),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Download'),
            ),
            CupertinoActionSheetAction(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Share'),
            ),
          ],
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Delete'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancel'),
        ),
      ),
    );
  }

  String _formatBytes(int bytes) {
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(0)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  String _formatDurationShort(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}

class _RecordingTile extends StatelessWidget {
  final RecordingModel recording;
  final bool isDark;
  final VoidCallback onTap;

  const _RecordingTile({required this.recording, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Thumbnail
            Container(
              width: 52, height: 52,
              decoration: BoxDecoration(
                color: _statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    recording.status == RecordingStatus.ready
                        ? CupertinoIcons.play_fill
                        : recording.status == RecordingStatus.processing
                            ? CupertinoIcons.arrow_2_circlepath
                            : CupertinoIcons.exclamationmark_triangle,
                    size: 20,
                    color: _statusColor,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recording.meetingTitle ?? 'Untitled Recording',
                    style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600,
                      color: isDark ? SColors.textDark : SColors.textLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      _InfoChip(
                        icon: CupertinoIcons.clock,
                        label: recording.formattedDuration,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _InfoChip(
                        icon: CupertinoIcons.doc,
                        label: recording.formattedSize,
                        isDark: isDark,
                      ),
                      const SizedBox(width: 10),
                      _InfoChip(
                        icon: CupertinoIcons.calendar,
                        label: DateFormat.MMMd().format(recording.createdAt),
                        isDark: isDark,
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Status badge
            StatusBadge(
              label: recording.status.name[0].toUpperCase() + recording.status.name.substring(1),
              color: _statusColor,
              pulse: recording.status == RecordingStatus.processing,
            ),
          ],
        ),
      ),
    );
  }

  Color get _statusColor {
    switch (recording.status) {
      case RecordingStatus.ready: return SColors.success;
      case RecordingStatus.processing: return SColors.warning;
      case RecordingStatus.failed: return SColors.error;
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;

  const _InfoChip({required this.icon, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12,
          color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
        const SizedBox(width: 3),
        Text(label, style: TextStyle(
          fontSize: 11,
          color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
        )),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;

  const _MiniStat({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: TextStyle(
          fontSize: 16, fontWeight: FontWeight.w700,
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
        Text(label, style: TextStyle(
          fontSize: 11,
          color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
        )),
      ],
    );
  }
}
