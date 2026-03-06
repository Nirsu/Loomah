import 'package:flutter/material.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// Widget to display pricing information about a place.
class PlacePricingInfo extends StatelessWidget {
  /// Creates a new [PlacePricingInfo].
  const PlacePricingInfo({required this.pricing, super.key});

  /// The pricing information of the place.
  final Pricing pricing;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = Theme.of(context).extension<LoomahPalette>()!;
    final TextTheme textTheme = Theme.of(context).textTheme;

    String? symbolText;
    String labelText = 'Inconnu';

    if (pricing.kind == PricingKind.free) {
      labelText = 'Gratuit';
    } else if (pricing.kind == PricingKind.paid ||
        pricing.kind == PricingKind.mixed) {
      if (pricing.tier != null && pricing.tier! >= 1 && pricing.tier! <= 4) {
        symbolText = '€' * pricing.tier!;
        switch (pricing.tier) {
          case 1:
            labelText = 'Abordable';
            break;
          case 2:
            labelText = 'Prix moyen';
            break;
          case 3:
            labelText = 'Cher';
            break;
          case 4:
            labelText = 'Très cher';
            break;
        }
      } else {
        labelText = 'Payant';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Tarifs',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: <Widget>[
            if (symbolText != null) ...<Widget>[
              Text(
                symbolText,
                style: textTheme.bodyMedium?.copyWith(color: palette.textDark),
              ),
              const SizedBox(width: 8),
            ],
            Text(
              labelText,
              style: textTheme.bodyMedium?.copyWith(color: palette.textDark),
            ),
          ],
        ),
      ],
    );
  }
}
