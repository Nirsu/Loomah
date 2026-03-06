import 'package:flutter/material.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// Widget to display practical information about a place.
class PlacePracticalInfo extends StatelessWidget {
  /// Creates a new [PlacePracticalInfo].
  const PlacePracticalInfo({required this.place, super.key});

  /// The place to display practical information about.
  final PlaceDetails place;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = Theme.of(context).extension<LoomahPalette>()!;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Informations pratiques',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.textDark,
          ),
        ),
        const SizedBox(height: 16),
        if (place.address != null) ...<Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(
                Icons.location_on_outlined,
                size: 24,
                color: palette.accentPrimary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '${place.address!.street}, ${place.address!.postalCode} ${place.address!.city}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: palette.textDark,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (place.website != null) ...<Widget>[
          Row(
            children: <Widget>[
              Icon(Icons.language, size: 24, color: palette.accentPrimary),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Site web',
                  style: textTheme.bodyMedium?.copyWith(
                    decoration: TextDecoration.underline,
                    color: palette.textDark,
                  ),
                ),
              ),
              Icon(Icons.chevron_right, size: 20, color: palette.accentPrimary),
            ],
          ),
          const SizedBox(height: 12),
        ],
        if (place.phone != null) ...<Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.phone_outlined,
                size: 24,
                color: palette.accentPrimary,
              ),
              const SizedBox(width: 12),
              Text(
                place.phone!,
                style: textTheme.bodyMedium?.copyWith(color: palette.textDark),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
