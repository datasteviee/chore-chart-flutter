import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mix/mix.dart';

import 'chore_mix_tokens.dart';

/// Token value maps for [MixScope] (DESIGN_RULES §3.2, §§5–7, 9–11).
///
/// Maps are [static final] so [MixScope] does not see new map instances every
/// build (avoids unnecessary inherited notifications / subtree churn).
abstract final class ChoreMixTheme {
  static final Map<ColorToken, Color> lightColors = {
        ChoreMixTokens.colorPrimary: const Color(0xFF2E9D76),
        ChoreMixTokens.colorOnPrimary: Colors.white,
        ChoreMixTokens.colorPrimaryContainer: const Color(0xFFDDF6EA),
        ChoreMixTokens.colorOnPrimaryContainer: const Color(0xFF123A2D),
        ChoreMixTokens.colorSecondary: const Color(0xFFF3B63F),
        ChoreMixTokens.colorOnSecondary: const Color(0xFF3F2F0B),
        ChoreMixTokens.colorSecondaryContainer: const Color(0xFFFFF1C7),
        ChoreMixTokens.colorOnSecondaryContainer: const Color(0xFF3F2F0B),
        ChoreMixTokens.colorTertiary: const Color(0xFF4F8FD8),
        ChoreMixTokens.colorOnTertiary: Colors.white,
        ChoreMixTokens.colorBackground: const Color(0xFFFFFDF7),
        ChoreMixTokens.colorOnBackground: const Color(0xFF25312C),
        ChoreMixTokens.colorSurface: Colors.white,
        ChoreMixTokens.colorOnSurface: const Color(0xFF25312C),
        ChoreMixTokens.colorSurfaceVariant: const Color(0xFFF4EFE7),
        ChoreMixTokens.colorOnSurfaceVariant: const Color(0xFF65736E),
        ChoreMixTokens.colorOutline: const Color(0xFFC8D2CC),
        ChoreMixTokens.colorOutlineVariant: const Color(0xFFE1E8E3),
        ChoreMixTokens.colorError: const Color(0xFFD9534F),
        ChoreMixTokens.colorOnError: Colors.white,
        ChoreMixTokens.statusDoneBg: const Color(0xFFDDF6EA),
        ChoreMixTokens.statusDoneFg: const Color(0xFF2E9D76),
        ChoreMixTokens.statusPendingBg: const Color(0xFFF4EFE7),
        ChoreMixTokens.statusPendingFg: const Color(0xFF65736E),
        ChoreMixTokens.statusOverdueBg: const Color(0xFFFFE1E7),
        ChoreMixTokens.statusOverdueFg: const Color(0xFFE85D75),
        ChoreMixTokens.statusSkippedBg: const Color(0xFFEDEDED),
        ChoreMixTokens.statusSkippedFg: const Color(0xFF6F7471),
        ChoreMixTokens.statusWarningBg: const Color(0xFFFFF1C7),
        ChoreMixTokens.statusWarningFg: const Color(0xFF9A6A11),
        ChoreMixTokens.statusOfflineBg: const Color(0xFFE4F0F6),
        ChoreMixTokens.statusOfflineFg: const Color(0xFF4F7F99),
        ChoreMixTokens.statusPremiumBg: const Color(0xFFFFE7A3),
        ChoreMixTokens.statusPremiumFg: const Color(0xFF75520D),
      };

