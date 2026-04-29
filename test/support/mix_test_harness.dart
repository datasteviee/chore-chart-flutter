import 'package:chore_chart/core/theme/chore_material_theme.dart';
import 'package:chore_chart/core/theme/chore_mix_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mix/mix.dart';

/// [LoginScreen] und andere Mix-Widgets brauchen [MixScope] wie in [ChoreApp].
Widget pumpWithMixScope(Widget home) {
  return ProviderScope(
    child: MixScope(
      colors: ChoreMixTheme.lightColors,
      spaces: ChoreMixTheme.spaces,
      radii: ChoreMixTheme.radii,
      textStyles: ChoreMixTheme.lightTextStyles,
      child: MaterialApp(
        theme: ChoreMaterialTheme.light,
        home: home,
      ),
    ),
  );
}
