import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';

class ChatRoomScreen extends StatefulWidget {
  final String chatId;
  final String? title;

  const ChatRoomScreen({super.key, required this.chatId, this.title});

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _messageCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title ?? 'Chat'),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam_outlined),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.info_outline),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages area
          Expanded(
            child: Center(
              child: Text(
                'Start a conversation',
                style: TextStyle(
                  color: isDark
                      ? SColors.textDarkTertiary
                      : SColors.textLightTertiary,
                ),
              ),
            ),
          ),
          // Input bar
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: SSizes.sm,
              vertical: SSizes.sm,
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
            child: SafeArea(
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.attach_file,
                      color: isDark ? SColors.darkMuted : SColors.lightMuted,
                    ),
                  ),
                  Expanded(
                    child: TextField(
                      controller: _messageCtrl,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        filled: true,
                        fillColor:
                            isDark ? SColors.darkCard : SColors.lightElevated,
                        border: OutlineInputBorder(
                          borderRadius:
                              BorderRadius.circular(SSizes.radiusFull),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: SSizes.md,
                          vertical: SSizes.sm,
                        ),
                      ),
                      maxLines: 4,
                      minLines: 1,
                    ),
                  ),
                  const SizedBox(width: SSizes.xs),
                  Material(
                    color: SColors.primary,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        // TODO: Send message
                        _messageCtrl.clear();
                      },
                      child: const SizedBox(
                        width: 40,
                        height: 40,
                        child: Icon(Icons.send, color: Colors.white, size: 20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
