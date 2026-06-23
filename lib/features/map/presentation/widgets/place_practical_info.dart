import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/features/map/presentation/widgets/place_launchers.dart';
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
          'Infos pratiques',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w900,
            color: palette.textDark,
          ),
        ),
        const SizedBox(height: 12),
        if (place.address != null) ...<Widget>[
          _InfoRow(
            icon: Icons.location_on_outlined,
            label:
                '${place.address!.street}, ${place.address!.postalCode} ${place.address!.city}',
          ),
          const SizedBox(height: 8),
        ],
        if (place.website != null) ...<Widget>[
          _InfoRow(
            icon: Icons.language_rounded,
            label: 'Site web',
            onTap: () => unawaited(openPlaceUrl(place.website!)),
            showChevron: true,
          ),
          const SizedBox(height: 8),
        ],
        if (place.phone != null) ...<Widget>[
          _InfoRow(
            icon: Icons.phone_outlined,
            label: place.phone!,
            onTap: () => unawaited(callPlacePhone(place.phone!)),
            showChevron: true,
          ),
        ],
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    this.onTap,
    this.showChevron = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool showChevron;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 20, color: palette.accentSecondary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: textTheme.bodyMedium?.copyWith(
                  color: palette.textDark,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                ),
              ),
            ),
            if (showChevron)
              Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: palette.accentSecondary,
              ),
          ],
        ),
      ),
    );
  }
}