  static final Map<ColorToken, Color> darkColors = {
        ChoreMixTokens.colorPrimary: const Color(0xFF77D7B0),
        ChoreMixTokens.colorOnPrimary: const Color(0xFF0D3024),
        ChoreMixTokens.colorPrimaryContainer: const Color(0xFF174D3B),
        ChoreMixTokens.colorOnPrimaryContainer: const Color(0xFFDDF6EA),
        ChoreMixTokens.colorSecondary: const Color(0xFFF5C96B),
        ChoreMixTokens.colorOnSecondary: const Color(0xFF3F2F0B),
        ChoreMixTokens.colorSecondaryContainer: const Color(0xFF5A4218),
        ChoreMixTokens.colorOnSecondaryContainer: const Color(0xFFFFF1C7),
        ChoreMixTokens.colorTertiary: const Color(0xFF8BBDF2),
        ChoreMixTokens.colorOnTertiary: const Color(0xFF10253D),
        ChoreMixTokens.colorBackground: const Color(0xFF101815),
        ChoreMixTokens.colorOnBackground: const Color(0xFFF3F8F4),
        ChoreMixTokens.colorSurface: const Color(0xFF18221E),
        ChoreMixTokens.colorOnSurface: const Color(0xFFF3F8F4),
        ChoreMixTokens.colorSurfaceVariant: const Color(0xFF24322D),
        ChoreMixTokens.colorOnSurfaceVariant: const Color(0xFFB9C8C0),
        ChoreMixTokens.colorOutline: const Color(0xFF43524B),
        ChoreMixTokens.colorOutlineVariant: const Color(0xFF2E3B36),
        ChoreMixTokens.colorError: const Color(0xFFFF8A8A),
        ChoreMixTokens.colorOnError: const Color(0xFF3D1111),
        ChoreMixTokens.statusDoneBg: const Color(0xFF174D3B),
        ChoreMixTokens.statusDoneFg: const Color(0xFF77D7B0),
        ChoreMixTokens.statusPendingBg: const Color(0xFF24322D),
        ChoreMixTokens.statusPendingFg: const Color(0xFFB9C8C0),
        ChoreMixTokens.statusOverdueBg: const Color(0xFF5A1E2B),
        ChoreMixTokens.statusOverdueFg: const Color(0xFFFF8FA3),
        ChoreMixTokens.statusSkippedBg: const Color(0xFF303634),
        ChoreMixTokens.statusSkippedFg: const Color(0xFFB9C0BC),
        ChoreMixTokens.statusWarningBg: const Color(0xFF5A4218),
        ChoreMixTokens.statusWarningFg: const Color(0xFFF5C96B),
        ChoreMixTokens.statusOfflineBg: const Color(0xFF203744),
        ChoreMixTokens.statusOfflineFg: const Color(0xFF9DB8C8),
        ChoreMixTokens.statusPremiumBg: const Color(0xFF6A4C12),
        ChoreMixTokens.statusPremiumFg: const Color(0xFFFFE7A3),
      };

  static final Map<SpaceToken, double> spaces = {
        ChoreMixTokens.spaceXxs: 2,
        ChoreMixTokens.spaceXs: 4,
        ChoreMixTokens.spaceSm: 8,
        ChoreMixTokens.spaceMd: 16,
        ChoreMixTokens.spaceLg: 24,
        ChoreMixTokens.spaceXl: 32,
        ChoreMixTokens.spaceXxl: 48,
      };

  static final Map<RadiusToken, Radius> radii = {
        ChoreMixTokens.radiusXs: const Radius.circular(6),
        ChoreMixTokens.radiusSm: const Radius.circular(10),
        ChoreMixTokens.radiusMd: const Radius.circular(16),
        ChoreMixTokens.radiusLg: const Radius.circular(24),
        ChoreMixTokens.radiusXl: const Radius.circular(32),
        ChoreMixTokens.radiusFull: const Radius.circular(999),
      };

  static TextStyle _nunito({
    required double size,
    required FontWeight weight,
    required double height,
  }) {
    return GoogleFonts.nunitoSans(
      fontSize: size,
      fontWeight: weight,
      height: height,
    );
  }

  static final Map<TextStyleToken, TextStyle> lightTextStyles = {
    ChoreMixTokens.textDisplay: _nunito(size: 32, weight: FontWeight.w800, height: 1.1),
    ChoreMixTokens.textHeadline: _nunito(size: 28, weight: FontWeight.w800, height: 1.15),
    ChoreMixTokens.textTitleLg: _nunito(size: 24, weight: FontWeight.w800, height: 1.2),
    ChoreMixTokens.textTitleMd: _nunito(size: 18, weight: FontWeight.w700, height: 1.25),
    ChoreMixTokens.textTitleSm: _nunito(size: 16, weight: FontWeight.w700, height: 1.3),
    ChoreMixTokens.textBodyLg: _nunito(size: 16, weight: FontWeight.w500, height: 1.45),
    ChoreMixTokens.textBodyMd: _nunito(size: 14, weight: FontWeight.w500, height: 1.4),
    ChoreMixTokens.textLabelLg: _nunito(size: 14, weight: FontWeight.w800, height: 1.2),
    ChoreMixTokens.textLabelMd: _nunito(size: 12, weight: FontWeight.w700, height: 1.2),
    ChoreMixTokens.textChildAction: _nunito(size: 20, weight: FontWeight.w800, height: 1.2),
  };

  static final Map<TextStyleToken, TextStyle> darkTextStyles = lightTextStyles;
}
