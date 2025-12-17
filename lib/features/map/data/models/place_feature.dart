import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loomah/features/map/data/models/place_geometry.dart';
import 'package:loomah/features/map/data/models/place_properties.dart';

part 'place_feature.freezed.dart';
part 'place_feature.g.dart';

/// Feature model representing a single place
@freezed
abstract class PlaceFeature with _$PlaceFeature {
  /// Constructor for [PlaceFeature]
  const factory PlaceFeature({
    required String type,
    required PlaceGeometry geometry,
    required PlaceProperties properties,
  }) = _PlaceFeature;

  /// Create a [PlaceFeature] from JSON
  factory PlaceFeature.fromJson(Map<String, dynamic> json) =>
      _$PlaceFeatureFromJson(json);
}
