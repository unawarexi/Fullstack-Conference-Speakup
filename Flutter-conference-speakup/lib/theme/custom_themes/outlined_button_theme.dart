import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';

class TOutlineButtonTheme {
  TOutlineButtonTheme._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: SColors.textLight,
          side: const BorderSide(color: SColors.primary),
          textStyle: const TextStyle(
              fontSize: 16, color: SColors.textLight, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
          elevation: 0,
          foregroundColor: SColors.textDark,
          side: const BorderSide(color: SColors.primary),
          textStyle: const TextStyle(
              fontSize: 16, color: SColors.textDark, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
}
