import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

class RoomCopilotPanel extends StatelessWidget {
  final MeetingAIState aiState;
  final String meetingId;
  final bool isDark;
  final VoidCallback onClose;
  final ValueChanged<String> onDismiss;
  final VoidCallback onRequestSummary;

  const RoomCopilotPanel({
    super.key,
    required this.aiState,
    required this.meetingId,
    required this.isDark,
    required this.onClose,
    required this.onDismiss,
    required this.onRequestSummary,
  });

  @override
  Widget build(BuildContext context) {
    final activeSuggestions =
        aiState.suggestions.where((s) => !s.isDismissed).toList().reversed.toList();
    final surfaceColor = isDark ? SColors.darkSurface : SColors.lightSurface;
    final borderColor = isDark ? SColors.darkBorder : SColors.lightBorder;
    final textPrimary = isDark ? SColors.textDark : SColors.textLight;
    final textSecondary = isDark ? SColors.textDarkSecondary : SColors.textLightSecondary;
    final textTertiary = isDark ? SColors.textDarkTertiary : SColors.textLightTertiary;

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius:
            const BorderRadius.only(topLeft: Radius.circular(SSizes.radiusXl)),
        border: Border(
          left: BorderSide(color: borderColor.withOpacity(0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.4 : 0.15),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + SSizes.sm,
              left: SSizes.md,
              right: SSizes.sm,
              bottom: SSizes.sm,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: SColors.accentGradient,
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  ),
                  child: const Icon(Iconsax.cpu, size: 18, color: Colors.white),
                ),
                const SizedBox(width: SSizes.sm + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Copilot',
                        style: TextStyle(
                          color: textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Real-time suggestions',
                        style: TextStyle(
                          color: textTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: Icon(Icons.close, color: textSecondary, size: 20),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: borderColor.withOpacity(0.5)),

          // Tabs / content
          Expanded(
            child: activeSuggestions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.cpu,
                          size: 40,
                          color: textTertiary.withOpacity(0.4),
                        ),
                        const SizedBox(height: SSizes.sm),
                        Text(
                          'Listening for insights…',
                          style: TextStyle(
                            color: textTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(SSizes.sm),
                    itemCount: activeSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = activeSuggestions[index];
                      return RoomSuggestionCard(
                        suggestion: suggestion,
                        isDark: isDark,
                        onDismiss: () => onDismiss(suggestion.id),
                      );
                    },
                  ),
          ),

          // Action items section
          if (aiState.actionItems.isNotEmpty)
            RoomActionItemsPreview(items: aiState.actionItems, isDark: isDark),

          // Summary button
          Padding(
            padding: const EdgeInsets.all(SSizes.sm),
            child: GestureDetector(
              onTap: onRequestSummary,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: SSizes.sm + 2),
                decoration: BoxDecoration(
                  color: SColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  border: Border.all(
                    color: SColors.primary.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.document_text, size: 16, color: SColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Generate Summary',
                      style: TextStyle(
                        color: SColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class RoomSuggestionCard extends StatelessWidget {
  final CopilotSuggestion suggestion;
  final bool isDark;
  final VoidCallback onDismiss;

  const RoomSuggestionCard({
    super.key,
    required this.suggestion,
    required this.isDark,
    required this.onDismiss,
  });

  IconData get _icon => switch (suggestion.type) {
        SuggestionType.talkingPoint => Iconsax.message_text,
        SuggestionType.question => Iconsax.message_question,
        SuggestionType.insight => Iconsax.lamp_on,
        SuggestionType.warning => Iconsax.warning_2,
        SuggestionType.followUp => Iconsax.arrow_right_1,
      };

  Color get _color => switch (suggestion.type) {
        SuggestionType.talkingPoint => SColors.primary,
        SuggestionType.question => SColors.info,
        SuggestionType.insight => SColors.screenShare,
        SuggestionType.warning => SColors.warning,
        SuggestionType.followUp => SColors.success,
      };

  String get _label => switch (suggestion.type) {
        SuggestionType.talkingPoint => 'Talking Point',
        SuggestionType.question => 'Question',
        SuggestionType.insight => 'Insight',
        SuggestionType.warning => 'Warning',
        SuggestionType.followUp => 'Follow Up',
      };

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(suggestion.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SSizes.md),
        decoration: BoxDecoration(
          color: SColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
        ),
        child: const Icon(Icons.close, color: SColors.error, size: 20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: SSizes.sm),
        padding: const EdgeInsets.all(SSizes.sm + 2),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(
            color: _color.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(_icon, size: 14, color: _color),
                ),
                const SizedBox(width: SSizes.sm),
                Text(
                  _label,
                  style: TextStyle(
                    color: _color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                // Confidence indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: isDark ? SColors.darkElevated : SColors.lightElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(suggestion.confidence * 100).toInt()}%',
                    style: TextStyle(
                      color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SSizes.sm),
            Text(
              suggestion.text,
              style: TextStyle(
                color: isDark ? SColors.textDark : SColors.textLight,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (suggestion.context != null) ...[
              const SizedBox(height: 4),
              Text(
                suggestion.context!,
                style: TextStyle(
                  color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.1);
  }
}

class RoomActionItemsPreview extends StatelessWidget {
  final List<ActionItem> items;
  final bool isDark;

  const RoomActionItemsPreview({super.key, required this.items, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final recent = items.length > 3 ? items.sublist(items.length - 3) : items;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SSizes.sm),
      padding: const EdgeInsets.all(SSizes.sm + 2),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightCard,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(color: SColors.success.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.task_square, size: 14, color: SColors.success),
              const SizedBox(width: 6),
              Text(
                'Action Items (${items.length})',
                style: const TextStyle(
                  color: SColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: SSizes.sm),
          ...recent.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: item.priority == 'high'
                            ? SColors.error
                            : item.priority == 'medium'
                                ? SColors.warning
                                : isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.text,
                        style: TextStyle(
                          color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
