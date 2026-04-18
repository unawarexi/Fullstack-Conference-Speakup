import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/utils/formatters.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/domain/models/chat_model.dart';
import 'package:flutter_conference_speakup/store/chat_provider.dart';
import 'package:flutter_conference_speakup/store/auth_provider.dart';

/// In-meeting chat provider — fetches/creates chat room for a meeting.
final meetingChatRoomProvider =
    FutureProvider.family.autoDispose<ChatRoom, String>((ref, meetingId) {
  return ref.read(chatRepositoryProvider).getOrCreateMeetingChat(meetingId);
});

/// Bottom sheet chat panel shown inside the meeting room.
class MeetingChatSheet extends ConsumerStatefulWidget {
  final String meetingId;
  final VoidCallback onClose;

  const MeetingChatSheet({
    super.key,
    required this.meetingId,
    required this.onClose,
  });

  @override
  ConsumerState<MeetingChatSheet> createState() => _MeetingChatSheetState();
}

class _MeetingChatSheetState extends ConsumerState<MeetingChatSheet> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _messageCtrl.addListener(() {
      final composing = _messageCtrl.text.trim().isNotEmpty;
      if (composing != _isComposing) setState(() => _isComposing = composing);
    });
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatRoomAsync = ref.watch(meetingChatRoomProvider(widget.meetingId));

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: isDark ? SColors.darkSurface : SColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        children: [
          // Handle bar + header
          _buildHeader(isDark),
          Divider(
            height: 1,
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
          ),

          // Messages body
          Expanded(
            child: chatRoomAsync.when(
              data: (chatRoom) => _ChatBody(
                chatRoomId: chatRoom.id,
                scrollCtrl: _scrollCtrl,
                isDark: isDark,
              ),
              loading: () => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load chat',
                  style: TextStyle(
                    color: isDark
                        ? SColors.textDarkSecondary
                        : SColors.textLightSecondary,
                  ),
                ),
              ),
            ),
          ),

          // Input bar
          chatRoomAsync.when(
            data: (chatRoom) => _buildInputBar(isDark, chatRoom.id),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: SColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
            ),
            child: Icon(Iconsax.message, size: 18, color: SColors.primary),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Meeting Chat',
              style: TextStyle(
                color: isDark ? SColors.textDark : SColors.textLight,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          IconButton(
            onPressed: widget.onClose,
            icon: Icon(
              Icons.close,
              size: 20,
              color: isDark
                  ? SColors.textDarkSecondary
                  : SColors.textLightSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(bool isDark, String chatRoomId) {
    return Container(
      padding: EdgeInsets.only(
        left: 12,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).padding.bottom + 8,
      ),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkSurface : SColors.lightSurface,
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
              decoration: BoxDecoration(
                color: isDark ? SColors.darkCard : SColors.lightElevated,
                borderRadius: BorderRadius.circular(SSizes.radiusFull),
              ),
              child: TextField(
                controller: _messageCtrl,
                style: TextStyle(
                  color: isDark ? SColors.textDark : SColors.textLight,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? SColors.textDarkTertiary
                        : SColors.textLightTertiary,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                ),
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => _sendMessage(chatRoomId),
              ),
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: _isComposing ? () => _sendMessage(chatRoomId) : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _isComposing
                    ? SColors.primary
                    : isDark
                        ? SColors.darkElevated
                        : SColors.lightElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Iconsax.send_1,
                size: 18,
                color: _isComposing
                    ? Colors.white
                    : isDark
                        ? SColors.textDarkTertiary
                        : SColors.textLightTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage(String chatRoomId) {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    ref.read(chatMessagesProvider(chatRoomId).notifier).sendMessage(content: text);
    _messageCtrl.clear();
    HapticFeedback.lightImpact();
  }
}

class _ChatBody extends ConsumerWidget {
  final String chatRoomId;
  final ScrollController scrollCtrl;
  final bool isDark;

  const _ChatBody({
    required this.chatRoomId,
    required this.scrollCtrl,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatMessagesProvider(chatRoomId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;

    if (chatState.isLoading && chatState.messages.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    if (chatState.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Iconsax.message,
              size: 40,
              color: isDark
                  ? SColors.textDarkTertiary.withOpacity(0.4)
                  : SColors.textLightTertiary.withOpacity(0.4),
            ),
            const SizedBox(height: 8),
            Text(
              'No messages yet',
              style: TextStyle(
                color: isDark
                    ? SColors.textDarkTertiary
                    : SColors.textLightTertiary,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Start the conversation!',
              style: TextStyle(
                color: isDark
                    ? SColors.textDarkTertiary.withOpacity(0.6)
                    : SColors.textLightTertiary.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollCtrl,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: chatState.messages.length,
      itemBuilder: (context, index) {
        final msg = chatState.messages[index];
        final isMe = msg.senderId == currentUser?.id;
        return _MessageBubble(
          message: msg,
          isMe: isMe,
          isDark: isDark,
        ).animate().fadeIn(duration: 150.ms);
      },
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool isDark;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.7,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isMe
              ? SColors.chatBubbleSent
              : isDark
                  ? SColors.chatBubbleReceived
                  : SColors.chatBubbleReceivedLight,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(isMe ? 14 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe && message.senderName != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: Text(
                  message.senderName!,
                  style: TextStyle(
                    color: isMe
                        ? Colors.white.withOpacity(0.7)
                        : SColors.primary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            Text(
              message.content,
              style: TextStyle(
                color: isMe
                    ? Colors.white
                    : isDark
                        ? SColors.textDark
                        : SColors.textLight,
                fontSize: 14,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              SFormatters.formatTime24h(message.createdAt),
              style: TextStyle(
                color: isMe
                    ? Colors.white.withOpacity(0.5)
                    : isDark
                        ? SColors.textDarkTertiary
                        : SColors.textLightTertiary,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
