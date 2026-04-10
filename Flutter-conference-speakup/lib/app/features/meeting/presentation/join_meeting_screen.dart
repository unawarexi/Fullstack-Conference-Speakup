import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';

class JoinMeetingScreen extends ConsumerStatefulWidget {
  final String? initialCode;
  const JoinMeetingScreen({super.key, this.initialCode});

  @override
  ConsumerState<JoinMeetingScreen> createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends ConsumerState<JoinMeetingScreen> {
  final _meetingIdCtrl = TextEditingController();
  bool _muteAudio = false;
  bool _muteVideo = false;
  bool _isCreating = false;
  bool _isJoining = false;

  /// Regex for SpeakUp meeting codes: spk-xxxx-xxxx
  static final _speakUpCodeRegex = RegExp(r'^spk-[a-z0-9]{4}-[a-z0-9]{4}$');

  /// Extract meeting code from various input formats
  String? _extractCode(String input) {
    final trimmed = input.trim().toLowerCase();

    // Full link: https://speakup.app/join/spk-xxxx-xxxx
    final urlMatch = RegExp(r'speakup\.app/(?:join|meeting)/([a-z0-9-]+)')
        .firstMatch(trimmed);
    if (urlMatch != null) return urlMatch.group(1);

    // Deep link: speakup://meet/spk-xxxx-xxxx
    final deepMatch =
        RegExp(r'speakup://meet/([a-z0-9-]+)').firstMatch(trimmed);
    if (deepMatch != null) return deepMatch.group(1);

    // Plain code
    if (_speakUpCodeRegex.hasMatch(trimmed)) return trimmed;

    // Legacy cuid fallback (alphanumeric, 20+ chars)
    if (RegExp(r'^[a-z0-9]{8,}$').hasMatch(trimmed)) return trimmed;

    return trimmed.isNotEmpty ? trimmed : null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialCode != null && widget.initialCode!.isNotEmpty) {
      _meetingIdCtrl.text = widget.initialCode!;
      // Auto-join after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _joinWithCode();
      });
    }
  }

  @override
  void dispose() {
    _meetingIdCtrl.dispose();
    super.dispose();
  }

  Future<void> _instantMeeting() async {
    setState(() => _isCreating = true);
    try {
      final repo = ref.read(meetingRepositoryProvider);
      final meeting = await repo.create({
        'title': 'Quick Meeting',
        'type': 'INSTANT',
      });
      if (mounted) {
        ref.invalidate(meetingsProvider(null));
        context.pushReplacement('/meeting/${meeting.id}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCreating = false);
    }
  }

  Future<void> _joinWithCode() async {
    final code = _extractCode(_meetingIdCtrl.text);
    if (code == null || code.isEmpty) return;

    setState(() => _isJoining = true);
    try {
      final notifier = ref.read(activeMeetingProvider.notifier);
      await notifier.joinByCode(code);
      if (mounted) {
        final meeting = ref.read(activeMeetingProvider).meeting;
        if (meeting != null) {
          context.pushReplacement('/meeting/${meeting.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to join: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isJoining = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasCode = _meetingIdCtrl.text.trim().isNotEmpty;

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
        title: Text(
          'Join or Create',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? SColors.textDark : SColors.textLight,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Quick Start Section ──
            SectionHeader(title: 'Quick Start'),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.bolt_rounded,
                    label: 'Instant Meeting',
                    subtitle: 'Start now',
                    gradient: SColors.primaryGradient,
                    textColor: Colors.white,
                    isLoading: _isCreating,
                    onTap: _instantMeeting,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionCard(
                    icon: SIcons.calendar,
                    label: 'Schedule',
                    subtitle: 'Plan ahead',
                    color: isDark ? SColors.darkCard : SColors.lightCard,
                    borderColor:
                        isDark ? SColors.darkBorder : SColors.lightBorder,
                    textColor: isDark ? SColors.textDark : SColors.textLight,
                    iconColor: SColors.screenShare,
                    onTap: () => context.push('/create-meeting'),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: 24),

            // ── Join with Code Section ──
            SectionHeader(title: 'Join with Code'),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark ? SColors.darkCard : SColors.lightCard,
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
                border: Border.all(
                  color: isDark ? SColors.darkBorder : SColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  // Meeting code input
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? SColors.darkElevated
                          : SColors.lightElevated,
                      borderRadius: BorderRadius.circular(SSizes.radiusSm),
                    ),
                    child: TextField(
                      controller: _meetingIdCtrl,
                      onChanged: (_) => setState(() {}),
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark ? SColors.textDark : SColors.textLight,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Enter code (spk-xxxx-xxxx) or link',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: isDark
                              ? SColors.textDarkTertiary
                              : SColors.textLightTertiary,
                        ),
                        prefixIcon: Icon(SIcons.link,
                            size: 17,
                            color: isDark
                                ? SColors.textDarkTertiary
                                : SColors.textLightTertiary),
                        prefixIconConstraints: const BoxConstraints(
                            minWidth: 40, minHeight: 40),
                        suffixIcon: hasCode
                            ? GestureDetector(
                                onTap: () {
                                  _meetingIdCtrl.clear();
                                  setState(() {});
                                },
                                child: Icon(CupertinoIcons.clear_circled,
                                    size: 16,
                                    color: isDark
                                        ? SColors.textDarkTertiary
                                        : SColors.textLightTertiary),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      textInputAction: TextInputAction.go,
                      onSubmitted: hasCode
                          ? (_) => _joinWithCode()
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Media toggles
                  Row(
                    children: [
                      _CompactToggle(
                        icon: _muteAudio
                            ? SIcons.micOff
                            : SIcons.micOn,
                        label: _muteAudio ? 'Mic off' : 'Mic on',
                        isActive: !_muteAudio,
                        isDark: isDark,
                        onTap: () =>
                            setState(() => _muteAudio = !_muteAudio),
                      ),
                      const SizedBox(width: 10),
                      _CompactToggle(
                        icon: _muteVideo
                            ? SIcons.cameraOff
                            : SIcons.cameraOn,
                        label: _muteVideo ? 'Cam off' : 'Cam on',
                        isActive: !_muteVideo,
                        isDark: isDark,
                        onTap: () =>
                            setState(() => _muteVideo = !_muteVideo),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Join button
                  SButton(
                    text: 'Join Meeting',
                    prefixIcon: Icons.login_rounded,
                    isLoading: _isJoining,
                    onPressed: hasCode ? _joinWithCode : null,
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 24),

            // ── Create Options Section ──
            SectionHeader(title: 'More Options'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              decoration: BoxDecoration(
                color: isDark ? SColors.darkCard : SColors.lightCard,
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
                border: Border.all(
                  color: isDark ? SColors.darkBorder : SColors.lightBorder,
                  width: 0.5,
                ),
              ),
              child: Column(
                children: [
                  DenseTile(
                    icon: Icons.videocam_rounded,
                    iconColor: SColors.primary,
                    title: 'New Meeting',
                    subtitle: 'Custom title, settings & more',
                    showChevron: true,
                    onTap: () => context.push('/create-meeting'),
                  ),
                  DenseTile(
                    icon: Icons.repeat_rounded,
                    iconColor: SColors.screenShare,
                    title: 'Recurring Meeting',
                    subtitle: 'Set up a repeating schedule',
                    showChevron: true,
                    hasDivider: false,
                    onTap: () =>
                        context.push('/create-meeting?type=recurring'),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms)
                .slideY(begin: 0.05, end: 0),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Action Card — compact hero action
// ─────────────────────────────────────────────
class _ActionCard extends StatefulWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final Color textColor;
  final Color? iconColor;
  final bool isLoading;
  final VoidCallback? onTap;

  const _ActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    this.gradient,
    this.color,
    this.borderColor,
    required this.textColor,
    this.iconColor,
    this.isLoading = false,
    this.onTap,
  });

  @override
  State<_ActionCard> createState() => _ActionCardState();
}

class _ActionCardState extends State<_ActionCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            color: widget.gradient == null ? widget.color : null,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!, width: 0.5)
                : null,
            boxShadow: widget.gradient != null
                ? [
                    BoxShadow(
                      color: SColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 3),
                    )
                  ]
                : null,
          ),
          child: widget.isLoading
              ? SizedBox(
                  height: 44,
                  child: Center(
                    child: CupertinoActivityIndicator(
                      color: widget.textColor,
                    ),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(widget.icon,
                        color: widget.iconColor ?? widget.textColor,
                        size: 24),
                    const SizedBox(height: 10),
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.textColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.textColor.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Compact Toggle — mic/cam toggle chip
// ─────────────────────────────────────────────
class _CompactToggle extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isDark;
  final VoidCallback? onTap;

  const _CompactToggle({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
          decoration: BoxDecoration(
            color: isActive
                ? SColors.primary.withValues(alpha: 0.1)
                : (isDark ? SColors.darkElevated : SColors.lightElevated),
            borderRadius: BorderRadius.circular(SSizes.radiusSm),
            border: Border.all(
              color: isActive
                  ? SColors.primary.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 16,
                  color: isActive
                      ? SColors.primary
                      : (isDark
                          ? SColors.textDarkTertiary
                          : SColors.textLightTertiary)),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive
                      ? SColors.primary
                      : (isDark
                          ? SColors.textDarkSecondary
                          : SColors.textLightSecondary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
