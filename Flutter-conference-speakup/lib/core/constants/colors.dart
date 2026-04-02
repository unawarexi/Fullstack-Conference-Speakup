import 'package:flutter/material.dart';

/// SpeakUp brand color palette.
/// Dark mode: shades of black + blue accents.
/// Light mode: soft whites + sharp blue variants.
class SColors {
  SColors._();

  // ──────────────── PRIMARY BLUE ────────────────
  static const Color primary = Color(0xFF1A6BF5);
  static const Color primaryLight = Color(0xFF4D8FF7);
  static const Color primaryDark = Color(0xFF0D4FCC);
  static const Color primarySurface = Color(0xFFE8F0FE);
  static const Color primaryMuted = Color(0xFFB3D1FC);

  // ──────────────── BLUE VARIANTS (Sharp) ────────────────
  static const Color blue50 = Color(0xFFE8F0FE);
  static const Color blue100 = Color(0xFFBDD5FC);
  static const Color blue200 = Color(0xFF8FB8FA);
  static const Color blue300 = Color(0xFF619BF8);
  static const Color blue400 = Color(0xFF3E84F6);
  static const Color blue500 = Color(0xFF1A6BF5);
  static const Color blue600 = Color(0xFF1560DC);
  static const Color blue700 = Color(0xFF1052BE);
  static const Color blue800 = Color(0xFF0B44A0);
  static const Color blue900 = Color(0xFF063072);

  // ──────────────── DARK MODE BLACKS ────────────────
  static const Color darkBg = Color(0xFF0A0A0F);
  static const Color darkSurface = Color(0xFF12121A);
  static const Color darkCard = Color(0xFF1A1A25);
  static const Color darkElevated = Color(0xFF222233);
  static const Color darkBorder = Color(0xFF2A2A3D);
  static const Color darkHover = Color(0xFF32324A);
  static const Color darkMuted = Color(0xFF8888A0);

  // ──────────────── LIGHT MODE WHITES ────────────────
  static const Color lightBg = Color(0xFFF8F9FC);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightElevated = Color(0xFFF2F4F8);
  static const Color lightBorder = Color(0xFFE2E5EB);
  static const Color lightHover = Color(0xFFEDF0F5);
  static const Color lightMuted = Color(0xFF6B7280);

  // ──────────────── TEXT COLORS ────────────────
  static const Color textDark = Color(0xFFF0F0F5);
  static const Color textDarkSecondary = Color(0xFFA0A0B8);
  static const Color textDarkTertiary = Color(0xFF6B6B85);

  static const Color textLight = Color(0xFF0F1729);
  static const Color textLightSecondary = Color(0xFF4B5563);
  static const Color textLightTertiary = Color(0xFF9CA3AF);

  // ──────────────── SEMANTIC COLORS ────────────────
  static const Color success = Color(0xFF10B981);
  static const Color successLight = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF064E3B);

  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color warningDark = Color(0xFF78350F);

  static const Color error = Color(0xFFEF4444);
  static const Color errorLight = Color(0xFFFEE2E2);
  static const Color errorDark = Color(0xFF7F1D1D);

  static const Color info = Color(0xFF3B82F6);
  static const Color infoLight = Color(0xFFDBEAFE);
  static const Color infoDark = Color(0xFF1E3A5F);

  // ──────────────── MEETING SPECIFIC ────────────────
  static const Color micOn = Color(0xFF10B981);
  static const Color micOff = Color(0xFFEF4444);
  static const Color cameraOn = Color(0xFF10B981);
  static const Color cameraOff = Color(0xFFEF4444);
  static const Color screenShare = Color(0xFF8B5CF6);
  static const Color handRaised = Color(0xFFF59E0B);
  static const Color callEnd = Color(0xFFDC2626);
  static const Color callEndHover = Color(0xFFB91C1C);
  static const Color participantTile = Color(0xFF1E1E2E);
  static const Color participantTileLight = Color(0xFFF1F3F5);

  // ──────────────── CHAT ────────────────
  static const Color chatBubbleSent = Color(0xFF1A6BF5);
  static const Color chatBubbleReceived = Color(0xFF222233);
  static const Color chatBubbleReceivedLight = Color(0xFFF2F4F8);

  // ──────────────── GRADIENTS ────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1A6BF5), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF0A0A0F), Color(0xFF12121A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF1A6BF5), Color(0xFF8B5CF6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
