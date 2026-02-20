/// A simple data class to hold the information needed for the PlaceMiniCardInfoWidget.
class PlaceMiniCardInfo {
  /// Constructor for [PlaceMiniCardInfo].
  PlaceMiniCardInfo({
    required this.typeText,
    required this.placeName,
    required this.address,
  });

  /// The type of the place (e.g., "Restaurant", "Museum").
  final String typeText;

  /// The name of the place.
  final String placeName;

  /// The address of the place.
  final String address;
}
