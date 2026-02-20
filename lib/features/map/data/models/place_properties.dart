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
    String? description,
    PlaceAddress? address,
    String? website,
    String? phone,
  }) = _PlaceProperties;

  /// Create a [PlaceProperties] from JSON
  factory PlaceProperties.fromJson(Map<String, dynamic> json) =>
      _$PlacePropertiesFromJson(json);
}

/// Address model for a place
@freezed
abstract class PlaceAddress with _$PlaceAddress {
  /// Constructor for [PlaceAddress]
  const factory PlaceAddress({
    required String street,
    required String city,
    required String postalCode,
    required String country,
  }) = _PlaceAddress;

  /// Create a [PlaceAddress] from JSON
  factory PlaceAddress.fromJson(Map<String, dynamic> json) =>
      _$PlaceAddressFromJson(json);
}
