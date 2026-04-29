import 'package:mix/mix.dart';

/// Design tokens for Chore Chart (see DESIGN_RULES.md).
abstract final class ChoreMixTokens {
  static const colorPrimary = ColorToken('color.primary');
  static const colorOnPrimary = ColorToken('color.onPrimary');
  static const colorPrimaryContainer = ColorToken('color.primaryContainer');
  static const colorOnPrimaryContainer = ColorToken('color.onPrimaryContainer');
  static const colorSecondary = ColorToken('color.secondary');
  static const colorOnSecondary = ColorToken('color.onSecondary');
  static const colorSecondaryContainer = ColorToken('color.secondaryContainer');
  static const colorOnSecondaryContainer = ColorToken('color.onSecondaryContainer');
  static const colorTertiary = ColorToken('color.tertiary');
  static const colorOnTertiary = ColorToken('color.onTertiary');
  static const colorBackground = ColorToken('color.background');
  static const colorOnBackground = ColorToken('color.onBackground');
  static const colorSurface = ColorToken('color.surface');
  static const colorOnSurface = ColorToken('color.onSurface');
  static const colorSurfaceVariant = ColorToken('color.surfaceVariant');
  static const colorOnSurfaceVariant = ColorToken('color.onSurfaceVariant');
  static const colorOutline = ColorToken('color.outline');
  static const colorOutlineVariant = ColorToken('color.outlineVariant');
  static const colorError = ColorToken('color.error');
  static const colorOnError = ColorToken('color.onError');

  static const statusDoneBg = ColorToken('status.done.bg');
  static const statusDoneFg = ColorToken('status.done.fg');
  static const statusPendingBg = ColorToken('status.pending.bg');
  static const statusPendingFg = ColorToken('status.pending.fg');
  static const statusOverdueBg = ColorToken('status.overdue.bg');
  static const statusOverdueFg = ColorToken('status.overdue.fg');
  static const statusSkippedBg = ColorToken('status.skipped.bg');
  static const statusSkippedFg = ColorToken('status.skipped.fg');
  static const statusWarningBg = ColorToken('status.warning.bg');
  static const statusWarningFg = ColorToken('status.warning.fg');
  static const statusOfflineBg = ColorToken('status.offline.bg');
  static const statusOfflineFg = ColorToken('status.offline.fg');
  static const statusPremiumBg = ColorToken('status.premium.bg');
  static const statusPremiumFg = ColorToken('status.premium.fg');

  static const spaceXxs = SpaceToken('space.xxs');
  static const spaceXs = SpaceToken('space.xs');
  static const spaceSm = SpaceToken('space.sm');
  static const spaceMd = SpaceToken('space.md');
  static const spaceLg = SpaceToken('space.lg');
  static const spaceXl = SpaceToken('space.xl');
  static const spaceXxl = SpaceToken('space.xxl');

  static const radiusXs = RadiusToken('radius.xs');
  static const radiusSm = RadiusToken('radius.sm');
  static const radiusMd = RadiusToken('radius.md');
  static const radiusLg = RadiusToken('radius.lg');
  static const radiusXl = RadiusToken('radius.xl');
  static const radiusFull = RadiusToken('radius.full');

  static const textDisplay = TextStyleToken('text.display');
  static const textHeadline = TextStyleToken('text.headline');
  static const textTitleLg = TextStyleToken('text.titleLg');
  static const textTitleMd = TextStyleToken('text.titleMd');
  static const textTitleSm = TextStyleToken('text.titleSm');
  static const textBodyLg = TextStyleToken('text.bodyLg');
  static const textBodyMd = TextStyleToken('text.bodyMd');
  static const textLabelLg = TextStyleToken('text.labelLg');
  static const textLabelMd = TextStyleToken('text.labelMd');
  static const textChildAction = TextStyleToken('text.childAction');
}
