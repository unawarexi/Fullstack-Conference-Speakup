import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// Full transcription viewer for a meeting — speaker-annotated, searchable.
class TranscriptionViewerScreen extends ConsumerStatefulWidget {
  final String meetingId;
  const TranscriptionViewerScreen({super.key, required this.meetingId});

  @override
  ConsumerState<TranscriptionViewerScreen> createState() => _TranscriptionViewerScreenState();
}

class _TranscriptionViewerScreenState extends ConsumerState<TranscriptionViewerScreen> {
  final _searchController = TextEditingController();
  String _filter = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final transcriptAsync = ref.watch(aiTranscriptProvider(widget.meetingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transcript'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(icon: const Icon(Icons.translate_rounded), onPressed: () {}),
          IconButton(icon: const Icon(Icons.download_rounded), onPressed: () {}),
        ],
      ),
      body: ResponsiveBody(child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(SSizes.md, SSizes.sm, SSizes.md, SSizes.sm),
            child: TextField(
              controller: _searchController,
              onChanged: (v) => setState(() => _filter = v),
              decoration: InputDecoration(
                hintText: 'Search transcript...',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                filled: true,
                fillColor: isDark ? SColors.darkCard : SColors.lightElevated,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(SSizes.radiusMd), borderSide: BorderSide.none),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: transcriptAsync.when(
              data: (segments) {
                final filtered = _filter.isEmpty
                    ? segments
                    : segments.where((s) => s.text.toLowerCase().contains(_filter.toLowerCase())).toList();

                if (filtered.isEmpty) {
                  return AIEmptyState(
                    icon: Icons.subtitles_off_rounded,
                    message: _filter.isEmpty ? 'No transcript available' : 'No matches found',
                    subMessage: _filter.isEmpty ? 'Transcript will appear after the meeting is processed' : null,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => ref.invalidate(aiTranscriptProvider(widget.meetingId)),
                  color: SColors.primary,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.sm),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      final seg = filtered[index];
                      return _TranscriptBubble(segment: seg, isDark: isDark);
                    },
                  ),
                );
              },
              loading: () => const AILoadingState(message: 'Loading transcript...'),
              error: (e, _) => AIErrorState(
                message: 'Failed to load transcript',
                onRetry: () => ref.invalidate(aiTranscriptProvider(widget.meetingId)),
              ),
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _TranscriptBubble extends StatelessWidget {
  final TranscriptionSegment segment;
  final bool isDark;
  const _TranscriptBubble({required this.segment, required this.isDark});

  String get _timeLabel {
    final ts = segment.timestamp;
    return '${ts.hour.toString().padLeft(2, '0')}:${ts.minute.toString().padLeft(2, '0')}:${ts.second.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final speaker = segment.speakerName ?? segment.speakerId ?? 'Unknown';
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightCard,
        borderRadius: BorderRadius.circular(SSizes.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(radius: 10, backgroundColor: SColors.primary.withValues(alpha: 0.12),
                  child: Text(speaker[0], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: SColors.primary))),
              const SizedBox(width: 6),
              Text(speaker, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: SColors.primary)),
              const Spacer(),
              Text(_timeLabel, style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary)),
            ],
          ),
          const SizedBox(height: 4),
          Text(segment.text, style: TextStyle(fontSize: 13, height: 1.4, color: isDark ? SColors.textDark : SColors.textLight)),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}
