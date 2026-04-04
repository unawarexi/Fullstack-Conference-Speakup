import 'package:flutter/material.dart';
import 'package:flutter_conference_speakup/core/constants/colors.dart';

class TBottomSheetTheme {
  TBottomSheetTheme._();

  static const BottomSheetThemeData lightBottomSheetTheme =
      BottomSheetThemeData(
    backgroundColor: SColors.lightSurface,
    modalBackgroundColor: SColors.lightSurface,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    constraints: BoxConstraints(minWidth: double.infinity),
    showDragHandle: true,
    dragHandleColor: SColors.lightMuted,
  );

  static const BottomSheetThemeData darkBottomSheetTheme = BottomSheetThemeData(
    backgroundColor: SColors.darkSurface,
    modalBackgroundColor: SColors.darkSurface,
    shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
    constraints: BoxConstraints(minWidth: double.infinity),
    showDragHandle: true,
    dragHandleColor: SColors.darkMuted,
  );
}
