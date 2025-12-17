import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:loomah/features/map/data/models/place_feature.dart';

part 'place_collection.freezed.dart';
part 'place_collection.g.dart';

/// FeatureCollection model containing all nearby places
@freezed
abstract class PlaceCollection with _$PlaceCollection {
  /// Constructor for [PlaceCollection]
  const factory PlaceCollection({
    required String type,
    required List<PlaceFeature> features,
  }) = _PlaceCollection;

  /// Create a [PlaceCollection] from JSON
  factory PlaceCollection.fromJson(Map<String, dynamic> json) =>
      _$PlaceCollectionFromJson(json);
}
