import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_conference_speakup/core/services/websocket.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/store/ai_provider.dart';
import 'package:flutter_conference_speakup/store/auth_provider.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/meeting_chat_sheet.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/meeting_participants_sheet.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/room_top_bar.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/room_video_grid.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/room_controls_bar.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/room_coaching_banner.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/room_transcription_overlay.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/room_copilot_panel.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/room_voice_assistant_sheet.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/room_more_options_overlay.dart';

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
  bool _isFrontCamera = true;
  final _voiceController = TextEditingController();
  StreamSubscription? _meetingEndedSub;
  StreamSubscription? _kickedSub;
  StreamSubscription? _bannedSub;

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
    // Listen for meeting:ended from WebSocket (e.g. auto-end on 2-person call,
    // or host ended the meeting)
    _meetingEndedSub = WebSocketService()
        .stream('meeting:ended')
        .listen(_onMeetingEnded);
    // Listen for kick/ban events targeting this user
    _kickedSub = WebSocketService()
        .stream('participant:kicked')
        .listen(_onKickedOrBanned);
    _bannedSub = WebSocketService()
        .stream('participant:banned')
        .listen(_onKickedOrBanned);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ));
  }

  void _onMeetingEnded(dynamic data) {
    // Only react if this event is for our current meeting
    if (data is Map && data['meetingId'] == widget.meetingId) {
      // Local-only cleanup — backend already ended the meeting
      ref.read(activeMeetingProvider.notifier).cleanupLocal();
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              data['reason'] == 'call_ended'
                  ? 'Call ended'
                  : 'Meeting has ended',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _onKickedOrBanned(dynamic data) {
    if (data is Map && data['meetingId'] == widget.meetingId) {
      ref.read(activeMeetingProvider.notifier).cleanupLocal();
      if (mounted) {
        Navigator.of(context).pop();
        final isBanned = data['banned'] == true ||
            data['reason'] != null;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isBanned
                  ? 'You have been banned from this meeting'
                  : 'You have been removed from this meeting',
            ),
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _meetingEndedSub?.cancel();
    _kickedSub?.cancel();
    _bannedSub?.cancel();
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
    final meetingState = ref.read(activeMeetingProvider);
    // +1 for self — participants list is other people
    final totalInCall = meetingState.participants.length + 1;
    final isTwoPersonCall = totalInCall <= 2;
    final title = isTwoPersonCall ? 'End Call?' : 'Leave Meeting?';
    final message = isTwoPersonCall
        ? 'This will end the call for both participants.'
        : 'The meeting will continue for other participants.';
    final actionLabel = isTwoPersonCall ? 'End Call' : 'Leave';

    showDialog(
      context: context,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return AlertDialog(
          backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SSizes.radiusLg),
          ),
          title: Text(
            title,
            style: TextStyle(
              color: isDark ? SColors.textDark : SColors.textLight,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            message,
            style: TextStyle(
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
              fontSize: 14,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'Cancel',
                style: TextStyle(
                  color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ref.read(activeMeetingProvider.notifier).leaveMeeting();
                if (context.mounted) Navigator.of(context).pop();
              },
              child: Text(actionLabel, style: const TextStyle(color: SColors.callEnd, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final meetingState = ref.watch(activeMeetingProvider);
    final aiState = ref.watch(meetingAIProvider);
    final currentUser = ref.watch(currentUserProvider).valueOrNull;
    final isHost = meetingState.meeting?.hostId == currentUser?.id;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final topPad = MediaQuery.of(context).padding.top;
    // Responsive inset so controls/top bar aren't glued to screen edges
    final controlsBottom = bottomPad + SResponsive.sp(context, 12, tabletSize: 20, desktopSize: 24);
    final controlsBarH = SResponsive.sp(context, 72, tabletSize: 80, desktopSize: 84);

    return Scaffold(
      backgroundColor: isDark ? SColors.participantTile : SColors.participantTileLight,
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () => setState(() => _topBarVisible = !_topBarVisible),
        child: Stack(
          children: [
            // ── Full-screen video grid (edge-to-edge behind everything) ──
            Positioned.fill(
              child: RoomVideoGrid(
                participants: meetingState.participants,
                emotions: aiState.emotions,
                isCameraOn: meetingState.isCameraOn,
                isMicOn: meetingState.isMicOn,
                isDark: isDark,
              ),
            ),

            // ── Top bar overlay (gradient fade on top of video) ──
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: AnimatedSlide(
                offset: _topBarVisible ? Offset.zero : const Offset(0, -1),
                duration: const Duration(milliseconds: 200),
                child: AnimatedOpacity(
                  opacity: _topBarVisible ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: RoomTopBar(
                  meetingId: widget.meetingId,
                  elapsed: meetingState.elapsed,
                  participantCount: meetingState.participants.length,
                  isRecording: meetingState.isRecording,
                  formatDuration: _formatDuration,
                  aiState: aiState,
                  isDark: isDark,
                  onToggleRecording: () =>
                      ref.read(activeMeetingProvider.notifier).toggleRecording(),
                  onTapParticipants: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => MeetingParticipantsSheet(
                        meetingId: widget.meetingId,
                        participants: meetingState.participants,
                        isHost: isHost,
                        onClose: () => Navigator.pop(context),
                      ),
                    );
                  },
                  onTapChat: () {
                    HapticFeedback.lightImpact();
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useRootNavigator: true,
                      backgroundColor: Colors.transparent,
                      builder: (_) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.65,
                        child: MeetingChatSheet(
                          meetingId: widget.meetingId,
                          onClose: () => Navigator.pop(context),
                        ),
                      ),
                    );
                  },
                ),
              ),
              ),
            ),

            // ── Coaching hint banner (below top bar area) ──
            if (aiState.isCoachingEnabled && aiState.coachingHints.isNotEmpty)
              Positioned(
                top: topPad + SResponsive.sp(context, 60, tabletSize: 72),
                left: 0,
                right: 0,
                child: RoomCoachingBanner(hint: aiState.coachingHints.last, isDark: isDark),
              ),

            // ── Transcription overlay (above controls, like movie subtitles) ──
            if (aiState.isTranscriptionEnabled && aiState.transcription.isNotEmpty)
              Positioned(
                left: SResponsive.pagePadding(context),
                right: SResponsive.pagePadding(context),
                bottom: controlsBottom + controlsBarH + SSizes.sm,
                child: RoomTranscriptionOverlay(segments: aiState.transcription, isDark: isDark),
              ),

            // ── Controls bar (floating glass pill) ──
            Positioned(
              left: SResponsive.sp(context, SSizes.cardPadding, tabletSize: SSizes.lg, desktopSize: SSizes.xl),
              right: SResponsive.sp(context, SSizes.cardPadding, tabletSize: SSizes.lg, desktopSize: SSizes.xl),
              bottom: controlsBottom,
              child: RoomControlsBar(
                meetingState: meetingState,
                aiState: aiState,
                showCopilot: _showCopilotPanel,
                isDark: isDark,
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
            ),

            // ── AI Copilot sliding panel ──
            if (_showCopilotPanel)
              Positioned(
                right: 0,
                top: topPad,
                bottom: controlsBarH + controlsBottom + SSizes.md,
                width: SResponsive.value(context, mobile: MediaQuery.of(context).size.width * 0.85, tablet: 360.0, desktop: 400.0),
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(1, 0),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _copilotSlideController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: RoomCopilotPanel(
                    aiState: aiState,
                    meetingId: widget.meetingId,
                    isDark: isDark,
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
                left: SResponsive.pagePadding(context),
                right: SResponsive.pagePadding(context),
                bottom: controlsBarH + controlsBottom + SSizes.md + SSizes.sm,
                child: SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(CurvedAnimation(
                    parent: _voiceAssistantController,
                    curve: Curves.easeOutCubic,
                  )),
                  child: RoomVoiceAssistantSheet(
                    controller: _voiceController,
                    lastResult: aiState.lastVoiceCommand,
                    isDark: isDark,
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
              Positioned.fill(
                child: RoomMoreOptionsOverlay(
                meetingState: meetingState,
                aiState: aiState,
                isHost: isHost,
                isDark: isDark,
                onClose: () => setState(() => _showMoreOptions = false),
                onToggleTranscription: () =>
                    ref.read(meetingAIProvider.notifier).toggleTranscription(),
                onToggleCoaching: () =>
                    ref.read(meetingAIProvider.notifier).toggleCoaching(),
                onToggleCopilot: () =>
                    ref.read(meetingAIProvider.notifier).toggleCopilot(),
                onToggleRecording: () =>
                    ref.read(activeMeetingProvider.notifier).toggleRecording(),
                onFlipCamera: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isFrontCamera = !_isFrontCamera);
                  ref.read(activeMeetingProvider.notifier).toggleCamera();
                },
                onShareMeetingLink: () {
                  final meeting = meetingState.meeting;
                  if (meeting != null) {
                    final link = 'https://speakup.app/join/${meeting.code}';
                    SharePlus.instance.share(
                      ShareParams(
                        text: 'Join my SpeakUp meeting: $link',
                        subject: 'SpeakUp Meeting Invite',
                      ),
                    );
                  }
                },
                onEndMeeting: isHost
                    ? () {
                        HapticFeedback.heavyImpact();
                        showDialog(
                          context: context,
                          builder: (ctx) {
                            final dlgDark = Theme.of(ctx).brightness == Brightness.dark;
                            return AlertDialog(
                              backgroundColor: dlgDark ? SColors.darkCard : SColors.lightCard,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(SSizes.radiusLg),
                              ),
                              title: Text(
                                'End Meeting?',
                                style: TextStyle(
                                  color: dlgDark ? SColors.textDark : SColors.textLight,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              content: Text(
                                'This will end the meeting for all participants.',
                                style: TextStyle(
                                  color: dlgDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                                  fontSize: 14,
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(
                                      color: dlgDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () {
                                    Navigator.pop(ctx);
                                    ref.read(activeMeetingProvider.notifier).endMeeting();
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text(
                                    'End Meeting',
                                    style: TextStyle(color: SColors.callEnd, fontWeight: FontWeight.w600),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    : null,
              ),
              ),
          ],
        ),
      ),
    );
  }
}

