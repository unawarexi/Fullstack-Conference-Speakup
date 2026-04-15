import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/domain/models/chat_model.dart';
import 'package:flutter_conference_speakup/store/chat_provider.dart';
import 'package:flutter_conference_speakup/store/auth_provider.dart';

class ChatRoomScreen extends ConsumerStatefulWidget {
  final String chatId;
  final String? title;

  const ChatRoomScreen({super.key, required this.chatId, this.title});

  @override
  ConsumerState<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends ConsumerState<ChatRoomScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _isComposing = false;

  @override
  void initState() {
    super.initState();
    _scrollCtrl.addListener(_onScroll);
    _messageCtrl.addListener(() {
      final composing = _messageCtrl.text.trim().isNotEmpty;
      if (composing != _isComposing) setState(() => _isComposing = composing);
    });
  }

  void _onScroll() {
    if (_scrollCtrl.position.pixels >= _scrollCtrl.position.maxScrollExtent - 200) {
      ref.read(chatMessagesProvider(widget.chatId).notifier).loadMore();
    }
  }

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _messageCtrl.text.trim();
    if (text.isEmpty) return;
    _messageCtrl.clear();
    HapticFeedback.lightImpact();
    await ref.read(chatMessagesProvider(widget.chatId).notifier).sendMessage(content: text);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final chatState = ref.watch(chatMessagesProvider(widget.chatId));
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final currentUserId = currentUser?.id ?? '';

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        leadingWidth: 32,
        titleSpacing: 4,
        title: Row(
          children: [
            SAvatar(name: widget.title ?? 'Chat', size: 32),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title ?? 'Chat',
                    style: TextStyle(
                      fontSize: 15, fontWeight: FontWeight.w600,
                      color: isDark ? SColors.textDark : SColors.textLight,
                    ),
                  ),
                  Text(
                    '${chatState.messages.length} messages',
                    style: TextStyle(
                      fontSize: 11,
                      color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(CupertinoIcons.video_camera, size: 22,
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(CupertinoIcons.info_circle, size: 20,
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
          ),
        ],
      ),
      body: ResponsiveBody(child: Column(
        children: [
          // Messages area
          Expanded(
            child: chatState.messages.isEmpty && !chatState.isLoading
                ? Center(
                    child: EmptyState(
                      icon: CupertinoIcons.chat_bubble_2,
                      message: 'Start the conversation',
                      subMessage: 'Say hello!',
                    ),
                  )
                : ListView.builder(
                    controller: _scrollCtrl,
                    reverse: true,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    itemCount: chatState.messages.length + (chatState.isLoading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (chatState.isLoading && index == chatState.messages.length) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: CupertinoActivityIndicator(color: SColors.primary),
                          ),
                        );
                      }
                      final msg = chatState.messages[index];
                      final isMe = msg.senderId == currentUserId;
                      final showAvatar = !isMe && (
                        index == chatState.messages.length - 1 ||
                        chatState.messages[index + 1].senderId != msg.senderId
                      );
                      return _MessageBubble(
                        message: msg,
                        isMe: isMe,
                        showAvatar: showAvatar,
                        isDark: isDark,
                        onLongPress: () => _showMessageOptions(context, msg, isMe, isDark),
                      );
                    },
                  ),
          ),

          // Input bar
          _InputBar(
            controller: _messageCtrl,
            isDark: isDark,
            isComposing: _isComposing,
            onSend: _sendMessage,
          ),
        ],
      ),
    ),
    );
  }

  void _showMessageOptions(BuildContext context, ChatMessage msg, bool isMe, bool isDark) {
    HapticFeedback.mediumImpact();
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: msg.content));
              Navigator.pop(ctx);
            },
            child: const Text('Copy'),
          ),
          if (isMe)
            CupertinoActionSheetAction(
              isDestructiveAction: true,
              onPressed: () {
                ref.read(chatMessagesProvider(widget.chatId).notifier).deleteMessage(msg.id);
                Navigator.pop(ctx);
              },
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
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final bool isDark;
  final VoidCallback onLongPress;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    required this.showAvatar,
    required this.isDark,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: onLongPress,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMe ? 48 : 0,
          right: isMe ? 0 : 48,
          bottom: 4,
        ),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              if (showAvatar)
                SAvatar(name: message.senderName ?? '?', size: 28)
              else
                const SizedBox(width: 28),
              const SizedBox(width: 6),
            ],
            Flexible(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                decoration: BoxDecoration(
                  color: isMe
                      ? SColors.primary
                      : (isDark ? SColors.darkCard : SColors.lightElevated),
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 18),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showAvatar && !isMe && message.senderName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          message.senderName!,
                          style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: SColors.primary,
                          ),
                        ),
                      ),
                    Text(
                      message.content,
                      style: TextStyle(
                        fontSize: 14,
                        color: isMe ? Colors.white
                            : (isDark ? SColors.textDark : SColors.textLight),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          DateFormat.jm().format(message.createdAt),
                          style: TextStyle(
                            fontSize: 10,
                            color: isMe ? Colors.white70
                                : (isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
                          ),
                        ),
                        if (message.isEdited) ...[
                          const SizedBox(width: 4),
                          Text(
                            'edited',
                            style: TextStyle(
                              fontSize: 10, fontStyle: FontStyle.italic,
                              color: isMe ? Colors.white54
                                  : (isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;
  final bool isComposing;
  final VoidCallback onSend;

  const _InputBar({
    required this.controller,
    required this.isDark,
    required this.isComposing,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkSurface : SColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {},
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isDark ? SColors.darkElevated : SColors.lightElevated,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(CupertinoIcons.plus, size: 20,
                  color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                decoration: BoxDecoration(
                  color: isDark ? SColors.darkCard : SColors.lightElevated,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: controller,
                  maxLines: 5,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  style: TextStyle(
                    fontSize: 15,
                    color: isDark ? SColors.textDark : SColors.textLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Message...',
                    hintStyle: TextStyle(
                      fontSize: 15,
                      color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isComposing ? onSend : null,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: isComposing ? SColors.primary : (isDark ? SColors.darkElevated : SColors.lightElevated),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.arrow_up,
                  size: 18,
                  color: isComposing ? Colors.white
                      : (isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
