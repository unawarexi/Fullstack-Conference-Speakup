import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/app/domain/models/meeting_model.dart';

// ═══════════════════════════════════════════════════════════════════
//  QUICK ACTION GRID — 4-button compact row (New · Join · Schedule · AI)
// ═══════════════════════════════════════════════════════════════════
class QuickActionGrid extends StatelessWidget {
  final bool isDark;
  const QuickActionGrid({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _QuickAction(
          icon: Icons.videocam_rounded,
          label: 'New',
          gradient: SColors.primaryGradient,
          textColor: Colors.white,
          onTap: () => context.push('/create-meeting'),
        ),
        const SizedBox(width: 8),
        _QuickAction(
          icon: Icons.login_rounded,
          label: 'Join',
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderColor: isDark ? SColors.darkBorder : SColors.lightBorder,
          textColor: isDark ? SColors.textDark : SColors.textLight,
          iconColor: SColors.primary,
          onTap: () => context.push('/join'),
        ),
        const SizedBox(width: 8),
        _QuickAction(
          icon: SIcons.calendar,
          label: 'Schedule',
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderColor: isDark ? SColors.darkBorder : SColors.lightBorder,
          textColor: isDark ? SColors.textDark : SColors.textLight,
          iconColor: SColors.screenShare,
          onTap: () => context.push('/create-meeting?type=scheduled'),
        ),
        const SizedBox(width: 8),
        _QuickAction(
          icon: Icons.auto_awesome_rounded,
          label: 'AI',
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderColor: isDark ? SColors.darkBorder : SColors.lightBorder,
          textColor: isDark ? SColors.textDark : SColors.textLight,
          iconColor: SColors.success,
          onTap: () => context.push('/ai-assistant'),
        ),
      ],
    );
  }
}

class _QuickAction extends StatefulWidget {
  final IconData icon;
  final String label;
  final Gradient? gradient;
  final Color? color;
  final Color? borderColor;
  final Color textColor;
  final Color? iconColor;
  final VoidCallback? onTap;

  const _QuickAction({
    required this.icon,
    required this.label,
    this.gradient,
    this.color,
    this.borderColor,
    required this.textColor,
    this.iconColor,
    this.onTap,
  });

  @override
  State<_QuickAction> createState() => _QuickActionState();
}

