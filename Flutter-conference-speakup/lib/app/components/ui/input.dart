import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/core/constants/sizes.dart';

/// Premium text input with Cupertino-style rounded container and smooth focus.
class SInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? label;
  final String? hint;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final bool obscureText;
  final bool readOnly;
  final bool autofocus;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;
  final FormFieldValidator<String>? validator;
  final List<TextInputFormatter>? inputFormatters;
  final FocusNode? focusNode;
  final bool enabled;

  const SInput({
    super.key,
    this.controller,
    this.label,
    this.hint,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.obscureText = false,
    this.readOnly = false,
    this.autofocus = false,
    this.maxLines = 1,
    this.keyboardType,
    this.textInputAction,
    this.onChanged,
    this.onTap,
    this.validator,
    this.inputFormatters,
    this.focusNode,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDark ? SColors.darkBorder : SColors.lightBorder;
    final focusColor = SColors.primary.withValues(alpha: 0.5);

    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      readOnly: readOnly,
      autofocus: autofocus,
      maxLines: maxLines,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onChanged: onChanged,
      onTap: onTap,
      validator: validator,
      inputFormatters: inputFormatters,
      focusNode: focusNode,
      enabled: enabled,
      cursorColor: SColors.primary,
      style: TextStyle(
        color: isDark ? SColors.textDark : SColors.textLight,
        fontSize: 15,
      ),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        errorText: errorText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: isDark ? SColors.darkMuted : SColors.lightMuted)
            : null,
        suffixIcon: suffix,
        filled: true,
        fillColor: isDark
            ? SColors.darkCard.withValues(alpha: 0.6)
            : SColors.lightElevated.withValues(alpha: 0.5),
        hintStyle: TextStyle(
          color: isDark ? SColors.darkMuted : SColors.lightMuted,
          fontSize: 15,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: SSizes.md,
          vertical: SSizes.inputPadding,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          borderSide: BorderSide(color: borderColor, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          borderSide: BorderSide(color: focusColor, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          borderSide: const BorderSide(color: SColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          borderSide: const BorderSide(color: SColors.error, width: 1.5),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(SSizes.radiusMd),
          borderSide: BorderSide(color: borderColor.withValues(alpha: 0.4), width: 1),
        ),
      ),
    );
  }
}

/// Premium search bar — CupertinoSearchTextField style.
class SSearchBar extends StatelessWidget {
  final TextEditingController? controller;
  final String hint;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;

  const SSearchBar({
    super.key,
    this.controller,
    this.hint = 'Search...',
    this.onChanged,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return CupertinoSearchTextField(
      controller: controller,
      onChanged: onChanged,
      placeholder: hint,
      placeholderStyle: TextStyle(
        color: isDark ? SColors.darkMuted : SColors.lightMuted,
        fontSize: 15,
      ),
      style: TextStyle(
        color: isDark ? SColors.textDark : SColors.textLight,
        fontSize: 15,
      ),
      backgroundColor: isDark
          ? SColors.darkCard.withValues(alpha: 0.6)
          : SColors.lightElevated,
      prefixIcon: Icon(
        CupertinoIcons.search,
        color: isDark ? SColors.darkMuted : SColors.lightMuted,
        size: 18,
      ),
      suffixIcon: const Icon(CupertinoIcons.xmark_circle_fill, size: 16),
      onSuffixTap: () {
        controller?.clear();
        onChanged?.call('');
        onClear?.call();
      },
      padding: const EdgeInsets.symmetric(
        horizontal: SSizes.sm,
        vertical: SSizes.sm + 2,
      ),
      borderRadius: BorderRadius.circular(SSizes.radiusMd),
    );
  }
}
