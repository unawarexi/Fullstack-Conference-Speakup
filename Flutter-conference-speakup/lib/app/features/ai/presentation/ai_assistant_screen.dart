import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final _msgCtrl = TextEditingController();
  final _messages = <_ChatMsg>[];
  bool _isTyping = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _send() {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(_ChatMsg(text: text, isUser: true));
      _msgCtrl.clear();
      _isTyping = true;
    });

    // Simulate AI response
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(_ChatMsg(
          text: _suggestedReply(text),
          isUser: false,
        ));
      });
    });
  }

  String _suggestedReply(String input) {
    final lower = input.toLowerCase();
    if (lower.contains('schedule') || lower.contains('meeting')) {
      return 'I can help schedule a meeting. What time works best for you?';
    }
    if (lower.contains('summary') || lower.contains('notes')) {
      return 'Here\'s a quick summary of your recent meetings — you had 3 this week with an average duration of 28 minutes.';
    }
    if (lower.contains('help')) {
      return 'I can help with:\n• Scheduling meetings\n• Summarizing past meetings\n• Finding participants\n• Meeting analytics';
    }
    return 'Got it! I\'m still learning — try asking about scheduling, summaries, or meeting analytics.';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(SIcons.back, size: 20,
              color: isDark ? SColors.textDark : SColors.textLight),
          onPressed: () => context.pop(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                gradient: SColors.accentGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.auto_awesome_rounded,
                  size: 15, color: Colors.white),
            ),
            const SizedBox(width: 8),
            Text(
              'AI Assistant',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? SColors.textDark : SColors.textLight,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _EmptyChat(isDark: isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (_isTyping && i == _messages.length) {
                        return _TypingBubble(isDark: isDark);
                      }
                      final msg = _messages[i];
                      return _MessageBubble(msg: msg, isDark: isDark)
                          .animate()
                          .fadeIn(duration: 200.ms)
                          .slideY(begin: 0.08, end: 0);
                    },
                  ),
          ),

          // Input bar
          Container(
            padding: EdgeInsets.fromLTRB(
                12, 8, 8, 8 + MediaQuery.of(context).padding.bottom),
            decoration: BoxDecoration(
              color: isDark ? SColors.darkCard : SColors.lightCard,
              border: Border(
                top: BorderSide(
                  color: isDark ? SColors.darkBorder : SColors.lightBorder,
                  width: 0.5,
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 40,
                    decoration: BoxDecoration(
                      color: isDark
                          ? SColors.darkElevated
                          : SColors.lightElevated,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: TextField(
                      controller: _msgCtrl,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark ? SColors.textDark : SColors.textLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Ask anything about meetings...',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? SColors.textDarkTertiary
                              : SColors.textLightTertiary,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: _send,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      gradient: SColors.primaryGradient,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Icon(Icons.arrow_upward_rounded,
                        size: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Models & Widgets
// ─────────────────────────────────────────────

class _ChatMsg {
  final String text;
  final bool isUser;
  _ChatMsg({required this.text, required this.isUser});
}

class _MessageBubble extends StatelessWidget {
  final _ChatMsg msg;
  final bool isDark;
  const _MessageBubble({required this.msg, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isUser = msg.isUser;
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.75),
        margin: EdgeInsets.only(
          bottom: 8,
          left: isUser ? 48 : 0,
          right: isUser ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: isUser ? SColors.primaryGradient : null,
          color: isUser
              ? null
              : (isDark ? SColors.darkCard : SColors.lightCard),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
          border: isUser
              ? null
              : Border.all(
                  color:
                      isDark ? SColors.darkBorder : SColors.lightBorder,
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

class _TypingBubble extends StatelessWidget {
  final bool isDark;
  const _TypingBubble({required this.isDark});

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
                .animate(
                  onPlay: (c) => c.repeat(),
                )
                .fadeIn(
                  delay: Duration(milliseconds: i * 200),
                  duration: 400.ms,
                )
                .fadeOut(delay: 400.ms, duration: 400.ms),
          ),
        ),
      ),
    );
  }
}

class _EmptyChat extends StatelessWidget {
  final bool isDark;
  const _EmptyChat({required this.isDark});

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
          ).animate().scale(begin: const Offset(0.8, 0.8), duration: 400.ms,
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
            ].map((s) => _SuggestionChip(
                  label: s,
                  isDark: isDark,
                  onTap: () {
                    // Could trigger sending this as a message
                  },
                )).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}

class _SuggestionChip extends StatelessWidget {
  final String label;
  final bool isDark;
  final VoidCallback? onTap;
  const _SuggestionChip({required this.label, required this.isDark, this.onTap});

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
