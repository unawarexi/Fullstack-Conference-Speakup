import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

/// Meeting Feedback & Rating — post-meeting quality survey with AI analysis.
class MeetingFeedbackScreen extends ConsumerStatefulWidget {
  const MeetingFeedbackScreen({super.key});

  @override
  ConsumerState<MeetingFeedbackScreen> createState() => _MeetingFeedbackScreenState();
}

class _MeetingFeedbackScreenState extends ConsumerState<MeetingFeedbackScreen> {
  int _overallRating = 4;
  int _audioRating = 5;
  int _contentRating = 3;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meeting Feedback'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          // Meeting context
          Container(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            decoration: BoxDecoration(
              color: isDark ? SColors.darkCard : SColors.lightCard,
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
              border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Sprint Planning — Dec 5', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
                const SizedBox(height: 4),
                Text('45 min · 6 participants', style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Ratings
          Text('Rate this meeting', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 12),
          _RatingRow(label: 'Overall Experience', value: _overallRating, onChanged: (v) => setState(() => _overallRating = v), isDark: isDark),
          const SizedBox(height: 12),
          _RatingRow(label: 'Audio / Video Quality', value: _audioRating, onChanged: (v) => setState(() => _audioRating = v), isDark: isDark),
          const SizedBox(height: 12),
          _RatingRow(label: 'Content & Value', value: _contentRating, onChanged: (v) => setState(() => _contentRating = v), isDark: isDark),
          const SizedBox(height: 20),
          // AI analysis
          Container(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            decoration: BoxDecoration(
              color: SColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.auto_awesome_rounded, size: 16, color: SColors.primary),
                    SizedBox(width: 8),
                    Text('AI Analysis', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SColors.primary)),
                  ],
                ),
                const SizedBox(height: 8),
                Text('Meeting ran 7 min over schedule. Speaking time was dominated by 2 of 6 participants. 3 agenda items were deferred — consider breaking into two sessions.', style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Quick tags
          Text('Quick Tags', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: const [
              _FeedbackChip(label: 'Productive'),
              _FeedbackChip(label: 'Too Long'),
              _FeedbackChip(label: 'Well-organized'),
              _FeedbackChip(label: 'Missing agenda'),
              _FeedbackChip(label: 'Great discussion'),
              _FeedbackChip(label: 'Could be an email'),
              _FeedbackChip(label: 'Action-oriented'),
              _FeedbackChip(label: 'Off-topic'),
            ],
          ),
          const SizedBox(height: 16),
          // Comments
          Text('Additional Comments', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          TextField(
            controller: _commentController,
            maxLines: 4,
            style: TextStyle(fontSize: 13, color: isDark ? SColors.textDark : SColors.textLight),
            decoration: InputDecoration(
              hintText: 'Share your thoughts...',
              hintStyle: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
              filled: true,
              fillColor: isDark ? SColors.darkCard : SColors.lightCard,
              contentPadding: const EdgeInsets.all(12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(SSizes.radiusMd), borderSide: BorderSide(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(SSizes.radiusMd), borderSide: BorderSide(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5)),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await ref.read(aiRepositoryProvider).executeTool('submit_feedback', {
                    'overallRating': _overallRating,
                    'audioRating': _audioRating,
                    'contentRating': _contentRating,
                    'comment': _commentController.text,
                  });
                } catch (_) {}
                if (context.mounted) Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: SColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SSizes.radiusMd)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Submit Feedback', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
            ),
          ),
        ].animate(interval: 40.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
      ),
    ),
    );
  }
}

class _RatingRow extends StatelessWidget {
  final String label;
  final int value;
  final ValueChanged<int> onChanged;
  final bool isDark;
  const _RatingRow({required this.label, required this.value, required this.onChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: isDark ? SColors.textDark : SColors.textLight)),
        const SizedBox(height: 6),
        Row(
          children: List.generate(5, (i) {
            final filled = i < value;
            return GestureDetector(
              onTap: () => onChanged(i + 1),
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(filled ? Icons.star_rounded : Icons.star_outline_rounded, size: 28, color: filled ? const Color(0xFFF59E0B) : (isDark ? SColors.darkBorder : SColors.lightBorder)),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FeedbackChip extends StatefulWidget {
  final String label;
  const _FeedbackChip({required this.label});

  @override
  State<_FeedbackChip> createState() => _FeedbackChipState();
}

class _FeedbackChipState extends State<_FeedbackChip> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: _selected ? SColors.primary.withValues(alpha: 0.12) : (isDark ? SColors.darkCard : SColors.lightCard),
          borderRadius: BorderRadius.circular(SSizes.radiusFull),
          border: Border.all(color: _selected ? SColors.primary : (isDark ? SColors.darkBorder : SColors.lightBorder), width: 0.5),
        ),
        child: Text(widget.label, style: TextStyle(fontSize: 12, fontWeight: _selected ? FontWeight.w600 : FontWeight.w400, color: _selected ? SColors.primary : (isDark ? SColors.textDark : SColors.textLight))),
      ),
);
  }
}
