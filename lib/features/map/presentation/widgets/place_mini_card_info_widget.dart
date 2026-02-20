import 'package:flutter/material.dart';
import 'package:loomah/features/map/domain/models/place_mini_card_info.dart';
import 'package:loomah/theme/loomah_theme.dart';

/// A widget that displays a mini card with information about a place.
class PlaceMiniCardInfoWidget extends StatelessWidget {
  /// Constructor for [PlaceMiniCardInfoWidget].
  const PlaceMiniCardInfoWidget({
    required this.info,
    required this.onClose,
    required this.onSeeDetails,
    super.key,
  });

  /// The information to display in the mini card.
  final PlaceMiniCardInfo info;

  /// Callback to close the mini card.
  final VoidCallback onClose;

  /// Callback to see the details of the place.
  final VoidCallback onSeeDetails;

  @override
  Widget build(BuildContext context) {
    final LoomahPalette palette = Theme.of(context).extension<LoomahPalette>()!;
    final TextTheme textTheme = Theme.of(context).textTheme;

    // TapRegion permet de détecter les clics en dehors de ce widget
    // pour le fermer automatiquement.
    return TapRegion(
      onTapOutside: (PointerDownEvent event) {
        onClose();
      },
      child: Container(
        width: 320, // Largeur fixe pour la carte
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: palette.background,
          borderRadius: BorderRadius.circular(24),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: palette.foreground.withOpacity(0.08),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Ligne du haut : Type (Texte) et Croix de fermeture
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: palette.pastelPeach,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    info.typeText,
                    style: textTheme.labelMedium?.copyWith(
                      color: palette.accentPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: palette.foreground.withOpacity(0.05),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.close,
                      size: 20,
                      color: palette.textLight,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Nom du lieu
            Text(
              info.placeName,
              style: textTheme.titleLarge?.copyWith(
                color: palette.textDark,
                fontWeight: FontWeight.w800,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 8),

            // Adresse du lieu
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(
                  Icons.location_on_outlined,
                  size: 16,
                  color: palette.textLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    info.address,
                    style: textTheme.bodyMedium?.copyWith(
                      color: palette.textLight,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Bouton pour voir la fiche
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSeeDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: palette.accentPrimary, // Orange du theme
                  foregroundColor: palette.background, // Texte blanc/fond
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(
                  'Voir la fiche',
                  style: textTheme.labelLarge?.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: palette.background,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
