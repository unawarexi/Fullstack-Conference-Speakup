import 'package:flutter/material.dart';
import 'package:video_confrence_app/core/constants/colors.dart';
import 'package:video_confrence_app/core/constants/sizes.dart';
import 'package:video_confrence_app/core/constants/text_strings.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(STexts.settings),
      ),
      body: ListView(
        children: [
          // Profile section
          Padding(
            padding: const EdgeInsets.all(SSizes.pagePadding),
            child: Row(
              children: [
                CircleAvatar(
                  radius: SSizes.avatarLg / 2,
                  backgroundColor: SColors.primary,
                  child: const Text(
                    'U',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: SSizes.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'User Name',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'user@email.com',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isDark
                                  ? SColors.textDarkSecondary
                                  : SColors.textLightSecondary,
                            ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.edit_outlined),
                ),
              ],
            ),
          ),
          Divider(
            height: 1,
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
          ),

          // Settings groups
          _SettingsSection(
            title: 'General',
            children: [
              _SettingsTile(
                icon: Icons.dark_mode_outlined,
                title: STexts.darkMode,
                trailing: Switch(value: isDark, onChanged: (_) {}),
              ),
              _SettingsTile(
                icon: Icons.notifications_outlined,
                title: STexts.notifications,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.language,
                title: STexts.language,
                subtitle: 'English',
                onTap: () {},
              ),
            ],
          ),

          _SettingsSection(
            title: 'Meeting',
            children: [
              _SettingsTile(
                icon: Icons.videocam_outlined,
                title: 'Default Camera',
                subtitle: 'Front',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.mic_outlined,
                title: 'Default Microphone',
                subtitle: 'On',
                onTap: () {},
              ),
            ],
          ),

          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.info_outline,
                title: STexts.about,
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.logout,
                title: STexts.logout,
                titleColor: SColors.error,
                onTap: () {},
              ),
            ],
          ),

          const SizedBox(height: SSizes.xxl),
          Center(
            child: Text(
              'SpeakUp v1.0.0',
              style: TextStyle(
                fontSize: 12,
                color: isDark
                    ? SColors.textDarkTertiary
                    : SColors.textLightTertiary,
              ),
            ),
          ),
          const SizedBox(height: SSizes.lg),
        ],
      ),
    );
  }
}

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
            SSizes.pagePadding,
            SSizes.lg,
            SSizes.pagePadding,
            SSizes.sm,
          ),
          child: Text(
            title,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? SColors.textDarkTertiary
                  : SColors.textLightTertiary,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: SSizes.iconMd),
      title: Text(title, style: TextStyle(color: titleColor)),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: SSizes.pagePadding,
      ),
    );
  }
}
