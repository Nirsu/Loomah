import 'package:flutter/material.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/features/map/presentation/widgets/place_opening_hours.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// Compact summary shown below the place title.
class PlaceQuickFacts extends StatelessWidget {
  /// Creates a [PlaceQuickFacts].
  const PlaceQuickFacts({required this.place, super.key});

  /// Place to summarize.
  final PlaceDetails place;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final List<String> facts = <String>[
      _areaLabel(place),
      if (todayOpeningHoursLabel(place.openingHours) case final String hours)
        hours,
    ].where((String fact) => fact.isNotEmpty).toList();

    return Text(
      facts.join(' · '),
      style: textTheme.bodyMedium?.copyWith(
        color: palette.textLight,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

String _areaLabel(PlaceDetails place) {
  final Address? address = place.address;
  if (address == null) return '';

  if (address.city.toLowerCase() == 'paris' &&
      address.postalCode.length == 5 &&
      address.postalCode.startsWith('75')) {
    final int? district = int.tryParse(address.postalCode.substring(3));
    if (district != null) return 'Paris ${district}e';
  }

  return address.city;
}
