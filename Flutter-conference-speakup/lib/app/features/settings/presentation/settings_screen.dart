import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/text_strings.dart';
import 'package:flutter_conference_speakup/app/components/ui/card.dart';
import 'package:flutter_conference_speakup/store/auth_provider.dart';
import 'package:flutter_conference_speakup/store/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(STexts.settings, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 96),
        children: [
          // ── Profile Card ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SSizes.pagePadding, vertical: SSizes.sm,
            ),
            child: SCard(
              onTap: () {},
              hasBorder: true,
              child: Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: SColors.primary.withValues(alpha: 0.2), width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: SSizes.avatarLg / 2,
                      backgroundColor: isDark ? SColors.darkElevated : SColors.primarySurface,
                      backgroundImage: user?.avatar != null ? NetworkImage(user!.avatar!) : null,
                      child: user?.avatar == null
                          ? Text(
                              user?.fullName.isNotEmpty == true
                                  ? user!.fullName[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.w700,
                                color: SColors.primary,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: SSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user?.fullName ?? 'User Name',
                          style: TextStyle(
                            fontSize: 17, fontWeight: FontWeight.w600,
                            color: isDark ? SColors.textDark : SColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          user?.email ?? 'user@email.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 36, height: 36,
                    decoration: BoxDecoration(
                      color: isDark ? SColors.darkElevated : SColors.lightElevated,
                      borderRadius: BorderRadius.circular(SSizes.radiusSm),
                    ),
                    child: Icon(SIcons.edit, size: 16,
                      color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.05, end: 0),
          ),

          const SizedBox(height: SSizes.sm),

          // ── AI Features ──
          _SettingsSection(
            title: 'AI Features',
            children: [
              _SettingsTile(
                icon: Icons.auto_awesome_rounded,
                iconBg: SColors.primary,
                title: 'AI Copilot',
                subtitle: 'Smart suggestions during meetings',
                trailing: _ToggleSwitch(value: true, onChanged: (_) {}),
              ),
              _SettingsTile(
                icon: Icons.subtitles_rounded,
                iconBg: SColors.info,
                title: 'Live Transcription',
                subtitle: 'Real-time captions & transcript',
                trailing: _ToggleSwitch(value: true, onChanged: (_) {}),
              ),
              _SettingsTile(
                icon: Icons.record_voice_over_rounded,
                iconBg: SColors.screenShare,
                title: 'Speaking Coach',
                subtitle: 'Pace, clarity & engagement hints',
                trailing: _ToggleSwitch(value: false, onChanged: (_) {}),
              ),
              _SettingsTile(
                icon: Icons.mic_rounded,
                iconBg: SColors.success,
                title: 'Voice Assistant',
                subtitle: 'Voice commands in meetings',
                trailing: _ToggleSwitch(value: true, onChanged: (_) {}),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),

          // ── General ──
          _SettingsSection(
            title: 'General',
            children: [
              _SettingsTile(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconBg: isDark ? SColors.blue800 : SColors.warning,
                title: STexts.darkMode,
                subtitle: themeMode == ThemeMode.dark ? 'On' : 'Off',
                trailing: _ToggleSwitch(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggleDarkMode(),
                ),
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                iconBg: SColors.error,
                title: STexts.notifications,
                subtitle: 'Push & in-app notifications',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.language_rounded,
                iconBg: SColors.info,
                title: STexts.language,
                subtitle: 'English',
                onTap: () {},
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),

          // ── Meeting Defaults ──
          _SettingsSection(
            title: 'Meeting Defaults',
            children: [
              _SettingsTile(
                icon: Icons.videocam_outlined,
                iconBg: SColors.success,
                title: 'Camera',
                subtitle: 'On by default',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.mic_outlined,
                iconBg: SColors.primary,
                title: 'Microphone',
                subtitle: 'On by default',
                onTap: () {},
              ),
              _SettingsTile(
                icon: SIcons.record,
                iconBg: SColors.error,
                title: 'Auto-Record',
                subtitle: 'Off',
                trailing: _ToggleSwitch(value: false, onChanged: (_) {}),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.05, end: 0),

          // ── Account ──
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.security_rounded,
                iconBg: SColors.screenShare,
                title: 'Privacy & Security',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.receipt_long_rounded,
                iconBg: SColors.warning,
                title: 'Subscription',
                subtitle: 'Free plan',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline_rounded,
                iconBg: SColors.info,
                title: STexts.about,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.logout_rounded,
                iconBg: SColors.error,
                title: STexts.logout,
                titleColor: SColors.error,
                onTap: () async {
                  final confirmed = await _showLogoutConfirmation(context, isDark);
                  if (confirmed == true && context.mounted) {
                    await ref.read(currentUserProvider.notifier).signOut();
                    if (context.mounted) context.go('/login');
                  }
                },
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.05, end: 0),

          const SizedBox(height: SSizes.lg),
          Center(
            child: Text('SpeakUp v1.0.0', style: TextStyle(
              fontSize: 12,
              color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
            )),
          ),
          const SizedBox(height: SSizes.lg),
        ],
      ),
    );
  }

  Future<bool?> _showLogoutConfirmation(BuildContext context, bool isDark) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusLg),
        ),
        title: Text('Sign Out', style: TextStyle(
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
        content: Text('Are you sure you want to sign out?', style: TextStyle(
          color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
        )),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancel', style: TextStyle(
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sign Out', style: TextStyle(color: SColors.error)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Settings Section
// ─────────────────────────────────────────────
class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            SSizes.pagePadding, SSizes.lg, SSizes.pagePadding, SSizes.sm,
          ),
          child: Text(title, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w600,
            color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
            letterSpacing: 0.3,
          )),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: SSizes.pagePadding),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? SColors.darkCard : SColors.lightCard,
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
              border: Border.all(
                color: isDark ? SColors.darkBorder : SColors.lightBorder,
              ),
            ),
            child: Column(
              children: [
                for (var i = 0; i < children.length; i++) ...[
                  children[i],
                  if (i < children.length - 1)
                    Divider(height: 1,
                      color: isDark ? SColors.darkBorder : SColors.lightBorder,
                      indent: 56, endIndent: SSizes.md,
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  Settings Tile
// ─────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon, required this.iconBg, required this.title,
    this.subtitle, this.trailing, this.onTap, this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SSizes.radiusMd),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: SSizes.md, vertical: SSizes.sm + 4,
        ),
        child: Row(
          children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: iconBg.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: Icon(icon, size: 18, color: iconBg),
            ),
            const SizedBox(width: SSizes.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w500,
                    color: titleColor ?? (isDark ? SColors.textDark : SColors.textLight),
                  )),
                  if (subtitle != null) ...[
                    const SizedBox(height: 1),
                    Text(subtitle!, style: TextStyle(
                      fontSize: 12,
                      color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
                    )),
                  ],
                ],
              ),
            ),
            trailing ?? Icon(Icons.chevron_right_rounded, size: 20,
              color: isDark ? SColors.darkMuted : SColors.lightMuted),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  Toggle Switch
// ─────────────────────────────────────────────
class _ToggleSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const _ToggleSwitch({required this.value, this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 28,
      child: Switch.adaptive(
        value: value,
        onChanged: (v) {
          HapticFeedback.lightImpact();
          onChanged?.call(v);
        },
        activeColor: SColors.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}
