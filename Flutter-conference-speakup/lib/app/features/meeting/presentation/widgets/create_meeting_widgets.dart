import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

class CreateMeetingTypeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const CreateMeetingTypeChip({
    super.key,
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: selected
                ? SColors.primary.withValues(alpha: 0.12)
                : (isDark ? SColors.darkCard : SColors.lightCard),
            borderRadius: BorderRadius.circular(SSizes.radiusSm),
            border: Border.all(
              color: selected
                  ? SColors.primary.withValues(alpha: 0.4)
                  : (isDark ? SColors.darkBorder : SColors.lightBorder),
              width: selected ? 1.5 : 0.5,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 20,
                  color: selected
                      ? SColors.primary
                      : (isDark
                          ? SColors.textDarkSecondary
                          : SColors.textLightSecondary)),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  color: selected
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

class CreateMeetingInputField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final bool isDark;
  final int maxLines;
  final bool isPassword;
  final FocusNode? focusNode;
  final TextInputAction? textInputAction;

  const CreateMeetingInputField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    required this.isDark,
    this.maxLines = 1,
    this.isPassword = false,
    this.focusNode,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDark ? SColors.textDarkSecondary : SColors.textLightSecondary,
            ),
          ),
          const SizedBox(height: 6),
        ],
        Container(
          decoration: BoxDecoration(
            color: isDark ? SColors.darkCard : SColors.lightCard,
            borderRadius: BorderRadius.circular(SSizes.radiusSm),
            border: Border.all(
              color: isDark ? SColors.darkBorder : SColors.lightBorder,
              width: 0.5,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            maxLines: maxLines,
            minLines: maxLines > 1 ? 1 : null,
            obscureText: isPassword,
            keyboardType: maxLines > 1 ? TextInputType.multiline : TextInputType.text,
            textInputAction: textInputAction ?? (maxLines > 1 ? TextInputAction.newline : TextInputAction.next),
            style: TextStyle(
              fontSize: 14,
              color: isDark ? SColors.textDark : SColors.textLight,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                fontSize: 14,
                color: isDark
                    ? SColors.textDarkTertiary
                    : SColors.textLightTertiary,
              ),
              prefixIcon:
                  Icon(icon, size: 18, color: isDark ? SColors.textDarkTertiary : SColors.textLightTertiary),
              prefixIconConstraints:
                  const BoxConstraints(minWidth: 42, minHeight: 42),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

class CreateMeetingPickerTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;

  const CreateMeetingPickerTile({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? SColors.darkCard : SColors.lightCard,
          borderRadius: BorderRadius.circular(SSizes.radiusSm),
          border: Border.all(
            color: isDark ? SColors.darkBorder : SColors.lightBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 17,
                color: isDark
                    ? SColors.textDarkSecondary
                    : SColors.textLightSecondary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: isDark ? SColors.textDark : SColors.textLight,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
