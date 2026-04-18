import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/utils/formatters.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/domain/models/notification_model.dart';
import 'package:flutter_conference_speakup/store/notification_provider.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _selectedFilter = 0;

  Future<void> _onRefresh() async {
    await ref.read(notificationsProvider.notifier).fetch();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final notificationsAsync = ref.watch(notificationsProvider);
    final unreadCount = ref.watch(unreadNotificationCountProvider);
    final filters = ['All', 'Unread', 'Meetings', 'Chat', 'System'];

    return Scaffold(
      backgroundColor: isDark ? SColors.darkBg : SColors.lightBg,
      appBar: AppBar(
        title: Text('Notifications', style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
        actions: [
          if (unreadCount > 0)
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                ref.read(notificationsProvider.notifier).markAllAsRead();
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: SColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(SSizes.radiusFull),
                ),
                child: Text(
                  'Read all',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: SColors.primary),
                ),
              ),
            ),
        ],
      ),
      body: ResponsiveBody(child: RefreshIndicator(
        onRefresh: _onRefresh,
        color: SColors.primary,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
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
                    icon: i == 1 && unreadCount > 0 ? CupertinoIcons.circle_fill : null,
                    onTap: () => setState(() => _selectedFilter = i),
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 12)),

            notificationsAsync.when(
              data: (notifications) {
                final filtered = _applyFilter(notifications);
                if (filtered.isEmpty) {
                  return SliverFillRemaining(
                    child: EmptyState(
                      icon: CupertinoIcons.bell_slash,
                      message: 'No notifications',
                      subMessage: 'You\'re all caught up!',
                    ),
                  );
                }

                // Group by date
                final grouped = _groupByDate(filtered);
                final sections = grouped.entries.toList();

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final section = sections[index];
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                            child: Text(
                              section.key,
                              style: TextStyle(
                                fontSize: 13, fontWeight: FontWeight.w600,
                                color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                              ),
                            ),
                          ),
                          ...section.value.asMap().entries.map((entry) {
                            return Dismissible(
                              key: Key(entry.value.id),
                              direction: DismissDirection.endToStart,
                              background: Container(
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 20),
                                color: SColors.error,
                                child: const Icon(CupertinoIcons.trash, color: Colors.white, size: 20),
                              ),
                              onDismissed: (_) {
                                ref.read(notificationsProvider.notifier).delete(entry.value.id);
                              },
                              child: _NotificationTile(
                                notification: entry.value,
                                isDark: isDark,
                                onTap: () => _handleTap(entry.value),
                              ).animate().fadeIn(
                                duration: 200.ms,
                                delay: (30 * entry.key).ms,
                              ),
                            );
                          }),
                        ],
                      );
                    },
                    childCount: sections.length,
                  ),
                );
              },
              loading: () => SliverFillRemaining(
                child: Center(child: CupertinoActivityIndicator(color: SColors.primary)),
              ),
              error: (e, _) => SliverFillRemaining(
                child: EmptyState(
                  icon: CupertinoIcons.exclamationmark_triangle,
                  message: 'Failed to load',
                  actionLabel: 'Retry',
                  onAction: _onRefresh,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 96)),
          ],
        ),
      ),
    ),
    );
  }

  List<NotificationModel> _applyFilter(List<NotificationModel> items) {
    switch (_selectedFilter) {
      case 1: return items.where((n) => !n.isRead).toList();
      case 2: return items.where((n) =>
          n.type == NotificationType.meetingInvite ||
          n.type == NotificationType.meetingReminder ||
          n.type == NotificationType.meetingStarted).toList();
      case 3: return items.where((n) => n.type == NotificationType.chatMessage).toList();
      case 4: return items.where((n) =>
          n.type == NotificationType.system ||
          n.type == NotificationType.recordingReady).toList();
      default: return items;
    }
  }

  Map<String, List<NotificationModel>> _groupByDate(List<NotificationModel> items) {
    final grouped = <String, List<NotificationModel>>{};
    final now = DateTime.now();
    for (final item in items) {
      final diff = now.difference(item.createdAt);
      String key;
      if (diff.inDays == 0) {
        key = 'Today';
      } else if (diff.inDays == 1) {
        key = 'Yesterday';
      } else if (diff.inDays < 7) {
        key = 'This Week';
      } else {
        key = SFormatters.formatDateYMMMd(item.createdAt);
      }
      grouped.putIfAbsent(key, () => []).add(item);
    }
    return grouped;
  }

  void _handleTap(NotificationModel notification) {
    HapticFeedback.selectionClick();
    if (!notification.isRead) {
      ref.read(notificationsProvider.notifier).markAsRead(notification.id);
    }
    final data = notification.data;
    if (data != null) {
      final meetingId = data['meetingId'] as String?;
      final chatId = data['chatRoomId'] as String?;
      if (meetingId != null) {
        context.push('/meeting-detail/$meetingId');
      } else if (chatId != null) {
        context.push('/chat/$chatId');
      }
    }
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final bool isDark;
  final VoidCallback onTap;

  const _NotificationTile({
    required this.notification,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isUnread = !notification.isRead;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUnread
              ? (isDark ? SColors.primary.withValues(alpha: 0.06) : SColors.primary.withValues(alpha: 0.04))
              : Colors.transparent,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: _typeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(_typeIcon, size: 18, color: _typeColor),
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
                          notification.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isUnread ? FontWeight.w600 : FontWeight.w500,
                            color: isDark ? SColors.textDark : SColors.textLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _formatTime(notification.createdAt),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    notification.body,
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            if (isUnread)
              Container(
                width: 8, height: 8,
                margin: const EdgeInsets.only(left: 8, top: 6),
                decoration: const BoxDecoration(
                  color: SColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData get _typeIcon {
    switch (notification.type) {
      case NotificationType.meetingInvite: return CupertinoIcons.calendar_badge_plus;
      case NotificationType.meetingReminder: return CupertinoIcons.bell;
      case NotificationType.meetingStarted: return CupertinoIcons.video_camera;
      case NotificationType.chatMessage: return CupertinoIcons.chat_bubble;
      case NotificationType.recordingReady: return CupertinoIcons.film;
      case NotificationType.system: return CupertinoIcons.info_circle;
    }
  }

  Color get _typeColor {
    switch (notification.type) {
      case NotificationType.meetingInvite: return SColors.primary;
      case NotificationType.meetingReminder: return SColors.warning;
      case NotificationType.meetingStarted: return SColors.success;
      case NotificationType.chatMessage: return SColors.info;
      case NotificationType.recordingReady: return SColors.screenShare;
      case NotificationType.system: return SColors.darkMuted;
    }
  }

  String _formatTime(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return SFormatters.formatTimeJm(date);
    return SFormatters.formatMonthDay(date);
  }
}
