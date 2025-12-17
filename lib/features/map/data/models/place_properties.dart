import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_properties.freezed.dart';
part 'place_properties.g.dart';

/// Properties model for a place feature
@freezed
abstract class PlaceProperties with _$PlaceProperties {
  /// Constructor for [PlaceProperties]
  const factory PlaceProperties({
    required String id,
    required String name,
    required String icon,
    required double distance,
  }) = _PlaceProperties;

  /// Create a [PlaceProperties] from JSON
  factory PlaceProperties.fromJson(Map<String, dynamic> json) =>
      _$PlacePropertiesFromJson(json);
}
