import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/domain/models/chat_model.dart';
import 'package:flutter_conference_speakup/store/chat_provider.dart';

class ChatListScreen extends ConsumerStatefulWidget {
  const ChatListScreen({super.key});

  @override
  ConsumerState<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends ConsumerState<ChatListScreen> {
  final _searchCtrl = TextEditingController();
  int _selectedFilter = 0;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    ref.invalidate(chatRoomsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final roomsAsync = ref.watch(chatRoomsProvider);
    final filters = ['All', 'Direct', 'Groups', 'Meetings'];

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text('Messages', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
        actions: [
          _AppBarButton(
            icon: CupertinoIcons.pencil_ellipsis_rectangle,
            isDark: isDark,
            onTap: () {},
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: SColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Search bar
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SSearchBar(
                  controller: _searchCtrl,
                  hint: 'Search messages...',
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),

            // Filter chips
            SliverToBoxAdapter(
              child: SizedBox(
                height: 36,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => SChip(
                    label: filters[i],
                    isSelected: _selectedFilter == i,
                    onTap: () => setState(() => _selectedFilter = i),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            // Chat rooms list
            roomsAsync.when(
              data: (rooms) {
                final filtered = _filterRooms(rooms);
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: CupertinoIcons.chat_bubble_2,
                      message: 'No conversations yet',
                      subMessage: 'Start a new chat or join a meeting',
                      actionLabel: 'New Chat',
                      onAction: () {},
                    ),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final room = filtered[index];
                      return _ChatRoomTile(
                        room: room,
                        isDark: isDark,
                        onTap: () => context.push(
                          '/chat/${room.id}?name=${Uri.encodeComponent(room.name ?? 'Chat')}',
                        ),
                      ).animate().fadeIn(
                        duration: 200.ms,
                        delay: (50 * index).ms,
                      );
                    },
                    childCount: filtered.length,
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(
                  child: CupertinoActivityIndicator(color: SColors.primary),
                ),
              ),
              error: (e, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: CupertinoIcons.exclamationmark_triangle,
                  message: 'Failed to load chats',
                  actionLabel: 'Retry',
                  onAction: () => ref.invalidate(chatRoomsProvider),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    );
  }

  List<ChatRoom> _filterRooms(List<ChatRoom> rooms) {
    var filtered = rooms;
    final query = _searchCtrl.text.toLowerCase();
    if (query.isNotEmpty) {
      filtered = filtered.where((r) =>
        (r.name ?? '').toLowerCase().contains(query) ||
        r.members.any((m) => (m.fullName ?? '').toLowerCase().contains(query))
      ).toList();
    }
    switch (_selectedFilter) {
      case 1: filtered = filtered.where((r) => !r.isGroup && r.meetingId == null).toList();
      case 2: filtered = filtered.where((r) => r.isGroup).toList();
      case 3: filtered = filtered.where((r) => r.meetingId != null).toList();
    }
    return filtered;
  }
}

class _ChatRoomTile extends StatelessWidget {
  final ChatRoom room;
  final bool isDark;
  final VoidCallback onTap;

  const _ChatRoomTile({required this.room, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final lastMsg = room.lastMessage;
    final hasUnread = room.unreadCount > 0;

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        color: Colors.transparent,
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                SAvatar(
                  name: room.name ?? 'Chat',
                  size: 48,
                  imageUrl: room.members.isNotEmpty ? room.members.first.avatar : null,
                ),
                if (room.isGroup)
                  Positioned(
                    right: 0, bottom: 0,
                    child: Container(
                      width: 18, height: 18,
                      decoration: BoxDecoration(
                        color: SColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? SColors.darkBg : SColors.lightBg,
                          width: 2,
                        ),
                      ),
                      child: const Icon(Icons.group, size: 10, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          room.name ?? 'Direct Message',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                            color: isDark ? SColors.textDark : SColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (lastMsg != null)
                        Text(
                          _formatTime(lastMsg.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.w400,
                            color: hasUnread
                                ? SColors.primary
                                : (isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      if (lastMsg != null && room.isGroup && lastMsg.senderName != null) ...[
                        Text(
                          '${lastMsg.senderName}: ',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                          ),
                        ),
                      ],
                      Expanded(
                        child: Text(
                          lastMsg?.content ?? 'No messages yet',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: hasUnread ? FontWeight.w500 : FontWeight.w400,
                            color: hasUnread
                                ? (isDark ? SColors.textDark : SColors.textLight)
                                : (isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (hasUnread)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: SColors.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            room.unreadCount > 99 ? '99+' : '${room.unreadCount}',
                            style: const TextStyle(
                              fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return DateFormat.jm().format(date);
    if (diff.inDays < 7) return DateFormat.E().format(date);
    return DateFormat.MMMd().format(date);
  }
}

class _AppBarButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _AppBarButton({required this.icon, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        width: 36, height: 36,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkElevated : SColors.lightElevated,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 18,
          color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
      ),
    );
  }
}
