import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';
import 'package:flutter_conference_speakup/theme/custom_themes/app_bar_theme.dart';
import 'package:flutter_conference_speakup/theme/custom_themes/bottom_sheet_theme.dart';
import 'package:flutter_conference_speakup/theme/custom_themes/check_box_theme.dart';
import 'package:flutter_conference_speakup/theme/custom_themes/chip_theme.dart';
import 'package:flutter_conference_speakup/theme/custom_themes/elevated_button_theme.dart';
import 'package:flutter_conference_speakup/theme/custom_themes/outlined_button_theme.dart';
import 'package:flutter_conference_speakup/theme/custom_themes/text_field_theme.dart';
import 'package:flutter_conference_speakup/theme/custom_themes/text_theme.dart';

class TAppTheme {
  TAppTheme._();

  // ──────────────── LIGHT THEME ────────────────
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.light,
    primaryColor: SColors.primary,
    colorScheme: const ColorScheme.light(
      primary: SColors.primary,
      primaryContainer: SColors.primarySurface,
      secondary: SColors.blue700,
      surface: SColors.lightSurface,
      error: SColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: SColors.textLight,
      onError: Colors.white,
      outline: SColors.lightBorder,
    ),
    scaffoldBackgroundColor: SColors.lightBg,
    cardColor: SColors.lightCard,
    dividerColor: SColors.lightBorder,
    hoverColor: SColors.lightHover,
    textTheme: TTextTheme.lightTextTheme,
    chipTheme: TChipTheme.lightChipTheme,
    appBarTheme: TAppBarTheme.lightAppBarTheme,
    checkboxTheme: TCheckBoxTheme.lightCheckBoxTheme,
    bottomSheetTheme: TBottomSheetTheme.lightBottomSheetTheme,
    outlinedButtonTheme: TOutlineButtonTheme.lightOutlinedButtonTheme,
    elevatedButtonTheme: TElevatedButtonTheme.lightElevatedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: SColors.lightSurface,
      selectedItemColor: SColors.primary,
      unselectedItemColor: SColors.lightMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: SColors.lightSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SColors.darkCard,
      contentTextStyle: const TextStyle(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: SColors.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return SColors.primary;
        return SColors.lightMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return SColors.primaryMuted;
        return SColors.lightBorder;
      }),
    ),
  );

  // ──────────────── DARK THEME ────────────────
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    fontFamily: 'Poppins',
    brightness: Brightness.dark,
    primaryColor: SColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: SColors.primary,
      primaryContainer: SColors.blue900,
      secondary: SColors.blue400,
      surface: SColors.darkSurface,
      error: SColors.error,
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onSurface: SColors.textDark,
      onError: Colors.white,
      outline: SColors.darkBorder,
    ),
    scaffoldBackgroundColor: SColors.darkBg,
    cardColor: SColors.darkCard,
    dividerColor: SColors.darkBorder,
    hoverColor: SColors.darkHover,
    textTheme: TTextTheme.darkTextTheme,
    chipTheme: TChipTheme.darkChipTheme,
    appBarTheme: TAppBarTheme.darkAppBarTheme,
    checkboxTheme: TCheckBoxTheme.darkCheckBoxTheme,
    bottomSheetTheme: TBottomSheetTheme.darkBottomSheetTheme,
    outlinedButtonTheme: TOutlineButtonTheme.darkOutlinedButtonTheme,
    elevatedButtonTheme: TElevatedButtonTheme.darkElevatedButtonTheme,
    inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: SColors.darkSurface,
      selectedItemColor: SColors.primary,
      unselectedItemColor: SColors.darkMuted,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SColors.primary,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: CircleBorder(),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: SColors.darkCard,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: SColors.darkElevated,
      contentTextStyle: const TextStyle(color: SColors.textDark),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      behavior: SnackBarBehavior.floating,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: SColors.primary,
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return SColors.primary;
        return SColors.darkMuted;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return SColors.blue900;
        return SColors.darkBorder;
      }),
    ),
  );
}
