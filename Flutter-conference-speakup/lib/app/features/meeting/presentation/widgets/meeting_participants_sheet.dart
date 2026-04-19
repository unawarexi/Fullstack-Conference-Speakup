import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

/// Participants bottom sheet shown inside the meeting room.
class MeetingParticipantsSheet extends ConsumerStatefulWidget {
  final String meetingId;
  final List<Participant> participants;
  final VoidCallback onClose;
  final bool isHost;

  const MeetingParticipantsSheet({
    super.key,
    required this.meetingId,
    required this.participants,
    required this.onClose,
    this.isHost = false,
  });

  @override
  ConsumerState<MeetingParticipantsSheet> createState() =>
      _MeetingParticipantsSheetState();
}

class _MeetingParticipantsSheetState
    extends ConsumerState<MeetingParticipantsSheet> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered = widget.participants
        .where((p) => p.name.toLowerCase().contains(_search.toLowerCase()))
        .toList();

    return Container(
      height: MediaQuery.of(context).size.height * 0.55,
      decoration: BoxDecoration(
        color: isDark ? SColors.darkSurface : SColors.lightSurface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: SColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  ),
                  child:
                      Icon(Iconsax.people, size: 18, color: SColors.primary),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Participants (${widget.participants.length})',
                    style: TextStyle(
                      color: isDark ? SColors.textDark : SColors.textLight,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (widget.isHost)
                  TextButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      // Mute all is a host-only action — toggle via provider
                    },
                    child: Text(
                      'Mute All',
                      style: TextStyle(
                        color: SColors.primary,
                        fontSize: 13,
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
          ),

          // Search
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                color: isDark ? SColors.darkCard : SColors.lightElevated,
                borderRadius: BorderRadius.circular(SSizes.radiusFull),
              ),
              child: TextField(
                onChanged: (v) => setState(() => _search = v),
                style: TextStyle(
                  color: isDark ? SColors.textDark : SColors.textLight,
                  fontSize: 14,
                ),
                decoration: InputDecoration(
                  hintText: 'Search participants...',
                  hintStyle: TextStyle(
                    color: isDark
                        ? SColors.textDarkTertiary
                        : SColors.textLightTertiary,
                    fontSize: 13,
                  ),
                  prefixIcon: Icon(
                    Iconsax.search_normal,
                    size: 18,
                    color: isDark
                        ? SColors.textDarkTertiary
                        : SColors.textLightTertiary,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),
          Divider(
            height: 1,
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
          ),

          // List
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: Text(
                      _search.isNotEmpty
                          ? 'No matching participants'
                          : 'No participants',
                      style: TextStyle(
                        color: isDark
                            ? SColors.textDarkTertiary
                            : SColors.textLightTertiary,
                        fontSize: 13,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      return _ParticipantRow(
                        participant: p,
                        isDark: isDark,
                        isHost: widget.isHost,
                        meetingId: widget.meetingId,
                      ).animate().fadeIn(
                            duration: 150.ms,
                            delay: Duration(milliseconds: index * 30),
                          );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantRow extends ConsumerWidget {
  final Participant participant;
  final bool isDark;
  final bool isHost;
  final String meetingId;

  const _ParticipantRow({
    required this.participant,
    required this.isDark,
    required this.isHost,
    required this.meetingId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: SColors.primary.withOpacity(0.15),
            backgroundImage: participant.avatar != null
                ? NetworkImage(participant.avatar!)
                : null,
            child: participant.avatar == null
                ? Text(
                    participant.name.isNotEmpty
                        ? participant.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      color: SColors.primary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name + role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: TextStyle(
                    color: isDark ? SColors.textDark : SColors.textLight,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (participant.role != ParticipantRole.attendee)
                  Text(
                    participant.role.name.toUpperCase(),
                    style: TextStyle(
                      color: participant.role == ParticipantRole.host
                          ? SColors.primary
                          : SColors.screenShare,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),

          // Status icons
          if (participant.isHandRaised)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Icon(Iconsax.lovely, size: 16, color: SColors.handRaised),
            ),

          Icon(
            participant.isMuted ? Iconsax.microphone_slash : Iconsax.microphone,
            size: 16,
            color: participant.isMuted
                ? SColors.micOff
                : isDark
                    ? SColors.textDarkTertiary
                    : SColors.textLightTertiary,
          ),

          const SizedBox(width: 8),

          Icon(
            participant.isCameraOff ? Iconsax.video_slash : Iconsax.video,
            size: 16,
            color: participant.isCameraOff
                ? SColors.cameraOff
                : isDark
                    ? SColors.textDarkTertiary
                    : SColors.textLightTertiary,
          ),

          // Host actions
          if (isHost && participant.role != ParticipantRole.host) ...[
            const SizedBox(width: 4),
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert,
                size: 18,
                color: isDark
                    ? SColors.textDarkTertiary
                    : SColors.textLightTertiary,
              ),
              color: isDark ? SColors.darkCard : SColors.lightCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
              ),
              onSelected: (action) {
                if (action == 'kick') {
                  _confirmKick(context, ref);
                } else if (action == 'ban') {
                  _confirmBan(context, ref);
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(
                  value: 'kick',
                  child: Row(
                    children: [
                      Icon(Iconsax.user_remove, size: 16, color: SColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Remove',
                        style: TextStyle(
                          color: SColors.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'ban',
                  child: Row(
                    children: [
                      Icon(Iconsax.slash, size: 16, color: SColors.error),
                      const SizedBox(width: 8),
                      Text(
                        'Remove & Ban',
                        style: TextStyle(
                          color: SColors.error,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _confirmKick(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusLg),
        ),
        title: Text(
          'Remove participant?',
          style: TextStyle(
            color: isDark ? SColors.textDark : SColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Remove ${participant.name} from this meeting? They can rejoin.',
          style: TextStyle(
            color: isDark
                ? SColors.textDarkSecondary
                : SColors.textLightSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref
                  .read(meetingRepositoryProvider)
                  .kickParticipant(meetingId, participant.id);
              ref.read(activeMeetingProvider.notifier).refreshParticipants();
            },
            child: const Text(
              'Remove',
              style: TextStyle(
                color: SColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBan(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusLg),
        ),
        title: Text(
          'Remove & Ban?',
          style: TextStyle(
            color: isDark ? SColors.textDark : SColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${participant.name} will be removed and cannot rejoin this meeting.',
              style: TextStyle(
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              maxLength: 200,
              style: TextStyle(
                color: isDark ? SColors.textDark : SColors.textLight,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: 'Reason (optional)',
                hintStyle: TextStyle(
                  color: isDark
                      ? SColors.textDarkTertiary
                      : SColors.textLightTertiary,
                  fontSize: 13,
                ),
                filled: true,
                fillColor: isDark ? SColors.darkSurface : SColors.lightElevated,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  borderSide: BorderSide.none,
                ),
                counterStyle: TextStyle(
                  color: isDark
                      ? SColors.textDarkTertiary
                      : SColors.textLightTertiary,
                  fontSize: 11,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final reason = reasonController.text.trim();
              ref.read(meetingRepositoryProvider).kickParticipant(
                    meetingId,
                    participant.id,
                    ban: true,
                    reason: reason.isNotEmpty ? reason : null,
                  );
              ref.read(activeMeetingProvider.notifier).refreshParticipants();
            },
            child: const Text(
              'Ban',
              style: TextStyle(
                color: SColors.error,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
