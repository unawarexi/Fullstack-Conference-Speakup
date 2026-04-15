import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// Quick Notes — lightweight note-taking during or between meetings.
class QuickNotesScreen extends ConsumerStatefulWidget {
  const QuickNotesScreen({super.key});

  @override
  ConsumerState<QuickNotesScreen> createState() => _QuickNotesScreenState();
}

class _QuickNotesScreenState extends ConsumerState<QuickNotesScreen> {
  final _controller = TextEditingController();
  final _localNotes = <_NoteItem>[];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Notes'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: Column(
        children: [
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: SSizes.md, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? SColors.darkCard : SColors.lightCard,
              border: Border(bottom: BorderSide(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: TextStyle(fontSize: 14, color: isDark ? SColors.textDark : SColors.textLight),
                    decoration: InputDecoration(
                      hintText: 'Capture a quick thought...',
                      hintStyle: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                      filled: true,
                      fillColor: isDark ? SColors.darkBg : SColors.lightBg,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(SSizes.radiusMd), borderSide: BorderSide.none),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: () async {
                    if (_controller.text.trim().isNotEmpty) {
                      final text = _controller.text.trim();
                      setState(() {
                        _localNotes.insert(0, _NoteItem(text: text, tag: 'info', time: 'Just now'));
                        _controller.clear();
                      });
                      try {
                        await ref.read(aiRepositoryProvider).executeTool('add_note', {'text': text});
                      } catch (_) {}
                    }
                  },
                  icon: const Icon(Icons.send_rounded, color: SColors.primary, size: 22),
                ),
              ],
            ),
          ),
          // AI suggestion
          Container(
            padding: const EdgeInsets.all(10),
            margin: const EdgeInsets.all(SSizes.md),
            decoration: BoxDecoration(
              color: SColors.primary.withValues(alpha: isDark ? 0.08 : 0.05),
              borderRadius: BorderRadius.circular(SSizes.radiusSm),
            ),
            child: Row(
              children: const [
                Icon(Icons.auto_awesome_rounded, size: 16, color: SColors.primary),
                SizedBox(width: 8),
                Expanded(child: Text('AI auto-tags notes as action, decision, or info', style: TextStyle(fontSize: 11, color: SColors.primary))),
              ],
            ),
          ),
          // Notes list
          Expanded(
            child: ref.watch(meetingAnalyticsProvider('latest')).when(
              loading: () => const AILoadingState(message: 'Loading notes...'),
              error: (e, _) => AIErrorState(message: e.toString(), onRetry: () => ref.invalidate(meetingAnalyticsProvider('latest'))),
              data: (data) {
                final serverNotes = (data['notes'] as List?)?.cast<Map<String, dynamic>>() ?? [];
                final allNotes = [
                  ..._localNotes,
                  ...serverNotes.map((n) => _NoteItem(
                    text: n['text'] as String? ?? '',
                    tag: n['tag'] as String? ?? 'info',
                    time: n['time'] as String? ?? '',
                  )),
                ];
                if (allNotes.isEmpty) {
                  return const Center(child: AIEmptyState(icon: Icons.note_rounded, message: 'No notes yet', subMessage: 'Capture your first thought above'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: SSizes.md),
                  itemCount: allNotes.length,
                  itemBuilder: (context, index) {
                    final note = allNotes[index];
                    return _NoteTile(note: note, isDark: isDark)
                        .animate()
                        .fadeIn(duration: 200.ms, delay: (index * 40).ms)
                        .slideY(begin: 0.03, end: 0);
                  },
                );
              },
            ),
          ),
        ],
      ),
    ),
    );
  }
}

class _NoteItem {
  final String text;
  final String tag;
  final String time;
  _NoteItem({required this.text, required this.tag, required this.time});
}

class _NoteTile extends StatelessWidget {
  final _NoteItem note;
  final bool isDark;
  const _NoteTile({required this.note, required this.isDark});

  Color _tagColor() {
    switch (note.tag) {
      case 'action': return SColors.primary;
      case 'decision': return SColors.success;
      default: return isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _tagColor().withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(note.tag.toUpperCase(), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: _tagColor())),
                ),
                const Spacer(),
                Text(note.time, style: TextStyle(fontSize: 10, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
              ],
            ),
            const SizedBox(height: 6),
            Text(note.text, style: TextStyle(fontSize: 13, color: isDark ? SColors.textDark : SColors.textLight)),
          ],
        ),
      ),
    );
  }
}
