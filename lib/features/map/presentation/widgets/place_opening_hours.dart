import 'package:flutter/material.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// Widget to display opening hours for a place.
class PlaceOpeningHours extends StatelessWidget {
  /// Creates a new [PlaceOpeningHours].
  const PlaceOpeningHours({required this.openingHours, super.key});

  /// The opening hours of the place.
  final OpeningHours? openingHours;

  @override
  Widget build(BuildContext context) {
    if (openingHours == null) return const SizedBox.shrink();

    final LoomahPalette palette = Theme.of(context).extension<LoomahPalette>()!;
    final TextTheme textTheme = Theme.of(context).textTheme;
    final OpeningHours hours = openingHours!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Horaires',
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.textDark,
          ),
        ),
        const SizedBox(height: 16),
        _DayRow(
          day: 'Lundi',
          periods: hours.monday,
          palette: palette,
          textTheme: textTheme,
        ),
        const SizedBox(height: 8),
        _DayRow(
          day: 'Mardi',
          periods: hours.tuesday,
          palette: palette,
          textTheme: textTheme,
        ),
        const SizedBox(height: 8),
        _DayRow(
          day: 'Mercredi',
          periods: hours.wednesday,
          palette: palette,
          textTheme: textTheme,
        ),
        const SizedBox(height: 8),
        _DayRow(
          day: 'Jeudi',
          periods: hours.thursday,
          palette: palette,
          textTheme: textTheme,
        ),
        const SizedBox(height: 8),
        _DayRow(
          day: 'Vendredi',
          periods: hours.friday,
          palette: palette,
          textTheme: textTheme,
        ),
        const SizedBox(height: 8),
        _DayRow(
          day: 'Samedi',
          periods: hours.saturday,
          palette: palette,
          textTheme: textTheme,
        ),
        const SizedBox(height: 8),
        _DayRow(
          day: 'Dimanche',
          periods: hours.sunday,
          palette: palette,
          textTheme: textTheme,
        ),
      ],
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.periods,
    required this.palette,
    required this.textTheme,
  });

  final String day;
  final List<OpeningPeriod> periods;
  final LoomahPalette palette;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final String timeText = periods.isEmpty
        ? 'FERMÉ'
        : periods.map((OpeningPeriod p) => '${p.open} - ${p.close}').join(', ');

    return Row(
      children: <Widget>[
        SizedBox(
          width: 100,
          child: Text(
            day,
            style: textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: palette.textDark,
            ),
          ),
        ),
        Text(
          timeText,
          style: textTheme.bodyMedium?.copyWith(
            color: palette.textDark,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
