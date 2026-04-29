import 'package:flutter/widgets.dart';
import 'package:mix/mix.dart';

/// Resolves [SpaceToken] values from [MixScope] for plain Flutter layout
/// ([EdgeInsets], [SizedBox], …).
///
/// Do **not** pass `token()` / `spaceMd()` doubles into Material widgets: Mix
/// uses negative [DoubleRef] placeholders until styles are resolved.
extension ChoreMixSpacingContext on BuildContext {
  double space(SpaceToken token) => MixScope.tokenOf(token, this);
}
