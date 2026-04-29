import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mix/mix.dart';

import 'core/router.dart';
import 'core/theme/chore_material_theme.dart';
import 'core/theme/chore_mix_theme.dart';

/// Root app: [MixScope] sits **above** [MaterialApp.router], not inside
/// `MaterialApp.builder`, so the navigator subtree is not reparented under an
/// [InheritedModel] on every Material rebuild (avoids framework assertion
/// `_elements.contains(element)` with GoRouter redirects).
class ChoreApp extends ConsumerStatefulWidget {
  const ChoreApp({super.key});

  @override
  ConsumerState<ChoreApp> createState() => _ChoreAppState();
}

class _ChoreAppState extends ConsumerState<ChoreApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(goRouterProvider);
    final isDark =
        WidgetsBinding.instance.platformDispatcher.platformBrightness ==
            Brightness.dark;

    return MixScope(
      colors: isDark ? ChoreMixTheme.darkColors : ChoreMixTheme.lightColors,
      spaces: ChoreMixTheme.spaces,
      radii: ChoreMixTheme.radii,
      textStyles: isDark ? ChoreMixTheme.darkTextStyles : ChoreMixTheme.lightTextStyles,
      child: MaterialApp.router(
        title: 'Chore Chart',
        theme: ChoreMaterialTheme.light,
        darkTheme: ChoreMaterialTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: router,
      ),
    );
  }
}
