import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';

class TAppBarTheme {
  TAppBarTheme._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: SColors.textLight, size: 24),
    actionsIconTheme: IconThemeData(color: SColors.textLight, size: 24),
    titleTextStyle: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w600, color: SColors.textLight),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark, // dark icons on light bg
      statusBarBrightness: Brightness.light, // iOS: light status bar bg
      systemNavigationBarColor: SColors.lightBg,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: false,
    scrolledUnderElevation: 0,
    backgroundColor: Colors.transparent,
    surfaceTintColor: Colors.transparent,
    iconTheme: IconThemeData(color: SColors.textDark, size: 24),
    actionsIconTheme: IconThemeData(color: SColors.textDark, size: 24),
    titleTextStyle: TextStyle(
        fontSize: 18.0, fontWeight: FontWeight.w600, color: SColors.textDark),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light, // light icons on dark bg
      statusBarBrightness: Brightness.dark, // iOS: dark status bar bg
      systemNavigationBarColor: SColors.darkBg,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
}
