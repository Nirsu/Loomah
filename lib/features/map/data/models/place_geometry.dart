import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_geometry.freezed.dart';
part 'place_geometry.g.dart';

/// Geometry model for a place point
@freezed
abstract class PlaceGeometry with _$PlaceGeometry {
  /// Constructor for [PlaceGeometry]
  const factory PlaceGeometry({
    required String type,
    required List<double> coordinates,
  }) = _PlaceGeometry;

  /// Create a [PlaceGeometry] from JSON
  factory PlaceGeometry.fromJson(Map<String, dynamic> json) =>
      _$PlaceGeometryFromJson(json);

  const PlaceGeometry._();

  /// Getters for longitude
  double get longitude => coordinates[0];

  /// Getters for latitude
  double get latitude => coordinates[1];
}
