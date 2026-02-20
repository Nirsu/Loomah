import 'package:flutter/material.dart';
import 'package:loomah/features/map/domain/models/place_mini_card_info.dart';

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
    // TapRegion permet de détecter les clics en dehors de ce widget
    // pour le fermer automatiquement.
    return TapRegion(
      onTapOutside: (PointerDownEvent event) {
        onClose();
      },
      child: Container(
        width: 320, // Largeur fixe pour la carte
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black87, width: 2.5),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: Colors.black12,
              blurRadius: 10,
              offset: Offset(0, 4),
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
                Text(
                  info.typeText,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
                GestureDetector(
                  onTap: onClose,
                  child: const Icon(
                    Icons.close,
                    size: 24,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nom du lieu
            Text(
              info.placeName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),

            // Adresse du lieu
            Text(
              info.address,
              style: const TextStyle(fontSize: 14, color: Colors.black54),
            ),
            const SizedBox(height: 20),

            // Bouton pour voir la fiche
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onSeeDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(
                    0xFFEAEAEA,
                  ), // Gris clair comme sur l'image
                  foregroundColor: Colors.black87,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: Colors.black87, width: 2),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  'Bouton pour voir fiche lieu',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
