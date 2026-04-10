import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Grouped section with a header title and bordered card container.
class SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const SettingsSection({super.key, required this.title, required this.children});

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

/// Individual settings row with icon, title, optional subtitle and trailing widget.
class SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconBg;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final Color? titleColor;

  const SettingsTile({
    super.key,
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

/// Compact adaptive toggle switch for settings rows.
class SettingsToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  const SettingsToggle({super.key, required this.value, this.onChanged});

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
        activeThumbColor: SColors.primary,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

/// Tappable row used inside bottom sheets (icon + title + chevron).
class SheetActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SheetActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ListTile(
      leading: Icon(icon, color: SColors.primary, size: 22),
      title: Text(title, style: TextStyle(
        fontSize: 15, fontWeight: FontWeight.w500,
        color: isDark ? SColors.textDark : SColors.textLight,
      )),
      trailing: Icon(Icons.chevron_right_rounded, size: 20,
        color: isDark ? SColors.darkMuted : SColors.lightMuted),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SSizes.radiusMd),
      ),
    );
  }
}
