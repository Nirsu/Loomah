import 'package:flutter/material.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/features/map/presentation/widgets/place_badge.dart';
import 'package:loomah/features/map/presentation/widgets/place_pricing_label.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// Widget to display badges for a place.
class PlaceBadgesWrap extends StatelessWidget {
  /// Creates a new [PlaceBadgesWrap].
  const PlaceBadgesWrap({
    required this.type,
    required this.ageRanges,
    required this.pricing,
    super.key,
  });

  /// The type of the place.
  final String type;

  /// The age ranges of the place.
  final AgeRanges? ageRanges;

  /// The pricing of the place.
  final Pricing? pricing;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = Theme.of(context).extension<LoomahPalette>()!;
    final String? pricingLabel = placePricingLabel(pricing);
    final List<Widget> children = <Widget>[
      PlaceBadge(
        text: type,
        bgColor: palette.pastelPeach,
        textColor: palette.accentPrimary,
      ),
    ];

    if (ageRanges != null) {
      final AgeRanges ranges = ageRanges!;
      final bool allTrue =
          ranges.babies && ranges.toddlers && ranges.kids && ranges.olderKids;

      if (allTrue) {
        children.add(
          PlaceBadge(
            text: 'Tous âges',
            bgColor: palette.pastelMint,
            textColor: palette.accentGreen,
          ),
        );
      } else {
        if (ranges.babies) {
          children.add(
            PlaceBadge(
              text: 'Bébé (0-1)',
              bgColor: palette.pastelMint,
              textColor: palette.accentGreen,
            ),
          );
        }
        if (ranges.toddlers) {
          children.add(
            PlaceBadge(
              text: '0-3 ans',
              bgColor: palette.pastelMint,
              textColor: palette.accentGreen,
            ),
          );
        }
        if (ranges.kids) {
          children.add(
            PlaceBadge(
              text: '3-6 ans',
              bgColor: palette.pastelMint,
              textColor: palette.accentGreen,
            ),
          );
        }
        if (ranges.olderKids) {
          children.add(
            PlaceBadge(
              text: '6+ ans',
              bgColor: palette.pastelMint,
              textColor: palette.accentGreen,
            ),
          );
        }
      }
    }

    if (pricingLabel != null) {
      children.add(
        PlaceBadge(
          text: pricingLabel,
          bgColor: palette.pastelPrice,
          textColor: palette.accentPrice,
        ),
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: children);
  }
}
