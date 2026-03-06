import 'package:flutter/material.dart';

/// Widget to display a badge for a place.
class PlaceBadge extends StatelessWidget {
  /// Creates a new [PlaceBadge].
  const PlaceBadge({
    required this.text,
    required this.bgColor,
    required this.textColor,
    super.key,
  });

  /// The text to display in the badge.
  final String text;

  /// The background color of the badge.
  final Color bgColor;

  /// The text color of the badge.
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: textColor.withValues(alpha: 0.2)),
      ),
      child: Text(
        text,
        style: textTheme.labelMedium?.copyWith(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
