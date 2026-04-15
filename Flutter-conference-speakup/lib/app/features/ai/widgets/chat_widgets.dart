import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Model for a single chat message.
class ChatMsg {
  final String text;
  final bool isUser;
  ChatMsg({required this.text, required this.isUser});
}

/// A single message bubble (user or AI).
class MessageBubble extends StatelessWidget {
  final ChatMsg msg;
  final bool isDark;
  const MessageBubble({super.key, required this.msg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isUser ? SColors.primaryGradient : null,
          color:
              isUser ? null : (isDark ? SColors.darkCard : SColors.lightCard),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(
                  color: isDark ? SColors.darkBorder : SColors.lightBorder,
                  width: 0.5),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            fontSize: 13,
            height: 1.45,
            color: isUser
                ? Colors.white
                : (isDark ? SColors.textDark : SColors.textLight),
          ),
        ),
      ),
    );
  }
}

/// Animated typing indicator bubble.
class TypingBubble extends StatelessWidget {
  final bool isDark;
  const TypingBubble({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8, right: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
          ),
          border: Border.all(
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => Container(
              width: 6,
              height: 6,
              margin: const EdgeInsets.symmetric(horizontal: 2),
              decoration: BoxDecoration(
                color: isDark
                    ? SColors.textDarkTertiary
                    : SColors.textLightTertiary,
                shape: BoxShape.circle,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .fadeIn(
                    delay: Duration(milliseconds: i * 200), duration: 400.ms)
                .fadeOut(delay: 400.ms, duration: 400.ms),
          ),
        ),
      ),
    );
  }
}

/// Empty chat state with suggestion chips.
class EmptyChat extends StatelessWidget {
  final bool isDark;
  final void Function(String suggestion)? onSuggestionTap;
  const EmptyChat({super.key, required this.isDark, this.onSuggestionTap});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: SColors.accentGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.auto_awesome_rounded,
                size: 28, color: Colors.white),
          ).animate().scale(
              begin: const Offset(0.8, 0.8),
              duration: 400.ms,
              curve: Curves.elasticOut),
          const SizedBox(height: 16),
          Text(
            'Meeting AI Assistant',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? SColors.textDark : SColors.textLight,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Ask about scheduling, summaries,\nor meeting analytics',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: isDark
                  ? SColors.textDarkSecondary
                  : SColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: [
              'Summarize my week',
              'Schedule a meeting',
              'Show analytics',
            ]
                .map((s) => SuggestionChip(
                      label: s,
                      isDark: isDark,
                      onTap: () => onSuggestionTap?.call(s),
                    ))
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

/// A small suggestion chip button.
class SuggestionChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback? onTap;
  const SuggestionChip(
      {super.key, required this.label, required this.isDark, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusFull),
          border: Border.all(
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: SColors.primary,
          ),
        ),
      ),
    );
  }
}
