import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/app/components/ui/dense_widgets.dart';
import 'package:flutter_conference_speakup/store/meeting_provider.dart';
import 'package:flutter_conference_speakup/app/features/meeting/usecases/join_meeting_usecase.dart';
import 'package:flutter_conference_speakup/app/features/meeting/presentation/widgets/join_meeting_widgets.dart';

class JoinMeetingScreen extends ConsumerStatefulWidget {
  final String? initialCode;
  const JoinMeetingScreen({super.key, this.initialCode});

  @override
  ConsumerState<JoinMeetingScreen> createState() => _JoinMeetingScreenState();
}

class _JoinMeetingScreenState extends ConsumerState<JoinMeetingScreen> {
  final _meetingIdCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _muteAudio = false;
  bool _muteVideo = false;
  bool _isJoining = false;
  bool _passwordRequired = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    if (widget.initialCode != null && widget.initialCode!.isNotEmpty) {
      _meetingIdCtrl.text = widget.initialCode!;
    }
  }

  @override
  void dispose() {
    _meetingIdCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinWithCode() async {
    final code = extractMeetingCode(_meetingIdCtrl.text);
    if (code == null || code.isEmpty) return;

    setState(() => _isJoining = true);
    try {
      final notifier = ref.read(activeMeetingProvider.notifier);
      final password = _passwordCtrl.text.trim();
      await notifier.joinByCode(
        code,
        password: password.isNotEmpty ? password : null,
      );
      if (mounted) {
        final meeting = ref.read(activeMeetingProvider).meeting;
        if (meeting != null) {
          context.pushReplacement('/meeting/${meeting.id}');
        }
      }
    } catch (e) {
      if (mounted) {
        final errorStr = e.toString();
        // Backend returns E4003 when password is required
        if (errorStr.contains('assword required') ||
            errorStr.contains('E4003')) {
          setState(() => _passwordRequired = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This meeting requires a password'),
            ),
          );
        } else if (errorStr.contains('ncorrect password') ||
            errorStr.contains('E4004')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Incorrect password')),
          );
        } else if (errorStr.contains('not found') ||
            errorStr.contains('E3003')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meeting not found')),
          );
        } else if (errorStr.contains('full') || errorStr.contains('E4001')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meeting is full')),
          );
        } else if (errorStr.contains('ended') ||
            errorStr.contains('E4002')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This meeting has ended')),
          );
        } else if (errorStr.contains('locked')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Meeting is locked by the host')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to join: $e')),
          );
        }
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
          'Join Meeting',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? SColors.textDark : SColors.textLight,
          ),
        ),
        centerTitle: true,
      ),
      body: ResponsiveBody(child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Join with Code Section ──
            SectionHeader(title: 'Meeting Code'),
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
                      textInputAction: _passwordRequired
                          ? TextInputAction.next
                          : TextInputAction.go,
                      onSubmitted: _passwordRequired
                          ? null
                          : (hasCode ? (_) => _joinWithCode() : null),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Password input (shown after password required, or always editable)
                  Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: isDark
                          ? SColors.darkElevated
                          : SColors.lightElevated,
                      borderRadius: BorderRadius.circular(SSizes.radiusSm),
                      border: _passwordRequired
                          ? Border.all(
                              color: SColors.warning.withValues(alpha: 0.4),
                              width: 0.5,
                            )
                          : null,
                    ),
                    child: TextField(
                      controller: _passwordCtrl,
                      obscureText: _obscurePassword,
                      style: TextStyle(
                        fontSize: 14,
                        color:
                            isDark ? SColors.textDark : SColors.textLight,
                      ),
                      decoration: InputDecoration(
                        hintText: _passwordRequired
                            ? 'Password required'
                            : 'Password (if required)',
                        hintStyle: TextStyle(
                          fontSize: 13,
                          color: _passwordRequired
                              ? SColors.warning
                              : (isDark
                                  ? SColors.textDarkTertiary
                                  : SColors.textLightTertiary),
                        ),
                        prefixIcon: Icon(
                          Icons.lock_outline_rounded,
                          size: 17,
                          color: _passwordRequired
                              ? SColors.warning
                              : (isDark
                                  ? SColors.textDarkTertiary
                                  : SColors.textLightTertiary),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                            minWidth: 40, minHeight: 40),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(
                              () => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 17,
                            color: isDark
                                ? SColors.textDarkTertiary
                                : SColors.textLightTertiary,
                          ),
                        ),
                        border: InputBorder.none,
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                      ),
                      textInputAction: TextInputAction.go,
                      onSubmitted:
                          hasCode ? (_) => _joinWithCode() : null,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
            const SizedBox(height: 20),

            // ── Join Preferences Section ──
            SectionHeader(title: 'Join Preferences'),
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
                  // Media toggles
                  Row(
                    children: [
                      JoinCompactToggle(
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
                      JoinCompactToggle(
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
                ],
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 100.ms)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: 24),

            // Join button
            SButton(
              text: 'Join Meeting',
              prefixIcon: Icons.login_rounded,
              isLoading: _isJoining,
              onPressed: hasCode ? _joinWithCode : null,
            ).animate().fadeIn(duration: 300.ms, delay: 150.ms)
                .slideY(begin: 0.05, end: 0),
            const SizedBox(height: SSizes.xxl),
          ],
        ),
      ),
    ),
    );
  }
}

