import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';

class TTextFormFieldTheme {
  TTextFormFieldTheme._();

  static InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: SColors.lightMuted,
    suffixIconColor: SColors.lightMuted,
    labelStyle: const TextStyle().copyWith(fontSize: 14, color: SColors.textLight),
    hintStyle: const TextStyle().copyWith(color: SColors.lightMuted),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal, color: SColors.error),
    floatingLabelStyle:
        const TextStyle().copyWith(color: SColors.primary),
    border: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: const BorderSide(color: SColors.lightBorder, width: 1),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: const BorderSide(color: SColors.lightBorder, width: 1)),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: const BorderSide(color: SColors.primary, width: 1.5),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: const BorderSide(color: SColors.error, width: 1),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: const BorderSide(color: SColors.warning, width: 2),
    ),
  );

  static InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    errorMaxLines: 3,
    prefixIconColor: SColors.darkMuted,
    suffixIconColor: SColors.darkMuted,
    labelStyle: const TextStyle().copyWith(fontSize: 14, color: SColors.textDark),
    hintStyle: const TextStyle().copyWith(color: SColors.darkMuted),
    errorStyle: const TextStyle().copyWith(fontStyle: FontStyle.normal, color: SColors.error),
    floatingLabelStyle:
        const TextStyle().copyWith(color: SColors.primary),
    border: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: const BorderSide(color: SColors.darkBorder, width: 1),
    ),
    enabledBorder: const OutlineInputBorder().copyWith(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        borderSide: const BorderSide(color: SColors.darkBorder, width: 1)),
    focusedBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: const BorderSide(color: SColors.primary, width: 1.5),
    ),
    errorBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: const BorderSide(color: SColors.error, width: 1),
    ),
    focusedErrorBorder: const OutlineInputBorder().copyWith(
      borderRadius: const BorderRadius.all(Radius.circular(12)),
      borderSide: const BorderSide(color: SColors.warning, width: 2),
    ),
  );
}
