import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/components/ui/input.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';
import 'package:flutter_conference_speakup/app/domain/repositories/room_repository.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

class ParticipantsScreen extends ConsumerStatefulWidget {
  final String meetingId;

  const ParticipantsScreen({super.key, required this.meetingId});

  @override
  ConsumerState<ParticipantsScreen> createState() => _ParticipantsScreenState();
}

class _ParticipantsScreenState extends ConsumerState<ParticipantsScreen> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final participantsAsync = ref.watch(meetingParticipantsProvider(widget.meetingId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Participants'),
        actions: [
          TextButton(
            onPressed: () async {
              final room = RoomRepository();
              await room.muteAll(widget.meetingId);
              ref.invalidate(meetingParticipantsProvider(widget.meetingId));
            },
            child: const Text('Mute All'),
          ),
        ],
      ),
      body: ResponsiveBody(child: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(meetingParticipantsProvider(widget.meetingId));
        },
        color: SColors.primary,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(SSizes.pagePadding),
              child: SSearchBar(
                hint: 'Search participants...',
                onChanged: (q) => setState(() => _searchQuery = q.toLowerCase()),
              ),
            ),
            Expanded(
              child: participantsAsync.when(
                data: (participants) {
                  final filtered = _searchQuery.isEmpty
                      ? participants
                      : participants.where((p) =>
                          p.name.toLowerCase().contains(_searchQuery)).toList();

                  if (filtered.isEmpty) {
                    return Center(
                      child: Text(
                        _searchQuery.isEmpty ? 'No participants' : 'No matches',
                        style: TextStyle(
                          color: isDark
                              ? SColors.textDarkSecondary
                              : SColors.textLightSecondary,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: SSizes.pagePadding),
                    itemCount: filtered.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 6),
                    itemBuilder: (context, index) {
                      final p = filtered[index];
                      return _ParticipantTile(participant: p, isDark: isDark);
                    },
                  );
                },
                loading: () => const Center(child: CupertinoActivityIndicator()),
                error: (e, _) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Failed to load participants',
                          style: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary)),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => ref.invalidate(meetingParticipantsProvider(widget.meetingId)),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final Participant participant;
  final bool isDark;
  const _ParticipantTile({required this.participant, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightCard,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(
          color: isDark ? SColors.darkBorder : SColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: SColors.primary.withValues(alpha: 0.12),
            backgroundImage: participant.avatar != null
                ? NetworkImage(participant.avatar!)
                : null,
            child: participant.avatar == null
                ? Text(
                    participant.name.isNotEmpty ? participant.name[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: SColors.primary),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  participant.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? SColors.textDark : SColors.textLight,
                  ),
                ),
                Text(
                  participant.role.name[0].toUpperCase() + participant.role.name.substring(1),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (participant.isHandRaised)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.back_hand_rounded, size: 16, color: SColors.warning),
            ),
          if (participant.isScreenSharing)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(Icons.screen_share_rounded, size: 16, color: SColors.info),
            ),
          Icon(
            participant.isMuted ? CupertinoIcons.mic_off : CupertinoIcons.mic_fill,
            size: 16,
            color: participant.isMuted ? SColors.error : SColors.success,
          ),
          const SizedBox(width: 6),
          Icon(
            participant.isCameraOff ? CupertinoIcons.video_camera_solid : CupertinoIcons.video_camera,
            size: 16,
            color: participant.isCameraOff ? SColors.error : SColors.success,
          ),
        ],
    ).animate().fadeIn(duration: 200.ms),
);
  }
}
