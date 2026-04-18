import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/icons.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';
import 'package:flutter_conference_speakup/core/constants/responsive.dart';
import 'package:flutter_conference_speakup/core/constants/text_strings.dart';
import 'package:flutter_conference_speakup/app/components/ui/card.dart';
import 'package:flutter_conference_speakup/app/components/ui/bottom_sheet.dart';
import 'package:flutter_conference_speakup/app/components/ui/activity_indicator.dart';
import 'package:flutter_conference_speakup/app/components/ui/button.dart';
import 'package:flutter_conference_speakup/store/auth_provider.dart';
import 'package:flutter_conference_speakup/store/theme_provider.dart';
import 'package:flutter_conference_speakup/store/settings_provider.dart';
import 'package:flutter_conference_speakup/store/billing_provider.dart';
import 'package:flutter_conference_speakup/store/user_provider.dart';
import 'package:flutter_conference_speakup/app/features/settings/presentation/widgets/settings_section.dart';
import 'package:flutter_conference_speakup/app/features/settings/presentation/widgets/edit_profile_content.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final user = ref.watch(currentUserProvider).valueOrNull;
    final themeMode = ref.watch(themeModeProvider);
    final settings = ref.watch(settingsProvider);
    final subscription = ref.watch(subscriptionProvider);

    Future<void> onRefresh() async {
      await ref.read(currentUserProvider.notifier).fetchProfile();
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(STexts.settings, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w700,
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
      ),
      body: ResponsiveBody(child: RefreshIndicator(
        onRefresh: onRefresh,
        color: SColors.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 96),
          children: [
          // ── Profile Card ──
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: SSizes.pagePadding, vertical: SSizes.sm,
            ),
            child: SCard(
              onTap: () => _showEditProfileSheet(context, ref, isDark),
              hasBorder: true,
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => _pickAvatar(context, ref),
                    child: Stack(
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
                        Positioned(
                          bottom: 0, right: 0,
                          child: Container(
                            width: 22, height: 22,
                            decoration: BoxDecoration(
                              color: SColors.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isDark ? SColors.darkCard : SColors.lightCard,
                                width: 2,
                              ),
                            ),
                            child: const Icon(Icons.camera_alt_rounded, size: 11, color: Colors.white),
                          ),
                        ),
                      ],
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
          SettingsSection(
            title: 'AI Features',
            children: [
              SettingsTile(
                icon: Icons.auto_awesome_rounded,
                iconBg: SColors.primary,
                title: 'AI Copilot',
                subtitle: 'Smart suggestions during meetings',
                trailing: SettingsToggle(
                  value: settings.aiCopilotEnabled,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleAiCopilot(),
                ),
              ),
              SettingsTile(
                icon: Icons.subtitles_rounded,
                iconBg: SColors.info,
                title: 'Live Transcription',
                subtitle: 'Real-time captions & transcript',
                trailing: SettingsToggle(
                  value: settings.aiTranscriptionEnabled,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleAiTranscription(),
                ),
              ),
              SettingsTile(
                icon: Icons.record_voice_over_rounded,
                iconBg: SColors.screenShare,
                title: 'Speaking Coach',
                subtitle: 'Pace, clarity & engagement hints',
                trailing: SettingsToggle(
                  value: settings.aiCoachingEnabled,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleAiCoaching(),
                ),
              ),
              SettingsTile(
                icon: Icons.mic_rounded,
                iconBg: SColors.success,
                title: 'Voice Assistant',
                subtitle: 'Voice commands in meetings',
                trailing: SettingsToggle(
                  value: settings.aiVoiceAssistantEnabled,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleAiVoiceAssistant(),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.05, end: 0),

          // ── General ──
          SettingsSection(
            title: 'General',
            children: [
              SettingsTile(
                icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconBg: isDark ? SColors.blue800 : SColors.warning,
                title: STexts.darkMode,
                subtitle: themeMode == ThemeMode.dark ? 'On' : 'Off',
                trailing: SettingsToggle(
                  value: themeMode == ThemeMode.dark,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggleDarkMode(),
                ),
              ),
              SettingsTile(
                icon: Icons.notifications_outlined,
                iconBg: SColors.error,
                title: STexts.notifications,
                subtitle: settings.notificationsEnabled ? 'Enabled' : 'Disabled',
                trailing: SettingsToggle(
                  value: settings.notificationsEnabled,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleNotifications(),
                ),
              ),
              SettingsTile(
                icon: Icons.language_rounded,
                iconBg: SColors.info,
                title: STexts.language,
                subtitle: 'English',
                onTap: () => _showLanguageInfo(context, isDark),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.05, end: 0),

          // ── Meeting Defaults ──
          SettingsSection(
            title: 'Meeting Defaults',
            children: [
              SettingsTile(
                icon: Icons.videocam_outlined,
                iconBg: SColors.success,
                title: 'Camera',
                subtitle: settings.cameraOnByDefault ? 'On by default' : 'Off by default',
                trailing: SettingsToggle(
                  value: settings.cameraOnByDefault,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleCameraDefault(),
                ),
              ),
              SettingsTile(
                icon: Icons.mic_outlined,
                iconBg: SColors.primary,
                title: 'Microphone',
                subtitle: settings.micOnByDefault ? 'On by default' : 'Off by default',
                trailing: SettingsToggle(
                  value: settings.micOnByDefault,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleMicDefault(),
                ),
              ),
              SettingsTile(
                icon: SIcons.record,
                iconBg: SColors.error,
                title: 'Auto-Record',
                subtitle: settings.autoRecordEnabled ? 'On' : 'Off',
                trailing: SettingsToggle(
                  value: settings.autoRecordEnabled,
                  onChanged: (_) => ref.read(settingsProvider.notifier).toggleAutoRecord(),
                ),
              ),
            ],
          ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.05, end: 0),

          // ── Account ──
          SettingsSection(
            title: 'Account',
            children: [
              SettingsTile(
                icon: Icons.security_rounded,
                iconBg: SColors.screenShare,
                title: 'Privacy & Security',
                onTap: () => _showPrivacySheet(context, isDark),
              ),
              SettingsTile(
                icon: Icons.receipt_long_rounded,
                iconBg: SColors.warning,
                title: 'Subscription',
                subtitle: subscription.when(
                  data: (sub) => sub != null
                      ? '${sub.plan.name[0].toUpperCase()}${sub.plan.name.substring(1)} plan'
                      : 'Free plan',
                  loading: () => 'Loading...',
                  error: (_, _) => 'Free plan',
                ),
                onTap: () => _showSubscriptionSheet(context, ref, isDark),
              ),
              SettingsTile(
                icon: Icons.info_outline_rounded,
                iconBg: SColors.info,
                title: STexts.about,
                onTap: () => _showAboutDialog(context, isDark),
              ),
              SettingsTile(
                icon: Icons.delete_outline_rounded,
                iconBg: SColors.error,
                title: STexts.deleteAccount,
                titleColor: SColors.error,
                onTap: () => _handleDeleteAccount(context, ref, isDark),
              ),
              SettingsTile(
                icon: Icons.logout_rounded,
                iconBg: SColors.error,
                title: STexts.logout,
                titleColor: SColors.error,
                onTap: () async {
                  final confirmed = await _showLogoutConfirmation(context, isDark);
                  if (confirmed == true && context.mounted) {
                    _showLoadingDialog(context, isDark, 'Signing out…');
                    try {
                      await ref.read(currentUserProvider.notifier).signOut();
                    } finally {
                      if (context.mounted) {
                        Navigator.of(context, rootNavigator: true).pop();
                        context.go('/login');
                      }
                    }
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
      ),
    ),
    );
  }

  Future<bool?> _showLogoutConfirmation(BuildContext context, bool isDark) {
    return showDialog<bool>(
      context: context,
      useRootNavigator: true,
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
            child: Text(STexts.cancel, style: TextStyle(
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

  // ─────────────────────────────────────────────
  //  Loading Dialog
  // ─────────────────────────────────────────────

  void _showLoadingDialog(BuildContext context, bool isDark, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (_) => PopScope(
        canPop: false,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            decoration: BoxDecoration(
              color: isDark ? SColors.darkCard : SColors.lightCard,
              borderRadius: BorderRadius.circular(SSizes.radiusMd),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SActivityIndicator(size: 28),
                const SizedBox(height: 16),
                Text(message, style: TextStyle(
                  fontSize: 14,
                  color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Avatar Picker
  // ─────────────────────────────────────────────

  Future<void> _pickAvatar(BuildContext context, WidgetRef ref) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 85,
    );
    if (image == null || !context.mounted) return;

    try {
      await ref.read(updateAvatarProvider)(image.path);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Avatar updated')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update avatar: $e')),
        );
      }
    }
  }

  // ─────────────────────────────────────────────
  //  Edit Profile Sheet
  // ─────────────────────────────────────────────

  Future<void> _showEditProfileSheet(BuildContext context, WidgetRef ref, bool isDark) async {
    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) return;

    final nameController = TextEditingController(text: user.fullName);
    final bioController = TextEditingController(text: user.bio ?? '');

    await SBottomSheet.show(
      context: context,
      title: 'Edit Profile',
      child: EditProfileContent(
        nameController: nameController,
        bioController: bioController,
        onSave: () async {
          final name = nameController.text.trim();
          final bio = bioController.text.trim();
          if (name.isEmpty) return;

          try {
            await ref.read(updateProfileProvider)(
              fullName: name,
              bio: bio.isNotEmpty ? bio : null,
            );
            if (context.mounted) Navigator.pop(context);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Failed to update: $e')),
              );
            }
          }
        },
      ),
    );

    nameController.dispose();
    bioController.dispose();
  }

  // ─────────────────────────────────────────────
  //  Language Info
  // ─────────────────────────────────────────────

  void _showLanguageInfo(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusLg),
        ),
        title: Text('Language', style: TextStyle(
          color: isDark ? SColors.textDark : SColors.textLight,
        )),
        content: Text(
          'English is the only supported language at this time. More languages coming soon.',
          style: TextStyle(
            color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(STexts.ok, style: TextStyle(color: SColors.primary)),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Privacy & Security Sheet
  // ─────────────────────────────────────────────

  void _showPrivacySheet(BuildContext context, bool isDark) {
    SBottomSheet.show(
      context: context,
      title: 'Privacy & Security',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetActionTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {
              Navigator.pop(context);
              context.push('/terms');
            },
          ),
          SheetActionTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {
              Navigator.pop(context);
              context.push('/privacy');
            },
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Subscription Sheet
  // ─────────────────────────────────────────────

  void _showSubscriptionSheet(BuildContext context, WidgetRef ref, bool isDark) {
    final subscription = ref.read(subscriptionProvider);

    SBottomSheet.show(
      context: context,
      title: 'Subscription',
      child: subscription.when(
        data: (sub) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: SResponsive.pagePadding(context), vertical: SSizes.md),
              decoration: BoxDecoration(
                color: isDark ? SColors.darkElevated : SColors.lightElevated,
                borderRadius: BorderRadius.circular(SSizes.radiusMd),
              ),
              child: Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: SColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(SSizes.radiusSm),
                    ),
                    child: const Icon(Icons.diamond_rounded, color: SColors.primary),
                  ),
                  const SizedBox(width: SSizes.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sub != null
                              ? '${sub.plan.name[0].toUpperCase()}${sub.plan.name.substring(1)} Plan'
                              : 'Free Plan',
                          style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w600,
                            color: isDark ? SColors.textDark : SColors.textLight,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub?.isPaid == true ? 'Active subscription' : 'Basic features included',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: SSizes.md),
            if (sub == null || !sub.isPaid)
              SButton(
                text: 'Upgrade to Pro',
                onPressed: () => Navigator.pop(context),
              )
            else
              SButton(
                text: 'Manage Subscription',
                variant: SButtonVariant.outline,
                onPressed: () => Navigator.pop(context),
              ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => Text(
          'Unable to load subscription info',
          style: TextStyle(color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  About Dialog
  // ─────────────────────────────────────────────

  void _showAboutDialog(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusLg),
        ),
        title: Row(
          children: [
            Container(
              width: 40, height: 40,
              decoration: BoxDecoration(
                color: SColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(SSizes.radiusSm),
              ),
              child: const Icon(Icons.video_chat_rounded, color: SColors.primary, size: 22),
            ),
            const SizedBox(width: SSizes.sm),
            Text(STexts.appName, style: TextStyle(
              color: isDark ? SColors.textDark : SColors.textLight,
            )),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(STexts.appTagline, style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w500,
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            )),
            const SizedBox(height: SSizes.md),
            _aboutRow('Version', '1.0.0', isDark),
            _aboutRow('Platform', 'Flutter', isDark),
            _aboutRow('Backend', 'Node.js + FastAPI', isDark),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/terms');
            },
            child: Text('Terms', style: TextStyle(
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            )),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/privacy');
            },
            child: Text('Privacy', style: TextStyle(
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(STexts.ok, style: TextStyle(color: SColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _aboutRow(String label, String value, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: SSizes.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(
            fontSize: 13, color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary,
          )),
          Text(value, style: TextStyle(
            fontSize: 13, fontWeight: FontWeight.w500,
            color: isDark ? SColors.textDark : SColors.textLight,
          )),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  //  Delete Account
  // ─────────────────────────────────────────────

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref, bool isDark) async {
    final confirmed = await showDialog<bool>(
      context: context,
      useRootNavigator: true,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? SColors.darkCard : SColors.lightCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusLg),
        ),
        title: Text(STexts.deleteAccount, style: TextStyle(
          color: SColors.error,
        )),
        content: Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
          style: TextStyle(
            color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(STexts.cancel, style: TextStyle(
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            )),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(STexts.delete, style: TextStyle(color: SColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      _showLoadingDialog(context, isDark, 'Deleting account…');
      try {
        await ref.read(currentUserProvider.notifier).deleteAccount();
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          context.go('/login');
        }
      } catch (e) {
        if (context.mounted) {
          Navigator.of(context, rootNavigator: true).pop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete account: $e')),
          );
        }
      }
    }
  }
}
