import 'dart:async';

import 'package:flutter/material.dart';
import 'package:loomah/features/map/data/models/place_details.dart';
import 'package:loomah/features/map/presentation/widgets/place_launchers.dart';
import 'package:loomah/i18n/strings.g.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// Bottom actions for a place details page.
class PlaceActionsBar extends StatelessWidget {
  /// Creates a [PlaceActionsBar].
  const PlaceActionsBar({required this.place, super.key});

  /// Place used by action buttons.
  final PlaceDetails place;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;
    final Translations$map$fr map = Translations.of(context).map;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: palette.background.withValues(alpha: .96),
        border: Border(
          top: BorderSide(color: palette.textDark.withValues(alpha: .08)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: <Widget>[
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => unawaited(openPlaceInMaps(place)),
                  icon: const Icon(Icons.map_outlined),
                  label: Text(map.actions.openMaps),
                  style: FilledButton.styleFrom(
                    backgroundColor: palette.accentPrimary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              if (place.website != null) ...<Widget>[
                const SizedBox(width: 10),
                _ActionIconButton(
                  icon: Icons.language_rounded,
                  tooltip: map.actions.website,
                  onPressed: () => unawaited(openPlaceUrl(place.website!)),
                ),
              ],
              if (place.phone != null) ...<Widget>[
                const SizedBox(width: 10),
                _ActionIconButton(
                  icon: Icons.phone_rounded,
                  tooltip: map.actions.call,
                  onPressed: () => unawaited(callPlacePhone(place.phone!)),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ActionIconButton extends StatelessWidget {
  const _ActionIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = context.loomahPalette;

    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      color: palette.accentSecondary,
      style: IconButton.styleFrom(
        backgroundColor: palette.accentLight,
        minimumSize: const Size.square(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
