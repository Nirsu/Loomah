import 'package:flutter/material.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/i18n/strings.g.dart';
import 'package:loomah/theme/loomah_theme.dart';

typedef _OpeningDay = ({
  String label,
  List<OpeningPeriod>? periods,
  int weekday,
});

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
    final Translations$map$fr map = Translations.of(context).map;
    final OpeningHours hours = openingHours!;
    final int today = DateTime.now().weekday;
    final List<_OpeningDay> days = <_OpeningDay>[
      (
        label: map.opening.days.monday,
        periods: hours.monday,
        weekday: DateTime.monday,
      ),
      (
        label: map.opening.days.tuesday,
        periods: hours.tuesday,
        weekday: DateTime.tuesday,
      ),
      (
        label: map.opening.days.wednesday,
        periods: hours.wednesday,
        weekday: DateTime.wednesday,
      ),
      (
        label: map.opening.days.thursday,
        periods: hours.thursday,
        weekday: DateTime.thursday,
      ),
      (
        label: map.opening.days.friday,
        periods: hours.friday,
        weekday: DateTime.friday,
      ),
      (
        label: map.opening.days.saturday,
        periods: hours.saturday,
        weekday: DateTime.saturday,
      ),
      (
        label: map.opening.days.sunday,
        periods: hours.sunday,
        weekday: DateTime.sunday,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          map.opening.title,
          style: textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: palette.textDark,
          ),
        ),
        const SizedBox(height: 16),
        for (final _OpeningDay day in days) ...<Widget>[
          _DayRow(
            day: day.label,
            periods: day.periods,
            palette: palette,
            textTheme: textTheme,
            isToday: today == day.weekday,
            todayLabel: map.opening.today,
            closedLabel: map.opening.closed,
          ),
          if (day.weekday != DateTime.sunday) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Summary of today's opening hours.
String? todayOpeningHoursLabel(
  BuildContext context,
  OpeningHours? openingHours,
) {
  if (openingHours == null) return null;

  final Translations$map$fr map = Translations.of(context).map;
  final List<OpeningPeriod> periods =
      _periodsForWeekday(openingHours, DateTime.now().weekday) ??
      const <OpeningPeriod>[];
  if (periods.isEmpty) return map.opening.closedToday;

  return map.opening.openToday(hours: _formatPeriods(periods));
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.periods,
    required this.palette,
    required this.textTheme,
    required this.isToday,
    required this.todayLabel,
    required this.closedLabel,
  });

  final String day;
  final List<OpeningPeriod>? periods;
  final LoomahPalette palette;
  final TextTheme textTheme;
  final bool isToday;
  final String todayLabel;
  final String closedLabel;

  @override
  Widget build(BuildContext context) {
    final List<OpeningPeriod> dayPeriods = periods ?? const <OpeningPeriod>[];
    final String timeText = dayPeriods.isEmpty
        ? closedLabel
        : _formatPeriods(dayPeriods);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: isToday ? palette.accentLight : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: 96,
              child: Text(
                isToday ? todayLabel : day,
                style: textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isToday ? palette.accentSecondary : palette.textDark,
                ),
              ),
            ),
            Expanded(
              child: Text(
                timeText,
                style: textTheme.bodyMedium?.copyWith(
                  color: palette.textDark,
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

List<OpeningPeriod>? _periodsForWeekday(OpeningHours hours, int weekday) {
  return switch (weekday) {
    DateTime.monday => hours.monday,
    DateTime.tuesday => hours.tuesday,
    DateTime.wednesday => hours.wednesday,
    DateTime.thursday => hours.thursday,
    DateTime.friday => hours.friday,
    DateTime.saturday => hours.saturday,
    DateTime.sunday => hours.sunday,
    _ => null,
  };
}

String _formatPeriods(List<OpeningPeriod> periods) {
  return periods
      .map((OpeningPeriod period) => '${period.open} - ${period.close}')
      .join(', ');
}
