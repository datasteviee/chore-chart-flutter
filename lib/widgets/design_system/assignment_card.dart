import 'package:flutter/material.dart';
import 'package:mix/mix.dart';

import '../../core/theme/chore_mix_spacing.dart';
import '../../core/theme/chore_mix_tokens.dart';

enum AssignmentCardVariant {
  pending,
  done,
  overdue,
  skipped,
  conflict,
  offlineQueued,
  readOnly,
}

/// Assignment card with Mix tokens and named variants (DESIGN_RULES §14.1).
class AssignmentCard extends StatelessWidget {
  const AssignmentCard({
    super.key,
    required this.title,
    required this.points,
    required this.variant,
    this.subtitle,
    this.trailing,
  });

  final String title;
  final int points;
  final AssignmentCardVariant variant;
  final String? subtitle;
  final Widget? trailing;

  static NamedVariant _named(AssignmentCardVariant v) => Variant.named('assignment.${v.name}');

  @override
  Widget build(BuildContext context) {
    final base = BoxStyler()
        .color(ChoreMixTokens.colorSurface())
        .borderRadius(BorderRadiusGeometryMix.all(ChoreMixTokens.radiusLg()))
        .padding(EdgeInsetsGeometryMix.all(ChoreMixTokens.spaceMd()))
        .border(BoxBorderMix.all(BorderSideMix.color(ChoreMixTokens.colorOutlineVariant())))
        .variant(
          _named(AssignmentCardVariant.done),
          BoxStyler()
              .color(ChoreMixTokens.statusDoneBg())
              .border(BoxBorderMix.all(BorderSideMix.color(ChoreMixTokens.statusDoneFg()))),
        )
        .variant(
          _named(AssignmentCardVariant.overdue),
          BoxStyler()
              .color(ChoreMixTokens.statusOverdueBg())
              .border(BoxBorderMix.all(BorderSideMix.color(ChoreMixTokens.statusOverdueFg()))),
        )
        .variant(
          _named(AssignmentCardVariant.skipped),
          BoxStyler()
              .color(ChoreMixTokens.statusSkippedBg())
              .border(BoxBorderMix.all(BorderSideMix.color(ChoreMixTokens.statusSkippedFg()))),
        )
        .variant(
          _named(AssignmentCardVariant.conflict),
          BoxStyler()
              .color(ChoreMixTokens.statusWarningBg())
              .border(BoxBorderMix.all(BorderSideMix.color(ChoreMixTokens.statusWarningFg()))),
        )
        .variant(
          _named(AssignmentCardVariant.offlineQueued),
          BoxStyler()
              .color(ChoreMixTokens.statusOfflineBg())
              .border(BoxBorderMix.all(BorderSideMix.color(ChoreMixTokens.statusOfflineFg()))),
        )
        .variant(
          _named(AssignmentCardVariant.readOnly),
          BoxStyler()
              .color(ChoreMixTokens.statusPendingBg())
              .border(BoxBorderMix.all(BorderSideMix.color(ChoreMixTokens.colorOutline()))),
        );

    final style = base.applyVariants([_named(variant)]);

    return Box(
      style: style,
      child: Row(
        children: [
          Icon(Icons.cleaning_services, color: Theme.of(context).colorScheme.primary, size: 28),
          SizedBox(width: context.space(ChoreMixTokens.spaceMd)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: context.space(ChoreMixTokens.spaceXs)),
                Text(
                  subtitle != null ? '$subtitle · $points Pkt.' : '$points Pkt.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}
