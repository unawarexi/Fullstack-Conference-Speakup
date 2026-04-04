import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';

class TChipTheme {
  TChipTheme._();

  static ChipThemeData lightChipTheme = ChipThemeData(
      disabledColor: SColors.lightMuted.withValues(alpha: 0.4),
      labelStyle: const TextStyle(color: SColors.textLight),
      selectedColor: SColors.primary,
      padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
      checkmarkColor: Colors.white);

  static const ChipThemeData darkChipTheme = ChipThemeData(
      disabledColor: SColors.darkMuted,
      labelStyle: TextStyle(color: SColors.textDark),
      selectedColor: SColors.primary,
      padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
      checkmarkColor: Colors.white);
}
