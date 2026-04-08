import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/app/domain/models/ai_models.dart';
import 'package:flutter_conference_speakup/app/domain/models/participant_model.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';

/// Active meeting / video call screen with full AI integration.
class MeetingRoomScreen extends ConsumerStatefulWidget {
  final String meetingId;

  const MeetingRoomScreen({super.key, required this.meetingId});

  @override
  ConsumerState<MeetingRoomScreen> createState() => _MeetingRoomScreenState();
}

class _MeetingRoomScreenState extends ConsumerState<MeetingRoomScreen>
    with TickerProviderStateMixin {
  bool _showCopilotPanel = false;
  bool _showVoiceAssistant = false;
  bool _showMoreOptions = false;
  bool _topBarVisible = true;
  final _voiceController = TextEditingController();

  late final AnimationController _copilotSlideController;
  late final AnimationController _voiceAssistantController;

  @override
  void initState() {
    super.initState();
    _copilotSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _voiceAssistantController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    // Start AI listeners
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(meetingAIProvider.notifier).startListening(widget.meetingId);
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    _copilotSlideController.dispose();
    _voiceAssistantController.dispose();
    _voiceController.dispose();
    ref.read(meetingAIProvider.notifier).stopListening();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _toggleCopilotPanel() {
    HapticFeedback.lightImpact();
    setState(() => _showCopilotPanel = !_showCopilotPanel);
    if (_showCopilotPanel) {
      _copilotSlideController.forward();
    } else {
      _copilotSlideController.reverse();
    }
  }

  void _toggleVoiceAssistant() {
    HapticFeedback.lightImpact();
    setState(() => _showVoiceAssistant = !_showVoiceAssistant);
    if (_showVoiceAssistant) {
      _voiceAssistantController.forward();
    } else {
      _voiceAssistantController.reverse();
    }
    ref.read(meetingAIProvider.notifier).toggleVoiceAssistant();
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  void _handleLeave() {
    HapticFeedback.heavyImpact();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: SColors.darkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusLg),
        ),
        title: const Text(
          'Leave Meeting?',
          style: TextStyle(color: SColors.textDark, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Are you sure you want to leave this meeting?',
          style: TextStyle(color: SColors.textDarkSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel', style: TextStyle(color: SColors.textDarkSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(activeMeetingProvider.notifier).leaveMeeting();
              Navigator.of(context).pop();
            },
            child: const Text('Leave', style: TextStyle(color: SColors.callEnd, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final meetingState = ref.watch(activeMeetingProvider);
    final aiState = ref.watch(meetingAIProvider);

    return Scaffold(
      backgroundColor: SColors.darkBg,
      body: GestureDetector(
        onTap: () => setState(() => _topBarVisible = !_topBarVisible),
        child: Stack(
          children: [
            // ── Main content column ──
            Column(
              children: [
                // Top bar
                AnimatedSlide(
                  offset: _topBarVisible ? Offset.zero : const Offset(0, -1),
                  duration: const Duration(milliseconds: 200),
                  child: AnimatedOpacity(
                    opacity: _topBarVisible ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: _TopBar(
                      meetingId: widget.meetingId,
                      elapsed: meetingState.elapsed,
                      participantCount: meetingState.participants.length,
                      isRecording: meetingState.isRecording,
                      formatDuration: _formatDuration,
                      aiState: aiState,
                      onToggleRecording: () =>
                          ref.read(activeMeetingProvider.notifier).toggleRecording(),
                    ),
                  ),
                ),

                // Coaching hint banner
                if (aiState.isCoachingEnabled && aiState.coachingHints.isNotEmpty)
                  _CoachingBanner(hint: aiState.coachingHints.last),

                // Video grid
                Expanded(
                  child: _VideoGrid(
                    participants: meetingState.participants,
                    emotions: aiState.emotions,
                    isCameraOn: meetingState.isCameraOn,
                    isMicOn: meetingState.isMicOn,
                  ),
                ),

                // Transcription overlay
                if (aiState.isTranscriptionEnabled && aiState.transcription.isNotEmpty)
                  _TranscriptionOverlay(segments: aiState.transcription),

                // Controls bar
                _ControlsBar(
                  meetingState: meetingState,
                  aiState: aiState,
                  showCopilot: _showCopilotPanel,
                  onToggleMic: () =>
                      ref.read(activeMeetingProvider.notifier).toggleMic(),
                  onToggleCamera: () =>
                      ref.read(activeMeetingProvider.notifier).toggleCamera(),
                  onToggleScreenShare: () =>
                      ref.read(activeMeetingProvider.notifier).toggleScreenShare(),
                  onToggleHandRaise: () =>
                      ref.read(activeMeetingProvider.notifier).toggleHandRaise(),
                  onToggleCopilot: _toggleCopilotPanel,
                  onToggleVoiceAssistant: _toggleVoiceAssistant,
                  onMore: () => setState(() => _showMoreOptions = !_showMoreOptions),
                  onLeave: _handleLeave,
                ),
              ],
            ),

            // ── AI Copilot sliding panel ──
            if (_showCopilotPanel)
              Positioned(
                right: 0,
                top: 0,
                bottom: SSizes.controlBarHeight + MediaQuery.of(context).padding.bottom,
                width: MediaQuery.of(context).size.width * 0.85,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _copilotSlideController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: _CopilotPanel(
                    aiState: aiState,
                    meetingId: widget.meetingId,
                    onClose: _toggleCopilotPanel,
                    onDismiss: (id) =>
                        ref.read(meetingAIProvider.notifier).dismissSuggestion(id),
                    onRequestSummary: () =>
                        ref.read(meetingAIProvider.notifier).requestSummary(widget.meetingId),
                  ),
                ),
              ),

            // ── Voice command assistant overlay ──
            if (_showVoiceAssistant)
              Positioned(
                left: SSizes.md,
                right: SSizes.md,
                bottom: SSizes.controlBarHeight + MediaQuery.of(context).padding.bottom + SSizes.md,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _voiceAssistantController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: _VoiceAssistantSheet(
                    controller: _voiceController,
                    lastResult: aiState.lastVoiceCommand,
                    onSend: (text) {
                      ref.read(meetingAIProvider.notifier)
                          .sendVoiceCommand(text, widget.meetingId);
                      _voiceController.clear();
                    },
                    onConfirm: (parsed) {
                      ref.read(meetingAIProvider.notifier)
                          .confirmVoiceCommand(widget.meetingId, parsed);
                    },
                    onClose: _toggleVoiceAssistant,
                  ),
                ),
              ),

            // ── More options bottom sheet ──
            if (_showMoreOptions)
              _MoreOptionsOverlay(
                meetingState: meetingState,
                aiState: aiState,
                onClose: () => setState(() => _showMoreOptions = false),
                onToggleTranscription: () =>
                    ref.read(meetingAIProvider.notifier).toggleTranscription(),
                onToggleCoaching: () =>
                    ref.read(meetingAIProvider.notifier).toggleCoaching(),
                onToggleCopilot: () =>
                    ref.read(meetingAIProvider.notifier).toggleCopilot(),
                onToggleRecording: () =>
                    ref.read(activeMeetingProvider.notifier).toggleRecording(),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// TOP BAR
// ═══════════════════════════════════════════════════════════════════

class _TopBar extends StatelessWidget {
  final String meetingId;
  final Duration elapsed;
  final int participantCount;
  final bool isRecording;
  final String Function(Duration) formatDuration;
  final MeetingAIState aiState;
  final VoidCallback onToggleRecording;

  const _TopBar({
    required this.meetingId,
    required this.elapsed,
    required this.participantCount,
    required this.isRecording,
    required this.formatDuration,
    required this.aiState,
    required this.onToggleRecording,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + SSizes.xs,
        left: SSizes.md,
        right: SSizes.sm,
        bottom: SSizes.sm,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [SColors.darkBg, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          // Encrypted badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: SColors.darkCard.withOpacity(0.8),
              borderRadius: BorderRadius.circular(SSizes.radiusFull),
              border: Border.all(color: SColors.darkBorder, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.lock_outline, color: SColors.success, size: 12),
                const SizedBox(width: 4),
                Text(
                  meetingId.length > 8 ? '${meetingId.substring(0, 8)}…' : meetingId,
                  style: const TextStyle(
                    color: SColors.textDarkSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: SSizes.sm),

          // Duration
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: SColors.darkCard.withOpacity(0.8),
              borderRadius: BorderRadius.circular(SSizes.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isRecording) ...[
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: SColors.error,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat()).fadeIn(duration: 600.ms).then().fadeOut(duration: 600.ms),
                  const SizedBox(width: 6),
                ],
                Text(
                  formatDuration(elapsed),
                  style: TextStyle(
                    color: isRecording ? SColors.error : SColors.textDark,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),

          const Spacer(),

          // AI active indicators
          if (aiState.isCopilotEnabled)
            _TopBarChip(
              icon: Iconsax.cpu,
              label: 'AI',
              color: SColors.screenShare,
            ),

          if (aiState.isTranscriptionEnabled)
            _TopBarChip(
              icon: Iconsax.subtitle,
              label: 'CC',
              color: SColors.info,
            ),

          // Participants
          _TopBarIconButton(
            icon: Iconsax.people,
            badge: participantCount > 0 ? '$participantCount' : null,
            onTap: () {},
          ),

          // Chat
          _TopBarIconButton(
            icon: Iconsax.message,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _TopBarChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _TopBarChip({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(SSizes.radiusFull),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  const _TopBarIconButton({required this.icon, this.badge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Icon(icon, color: SColors.textDark, size: 22),
            if (badge != null)
              Positioned(
                right: -6,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: SColors.primary,
                    borderRadius: BorderRadius.circular(SSizes.radiusFull),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// COACHING HINT BANNER
// ═══════════════════════════════════════════════════════════════════

class _CoachingBanner extends StatelessWidget {
  final CoachingHint hint;

  const _CoachingBanner({required this.hint});

  IconData get _icon => switch (hint.type) {
        CoachingType.pace => Iconsax.speedometer,
        CoachingType.clarity => Iconsax.lamp_on,
        CoachingType.volume => Iconsax.volume_high,
        CoachingType.filler => Iconsax.message_remove,
        CoachingType.pause => Iconsax.pause,
        CoachingType.engagement => Iconsax.people,
      };

  Color get _color => switch (hint.severity) {
        'high' => SColors.warning,
        'medium' => SColors.info,
        _ => SColors.textDarkSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.xs),
      padding: const EdgeInsets.symmetric(horizontal: SSizes.sm + 4, vertical: SSizes.sm),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(color: _color.withOpacity(0.25), width: 0.5),
      ),
      child: Row(
        children: [
          Icon(_icon, size: 16, color: _color),
          const SizedBox(width: SSizes.sm),
          Expanded(
            child: Text(
              hint.message,
              style: TextStyle(color: _color, fontSize: 12, fontWeight: FontWeight.w500),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(begin: -0.3);
  }
}

// ═══════════════════════════════════════════════════════════════════
// VIDEO GRID
// ═══════════════════════════════════════════════════════════════════

class _VideoGrid extends StatelessWidget {
  final List<Participant> participants;
  final Map<String, EmotionSignal> emotions;
  final bool isCameraOn;
  final bool isMicOn;

  const _VideoGrid({
    required this.participants,
    required this.emotions,
    required this.isCameraOn,
    required this.isMicOn,
  });

  @override
  Widget build(BuildContext context) {
    final totalParticipants = participants.length + 1; // +1 for self
    final crossAxisCount = totalParticipants <= 1
        ? 1
        : totalParticipants <= 4
            ? 2
            : 3;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: SSizes.sm, vertical: SSizes.xs),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          mainAxisSpacing: SSizes.sm,
          crossAxisSpacing: SSizes.sm,
          childAspectRatio: totalParticipants <= 1 ? 0.75 : 4 / 3,
        ),
        itemCount: totalParticipants,
        itemBuilder: (context, index) {
          if (index == 0) {
            // Local user tile
            return _ParticipantTile(
              name: 'You',
              isSelf: true,
              isCameraOn: isCameraOn,
              isMicOn: isMicOn,
              emotion: null,
            );
          }
          final participant = participants[index - 1];
          return _ParticipantTile(
            name: participant.name,
            avatarUrl: participant.avatar,
            isSelf: false,
            isCameraOn: !participant.isCameraOff,
            isMicOn: !participant.isMuted,
            emotion: emotions[participant.userId],
          );
        },
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  final String name;
  final String? avatarUrl;
  final bool isSelf;
  final bool isCameraOn;
  final bool isMicOn;
  final EmotionSignal? emotion;

  const _ParticipantTile({
    required this.name,
    this.avatarUrl,
    required this.isSelf,
    required this.isCameraOn,
    required this.isMicOn,
    this.emotion,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: SColors.participantTile,
        borderRadius: BorderRadius.circular(SSizes.tileRadius),
        border: isSelf
            ? Border.all(color: SColors.primary.withOpacity(0.3), width: 1.5)
            : null,
      ),
      child: Stack(
        children: [
          // Camera off / avatar placeholder
          Center(
            child: isCameraOn
                ? Container(
                    decoration: BoxDecoration(
                      color: SColors.darkElevated,
                      borderRadius: BorderRadius.circular(SSizes.tileRadius),
                    ),
                    child: Center(
                      child: CircleAvatar(
                        radius: 28,
                        backgroundColor: SColors.primary.withOpacity(0.2),
                        backgroundImage:
                            avatarUrl != null ? NetworkImage(avatarUrl!) : null,
                        child: avatarUrl == null
                            ? Text(
                                name.isNotEmpty ? name[0].toUpperCase() : '?',
                                style: const TextStyle(
                                  color: SColors.primary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : null,
                      ),
                    ),
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: SColors.darkElevated,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(
                            color: SColors.textDark,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Icon(
                        Iconsax.video_slash,
                        size: 14,
                        color: SColors.textDarkTertiary,
                      ),
                    ],
                  ),
          ),

          // Name label (bottom left)
          Positioned(
            left: SSizes.sm,
            bottom: SSizes.sm,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isMicOn) ...[
                    Icon(Iconsax.microphone_slash, size: 11, color: SColors.micOff),
                    const SizedBox(width: 4),
                  ],
                  Text(
                    isSelf ? 'You' : name,
                    style: const TextStyle(
                      color: SColors.textDark,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Emotion badge (top right)
          if (emotion != null)
            Positioned(
              right: SSizes.sm,
              top: SSizes.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(SSizes.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(emotion!.emoji, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 3),
                    SizedBox(
                      width: 20,
                      height: 4,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(2),
                        child: LinearProgressIndicator(
                          value: emotion!.engagementScore,
                          backgroundColor: SColors.darkBorder,
                          valueColor: AlwaysStoppedAnimation(
                            emotion!.engagementScore > 0.6
                                ? SColors.success
                                : emotion!.engagementScore > 0.3
                                    ? SColors.warning
                                    : SColors.error,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(duration: 200.ms).scale(begin: const Offset(0.8, 0.8)),
            ),

          // Self badge
          if (isSelf)
            Positioned(
              right: SSizes.sm,
              top: SSizes.sm,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: SColors.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(SSizes.radiusFull),
                  border: Border.all(color: SColors.primary.withOpacity(0.4), width: 0.5),
                ),
                child: const Text(
                  'You',
                  style: TextStyle(
                    color: SColors.primary,
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// LIVE TRANSCRIPTION OVERLAY
// ═══════════════════════════════════════════════════════════════════

class _TranscriptionOverlay extends StatelessWidget {
  final List<TranscriptionSegment> segments;

  const _TranscriptionOverlay({required this.segments});

  @override
  Widget build(BuildContext context) {
    // Show last 3 segments
    final recent = segments.length > 3 ? segments.sublist(segments.length - 3) : segments;

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: SSizes.md),
      padding: const EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.sm + 2),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.75),
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(color: SColors.darkBorder.withOpacity(0.5), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // CC indicator
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: SColors.info.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(3),
                ),
                child: const Text(
                  'CC',
                  style: TextStyle(
                    color: SColors.info,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              Icon(Iconsax.subtitle, size: 12, color: SColors.textDarkTertiary),
            ],
          ),
          const SizedBox(height: 4),
          ...recent.map((seg) => Padding(
                padding: const EdgeInsets.only(bottom: 2),
                child: RichText(
                  text: TextSpan(
                    children: [
                      if (seg.speakerName != null)
                        TextSpan(
                          text: '${seg.speakerName}: ',
                          style: const TextStyle(
                            color: SColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      TextSpan(
                        text: seg.text,
                        style: TextStyle(
                          color: seg.isFinal
                              ? SColors.textDark
                              : SColors.textDarkSecondary,
                          fontSize: 12,
                          fontStyle:
                              seg.isFinal ? FontStyle.normal : FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              )),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms);
  }
}

// ═══════════════════════════════════════════════════════════════════
// CONTROLS BAR
// ═══════════════════════════════════════════════════════════════════

class _ControlsBar extends StatelessWidget {
  final MeetingRoomState meetingState;
  final MeetingAIState aiState;
  final bool showCopilot;
  final VoidCallback onToggleMic;
  final VoidCallback onToggleCamera;
  final VoidCallback onToggleScreenShare;
  final VoidCallback onToggleHandRaise;
  final VoidCallback onToggleCopilot;
  final VoidCallback onToggleVoiceAssistant;
  final VoidCallback onMore;
  final VoidCallback onLeave;

  const _ControlsBar({
    required this.meetingState,
    required this.aiState,
    required this.showCopilot,
    required this.onToggleMic,
    required this.onToggleCamera,
    required this.onToggleScreenShare,
    required this.onToggleHandRaise,
    required this.onToggleCopilot,
    required this.onToggleVoiceAssistant,
    required this.onMore,
    required this.onLeave,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        left: SSizes.md,
        right: SSizes.md,
        top: SSizes.sm + 4,
        bottom: MediaQuery.of(context).padding.bottom + SSizes.sm,
      ),
      decoration: BoxDecoration(
        color: SColors.darkSurface,
        border: Border(top: BorderSide(color: SColors.darkBorder.withOpacity(0.5))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _ControlBtn(
            icon: meetingState.isMicOn ? SIcons.micOn : SIcons.micOff,
            label: meetingState.isMicOn ? 'Mute' : 'Unmute',
            isActive: meetingState.isMicOn,
            activeColor: SColors.micOn,
            inactiveColor: SColors.micOff,
            onTap: onToggleMic,
          ),
          _ControlBtn(
            icon: meetingState.isCameraOn ? SIcons.cameraOn : SIcons.cameraOff,
            label: 'Camera',
            isActive: meetingState.isCameraOn,
            activeColor: SColors.cameraOn,
            inactiveColor: SColors.cameraOff,
            onTap: onToggleCamera,
          ),
          _ControlBtn(
            icon: meetingState.isScreenSharing
                ? SIcons.stopScreenShare
                : SIcons.screenShare,
            label: 'Share',
            isActive: meetingState.isScreenSharing,
            activeColor: SColors.screenShare,
            onTap: onToggleScreenShare,
          ),
          _ControlBtn(
            icon: Iconsax.cpu,
            label: 'Copilot',
            isActive: showCopilot,
            activeColor: SColors.screenShare,
            hasDot: aiState.suggestions.where((s) => !s.isDismissed).isNotEmpty,
            onTap: onToggleCopilot,
          ),
          _ControlBtn(
            icon: Iconsax.microphone_2,
            label: 'Voice',
            isActive: aiState.isVoiceAssistantActive,
            activeColor: SColors.warning,
            onTap: onToggleVoiceAssistant,
          ),
          _ControlBtn(
            icon: SIcons.moreOptions,
            label: 'More',
            isActive: false,
            onTap: onMore,
          ),
          // Leave button
          GestureDetector(
            onTap: onLeave,
            child: Container(
              width: 52,
              height: 40,
              decoration: BoxDecoration(
                color: SColors.callEnd,
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
              ),
              child: const Icon(
                SIcons.callEnd,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final Color inactiveColor;
  final bool hasDot;
  final VoidCallback onTap;

  const _ControlBtn({
    required this.icon,
    required this.label,
    required this.isActive,
    this.activeColor = SColors.textDark,
    this.inactiveColor = SColors.textDarkTertiary,
    this.hasDot = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 48,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                        ? activeColor.withOpacity(0.15)
                        : SColors.darkElevated,
                    shape: BoxShape.circle,
                    border: isActive
                        ? Border.all(color: activeColor.withOpacity(0.4), width: 1)
                        : null,
                  ),
                  child: Icon(
                    icon,
                    size: 18,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                ),
                if (hasDot)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: SColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: SColors.darkSurface, width: 1.5),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isActive ? activeColor : SColors.textDarkTertiary,
                fontSize: 9,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// AI COPILOT PANEL (slides from right)
// ═══════════════════════════════════════════════════════════════════

class _CopilotPanel extends StatelessWidget {
  final MeetingAIState aiState;
  final String meetingId;
  final VoidCallback onClose;
  final ValueChanged<String> onDismiss;
  final VoidCallback onRequestSummary;

  const _CopilotPanel({
    required this.aiState,
    required this.meetingId,
    required this.onClose,
    required this.onDismiss,
    required this.onRequestSummary,
  });

  @override
  Widget build(BuildContext context) {
    final activeSuggestions =
        aiState.suggestions.where((s) => !s.isDismissed).toList().reversed.toList();

    return Container(
      decoration: BoxDecoration(
        color: SColors.darkSurface,
        borderRadius:
            const BorderRadius.only(topLeft: Radius.circular(SSizes.radiusXl)),
        border: Border(
          left: BorderSide(color: SColors.darkBorder.withOpacity(0.5)),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(-4, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + SSizes.sm,
              left: SSizes.md,
              right: SSizes.sm,
              bottom: SSizes.sm,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: SColors.accentGradient,
                    borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  ),
                  child: const Icon(Iconsax.cpu, size: 18, color: Colors.white),
                ),
                const SizedBox(width: SSizes.sm + 2),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'AI Copilot',
                        style: TextStyle(
                          color: SColors.textDark,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Real-time suggestions',
                        style: TextStyle(
                          color: SColors.textDarkTertiary,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: SColors.textDarkSecondary, size: 20),
                ),
              ],
            ),
          ),

          Divider(height: 1, color: SColors.darkBorder.withOpacity(0.5)),

          // Tabs / content
          Expanded(
            child: activeSuggestions.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.cpu,
                          size: 40,
                          color: SColors.textDarkTertiary.withOpacity(0.4),
                        ),
                        const SizedBox(height: SSizes.sm),
                        const Text(
                          'Listening for insights…',
                          style: TextStyle(
                            color: SColors.textDarkTertiary,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(SSizes.sm),
                    itemCount: activeSuggestions.length,
                    itemBuilder: (context, index) {
                      final suggestion = activeSuggestions[index];
                      return _SuggestionCard(
                        suggestion: suggestion,
                        onDismiss: () => onDismiss(suggestion.id),
                      );
                    },
                  ),
          ),

          // Action items section
          if (aiState.actionItems.isNotEmpty)
            _ActionItemsPreview(items: aiState.actionItems),

          // Summary button
          Padding(
            padding: const EdgeInsets.all(SSizes.sm),
            child: GestureDetector(
              onTap: onRequestSummary,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: SSizes.sm + 2),
                decoration: BoxDecoration(
                  color: SColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                  border: Border.all(
                    color: SColors.primary.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Iconsax.document_text, size: 16, color: SColors.primary),
                    SizedBox(width: 6),
                    Text(
                      'Generate Summary',
                      style: TextStyle(
                        color: SColors.primary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final CopilotSuggestion suggestion;
  final VoidCallback onDismiss;

  const _SuggestionCard({required this.suggestion, required this.onDismiss});

  IconData get _icon => switch (suggestion.type) {
        SuggestionType.talkingPoint => Iconsax.message_text,
        SuggestionType.question => Iconsax.message_question,
        SuggestionType.insight => Iconsax.lamp_on,
        SuggestionType.warning => Iconsax.warning_2,
        SuggestionType.followUp => Iconsax.arrow_right_1,
      };

  Color get _color => switch (suggestion.type) {
        SuggestionType.talkingPoint => SColors.primary,
        SuggestionType.question => SColors.info,
        SuggestionType.insight => SColors.screenShare,
        SuggestionType.warning => SColors.warning,
        SuggestionType.followUp => SColors.success,
      };

  String get _label => switch (suggestion.type) {
        SuggestionType.talkingPoint => 'Talking Point',
        SuggestionType.question => 'Question',
        SuggestionType.insight => 'Insight',
        SuggestionType.warning => 'Warning',
        SuggestionType.followUp => 'Follow Up',
      };

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(suggestion.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => onDismiss(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: SSizes.md),
        decoration: BoxDecoration(
          color: SColors.error.withOpacity(0.15),
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
        ),
        child: const Icon(Icons.close, color: SColors.error, size: 20),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: SSizes.sm),
        padding: const EdgeInsets.all(SSizes.sm + 2),
        decoration: BoxDecoration(
          color: SColors.darkCard,
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          border: Border.all(
            color: _color.withOpacity(0.2),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: _color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(_icon, size: 14, color: _color),
                ),
                const SizedBox(width: SSizes.sm),
                Text(
                  _label,
                  style: TextStyle(
                    color: _color,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const Spacer(),
                // Confidence indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: SColors.darkElevated,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${(suggestion.confidence * 100).toInt()}%',
                    style: const TextStyle(
                      color: SColors.textDarkTertiary,
                      fontSize: 9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: SSizes.sm),
            Text(
              suggestion.text,
              style: const TextStyle(
                color: SColors.textDark,
                fontSize: 13,
                height: 1.4,
              ),
            ),
            if (suggestion.context != null) ...[
              const SizedBox(height: 4),
              Text(
                suggestion.context!,
                style: const TextStyle(
                  color: SColors.textDarkTertiary,
                  fontSize: 11,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(begin: 0.1);
  }
}

class _ActionItemsPreview extends StatelessWidget {
  final List<ActionItem> items;

  const _ActionItemsPreview({required this.items});

  @override
  Widget build(BuildContext context) {
    final recent = items.length > 3 ? items.sublist(items.length - 3) : items;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: SSizes.sm),
      padding: const EdgeInsets.all(SSizes.sm + 2),
      decoration: BoxDecoration(
        color: SColors.darkCard,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(color: SColors.success.withOpacity(0.2), width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.task_square, size: 14, color: SColors.success),
              const SizedBox(width: 6),
              Text(
                'Action Items (${items.length})',
                style: const TextStyle(
                  color: SColors.success,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: SSizes.sm),
          ...recent.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: item.priority == 'high'
                            ? SColors.error
                            : item.priority == 'medium'
                                ? SColors.warning
                                : SColors.textDarkTertiary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.text,
                        style: const TextStyle(
                          color: SColors.textDarkSecondary,
                          fontSize: 11,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// VOICE ASSISTANT SHEET
// ═══════════════════════════════════════════════════════════════════

class _VoiceAssistantSheet extends StatelessWidget {
  final TextEditingController controller;
  final VoiceCommandResult? lastResult;
  final ValueChanged<String> onSend;
  final ValueChanged<Map<String, dynamic>> onConfirm;
  final VoidCallback onClose;

  const _VoiceAssistantSheet({
    required this.controller,
    this.lastResult,
    required this.onSend,
    required this.onConfirm,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(SSizes.md),
      decoration: BoxDecoration(
        color: SColors.darkSurface,
        borderRadius: BorderRadius.circular(SSizes.radiusXl),
        border: Border.all(color: SColors.darkBorder.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: SColors.warning.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(SSizes.radiusMd),
                ),
                child: const Icon(Iconsax.microphone_2, size: 18, color: SColors.warning),
              ),
              const SizedBox(width: SSizes.sm + 2),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Voice Assistant',
                      style: TextStyle(
                        color: SColors.textDark,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Type or speak a command',
                      style: TextStyle(
                        color: SColors.textDarkTertiary,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: SColors.textDarkSecondary, size: 20),
              ),
            ],
          ),

          const SizedBox(height: SSizes.sm + 4),

          // Last result
          if (lastResult != null) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(SSizes.sm + 2),
              decoration: BoxDecoration(
                color: SColors.darkCard,
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
                border: Border.all(color: SColors.darkBorder, width: 0.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: lastResult!.status == 'executed'
                              ? SColors.success
                              : lastResult!.status == 'failed'
                                  ? SColors.error
                                  : SColors.warning,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        lastResult!.status.toUpperCase(),
                        style: TextStyle(
                          color: SColors.textDarkTertiary,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                  if (lastResult!.command != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lastResult!.command!,
                      style: const TextStyle(
                        color: SColors.textDarkSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  if (lastResult!.result != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      lastResult!.result!,
                      style: const TextStyle(
                        color: SColors.textDark,
                        fontSize: 13,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (lastResult!.needsConfirmation &&
                      lastResult!.parsedParameters != null) ...[
                    const SizedBox(height: SSizes.sm),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => onConfirm(lastResult!.parsedParameters!),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: SColors.success.withOpacity(0.15),
                                borderRadius:
                                    BorderRadius.circular(SSizes.radiusSm),
                                border: Border.all(
                                    color: SColors.success.withOpacity(0.3)),
                              ),
                              child: const Center(
                                child: Text(
                                  'Confirm',
                                  style: TextStyle(
                                    color: SColors.success,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: SSizes.sm),
                        Expanded(
                          child: GestureDetector(
                            onTap: onClose,
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color: SColors.darkElevated,
                                borderRadius:
                                    BorderRadius.circular(SSizes.radiusSm),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: SColors.textDarkSecondary,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: SSizes.sm + 2),
          ],

          // Input
          Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: SColors.darkCard,
                    borderRadius: BorderRadius.circular(SSizes.radiusFull),
                    border: Border.all(color: SColors.darkBorder, width: 0.5),
                  ),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(color: SColors.textDark, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'e.g. "Summarize the last 5 minutes"',
                      hintStyle:
                          TextStyle(color: SColors.textDarkTertiary, fontSize: 13),
                      border: InputBorder.none,
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: SSizes.md, vertical: SSizes.sm + 2),
                    ),
                    onSubmitted: (text) {
                      if (text.trim().isNotEmpty) onSend(text.trim());
                    },
                  ),
                ),
              ),
              const SizedBox(width: SSizes.sm),
              GestureDetector(
                onTap: () {
                  final text = controller.text.trim();
                  if (text.isNotEmpty) onSend(text);
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: const BoxDecoration(
                    gradient: SColors.accentGradient,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Iconsax.send_1, size: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MORE OPTIONS OVERLAY
// ═══════════════════════════════════════════════════════════════════

class _MoreOptionsOverlay extends StatelessWidget {
  final MeetingRoomState meetingState;
  final MeetingAIState aiState;
  final VoidCallback onClose;
  final VoidCallback onToggleTranscription;
  final VoidCallback onToggleCoaching;
  final VoidCallback onToggleCopilot;
  final VoidCallback onToggleRecording;

  const _MoreOptionsOverlay({
    required this.meetingState,
    required this.aiState,
    required this.onClose,
    required this.onToggleTranscription,
    required this.onToggleCoaching,
    required this.onToggleCopilot,
    required this.onToggleRecording,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onClose,
      child: Container(
        color: Colors.black.withOpacity(0.5),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: GestureDetector(
            onTap: () {}, // absorb taps
            child: Container(
              margin: EdgeInsets.only(
                bottom: SSizes.controlBarHeight +
                    MediaQuery.of(context).padding.bottom +
                    SSizes.sm,
              ),
              padding: const EdgeInsets.all(SSizes.md),
              width: MediaQuery.of(context).size.width - SSizes.xl,
              decoration: BoxDecoration(
                color: SColors.darkSurface,
                borderRadius: BorderRadius.circular(SSizes.radiusXl),
                border: Border.all(color: SColors.darkBorder.withOpacity(0.5)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: SColors.darkBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: SSizes.md),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'AI Features',
                      style: TextStyle(
                        color: SColors.textDarkTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: SSizes.sm),

                  _OptionToggle(
                    icon: Iconsax.subtitle,
                    label: 'Live Transcription',
                    isActive: aiState.isTranscriptionEnabled,
                    onTap: onToggleTranscription,
                  ),
                  _OptionToggle(
                    icon: Iconsax.cpu,
                    label: 'AI Copilot',
                    isActive: aiState.isCopilotEnabled,
                    onTap: onToggleCopilot,
                  ),
                  _OptionToggle(
                    icon: Iconsax.teacher,
                    label: 'Speaking Coach',
                    isActive: aiState.isCoachingEnabled,
                    onTap: onToggleCoaching,
                  ),

                  const SizedBox(height: SSizes.sm),
                  Divider(height: 1, color: SColors.darkBorder.withOpacity(0.5)),
                  const SizedBox(height: SSizes.sm),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Meeting',
                      style: TextStyle(
                        color: SColors.textDarkTertiary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  const SizedBox(height: SSizes.sm),

                  _OptionToggle(
                    icon: SIcons.record,
                    label: 'Recording',
                    isActive: meetingState.isRecording,
                    activeColor: SColors.error,
                    onTap: onToggleRecording,
                  ),
                  _OptionRow(
                    icon: SIcons.flipCamera,
                    label: 'Flip Camera',
                    onTap: () {},
                  ),
                  _OptionRow(
                    icon: SIcons.share,
                    label: 'Share Meeting Link',
                    onTap: () {},
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 150.ms).slideY(begin: 0.15),
          ),
        ),
      ),
    );
  }
}

class _OptionToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;

  const _OptionToggle({
    required this.icon,
    required this.label,
    required this.isActive,
    this.activeColor = SColors.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SSizes.sm + 2),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: isActive
                    ? activeColor.withOpacity(0.12)
                    : SColors.darkElevated,
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: Icon(
                icon,
                size: 16,
                color: isActive ? activeColor : SColors.textDarkTertiary,
              ),
            ),
            const SizedBox(width: SSizes.sm + 4),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: SColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(
              width: 44,
              height: 26,
              child: Switch.adaptive(
                value: isActive,
                onChanged: (_) {
                  HapticFeedback.selectionClick();
                  onTap();
                },
                activeColor: activeColor,
                activeTrackColor: activeColor.withOpacity(0.3),
                inactiveThumbColor: SColors.textDarkTertiary,
                inactiveTrackColor: SColors.darkElevated,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OptionRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionRow({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: SSizes.sm + 2),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: SColors.darkElevated,
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: Icon(icon, size: 16, color: SColors.textDarkSecondary),
            ),
            const SizedBox(width: SSizes.sm + 4),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  color: SColors.textDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Iconsax.arrow_right_3,
              size: 16,
              color: SColors.textDarkTertiary,
            ),
          ],
        ),
      ),
    );
  }
}