class _QuickActionState extends State<_QuickAction> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          HapticFeedback.lightImpact();
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.94 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
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
            child: Column(
              children: [
                Icon(widget.icon,
                    color: widget.iconColor ?? widget.textColor, size: 22),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: widget.textColor,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  AI INSIGHTS BANNER — compact tap-navigable banner
// ═══════════════════════════════════════════════════════════════════
class AIInsightsBanner extends StatefulWidget {
  final bool isDark;
  const AIInsightsBanner({super.key, required this.isDark});

  @override
  State<AIInsightsBanner> createState() => _AIInsightsBannerState();
}

class _AIInsightsBannerState extends State<AIInsightsBanner> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        HapticFeedback.lightImpact();
        context.push('/ai-assistant');
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: widget.isDark
                  ? [const Color(0xFF1A1A35), const Color(0xFF0F1A2E)]
                  : [const Color(0xFFEEF2FF), const Color(0xFFF0F7FF)],
            ),
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(
              color: SColors.primary
                  .withValues(alpha: widget.isDark ? 0.2 : 0.1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: SColors.accentGradient,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.auto_awesome_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Meeting Assistant',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark
                            ? SColors.textDark
                            : SColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Transcription, coaching & smart suggestions',
                      style: TextStyle(
                        fontSize: 11,
                        color: widget.isDark
                            ? SColors.textDarkSecondary
                            : SColors.textLightSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(CupertinoIcons.chevron_right,
                  size: 14,
                  color: widget.isDark
                      ? SColors.textDarkTertiary
                      : SColors.textLightTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  COMPACT MEETING TILE — dense meeting row
// ═══════════════════════════════════════════════════════════════════
class CompactMeetingTile extends StatefulWidget {
  final MeetingModel meeting;
  final bool isDark;
  final VoidCallback? onTap;

  const CompactMeetingTile({
    super.key,
    required this.meeting,
    required this.isDark,
    this.onTap,
  });

  @override
  State<CompactMeetingTile> createState() => _CompactMeetingTileState();
}

class _CompactMeetingTileState extends State<CompactMeetingTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final m = widget.meeting;
    final timeStr =
        m.scheduledAt != null ? DateFormat('h:mm a').format(m.scheduledAt!) : 'Now';

    return GestureDetector(
      onTapDown: widget.onTap != null
          ? (_) => setState(() => _pressed = true)
          : null,
      onTapUp: widget.onTap != null
          ? (_) {
              setState(() => _pressed = false);
              HapticFeedback.selectionClick();
              widget.onTap?.call();
            }
          : null,
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: widget.isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusMd),
            border: Border.all(
              color:
                  widget.isDark ? SColors.darkBorder : SColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: Row(
            children: [
              // Time badge
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: m.isLive
                      ? SColors.success.withValues(alpha: 0.12)
                      : SColors.primary
                          .withValues(alpha: widget.isDark ? 0.12 : 0.07),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (m.isLive) ...[
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                          color: SColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'LIVE',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w800,
                          color: SColors.success,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ] else ...[
                      Icon(SIcons.clock,
                          size: 14, color: SColors.primary),
                      const SizedBox(height: 1),
                      Text(
                        timeStr,
                        style: const TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w700,
                          color: SColors.primary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // Title + meta
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: widget.isDark
                            ? SColors.textDark
                            : SColors.textLight,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        if (m.hostName != null) ...[
                          Icon(SIcons.profile,
                              size: 11,
                              color: widget.isDark
                                  ? SColors.textDarkTertiary
                                  : SColors.textLightTertiary),
                          const SizedBox(width: 3),
                          Flexible(
                            child: Text(
                              m.hostName!,
                              style: TextStyle(
                                fontSize: 11,
                                color: widget.isDark
                                    ? SColors.textDarkSecondary
                                    : SColors.textLightSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                        Icon(SIcons.participants,
                            size: 11,
                            color: widget.isDark
                                ? SColors.textDarkTertiary
                                : SColors.textLightTertiary),
                        const SizedBox(width: 3),
                        Text(
                          '${m.participantCount}',
                          style: TextStyle(
                            fontSize: 11,
                            color: widget.isDark
                                ? SColors.textDarkSecondary
                                : SColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Join button for live meetings
              if (m.isLive)
                _JoinPill(onTap: widget.onTap)
              else
                Icon(CupertinoIcons.chevron_right,
                    size: 14,
                    color: widget.isDark
                        ? SColors.textDarkTertiary
                        : SColors.textLightTertiary),
            ],
          ),
        ),
      ),
    );
  }
}

class _JoinPill extends StatelessWidget {
  final VoidCallback? onTap;
  const _JoinPill({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          gradient: SColors.primaryGradient,
          borderRadius: BorderRadius.circular(SSizes.radiusFull),
        ),
        child: const Text(
          'Join',
          style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  WEEKLY STATS ROW — 3 compact stat cards
// ═══════════════════════════════════════════════════════════════════
class WeeklyStatsRow extends StatelessWidget {
  final bool isDark;
  const WeeklyStatsRow({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Meetings',
            value: '—',
            icon: SIcons.meetings,
            color: SColors.primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            label: 'Hours',
            value: '—',
            icon: SIcons.clock,
            color: SColors.screenShare,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: StatCard(
            label: 'Insights',
            value: '—',
            icon: Icons.auto_awesome_outlined,
            color: SColors.success,
          ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  RECENT ACTIVITY TILE — compact row for past meetings
// ═══════════════════════════════════════════════════════════════════
class RecentActivityTile extends StatelessWidget {
  final MeetingModel meeting;
  final bool isDark;
  final VoidCallback? onTap;

  const RecentActivityTile({
    super.key,
    required this.meeting,
    required this.isDark,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final date = meeting.endedAt ?? meeting.createdAt;
    final duration = meeting.startedAt != null && meeting.endedAt != null
        ? meeting.endedAt!.difference(meeting.startedAt!).inMinutes
        : null;

    return DenseTile(
      icon: SIcons.meetings,
      title: meeting.title,
      subtitle:
          '${DateFormat('MMM d, h:mm a').format(date)}${duration != null ? ' · ${duration}m' : ''}',
      showChevron: true,
      onTap: onTap ?? () => context.push('/meeting-detail/${meeting.id}'),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  MEETINGS SKELETON — compact shimmer placeholder
// ═══════════════════════════════════════════════════════════════════
class MeetingsSkeleton extends StatelessWidget {
  final bool isDark;
  const MeetingsSkeleton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        2,
        (i) => Padding(
          padding: EdgeInsets.only(bottom: i < 1 ? 6 : 0),
          child: Container(
            height: 62,
            decoration: BoxDecoration(
              color: isDark ? SColors.darkCard : SColors.lightCard,
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
              border: Border.all(
                color: isDark ? SColors.darkBorder : SColors.lightBorder,
                width: 0.5,
              ),
            ),
          ).animate(onPlay: (c) => c.repeat()).shimmer(
                duration: 1200.ms,
                color: (isDark ? SColors.darkElevated : SColors.lightElevated)
                    .withValues(alpha: 0.5),
              ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  COMPACT EMPTY STATE — small inline empty
// ═══════════════════════════════════════════════════════════════════
class CompactEmptyState extends StatelessWidget {
  final IconData icon;
  final String message;
  final String subMessage;
  final bool isDark;
  final String? actionLabel;
  final VoidCallback? onAction;

  const CompactEmptyState({
    super.key,
    required this.icon,
    required this.message,
    required this.subMessage,
    required this.isDark,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        color: isDark ? SColors.darkCard : SColors.lightCard,
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
        border: Border.all(
          color: isDark ? SColors.darkBorder : SColors.lightBorder,
          width: 0.5,
        ),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark ? SColors.darkElevated : SColors.lightElevated,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 22,
                  color: isDark ? SColors.darkMuted : SColors.lightMuted),
            ),
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? SColors.textDark : SColors.textLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subMessage,
              style: TextStyle(
                fontSize: 11,
                color: isDark
                    ? SColors.textDarkTertiary
                    : SColors.textLightTertiary,
              ),
            ),
            if (actionLabel != null) ...[
              const SizedBox(height: 10),
              GestureDetector(
                onTap: onAction,
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: SColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
