import 'package:flutter/widgets.dart';

/// Shared dimensions for the floating bottom navigation.
abstract final class FloatingBottomNavMetrics {
  /// Space above the floating navigation container.
  static const double outerTopPadding = 8;

  /// Space below the floating navigation container.
  static const double outerBottomPadding = 12;

  /// Padding inside the floating navigation container.
  static const double innerPadding = 6;

  /// Height of each navigation destination.
  static const double itemHeight = 56;

  /// Visible height of the navigation container, excluding outer padding.
  static const double visualHeight = itemHeight + innerPadding * 2;

  /// Bottom space needed for content to clear the floating navigation.
  static double clearance(BuildContext context) {
    return MediaQuery.viewPaddingOf(context).bottom +
        outerTopPadding +
        visualHeight +
        outerBottomPadding;
  }
}
