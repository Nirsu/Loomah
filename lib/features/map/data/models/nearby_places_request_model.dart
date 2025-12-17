import 'package:freezed_annotation/freezed_annotation.dart';

part 'nearby_places_request_model.freezed.dart';
part 'nearby_places_request_model.g.dart';

/// Request model for fetching nearby places
@freezed
abstract class NearbyPlacesRequestModel with _$NearbyPlacesRequestModel {
  /// Constructor for [NearbyPlacesRequestModel]
  const factory NearbyPlacesRequestModel({
    required double latitude,
    required double longitude,
    required int radius,
  }) = _NearbyPlacesRequestModel;

  /// Create a [NearbyPlacesRequestModel] from JSON
  factory NearbyPlacesRequestModel.fromJson(Map<String, dynamic> json) =>
      _$NearbyPlacesRequestModelFromJson(json);
}
