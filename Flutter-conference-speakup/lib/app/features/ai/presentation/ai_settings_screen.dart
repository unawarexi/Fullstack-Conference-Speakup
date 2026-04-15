import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/analytics_provider.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/ai_common_widgets.dart';

/// AI Settings — granular toggles for all AI features.
class AISettingsScreen extends ConsumerStatefulWidget {
  const AISettingsScreen({super.key});

  @override
  ConsumerState<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends ConsumerState<AISettingsScreen> {
  bool _initialized = false;
  bool _autoTranscribe = true;
  bool _realTimeSuggestions = true;
  bool _emotionDetection = false;
  bool _autoSummaries = true;
  bool _actionExtraction = true;
  bool _voiceAssistant = false;
  bool _smartScheduling = true;
  bool _knowledgeGraph = true;
  bool _autoRecap = true;
  bool _speakerCoach = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsAsync = ref.watch(analyticsDashboardProvider);

    // Initialize toggle values from provider data once
    if (!_initialized) {
      settingsAsync.whenData((data) {
        final s = data['aiSettings'] as Map<String, dynamic>? ?? {};
        setState(() {
          _autoTranscribe = s['autoTranscribe'] as bool? ?? _autoTranscribe;
          _realTimeSuggestions = s['realTimeSuggestions'] as bool? ?? _realTimeSuggestions;
          _emotionDetection = s['emotionDetection'] as bool? ?? _emotionDetection;
          _autoSummaries = s['autoSummaries'] as bool? ?? _autoSummaries;
          _actionExtraction = s['actionExtraction'] as bool? ?? _actionExtraction;
          _voiceAssistant = s['voiceAssistant'] as bool? ?? _voiceAssistant;
          _smartScheduling = s['smartScheduling'] as bool? ?? _smartScheduling;
          _knowledgeGraph = s['knowledgeGraph'] as bool? ?? _knowledgeGraph;
          _autoRecap = s['autoRecap'] as bool? ?? _autoRecap;
          _speakerCoach = s['speakerCoach'] as bool? ?? _speakerCoach;
          _initialized = true;
        });
      });
    }

    void updateSetting(String key, bool value) {
      ref.read(aiRepositoryProvider).executeTool('update_setting', {key: value}).catchError((_) {});
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Settings'),
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ResponsiveBody(child: ListView(
        padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [SColors.primary, SColors.primary.withValues(alpha: 0.7)]),
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('AI is enabled', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                      Text('${[_autoTranscribe, _realTimeSuggestions, _emotionDetection, _autoSummaries, _actionExtraction, _voiceAssistant, _smartScheduling, _knowledgeGraph, _autoRecap, _speakerCoach].where((v) => v).length} of 10 features active', style: const TextStyle(fontSize: 11, color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('During Meetings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          _ToggleTile(title: 'Auto-Transcription', desc: 'Transcribe meetings in real-time with speaker labels', value: _autoTranscribe, onChanged: (v) { setState(() => _autoTranscribe = v); updateSetting('autoTranscribe', v); }, isDark: isDark),
          _ToggleTile(title: 'Real-Time Suggestions', desc: 'AI nudges for talking points, follow-ups, and data', value: _realTimeSuggestions, onChanged: (v) { setState(() => _realTimeSuggestions = v); updateSetting('realTimeSuggestions', v); }, isDark: isDark),
          _ToggleTile(title: 'Emotion Detection', desc: 'Analyze tone, sentiment, and engagement signals', value: _emotionDetection, onChanged: (v) { setState(() => _emotionDetection = v); updateSetting('emotionDetection', v); }, isDark: isDark),
          _ToggleTile(title: 'Speaker Coach', desc: 'Live feedback on pace, filler words, and clarity', value: _speakerCoach, onChanged: (v) { setState(() => _speakerCoach = v); updateSetting('speakerCoach', v); }, isDark: isDark),
          _ToggleTile(title: 'Voice Assistant', desc: 'Control meetings with voice commands', value: _voiceAssistant, onChanged: (v) { setState(() => _voiceAssistant = v); updateSetting('voiceAssistant', v); }, isDark: isDark),
          const SizedBox(height: 20),
          Text('After Meetings', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          _ToggleTile(title: 'Auto-Summaries', desc: 'Generate meeting recaps automatically after each call', value: _autoSummaries, onChanged: (v) { setState(() => _autoSummaries = v); updateSetting('autoSummaries', v); }, isDark: isDark),
          _ToggleTile(title: 'Action Item Extraction', desc: 'Automatically identify and assign follow-up tasks', value: _actionExtraction, onChanged: (v) { setState(() => _actionExtraction = v); updateSetting('actionExtraction', v); }, isDark: isDark),
          _ToggleTile(title: 'Auto Recap Email', desc: 'Send recaps to all participants after meeting ends', value: _autoRecap, onChanged: (v) { setState(() => _autoRecap = v); updateSetting('autoRecap', v); }, isDark: isDark),
          const SizedBox(height: 20),
          Text('Background Intelligence', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
          _ToggleTile(title: 'Smart Scheduling', desc: 'AI suggests optimal meeting times based on habits', value: _smartScheduling, onChanged: (v) { setState(() => _smartScheduling = v); updateSetting('smartScheduling', v); }, isDark: isDark),
          _ToggleTile(title: 'Knowledge Graph', desc: 'Build semantic connections across all your meetings', value: _knowledgeGraph, onChanged: (v) { setState(() => _knowledgeGraph = v); updateSetting('knowledgeGraph', v); }, isDark: isDark),
          const SizedBox(height: 20),
          Text('AI Model', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: isDark ? SColors.textDark : SColors.textLight)),
          const SizedBox(height: 8),
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
                _InfoRow(label: 'Primary', value: 'GPT-4o', isDark: isDark),
                _InfoRow(label: 'Fallback', value: 'Claude 3.5 Sonnet', isDark: isDark),
                _InfoRow(label: 'Speech-to-Text', value: 'Whisper v3', isDark: isDark),
                _InfoRow(label: 'Embeddings', value: 'text-embedding-3-small', isDark: isDark),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Privacy
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: SColors.warning.withValues(alpha: isDark ? 0.08 : 0.05),
              borderRadius: BorderRadius.circular(SSizes.radiusSm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.shield_rounded, size: 18, color: SColors.warning),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'All AI processing follows your privacy settings. Meeting data is encrypted end-to-end and never used for model training.',
                    style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                  ),
                ),
              ],
            ),
          ),
        ].animate(interval: 40.ms).fadeIn(duration: 300.ms).slideY(begin: 0.04, end: 0),
      ),
    ),
    );
  }
}

class _ToggleTile extends StatelessWidget {
  final String title;
  final String desc;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;
  const _ToggleTile({required this.title, required this.desc, required this.value, required this.onChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(color: isDark ? SColors.darkBorder : SColors.lightBorder, width: 0.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
                  Text(desc, style: TextStyle(fontSize: 11, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Switch.adaptive(value: value, onChanged: onChanged, activeTrackColor: SColors.primary),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  const _InfoRow({required this.label, required this.value, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: isDark ? SColors.textDark : SColors.textLight)),
        ],
      ),
);
  }
}
