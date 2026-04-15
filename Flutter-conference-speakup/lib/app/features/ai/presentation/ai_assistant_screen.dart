import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/app/features/ai/widgets/chat_widgets.dart';

class AIAssistantScreen extends ConsumerStatefulWidget {
  const AIAssistantScreen({super.key});

  @override
  ConsumerState<AIAssistantScreen> createState() => _AIAssistantScreenState();
}

class _AIAssistantScreenState extends ConsumerState<AIAssistantScreen> {
  final _msgCtrl = TextEditingController();
  final _messages = <ChatMsg>[];
  bool _isTyping = false;

  @override
  void dispose() {
    _msgCtrl.dispose();
    super.dispose();
  }

  void _send() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    HapticFeedback.lightImpact();
    setState(() {
      _messages.add(ChatMsg(text: text, isUser: true));
      _msgCtrl.clear();
      _isTyping = true;
    });

    // Real AI response via API
    try {
      final result = await ref.read(aiRepositoryProvider).queryMemory(text);
      if (!mounted) return;
      final reply = (result.isNotEmpty)
          ? (result.first['answer'] as String? ?? result.first['text'] as String? ?? 'I could not find a specific answer. Try rephrasing your question.')
          : 'I could not find a specific answer. Try rephrasing your question.';
      setState(() {
        _isTyping = false;
        _messages.add(ChatMsg(text: reply, isUser: false));
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add(ChatMsg(
          text: 'Sorry, something went wrong. Please try again.',
          isUser: false,
        ));
      });
    }
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
      body: ResponsiveBody(child: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? EmptyChat(isDark: isDark)
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    itemCount: _messages.length + (_isTyping ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (_isTyping && i == _messages.length) {
                        return TypingBubble(isDark: isDark);
                      }
                      final msg = _messages[i];
                      return MessageBubble(msg: msg, isDark: isDark)
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
    ),
    );
  }
}

